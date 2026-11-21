# Construir modelos de ruido

> Fuente: <https://quantum.cloud.ibm.com/docs/en/qiskit/build-noise-models>

> Documentación de IBM Quantum Platform (repositorio <https://github.com/Qiskit/documentation>). Solo texto, sin las celdas de código.

# Build noise models

<Accordion>
<AccordionItem title="Package versions">

The code on this page was developed using the following requirements.
We recommend using these versions or newer.

```
qiskit[all]~=2.6.2
qiskit-ibm-runtime~=0.52.0
qiskit-aer~=0.18
```
</AccordionItem>
</Accordion>

This page shows how to use the Qiskit Aer [`noise`](https://qiskit.org/ecosystem/aer/apidocs/aer_noise.html) module to build noise models for simulating quantum circuits in the presence of errors. This is useful for emulating noisy quantum processors and for studying the effects of noise on the execution of quantum algorithms.

## Qiskit Aer `noise` module

The Qiskit Aer `noise` module contains Python classes to build customized noise models for simulation. There are three key classes:

1. The `NoiseModel` class which stores a noise model used for noisy simulation.
2. The `QuantumError` class which describes CPTP gate errors. These can be applied:
    * After *gate* or *reset* instructions
    * Before *measure* instructions.

3. The `ReadoutError` class which describes classical readout errors.

## Initialize a noise model from a backend

You can initialize a noise model with parameters set from the latest calibration data for a physical backend.

<Admonition type="note">
The  `FakeSherbrooke` mock backend from `qiskit_ibm_runtime` is used in these examples,  but you can try it on any Qiskit-compatible real or fake backend.
</Admonition>

This will yield a noise model that roughly approximates the errors one would encounter when using that backend. If you want to have more detailed control over the parameters of the noise model, then you'll need to create your own noise model, as described in the rest of this page.

## Quantum errors

Rather than deal with the `QuantumError` object directly, many helper functions exist to automatically generate a specific type of parameterized quantum error. These are contained in the `noise` module and include functions for many common error types used in quantum computing research. The function names and the type of error they return are:

| Standard error function | Details |
| --- | --- |
| `kraus_error` | a general n-qubit CPTP error channel given as a list of Kraus matrices $[K_0, ...]$. |
| `mixed_unitary_error` | an n-qubit mixed unitary error given as a list of unitary matrices and probabilities $[(U_0, p_0),...]$. |
| `coherent_unitary_error` | an n-qubit coherent unitary error given as a single unitary matrix $U$. |
| `pauli_error` | an n-qubit Pauli error channel (mixed unitary) given as a list of Pauli's and probabilities $[(P_0, p_0),...]$ |
| `depolarizing_error` | an n-qubit depolarizing error channel parameterized by a depolarization probability $p$. |
| `reset_error` | a single-qubit reset error parameterized by probabilities $p_0, p_1$ of resetting to the $\vert0\rangle$, $\vert1\rangle$ state.|
| `thermal_relaxation_error` | a single qubit thermal relaxation channel parameterized by relaxation time constants $T_1$, $T_2$, gate time $t$, and excited state thermal population $p_1$. |
| `phase_amplitude_damping_error` | A single-qubit generalized combined phase and amplitude damping error channel given by an amplitude damping parameter $\lambda$, a phase damping parameter $\gamma$, and an excited state thermal population $p_1$. |
| `amplitude_damping_error` |  A single-qubit generalized amplitude damping error channel given by an amplitude damping parameter $\lambda$, and an excited state thermal population $p_1$. |
| `phase_damping_error` |  A single-qubit phase damping error channel given by a phase damping parameter $\gamma$. |

### Combine quantum errors

`QuantumError` instances can be combined by using composition, tensor product, and tensor expansion (reversed order tensor product) to produce new `QuantumErrors` as:

 * Composition: $\cal{E}(\rho)=\cal{E_2}(\cal{E_1}(\rho))$ as `error = error1.compose(error2)`
 * Tensor product: $\cal{E}(\rho) =(\cal{E_1}\otimes\cal{E_2})(\rho)$ as `error = error1.tensor(error2)`
 * Expand product: $\cal{E}(\rho) =(\cal{E_2}\otimes\cal{E_1})(\rho)$ as `error = error1.expand(error2)`

### Example

To construct a 5% single-qubit bit-flip error:

### Convert to and from QuantumChannel operators

We can also convert back and forth between `QuantumError` objects in Qiskit Aer and `QuantumChannel` objects in Qiskit.

### Readout error

Classical readout errors are specified by a list of assignment probability vectors $P(A|B)$:

  * $A$ is the *recorded* classical bit value
  * $B$ is the *true* bit value returned from the measurement

For example, for one qubit: $ P(A|B) = [P(A|0), P(A|1)]$.

Readout errors may also be combined using `compose`, `tensor` and `expand`, like with quantum errors.

## Add errors to a noise model

When adding a quantum error to a noise model, we must specify the type of *instruction* that it acts on and what qubits to apply it to. There are two cases of quantum errors:

 1. All-qubit quantum error
 2. Specific qubit quantum error

### 1. All-qubit quantum error

This applies the same error to any occurrence of an instruction, regardless of which qubits it acts on.

It is added as `noise_model.add_all_qubit_quantum_error(error, instructions)`:

### 2. Specific qubit quantum error

This applies the error to any occurrence of an instruction acting on a specified list of qubits. Note that the order of the qubit matters: for example, an error applied to qubits [0, 1] for a two-qubit gate is different to one applied to qubits [1, 0].

It is added as `noise_model.add_quantum_error(error, instructions, qubits)`:

### Note on non-local qubit quantum error

`NoiseModel` does not support addition of non-local qubit quantum errors. They should be handled outside of `NoiseModel`. That suggests you should [write your own transpiler pass](https://quantum.cloud.ibm.com/docs/qiskit/custom-transpiler-pass) (`TransformationPass`) and run the pass just before running the simulator if you need to insert your quantum errors into your circuit under your own conditions.

### Execute a noisy simulation with a noise model

The command `AerSimulator(noise_model=noise_model)` returns a simulator configured to the given noise model. In addition to setting the simulator's noise model, it also overrides the simulator's basis gates, according to the gates of the noise model.

## Noise model examples

We will now give some examples of noise models. For our demonstrations we use a simple test circuit generating an n-qubit GHZ state:

### Ideal simulation

## Noise example 1: Basic bit-flip error noise model

Let's consider a simple toy noise model example common in quantum information theory research:

* When applying a single-qubit gate, flip the state of the qubit with probability `p_gate1`.
* When applying a two-qubit gate, apply single-qubit errors to each qubit.
* When resetting a qubit, reset to 1 instead of 0 with probability `p_reset`.
* When measuring a qubit, flip the state of the qubit with probability `p_meas`.

### Execute the noisy simulation

## Example 2: T1/T2 thermal relaxation

Now consider a more realistic error model based on thermal relaxation with the qubit environment:
* Each qubit is parameterized by a thermal relaxation time constant $T_1$ and a dephasing time constant $T_2$.
* Note that we must have $T_2 \le 2 T_1$.
* Error rates on instructions are determined by gate times and qubit $T_1$, $T_2$ values.

### Execute the noisy simulation

## Next steps

<Admonition type="tip" title="Recommendations">
  - To simulate noisy circuits, see [Exact and noisy simulation with Qiskit Aer primitives](https://quantum.cloud.ibm.com/docs/qiskit/simulate-with-qiskit-sdk-primitives).
  - Review the [Qiskit Aer noise module](https://qiskit.org/ecosystem/aer/apidocs/aer_noise.html) reference.
</Admonition>
