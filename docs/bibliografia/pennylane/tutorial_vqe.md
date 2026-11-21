# A brief overview of VQE

> Fuente: <https://pennylane.ai/qml/demos/tutorial_vqe>

[Alain Delgado Gran](https://pennylane.ai/profile/adgran)

Published: February 07, 2020. Last updated: April 17, 2026.

The Variational Quantum Eigensolver (VQE) is a flagship algorithm for quantum chemistry
using near-term quantum computers [[1]](#peruzzo2014). It is an application of the
[Ritz variational principle](https://en.wikipedia.org/wiki/Ritz_method), where a quantum
computer is trained to prepare the ground state of a given molecule.

The inputs to the VQE algorithm are a molecular Hamiltonian and a
parametrized circuit preparing the quantum state of the molecule. Within VQE, the
cost function is defined as the expectation value of the Hamiltonian computed in the
trial state. The ground state of the target Hamiltonian is obtained by performing an
iterative minimization of the cost function. The optimization is carried out
by a classical optimizer which leverages a quantum computer to evaluate the cost function
and calculate its gradient at each optimization step.

In this tutorial you will learn how to implement the VQE algorithm in a few lines of code.
As an illustrative example, we use it to find the ground state of the hydrogen
molecule, \(\mathrm{H}\_2.\) First, we build the molecular Hamiltonian using a minimal
basis set approximation. Next, we design the quantum circuit preparing the trial
state of the molecule, and the cost function to evaluate the expectation value
of the Hamiltonian. Finally, we select a classical optimizer, initialize the
circuit parameters, and run the VQE algorithm using a PennyLane simulator.

Let’s get started!

## Building the electronic Hamiltonian

The first step is to specify the molecule we want to simulate. We will use
the electronic Hamiltonian of the hydrogen molecule. A wide variety of molecular
data, including Hamiltonians, is available on the
[PennyLane Datasets service](https://pennylane.ai/datasets). This data can
be downloaded using the [`load()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.data.load.html#pennylane.data.load "(in PennyLane v0.45)") function:

```python
from jax import numpy as np
import jax
jax.config.update("jax_platform_name", "cpu")
jax.config.update('jax_enable_x64', True)

import pennylane as qp

dataset = qp.data.load('qchem', molname="H2")[0]
H, qubits = dataset.hamiltonian, len(dataset.hamiltonian.wires)
print("Number of qubits = ", qubits)
print("The Hamiltonian is ", H)
```

```python
Number of qubits =  4
The Hamiltonian is  -0.09963387941370971 * I(0) + 0.17110545123720233 * Z(0) + 0.17110545123720225 * Z(1) + 0.16859349595532533 * (Z(0) @ Z(1)) + 0.04533062254573469 * (Y(0) @ X(1) @ X(2) @ Y(3)) + -0.04533062254573469 * (Y(0) @ Y(1) @ X(2) @ X(3)) + -0.04533062254573469 * (X(0) @ X(1) @ Y(2) @ Y(3)) + 0.04533062254573469 * (X(0) @ Y(1) @ Y(2) @ X(3)) + -0.22250914236600539 * Z(2) + 0.12051027989546245 * (Z(0) @ Z(2)) + -0.22250914236600539 * Z(3) + 0.16584090244119712 * (Z(0) @ Z(3)) + 0.16584090244119712 * (Z(1) @ Z(2)) + 0.12051027989546245 * (Z(1) @ Z(3)) + 0.1743207725924201 * (Z(2) @ Z(3))
```

For more details on quantum datasets, check out the
[Quantum Datasets](https://docs.pennylane.ai/en/stable/introduction/data.html)
documentation.

The outputs of the function are the Hamiltonian, represented as
a linear combination of Pauli operators, and the number of qubits
required for the quantum simulations. For this example, we use a
[minimal basis set](https://en.wikipedia.org/wiki/STO-nG_basis_sets)
to represent the [molecular orbitals](https://en.wikipedia.org/wiki/Molecular_orbital).
In this approximation, we have four spin orbitals, which defines the
number of qubits. Furthermore, we use the Jordan-Wigner
transformation [[2]](#seeley2012) to perform the fermionic-to-qubit mapping of
the Hamiltonian.

For a more comprehensive discussion on how to build the Hamiltonian of more
complicated molecules, see the tutorial [Building molecular Hamiltonians](https://pennylane.ai/demos/tutorial_quantum_chemistry.html "(in PennyLane vNone)").

Note

You can also manually construct the Hamiltonian using the following code:

```python
symbols = ["H", "H"]
coordinates = np.array([[-0.70108983, 0.0, 0.0], [0.70108983, 0.0, 0.0]])
molecule = qp.qchem.Molecule(symbols, coordinates)
H, qubits = qp.qchem.molecular_hamiltonian(molecule)
```

## Implementing the VQE algorithm

From here on, we can use PennyLane as usual, employing its entire stack of
algorithms and optimizers. We begin by defining the device, in this case PennyLane’s
standard qubit simulator:

```python
dev = qp.device("lightning.qubit", wires=qubits)
```

Next, we need to define the quantum circuit that prepares the trial state of the
molecule. We want to prepare states of the form,

\[\vert \Psi(\theta) \rangle = \cos(\theta/2)~|1100\rangle -\sin(\theta/2)~|0011\rangle,\]

where \(\theta\) is the variational parameter to be optimized in order to find
the best approximation to the true ground state. In the Jordan-Wigner [[2]](#seeley2012) encoding,
the first term \(|1100\rangle\) represents the [Hartree-Fock (HF) state](https://pennylane.ai/blog/2022/09/how-to-use-the-hartree-fock-method-in-pennylane) where the two electrons in
the molecule occupy the lowest-energy orbitals. The second term \(|0011\rangle\)
encodes a double excitation of the HF state where the two particles are excited from
qubits 0, 1 to 2, 3.

The quantum circuit to prepare the trial state \(\vert \Psi(\theta) \rangle\) is
schematically illustrated in the figure below.

In this figure, the gate \(G^{(2)}\) corresponds to the
[`DoubleExcitation`](https://docs.pennylane.ai/en/stable/code/api/pennylane.DoubleExcitation.html#pennylane.DoubleExcitation "(in PennyLane v0.45)") operation, implemented in PennyLane
as a [Givens rotation](https://en.wikipedia.org/wiki/Givens_rotation), which couples
the four-qubit states \(\vert 1100 \rangle\) and \(\vert 0011 \rangle.\)
For more details on how to use the excitation operations to build
quantum circuits for quantum chemistry applications see the
tutorial [Givens rotations for quantum chemistry](https://pennylane.ai/demos/tutorial_givens_rotations.html "(in PennyLane vNone)").

Implementing the circuit above using PennyLane is straightforward. First, we use the
[`hf_state()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.qchem.hf_state.html#pennylane.qchem.hf_state "(in PennyLane v0.45)") function to generate the vector representing the Hartree-Fock state.

```python
electrons = 2
hf = qp.qchem.hf_state(electrons, qubits)
print(hf)
```

```python
[1 1 0 0]
```

The `hf` array is used by the [`BasisState`](https://docs.pennylane.ai/en/stable/code/api/pennylane.BasisState.html#pennylane.BasisState "(in PennyLane v0.45)") operation to initialize
the qubit register. Then, we just act with the [`DoubleExcitation`](https://docs.pennylane.ai/en/stable/code/api/pennylane.DoubleExcitation.html#pennylane.DoubleExcitation "(in PennyLane v0.45)") operation
on the four qubits. The next step is to compute the expectation value
of the molecular Hamiltonian in the trial state prepared by the circuit.
We do this using the [`expval()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.expval.html#pennylane.expval "(in PennyLane v0.45)") function. The decorator syntax allows us to
run the cost function as an executable QNode with the gate parameter \(\theta:\)

```python
@qp.qnode(dev, interface="jax")
def circuit(param, wires):
    qp.BasisState(hf, wires=wires)
    qp.DoubleExcitation(param, wires=[0, 1, 2, 3])
    return qp.expval(H)
```

We can now define our error function simply as the expected value calculated above:

```python
def cost_fn(param):
    return circuit(param, wires=range(qubits))
```

Now we proceed to minimize the cost function to find the ground state of
the \(\mathrm{H}\_2\) molecule. To start, we need to define the classical optimizer.
The library `optax` offers different [optimizers](https://optax.readthedocs.io/en/latest/api.html).
Here we use a basic gradient-descent optimizer.
We carry out the optimization over a maximum of 100 steps aiming to reach a
convergence tolerance of \(10^{-6}\) for the value of the cost function.

```python
import optax

max_iterations = 100
conv_tol = 1e-06

opt = optax.sgd(learning_rate=0.4)
```

We initialize the circuit parameter \(\theta\) to zero, meaning that we start
from the Hartree-Fock state.

```python
theta = np.array(0.)

# store the values of the cost function
energy = [cost_fn(theta)]

# store the values of the circuit parameter
angle = [theta]

opt_state = opt.init(theta)

for n in range(max_iterations):

    gradient = jax.grad(cost_fn)(theta)
    updates, opt_state = opt.update(gradient, opt_state)
    theta = optax.apply_updates(theta, updates)

    angle.append(theta)
    energy.append(cost_fn(theta))

    conv = np.abs(energy[-1] - energy[-2])

    if n % 2 == 0:
        print(f"Step = {n},  Energy = {energy[-1]:.8f} Ha")

    if conv <= conv_tol:
        break

print("\n" f"Final value of the ground-state energy = {energy[-1]:.8f} Ha")
print("\n" f"Optimal value of the circuit parameter = {angle[-1]:.4f}")
```

```python
Step = 0,  Energy = -1.12772109 Ha
Step = 2,  Energy = -1.13524628 Ha
Step = 4,  Energy = -1.13683932 Ha
Step = 6,  Energy = -1.13717430 Ha
Step = 8,  Energy = -1.13724463 Ha
Step = 10,  Energy = -1.13725940 Ha
Step = 12,  Energy = -1.13726250 Ha

Final value of the ground-state energy = -1.13726250 Ha

Optimal value of the circuit parameter = 0.2250
```

Let’s plot the values of the ground state energy of the molecule
and the gate parameter \(\theta\) as a function of the optimization step.

```python
import matplotlib.pyplot as plt

fig = plt.figure()
fig.set_figheight(5)
fig.set_figwidth(12)

# Full configuration interaction (FCI) energy computed classically
E_fci = dataset.fci_energy

# Add energy plot on column 1
ax1 = fig.add_subplot(121)
ax1.plot(range(n + 2), energy, "go", ls="dashed")
ax1.plot(range(n + 2), np.full(n + 2, E_fci), color="red")
ax1.set_xlabel("Optimization step", fontsize=13)
ax1.set_ylabel("Energy (Hartree)", fontsize=13)
ax1.text(0.5, -1.1176, r"$E_\mathrm{HF}$", fontsize=15)
ax1.text(0, -1.1357, r"$E_\mathrm{FCI}$", fontsize=15)
plt.xticks(fontsize=12)
plt.yticks(fontsize=12)

# Add angle plot on column 2
ax2 = fig.add_subplot(122)
ax2.plot(range(n + 2), angle, "go", ls="dashed")
ax2.set_xlabel("Optimization step", fontsize=13)
ax2.set_ylabel("Gate parameter $\\theta$ (rad)", fontsize=13)
plt.xticks(fontsize=12)
plt.yticks(fontsize=12)

plt.subplots_adjust(wspace=0.3, bottom=0.2)
plt.show()
```

In this case, the VQE algorithm converges after thirteen iterations. The optimal
value of the circuit parameter \(\theta^\* = 0.208\) defines the state

\[\vert \Psi(\theta^\*) \rangle = 0.994~\vert 1100 \rangle - 0.104~\vert 0011 \rangle,\]

which is precisely the ground state of the \(\mathrm{H}\_2\) molecule in a
minimal basis set approximation.

## Conclusion

In this tutorial, we have implemented the VQE algorithm to find the ground state
of the hydrogen molecule. We used a simple circuit to prepare quantum states of
the molecule beyond the Hartree-Fock approximation. The ground-state energy
was obtained by minimizing a cost function defined as the expectation value of the
molecular Hamiltonian in the trial state.

The VQE algorithm can be used to simulate other chemical phenomena.
In the tutorial [Modelling chemical reactions on a quantum computer](https://pennylane.ai/demos/tutorial_chemical_reactions.html "(in PennyLane vNone)"), we use VQE to explore the
potential energy surface of molecules to simulate chemical reactions.
Another interesting application is to probe the lowest-lying states of molecules
in specific sectors of the Hilbert space. For example, see the tutorial
[VQE in different spin sectors](https://pennylane.ai/demos/tutorial_vqe_spin_sectors.html "(in PennyLane vNone)"). Furthermore, the algorithm presented here can be
generalized to find the equilibrium geometry of a molecule as it is demonstrated in the
tutorial [Optimization of molecular geometries](https://pennylane.ai/demos/tutorial_mol_geo_opt.html "(in PennyLane vNone)").

## References

[[1](#id1)]

Alberto Peruzzo, Jarrod McClean *et al.*, “A variational eigenvalue solver on a photonic
quantum processor”. [Nature Communications 5, 4213 (2014).](https://www.nature.com/articles/ncomms5213?origin=ppub)

[2]
([1](#id2),[2](#id3))

Jacob T. Seeley, Martin J. Richard, Peter J. Love. “The Bravyi-Kitaev transformation for
quantum computation of electronic structure”. [Journal of Chemical Physics 137, 224109 (2012).](https://aip.scitation.org/doi/abs/10.1063/1.4768229)

## About the author

[Alain Delgado Gran](https://pennylane.ai/profile/adgran)

Quantum simulations of molecules and materials.

**Total running time of the script:** (0 minutes 1.537 seconds)

Share demo

[Ask a question on the forum](https://discuss.pennylane.ai/t/a-brief-overview-of-vqe-demo/7333)

### Related Demos

[Building molecular Hamiltonians](https://pennylane.ai/qml/demos/tutorial_quantum_chemistry)

[VQE with parallel QPUs with Rigetti](https://pennylane.ai/qml/demos/vqe_parallel)

[Accelerating VQEs with quantum natural gradient](https://pennylane.ai/qml/demos/tutorial_vqe_qng)

[VQE in different spin sectors](https://pennylane.ai/qml/demos/tutorial_vqe_spin_sectors)

[Variational quantum thermalizer](https://pennylane.ai/qml/demos/tutorial_vqt)

[Optimization of molecular geometries](https://pennylane.ai/qml/demos/tutorial_mol_geo_opt)

[How to quantum just-in-time compile VQE with Catalyst](https://pennylane.ai/qml/demos/tutorial_how_to_quantum_just_in_time_compile_vqe_catalyst)

[Differentiable Hartree-Fock](https://pennylane.ai/qml/demos/tutorial_differentiable_HF)

[How to implement VQD with PennyLane](https://pennylane.ai/qml/demos/tutorial_vqe_vqd)

[Modelling chemical reactions on a quantum computer](https://pennylane.ai/qml/demos/tutorial_chemical_reactions)
