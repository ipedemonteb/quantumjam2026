# VQE in different spin sectors

> Fuente: <https://pennylane.ai/qml/demos/tutorial_vqe_spin_sectors>

[Alain Delgado Gran](https://pennylane.ai/profile/adgran)

Published: October 12, 2020. Last updated: July 23, 2026.

The Variational Quantum Eigensolver (VQE) algorithm is an approach for finding the
lowest-energy state of a molecule using a quantum computer [[1]](#peruzzo2014).

In the absence of [spin-orbit coupling](https://en.wikipedia.org/wiki/Spin-orbit_interaction),
the eigenstates of the molecular Hamiltonian can be calculated for specific values of the
spin quantum numbers. This allows us to compute quantities such as the energy of the electronic
states in different sectors of the total-spin projection \(S\_z.\) This is illustrated in the
figure below for the energy spectrum of the hydrogen molecule. In this case, the ground state has
total spin \(S=0\) while the lowest-lying excited states, with total spin \(S=1,\) form
a triplet related to the spin components \(S\_z=-1, 0, 1.\)

In this tutorial we demonstrate how to run VQE simulations to find the lowest-energy states
of the hydrogen molecule in different spin sectors. First, we show how to
build the electronic Hamiltonian and the total spin operator \(\hat{S}^2.\) Next, we use
excitation operations, implemented in PennyLane as Givens rotations [[2]](#qchemcircuits), to prepare
the trial states of the molecule. In order to probe the molecular states with different total spin,
\(S=0\) and \(S=1,\) we apply excitation operations which preserve and modify, respectively,
the total-spin projection of the initial state encoded in the qubit register. Finally, we run
the VQE algorithm to compute the energy of the states.

Let’s get started!

## Building the Hamiltonian and the total spin operator \(\hat{S}^2\)

First, we need to specify the structure of the molecule. This is done by providing a list
with the symbols of the constituent atoms and a one-dimensional array with the corresponding
nuclear coordinates in [atomic units](https://en.wikipedia.org/wiki/Hartree_atomic_units).

```python
import numpy as np

symbols = ["H", "H"]
coordinates = np.array([0.0, 0.0, -0.6614, 0.0, 0.0, 0.6614])
```

The geometry of the molecule can also be imported from an external file using
the [`read_structure()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.qchem.read_structure.html#pennylane.qchem.read_structure "(in PennyLane v0.45)") function.

Now, we can build the electronic Hamiltonian. We use a minimal [basis set](https://en.wikipedia.org/wiki/Basis_set_(chemistry)) approximation to represent
the [molecular orbitals](https://en.wikipedia.org/wiki/Molecular_orbital). Then,
the qubit Hamiltonian of the molecule is built using the
[`molecular_hamiltonian()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.qchem.molecular_hamiltonian.html#pennylane.qchem.molecular_hamiltonian "(in PennyLane v0.45)") function.

```python
import pennylane as qp

H, qubits = qp.qchem.molecular_hamiltonian(symbols, coordinates)

print("Number of qubits = ", qubits)
print("The Hamiltonian is ", H)
```

```python
Number of qubits =  4
The Hamiltonian is  -0.042072551947439224 * I([0, 1, 2, 3]) + 0.1777135822909176 * Z(0) + 0.1777135822909176 * Z(1) + 0.17059759276836803 * (Z(0) @ Z(1)) + -0.2427450126094144 * Z(2) + 0.12293330449299361 * (Z(0) @ Z(2)) + 0.16768338855601356 * (Z(1) @ Z(2)) + 0.044750084063019925 * (Y(0) @ X(1) @ X(2) @ Y(3)) + -0.044750084063019925 * (Y(0) @ Y(1) @ X(2) @ X(3)) + -0.044750084063019925 * (X(0) @ X(1) @ Y(2) @ Y(3)) + 0.044750084063019925 * (X(0) @ Y(1) @ Y(2) @ X(3)) + -0.2427450126094144 * Z(3) + 0.16768338855601356 * (Z(0) @ Z(3)) + 0.12293330449299361 * (Z(1) @ Z(3)) + 0.1762766139418181 * (Z(2) @ Z(3))
```

The outputs of the function are the Hamiltonian and the number of qubits
required for the quantum simulations. For the \(\mathrm{H}\_2\) molecule in a minimal
basis, we have four molecular **spin**-orbitals, which defines the number of qubits.

The [`molecular_hamiltonian()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.qchem.molecular_hamiltonian.html#pennylane.qchem.molecular_hamiltonian "(in PennyLane v0.45)") function allows us to define
additional keyword arguments to simulate more complicated molecules. For more details
take a look at the tutorial [Building molecular Hamiltonians](https://pennylane.ai/demos/tutorial_quantum_chemistry.html "(in PennyLane vNone)").

We also want to build the total spin operator \(\hat{S}^2,\)

\[\hat{S}^2 = \frac{3}{4} N + \sum\_{\alpha, \beta, \gamma, \delta}
\langle \alpha, \beta \vert \hat{s}\_1 \cdot \hat{s}\_2
\vert \gamma, \delta \rangle ~ \hat{c}\_\alpha^\dagger \hat{c}\_\beta^\dagger
\hat{c}\_\gamma \hat{c}\_\delta.\]

In the equation above, \(N\) is the number of electrons,
\(\hat{c}\) and \(\hat{c}^\dagger\) are respectively the electron annihilation and
creation operators, and
\(\langle \alpha, \beta \vert \hat{s}\_1 \cdot \hat{s}\_2 \vert \gamma, \delta \rangle\)
is the [matrix element of the two-body spin operator](https://docs.pennylane.ai/en/stable/code/api/pennylane.qchem.spin2.html)
\(\hat{s}\_1 \cdot \hat{s}\_2\) in the basis of spin orbitals.

We use the `spin2()` function to build the
\(\hat{S}^2\) observable.

```python
electrons = 2
S2 = qp.qchem.spin2(electrons, qubits)
print(S2)
```

```python
0.75 * I([0, 1, 2, 3]) + 0.375 * Z(0) + 0.375 * Z(1) + -0.375 * (Z(0) @ Z(1)) + 0.375 * Z(2) + 0.125 * (Z(0) @ Z(2)) + 0.375 * Z(3) + -0.125 * (Z(0) @ Z(3)) + -0.125 * (Z(1) @ Z(2)) + 0.125 * (Z(1) @ Z(3)) + -0.375 * (Z(2) @ Z(3)) + 0.125 * (Y(0) @ Y(2) @ X(3) @ X(1)) + 0.125 * (Y(0) @ X(2) @ X(3) @ Y(1)) + 0.125 * (Y(0) @ Y(2) @ Y(3) @ Y(1)) + -0.125 * (Y(0) @ X(2) @ Y(3) @ X(1)) + -0.125 * (X(0) @ Y(2) @ X(3) @ Y(1)) + 0.125 * (X(0) @ X(2) @ X(3) @ X(1)) + 0.125 * (X(0) @ Y(2) @ Y(3) @ X(1)) + 0.125 * (X(0) @ X(2) @ Y(3) @ Y(1))
```

## Building the quantum circuit to find the ground state

We build the variational circuit for the ground state of the hydrogen molecule using the
[`SingleExcitation`](https://docs.pennylane.ai/en/stable/code/api/pennylane.SingleExcitation.html#pennylane.SingleExcitation "(in PennyLane v0.45)") and [`DoubleExcitation`](https://docs.pennylane.ai/en/stable/code/api/pennylane.DoubleExcitation.html#pennylane.DoubleExcitation "(in PennyLane v0.45)") operations
which act as Givens rotations on subspaces of two and four qubits, respectively
[[2]](#qchemcircuits). The total number of excitation operations is given by
all possible single and double excitations of the Hartree-Fock reference state. The indices
of the qubits they act on correspond to the spin-orbitals involved in each excitation.
For more details on how to use the excitation operations see the
tutorial [Givens rotations for quantum chemistry](https://pennylane.ai/demos/tutorial_givens_rotations.html "(in PennyLane vNone)").

First, we use the [`hf_state()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.qchem.hf_state.html#pennylane.qchem.hf_state "(in PennyLane v0.45)")
function to generate the vector representing the Hartree-Fock state
\(\vert 1100 \rangle\) of the \(\mathrm{H}\_2\) molecule.

```python
hf = qp.qchem.hf_state(electrons, qubits)
print(hf)
```

```python
[1 1 0 0]
```

Next, we use the [`excitations()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.qchem.excitations.html#pennylane.qchem.excitations "(in PennyLane v0.45)")
function to generate all single and double excitations of the Hartree-Fock state.
This function allows us to define the keyword argument `delta_sz`
to specify the total-spin projection of the excitations with respect to the reference
state. This is illustrated in the figure below.

Therefore, for the ground state of the \(\mathrm{H}\_2\) molecule we choose
`delta_sz = 0`.

```python
singles, doubles = qp.qchem.excitations(electrons, qubits, delta_sz=0)
print(singles)
print(doubles)
```

```python
[[0, 2], [1, 3]]
[[0, 1, 2, 3]]
```

The output lists `singles` and `doubles` contain the qubit indices involved in the
single and double excitations. Even and odd indices correspond, respectively, to spin-up
and spin-down orbitals. For `delta_sz = 0` we have two single excitations, one from qubit
0 to 2 and the other from qubit 1 to 3, and one double excitation from qubits 0, 1 to 2, 3.
In order to build the variational circuit, we apply the corresponding
excitation operations. This can be done straightforwardly using the
`AllSinglesDoubles` template.

```python
def circuit(params, wires):
    qp.AllSinglesDoubles(params, wires, hf, singles, doubles)
```

The circuit above prepares trial states for the \(\mathrm{H}\_2\) molecule of the form:

\[\vert \Psi(\theta) \rangle =
c\_\mathrm{HF}(\theta) \vert 1100 \rangle
+ c\_{0123}(\theta) \vert 0011 \rangle
+ c\_{02}(\theta) \vert 0110 \rangle
+ c\_{13}(\theta) \vert 1001 \rangle,\]

where the coefficients \(c\) are functions of the variational parameters
\(\theta = (\theta\_1, \theta\_2, \theta\_3)\) to be optimized by the VQE algorithm.
Note that the prepared state \(\vert \Psi(\theta) \rangle\) is a superposition of the
Hartree-Fock (HF) state with all possible single and double excitations that preserve
the spin projection of the HF reference state.

## Running the VQE simulation

Now we proceed to optimize the variational parameters. First, we define the device,
in this case a qubit simulator:

```python
dev = qp.device("lightning.qubit", wires=qubits)
```

Next, we define the cost function as the following QNode, where we make use of
the [`expval()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.expval.html#pennylane.expval "(in PennyLane v0.45)") function to compute the expectation value of the hamiltonian.
This requires specifying the circuit, the target Hamiltonian, and the device. It returns
a cost function that can be evaluated with the circuit parameters:

```python
@qp.qnode(dev, interface="jax")
def cost_fn(params):
    circuit(params, wires=range(qubits))
    return qp.expval(H)
```

As a reminder, we also built the total spin operator \(\hat{S}^2\) for which
we can now define a function to compute its expectation value:

```python
@qp.qnode(dev, interface="jax")
def S2_exp_value(params):
    circuit(params, wires=range(qubits))
    return qp.expval(S2)
```

The total spin \(S\) of the trial state can be obtained from the
expectation value \(\langle \hat{S}^2 \rangle\) as

\[S = -\frac{1}{2} + \sqrt{\frac{1}{4} + \langle \hat{S}^2 \rangle}.\]

We define a function to compute the total spin.

```python
def total_spin(params):
    return -0.5 + np.sqrt(1 / 4 + S2_exp_value(params))
```

Now, we proceed to minimize the cost function to find the ground state. We define
the classical optimizer and initialize the circuit parameters.

```python
from jax import random
import optax

opt = optax.sgd(learning_rate=0.8) # sgd stands for StochasticGradientDescent
key = random.PRNGKey(0)
init_params = random.normal(key, shape=(len(singles) + len(doubles),)) * np.pi
```

We carry out the optimization over a maximum of 100 steps, aiming to reach a
convergence tolerance of \(10^{-6}\) for the value of the cost function.

```python
import catalyst
max_iterations = 100

prev_energy = 0.0
@qp.qjit
def update_step(i, params, opt_state):
    """Perform a single gradient update step"""
    grads = qp.grad(cost_fn)(params)
    updates, opt_state = opt.update(grads, opt_state)
    params = optax.apply_updates(params, updates)
    return (params, opt_state)

loss_history = []

opt_state = opt.init(init_params)
params = init_params

for i in range(max_iterations):
    params, opt_state = update_step(i, params, opt_state)
    energy = cost_fn(params)

print("\n" f"Final value of the ground-state energy = {energy:.8f} Ha")
print("\n" f"Optimal value of the circuit parameters = {params}")
```

```python
Final value of the ground-state energy = -1.13618916 Ha

Optimal value of the circuit parameters = [6.283185   6.2831855  0.20973289]
```

As a result, we have estimated the lowest-energy state of the hydrogen molecule
with total spin \(S = 0\) which corresponds to the ground state.

## Finding the lowest-lying excited state with \(S=1\)

In the last part of the tutorial, we will use VQE to find the lowest-lying
excited state of the hydrogen molecule with total spin \(S=1.\)
In this case, we use the [`excitations()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.qchem.excitations.html#pennylane.qchem.excitations "(in PennyLane v0.45)") function to generate
excitations whose total-spin projection differs by the quantity `delta_sz=1`
with respect to the Hartree-Fock state.

```python
singles, doubles = qp.qchem.excitations(electrons, qubits, delta_sz=1)
print(singles)
print(doubles)
```

```python
[[1, 2]]
[]
```

For the \(\mathrm{H}\_2\) molecule in a minimal basis set there are no
double excitations, but only a spin-flip single excitation from qubit 1 to 2.
In this case, the circuit will contain only one [`SingleExcitation`](https://docs.pennylane.ai/en/stable/code/api/pennylane.SingleExcitation.html#pennylane.SingleExcitation "(in PennyLane v0.45)")
operation. Additionally, as we want to probe the excited state of the hydrogen molecule,
we initialize the qubit register to the state \(\vert 0011 \rangle.\)

```python
def circuit(params, wires):
    qp.AllSinglesDoubles(params, wires, np.flip(hf), singles, doubles)
```

This allows us to prepare trial states of the form

\[\vert \Psi(\theta) \rangle = c\_{03}(\theta) \vert 0101 \rangle
+ c\_{0123}(\theta) \vert 0011 \rangle,\]

where the first term \(\vert 0101 \rangle\) encodes a spin-flip excitation with
\(S\_z=-1\) and the second term is a double excitation with \(S\_z=0.\)
Since an eigenstate of the electronic Hamiltonian cannot contain a superposition of
states with different total-spin projections, the double excitation coefficient
should vanish as the VQE algorithm minimizes the cost function. The optimized state will
correspond to the lowest-energy state with spin quantum numbers \(S=1, S\_z=-1.\)

Now, we define the new functions to compute the expectation values of the Hamiltonian
and the total spin operator for the new circuit.

```python
@qp.qnode(dev, interface="jax")
def cost_fn(params):
    circuit(params, wires=range(qubits))
    return qp.expval(H)

@qp.qnode(dev, interface="jax")
def S2_exp_value(params):
    circuit(params, wires=range(qubits))
    return qp.expval(S2)
```

Finally, we generate the new set of initial parameters, and proceed with the VQE algorithm to
optimize the variational circuit.

```python
opt = optax.sgd(learning_rate=0.8) # sgd stands for StochasticGradientDescent
key = random.PRNGKey(0)
init_params = random.normal(key, shape=(len(singles) + len(doubles),)) * np.pi

max_iterations = 100

@qp.qjit
def update_step(i, params, opt_state):
    """Perform a single gradient update step"""
    grads = qp.grad(cost_fn)(params)
    updates, opt_state = opt.update(grads, opt_state)
    params = optax.apply_updates(params, updates)
    return (params, opt_state)

loss_history = []

opt_state = opt.init(init_params)
params = init_params

for i in range(max_iterations):
    params, opt_state = update_step(i, params, opt_state)
    energy = cost_fn(params)

print("\n" f"Final value of the energy = {energy:.8f} Ha")
print("\n" f"Optimal value of the circuit parameters = {params}")
```

```python
Final value of the energy = -0.47844693 Ha

Optimal value of the circuit parameters = [-3.14159265]
```

As expected, the VQE algorithm has found the lowest-energy state with total spin
\(S=1\) which is an excited state of the hydrogen molecule.

## Conclusion

In this tutorial we have used the standard VQE algorithm to find the ground and the
lowest-lying excited states of the hydrogen molecule. We used the single and
double excitation operations, implemented as Givens rotations,
to prepare the trial states of a molecule. We also showed how to build
the total-spin operator \(\hat{S}^2\) and used it to compute the total spin
of the optimized states. By choosing the total-spin projection of the
generated excitations, we were able to probe the lowest-energy eigenstates of the
molecular Hamiltonian in different sectors of the spin quantum numbers.

## References

[[1](#id1)]

A. Peruzzo, J. McClean *et al.*, “A variational eigenvalue solver on a photonic
quantum processor”. [Nature Communications 5, 4213 (2014).](https://www.nature.com/articles/ncomms5213?origin=ppub)

[2]
([1](#id2),[2](#id3))

J.M. Arrazola, O. Di Matteo, N. Quesada, S. Jahangiri, A. Delgado, N. Killoran.
“Universal quantum circuits for quantum chemistry”. [arXiv:2106.13839, (2021)](https://arxiv.org/abs/2106.13839)

## About the author

[Alain Delgado Gran](https://pennylane.ai/profile/adgran)

Quantum simulations of molecules and materials.

**Total running time of the script:** (0 minutes 5.642 seconds)

Share demo

[Ask a question on the forum](https://discuss.pennylane.ai/c/demos/25)

### Related Demos

[A brief overview of VQE](https://pennylane.ai/qml/demos/tutorial_vqe)

[VQE with parallel QPUs with Rigetti](https://pennylane.ai/qml/demos/vqe_parallel)

[Qubit tapering](https://pennylane.ai/qml/demos/tutorial_qubit_tapering)

[Optimization of molecular geometries](https://pennylane.ai/qml/demos/tutorial_mol_geo_opt)

[Adaptive circuits for quantum chemistry](https://pennylane.ai/qml/demos/tutorial_adaptive_circuits)

[Building molecular Hamiltonians](https://pennylane.ai/qml/demos/tutorial_quantum_chemistry)

[Givens rotations for quantum chemistry](https://pennylane.ai/qml/demos/tutorial_givens_rotations)

[Modelling chemical reactions on a quantum computer](https://pennylane.ai/qml/demos/tutorial_chemical_reactions)

[Classically-boosted variational quantum eigensolver](https://pennylane.ai/qml/demos/tutorial_classically_boosted_vqe)

[Accelerating VQEs with quantum natural gradient](https://pennylane.ai/qml/demos/tutorial_vqe_qng)
