# How to use noise models in PennyLane

> Fuente: <https://pennylane.ai/qml/demos/tutorial_how_to_use_noise_models>

[Utkarsh Azad](https://pennylane.ai/profile/whatsis)

Published: September 30, 2024. Last updated: May 25, 2026.

Noise models are essential for understanding and describing the effects of physical errors
in a quantum computation. They allow for simulating the imperfections in state evolution
arising from environment-based [errors](https://pennylane.ai/codebook/07-error-correction/),
state preparation routines, measurements, and more.

Here, we show how to use the features provided in PennyLane’s `noise`
module to construct and manipulate noise models, enabling noisy simulation (see the [noise module documentation](https://docs.pennylane.ai/en/stable/code/qp_noise.html "(in PennyLane v0.45)") for more details). In PennyLane,
noise models are constructed from two main components:

1. Boolean conditions (referred to as *conditionals*) that dictate whether noise is inserted into the circuit.
2. Callables (called noise *functions*) that apply noise operations when a corresponding condition is satisfied.

The following figure is an example that shows how a noise model transforms a sample circuit by inserting
amplitude and phase damping errors for [`RX`](https://docs.pennylane.ai/en/stable/code/api/pennylane.RX.html#pennylane.RX "(in PennyLane v0.45)")
and [`RY`](https://docs.pennylane.ai/en/stable/code/api/pennylane.RY.html#pennylane.RY "(in PennyLane v0.45)") gates, respectively.

In the upcoming sections, we will first cover the underlying components of
noise models and learn how to use them to construct desired noise models.
Finally, we will use our noise model to perform noisy simulations.

## Conditionals

We implement conditions as Boolean functions that accept an operation and evaluate it
to return a Boolean output. In PennyLane, such objects are referred to as **conditionals**.
They are constructed as instances of [`BooleanFn`](https://docs.pennylane.ai/en/stable/code/api/pennylane.BooleanFn.html#pennylane.BooleanFn "(in PennyLane v0.45)") and can be combined
using standard bitwise operations such as `&`, `|`, `^`, or `~`. PennyLane supports
the following types of conditionals:

1. **Operation-based conditionals:** They evaluate whether a gate operation is a
   specific type of operation or belongs to a specified set of operations. They are
   built using [`op_eq()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.noise.op_eq.html#pennylane.noise.op_eq "(in PennyLane v0.45)") and [`op_in()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.noise.op_in.html#pennylane.noise.op_in "(in PennyLane v0.45)"), respectively.
2. **Wire-based conditionals:** They evaluate whether a gate operation’s wires are
   equal to or are contained in a specified set of wires. They are built using
   [`wires_eq()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.noise.wires_eq.html#pennylane.noise.wires_eq "(in PennyLane v0.45)") and [`wires_in()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.noise.wires_in.html#pennylane.noise.wires_in "(in PennyLane v0.45)"), respectively.
3. **Arbitrary conditionals:** Custom conditionals can be defined as a function wrapped
   with a [`BooleanFn`](https://docs.pennylane.ai/en/stable/code/api/pennylane.BooleanFn.html#pennylane.BooleanFn "(in PennyLane v0.45)") decorator. The signature for such conditionals
   must be `cond_fn(operation: Operation) -> bool`.

For example, here’s how we would define a conditional that checks for \(R\_X(\phi)\)
gate operations with \(|\phi| < 1.0\) and wires \(\in \{0, 1\}\):

```python
import pennylane as qp
import numpy as np

@qp.BooleanFn
def rx_cond(op):
    return isinstance(op, qp.RX) and np.abs(op.parameters[0]) < 1.0

# Combine this arbitrary conditional with a wire-based conditional
rx_and_wires_cond = rx_cond & qp.noise.wires_in([0, 1])
for op in [qp.RX(0.05, wires=[0]), qp.RX(2.34, wires=[1])]:
    print(f"Result for {op}: {rx_and_wires_cond(op)}")
```

```python
Result for RX(0.05, wires=[0]): True
Result for RX(2.34, wires=[1]): False
```

## Noise functions

Callables that apply noise operations are referred to as **noise functions** and have the
signature `fn(op, **metadata) -> None`. Their definition has no return statement and
contains the error operations that are *inserted* when a gate operation in the circuit
satisfies corresponding conditional. There are a few ways to construct noise functions:

1. **Single-instruction noise functions:** To add a single-operation noise, we can use
   [`partial_wires()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.noise.partial_wires.html#pennylane.noise.partial_wires "(in PennyLane v0.45)"). It performs a partial initialization of the
   noise operation and queues it on the `wires` of the gate operation.
2. **User-defined noise functions:** For adding more sophisticated and custom noise,
   we can define our own quantum function with the signature specified above.

For example, one can use the following to insert a depolarization error and show
the error that gets queued with an example gate operation:

```python
depol_error = qp.noise.partial_wires(qp.DepolarizingChannel, 0.01)

op = qp.X('w1') # Example gate operation
print(f"Error for {op}: {depol_error(op)}")
```

```python
Error for X('w1'): DepolarizingChannel(0.01, wires=['w1'])
```

## Creating a noise model

We can now create a PennyLane [`NoiseModel`](https://docs.pennylane.ai/en/stable/code/api/pennylane.NoiseModel.html#pennylane.NoiseModel "(in PennyLane v0.45)") by stitching together
multiple condition-callable pairs, where noise operations are inserted into the
circuit when their corresponding condition is satisfied. For the first pair, we
will use the previously constructed conditional and callable to insert a depolarization
error after [`RX`](https://docs.pennylane.ai/en/stable/code/api/pennylane.RX.html#pennylane.RX "(in PennyLane v0.45)") gates that satisfy \(|\phi| < 1.0\) and that
act on the wires \(\in \{0, 1\}\).

```python
fcond1, noise1 = rx_and_wires_cond, depol_error
```

Next, we construct a pair to mimic thermal relaxation errors that are encountered
during the state preparation via [`ThermalRelaxationError`](https://docs.pennylane.ai/en/stable/code/api/pennylane.ThermalRelaxationError.html#pennylane.ThermalRelaxationError "(in PennyLane v0.45)"):

```python
fcond2 = qp.noise.op_eq(qp.StatePrep)

def noise2(op, **kwargs):
    for wire in op.wires:
        qp.ThermalRelaxationError(0.1, kwargs["t1"], kwargs["t2"], kwargs["tg"], wire)
```

By default, noise operations specified by a noise function will be inserted *after* the
gate operation that satisfies the conditional. However, they can be inserted in a custom
order by manually queuing the evaluated gate operation via [`apply()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.apply.html#pennylane.apply "(in PennyLane v0.45)")
within the function definition. For example, we can add a sandwiching constant-valued
rotation error for [`Hadamard`](https://docs.pennylane.ai/en/stable/code/api/pennylane.Hadamard.html#pennylane.Hadamard "(in PennyLane v0.45)") gates on the wires \(\in \{0, 1\}\):

```python
fcond3 = qp.noise.op_eq("Hadamard") & qp.noise.wires_in([0, 1])

def noise3(op, **kwargs):
    qp.RX(np.pi / 16, op.wires)
    qp.apply(op)
    qp.RY(np.pi / 8, op.wires)
```

Finally, we can build the noise model with some required `metadata` for `noise2`:

```python
metadata = dict(t1=0.02, t2=0.03, tg=0.001)  # times unit: sec
noise_model = qp.NoiseModel(
    {fcond1: noise1, fcond2: noise2, fcond3: noise3}, **metadata
)
print(noise_model)
```

```python
NoiseModel({
    rx_cond & WiresIn([0, 1]): DepolarizingChannel(p=0.01)
    OpEq(StatePrep): noise2
    OpEq(Hadamard) & WiresIn([0, 1]): noise3
}, t1 = 0.02, t2 = 0.03, tg = 0.001)
```

## Adding noise models to your workflow

Now that we have built our noise model, we can learn how to use it.
A noise model can be applied to a circuit or device via the
[`add_noise()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.add_noise.html#pennylane.add_noise "(in PennyLane v0.45)") transform. For example, consider
the following circuit that performs the evolution and de-evolution
of a given initial state based on some parameters:

```python
from matplotlib import pyplot as plt

qp.drawer.use_style("pennylane")
dev = qp.device("default.mixed", wires=3)
init_state = np.random.RandomState(42).rand(2 ** len(dev.wires))
init_state /= np.linalg.norm(init_state)

def circuit(theta, phi):
    # State preparation
    qp.StatePrep(init_state, wires=[0, 1, 2])

    # Evolve state
    qp.Hadamard(0)
    qp.RX(theta, 1)
    qp.RX(phi, 2)
    qp.CNOT([1, 2])
    qp.CNOT([0, 1])

    # De-evolve state
    qp.CNOT([0, 1])
    qp.CNOT([1, 2])
    qp.RX(-phi, 2)
    qp.RX(-theta, 1)
    qp.Hadamard(0)
    return qp.state()

theta, phi = 0.21, 0.43
ideal_circuit = qp.QNode(circuit, dev)
qp.draw_mpl(ideal_circuit)(theta, phi)
plt.show()
```

To attach the `noise_model` to this quantum circuit, we use the
[`add_noise()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.add_noise.html#pennylane.add_noise "(in PennyLane v0.45)") transform:

```python
noisy_circuit = qp.add_noise(ideal_circuit, noise_model)
qp.draw_mpl(noisy_circuit)(theta, phi)
plt.show()
```

We can then use the `noisy_circuit` to run noisy simulations as shown below:

```python
init_dm = np.outer(init_state, init_state) # density matrix for the init_state
ideal_res = np.round(qp.math.fidelity(ideal_circuit(theta, phi), init_dm), 8)
noisy_res = np.round(qp.math.fidelity(noisy_circuit(theta, phi), init_dm), 8)

print(f"Ideal v/s Noisy: {ideal_res} and {noisy_res}")
```

```python
Ideal v/s Noisy: 1.00000004 and 0.90174224
```

The fidelity for the state obtained from the ideal circuit is \(\approx 1.0\),
which is expected since our circuit effectively does nothing to the initial state.
We see that this is not the case for the result obtained from the noisy simulation,
due to the error operations inserted in the circuit.

## Conclusion

Noise models provide a succinct way to describe the impact of the environment on
quantum computation. In PennyLane, we define such models as mapping between conditionals
that select the target operation and their corresponding noise operations. These
can be constructed with utmost flexibility as we showed here.

Should you have any questions about using noise models in PennyLane, you can consult the
[noise module documentation](https://docs.pennylane.ai/en/stable/code/qp_noise.html "(in PennyLane v0.45)"),
the PennyLane Codebook module on
[Noisy Quantum Theory](https://pennylane.ai/codebook/#06-noisy-quantum-theory)
on noise, or create a post on the [PennyLane Discussion Forum](https://discuss.pennylane.ai).
You can also follow us on [X (formerly Twitter)](https://twitter.com/PennyLaneAI)
or [LinkedIn](https://www.linkedin.com/company/pennylaneai/) to stay up-to-date with
the latest and greatest from PennyLane!

## About the author

[Utkarsh Azad](https://pennylane.ai/profile/whatsis)

Utkarsh is a quantum physicist and computer scientist. He currently works as a senior quantum scientist at Xanadu. When he's not untangling qubits there, you'll find him observing fractals and writing poetry.

**Total running time of the script:** (0 minutes 0.479 seconds)

Share demo

[Ask a question on the forum](https://discuss.pennylane.ai/c/demos/25)

### Related Demos

[Noisy circuits](https://pennylane.ai/qml/demos/tutorial_noisy_circuits)

[How to import noise models from Qiskit](https://pennylane.ai/qml/demos/tutorial_how_to_import_qiskit_noise_models)

[How to track algorithmic error using PennyLane](https://pennylane.ai/qml/demos/tutorial_error_prop)

[Unitary designs](https://pennylane.ai/qml/demos/tutorial_unitary_designs)

[Differentiating quantum error mitigation transforms](https://pennylane.ai/qml/demos/tutorial_diffable-mitigation)

[What are magic states?](https://pennylane.ai/qml/demos/tutorial_magic_states)

[Basic tutorial: qubit rotation](https://pennylane.ai/qml/demos/tutorial_qubit_rotation)

[Error mitigation with Mitiq and PennyLane](https://pennylane.ai/qml/demos/tutorial_error_mitigation)

[Digital zero-noise extrapolation with Catalyst](https://pennylane.ai/qml/demos/zne_catalyst)

[Compilation of quantum circuits](https://pennylane.ai/qml/demos/tutorial_circuit_compilation)
