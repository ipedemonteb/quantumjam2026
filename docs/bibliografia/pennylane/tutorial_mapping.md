# Mapping fermionic Hamiltonians to qubit Hamiltonians

> Fuente: <https://pennylane.ai/qml/demos/tutorial_mapping>

[Diksha Dhawan](https://pennylane.ai/profile/ddhawan)

Published: May 05, 2024. Last updated: July 22, 2026.

Simulating quantum systems stands as one of the most anticipated applications of quantum
chemistry with the potential to transform our understanding of chemical and physical systems. These
simulations typically require mapping schemes that transform fermionic representations into qubit
representations. There are a variety of mapping schemes used in quantum computing but the
conventional ones are the Jordan-Wigner, Parity, and Bravyi-Kitaev transformations [[1]](#tranter). In
this demo, you will learn about these mapping schemes and their implementation in PennyLane. You
will also learn how to use these mappings in the context of computing the ground state energy
of a molecular system.

## Jordan-Wigner Mapping

The state of a quantum system in the [second quantized](https://en.wikipedia.org/wiki/Second_quantization)
formalism is typically represented in the occupation-number basis. For fermions, the occupation
number is either \(0\) or \(1\) as a result of the Pauli exclusion principle. The
occupation-number basis states can be represented by a vector that is constructed by
applying the fermionic creation operators, \(a^\dagger,\) to a vacuum state:

\[a^\dagger | 0 \rangle = | 1 \rangle.\]

Similarly, electrons can be removed from a state by applying the fermionic annihilation
operators \(a:\)

\[a | 1 \rangle = | 0 \rangle.\]

An intuitive way to represent a fermionic system in the qubit basis is to store the fermionic
occupation numbers in qubit states. This requires constructing qubit creation and annihilation
operators that can be applied to an initial state to provide the desired occupation number state.
These operators are defined as

\[Q^{\dagger}\_j = \frac{1}{2}(X\_j - iY\_j),\]

and

\[Q\_j = \frac{1}{2}(X\_j + iY\_j),\]

where \(X\) and \(Y\) are Pauli operators. However, an important property of fermionic
creation and annihilation operators is the anti-commutation relations between them, which is not
preserved by directly using the analogous qubit operators.

\[[a^{\dagger}\_j, a^{\dagger}\_k]\_+ = 0, \:\:\:\:\:\:\: [a\_j, a\_k]\_+=0, \:\:\:\:\:\:\: [a\_j, a^{\dagger}\_k]\_+ = \delta\_{jk} I,\]

where \(I\) is the identity operator. These relations are essential for capturing the Pauli
exclusion principle which requires the fermionic wave function to be antisymmetric. The
anti-commutation relations between fermionic operators can be incorporated by adding a sequence of
Pauli \(Z\) operators to the qubit operators (can you verify that?). According to these,
the fermionic creation and annihilation operators can be represented in the basis of Pauli operators:

\[a\_{j}^{\dagger} = \frac{1}{2}(X\_j - iY\_j) \otimes\_{k<j} Z\_{k},\]

and

\[a\_{j} = \frac{1}{2}(X\_j + iY\_j) \otimes\_{k<j} Z\_{k}.\]

This representation is called the **Jordan-Wigner** mapping. Let’s now look at an example
using PennyLane. We map a simple fermionic operator to a qubit operator
using the Jordan-Wigner mapping. First, we define our
[fermionic operator](https://pennylane.ai/demos/tutorial_fermionic_operators.html "(in PennyLane vNone)"),
\(a\_{5}^{\dagger},\) which creates an electron in the fifth orbital. One
way to do this in PennyLane is to use [`from_string()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.fermi.from_string.html#pennylane.fermi.from_string "(in PennyLane v0.45)"). We
then map the operator using `jordan_wigner()`.

```python
import pennylane as qp
from pennylane.fermi import from_string, jordan_wigner

qubits = 10
fermi_op = from_string("5+")
pauli_jw = jordan_wigner(fermi_op, ps=True)
pauli_jw
```

```python
0.5 * Z(0) @ Z(1) @ Z(2) @ Z(3) @ Z(4) @ X(5)
+ -0.5j * Z(0) @ Z(1) @ Z(2) @ Z(3) @ Z(4) @ Y(5)
```

The long sequence of the \(Z\) operations can significantly increase the
resources needed to implement the operator on quantum hardware, as it may require using entangling
operations across multiple qubits, which can be challenging to implement efficiently. One way to
avoid having such long tails of \(Z\) operations is to work in the parity basis where the
fermionic state stores the parity instead of the occupation number.

## Parity Mapping

In the Parity representation, the state of a fermionic system is represented with a binary
vector that corresponds to the parity of the orbitals. Note that parity for a set of orbitals
is defined as the sum (mod 2) of the occupation numbers. Let’s look at an example using the
PennyLane function [`hf_state()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.qchem.hf_state.html#pennylane.qchem.hf_state "(in PennyLane v0.45)") to obtain the state of a system with
\(10\) orbitals and \(5\) electrons in both the occupation-number and parity bases.

```python
orbitals = 10
electrons = 5
state_number = qp.qchem.hf_state(electrons, orbitals)
state_parity = qp.qchem.hf_state(electrons, orbitals, basis="parity")

print("State in occupation number basis:\n", state_number)
print("State in parity basis:\n", state_parity)
```

```python
State in occupation number basis:
 [1 1 1 1 1 0 0 0 0 0]
State in parity basis:
 [1 0 1 0 1 1 1 1 1 1]
```

Note that Parity mapping solves the non-locality problem of the parity information by storing
the parity of orbital \(j\) in qubit \(j\) while the occupation information for the
orbital is stored non-locally. In the parity basis, we cannot represent the creation or
annihilation of a particle in orbital
\(j\) by simply operating with qubit creation or annihilation operators. In fact, the state of
the \((j − 1)\)-th qubit provides information about the occupation state of qubit \(j\)
and whether we need to act with a creation or annihilation operator. Similarly, the creation or
annihilation of a particle in qubit \(j\) changes the parity of all qubits following it.
As a result, the operator that is equivalent to creation and annihilation operators in
the parity basis is a two-qubit operator acting on qubits \(j\) and \(j − 1,\) and
an update operator which updates the parity of all qubits with index larger than j:

\[a\_{j}^{\dagger} = \frac{1}{2}(Z\_{j-1} \otimes X\_j - iY\_j) \otimes\_{k>j} X\_{k}\]

and

\[a\_{j} = \frac{1}{2}(Z\_{j-1} \otimes X\_j + iY\_j) \otimes\_{k>j} X\_{k}\]

Let’s now look at an example where we map our fermionic operator \(a\_{5}^{\dagger}\) in a
\(10\) qubit system with
Parity mapping using `parity_transform()` in PennyLane.

```python
qubits = 10
pauli_pr = qp.parity_transform(fermi_op, qubits, ps=True)
pauli_pr
```

```python
0.5 * Z(4) @ X(5) @ X(6) @ X(7) @ X(8) @ X(9)
+ -0.5j * Y(5) @ X(6) @ X(7) @ X(8) @ X(9)
```

It is evident from this example that the Parity mapping doesn’t improve upon the
the Jordan-Wigner mapping as the long \(Z\) strings are now replaced by \(X\)
strings. However, a very important advantage of using parity mapping is the ability to taper two
qubits by leveraging symmetries of molecular Hamiltonians. You can find
more information about this in our
[qubit tapering](https://pennylane.ai/demos/tutorial_qubit_tapering.html "(in PennyLane vNone)") demo.
Let’s look at an example.

```python
generators = [qp.prod(*[qp.Z(i) for i in range(qubits-1)]), qp.Z(qubits-1)]
paulixops = qp.paulix_ops(generators, qubits)
paulix_sector = [1, 1]
taper_op = qp.taper(pauli_pr, generators, paulixops, paulix_sector)
qp.simplify(taper_op)
```

```python
(
    (0.4999999999999998+0j) * (Z(4) @ X(5) @ X(6) @ X(7))
  + -0.4999999999999998j * (Y(5) @ X(6) @ X(7))
)
```

Note that the tapered operator doesn’t include qubit \(8\) and \(9.\)

## Bravyi-Kitaev Mapping

The Bravyi-Kitaev mapping aims to improve the linear scaling of the Jordan-Wigner and Parity
mappings, in the number of qubits,
by storing both the occupation number and the parity non-locally. In this formalism, even-labelled
qubits store the occupation number of orbitals and odd-labelled qubits store parity
through partial sums of occupation numbers. The corresponding creation and annihilation operators
are defined [here](https://docs.pennylane.ai/en/stable/code/api/pennylane.bravyi_kitaev.html).
Let’s use the `bravyi_kitaev()` function to map our \(a\_{5}^{\dagger}\)
operator.

```python
pauli_bk = qp.bravyi_kitaev(fermi_op, qubits, ps=True)
pauli_bk
```

```python
0.5 * Z(4) @ Z(3) @ X(5) @ X(7.0)
+ -0.5j * Z(3) @ Y(5) @ X(7.0)
```

It is clear that the local nature of the transformation in the Bravyi-Kitaev mapping helps to
improve the number of qubits. This advantage becomes even more clear if you
work with a larger qubit
system. We now use the Bravyi-Kitaev mapping to construct a qubit Hamiltonian and
compute its ground state energy with the [VQE](https://pennylane.ai/demos/tutorial_vqe.html "(in PennyLane vNone)")
method.

## Energy Calculation

To perform a VQE calculation for a desired Hamiltonian, we need an initial state typically set to
a Hartree-Fock state, and a set of excitation operators to build an ansatz that allows us to
obtain the ground state and then compute the expectation value of the Hamiltonian. It is important
to note that the initial state and the excitation operators should be consistent with the
mapping scheme used for obtaining the qubit Hamiltonian. Let’s now build these three components
for \(H\_2\) and compute its ground state energy. For this example, we will use the
Bravyi-Kitaev transformation but similar calculations can be run with the other mappings.

### Molecular Hamiltonian

First, let’s build the molecular Hamiltonian. This requires defining the atomic symbols and
coordinates.

```python
from pennylane import qchem
from jax import numpy as jnp
import jax

jax.config.update("jax_enable_x64", True)

symbols  = ['H', 'H']
geometry = jnp.array([[0.0, 0.0, -0.69434785],
                     [0.0, 0.0,  0.69434785]])

mol = qchem.Molecule(symbols, geometry)
```

We then use the [`fermionic_hamiltonian()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.qchem.fermionic_hamiltonian.html#pennylane.qchem.fermionic_hamiltonian "(in PennyLane v0.45)") function to build
the fermionic Hamiltonian for our molecule.

```python
h_fermi = qchem.fermionic_hamiltonian(mol)()
```

We now use `bravyi_kitaev()` to transform the fermionic Hamiltonian to its
qubit representation.

```python
electrons = 2
qubits = len(h_fermi.wires)
h_pauli = qp.bravyi_kitaev(h_fermi, qubits, tol=1e-16)
```

### Initial state

We now need the initial state that has the correct number of electrons. We use the Hartree-Fock
state which can be obtained in a user-defined basis by using [`hf_state()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.qchem.hf_state.html#pennylane.qchem.hf_state "(in PennyLane v0.45)") in
PennyLane. For that, we need to specify the number of electrons, the number of orbitals and the
desired mapping.

```python
hf_state = qchem.hf_state(electrons, qubits, basis="bravyi_kitaev")
```

### Excitation operators

We now build our quantum circuit with the [`UCCSD`](https://docs.pennylane.ai/en/stable/code/api/pennylane.UCCSD.html#pennylane.UCCSD "(in PennyLane v0.45)") ansatz. This ansatz is
constructed with a set of single and double excitation operators. In PennyLane, we have
[`SingleExcitation`](https://docs.pennylane.ai/en/stable/code/api/pennylane.SingleExcitation.html#pennylane.SingleExcitation "(in PennyLane v0.45)") and [`DoubleExcitation`](https://docs.pennylane.ai/en/stable/code/api/pennylane.DoubleExcitation.html#pennylane.DoubleExcitation "(in PennyLane v0.45)") operators which
are very efficient, but they are only compatible with the Jordan-Wigner mapping. Here we construct
the excitation operators manually. We start from the fermionic single and double excitation
operators defined as [[2]](#yordanov)

\[T\_i^k(\theta) = \theta(a\_k^{\dagger}a\_i - a\_i^{\dagger}a\_k)\]

and

\[T\_{ij}^{kl}(\theta) = \theta(a\_k^{\dagger}a\_l^{\dagger}a\_i a\_j -
a\_i^{\dagger}a\_j^{\dagger}a\_k a\_l),\]

where \(\theta\) is an adjustable parameter. We can easily construct these fermionic
excitation operators in PennyLane and then map them to the qubit basis with
`bravyi_kitaev()`, similar to the way we transformed the fermionic
Hamiltonian.

```python
from pennylane.fermi import from_string

singles, doubles = qchem.excitations(electrons, qubits)

singles_fermi = []
for ex in singles:
    singles_fermi.append(from_string(f"{ex[1]}+ {ex[0]}-")
                       - from_string(f"{ex[0]}+ {ex[1]}-"))

doubles_fermi = []
for ex in doubles:
    doubles_fermi.append(from_string(f"{ex[3]}+ {ex[2]}+ {ex[1]}- {ex[0]}-")
                       - from_string(f"{ex[0]}+ {ex[1]}+ {ex[2]}- {ex[3]}-"))
```

The fermionic operators are now mapped to qubit operators.

```python
singles_pauli = []
for op in singles_fermi:
    singles_pauli.append(qp.bravyi_kitaev(op, qubits, ps=True))

doubles_pauli = []
for op in doubles_fermi:
    doubles_pauli.append(qp.bravyi_kitaev(op, qubits, ps=True))
```

Note that we need to exponentiate these operators to be able to use them in the circuit
[[2]](#yordanov). We also use a set of pre-defined parameters to construct the excitation gates.

```python
params = jnp.array([0.22347661, 0.0, 0.0])

dev = qp.device("default.qubit", wires=qubits)

@qp.qnode(dev)
def circuit(params):
    qp.BasisState(hf_state, wires=range(qubits))

    for i, excitation in enumerate(doubles_pauli):
        qp.exp((excitation * params[i] / 2).operation()), range(qubits)

    for j, excitation in enumerate(singles_pauli):
        qp.exp((excitation * params[i + j + 1] / 2).operation()), range(qubits)

    return qp.expval(h_pauli)

print('Energy =', circuit(params))
```

```python
Energy = -1.137306051413467
```

Using the above circuit, we produce the ground state energy of \(H\_2\) molecule.

## Conclusion

In this demo, we learned about various mapping schemes available in PennyLane and how
they can be used to convert fermionic operators to qubits operators. We also learned
the pros and cons associated with each scheme. The Jordan-Wigner mapping provides an intuitive
approach while parity mapping allows tapering qubits in molecular systems. However, these two
methods usually give qubit operators with a long chain of Pauli operators, which makes them
challenging to implement on quantum hardware. The Bravyi-Kitaev mapping, on the other hand,
emphasizes locality and resource efficiency, making it an attractive option for certain
applications. Through this demonstration, we recognize the importance of choosing an appropriate
mapping scheme tailored to the specific problem at hand and the available quantum
resources. Lastly, we showed how a user can employ these different mappings in ground state energy
calculations through an example. We would like to encourage the interested readers to run
calculations for different molecular systems and observe how the scaling in the number of qubits
is influenced by the selected mapping techniques.

## References

[[1](#id1)]

A. Tranter, S. Sofia, *et al.*, “The Bravyi–Kitaev Transformation:
Properties and Applications”. [International Journal of Quantum Chemistry 115.19 (2015).](https://onlinelibrary.wiley.com/doi/10.1002/qua.24969)

[2]
([1](#id2),[2](#id3))

Y. S. Yordanov, *et al.*, “Efficient quantum circuits for quantum computational chemistry”.
[Physical Review A 102.6 (2020).](https://journals.aps.org/pra/abstract/10.1103/PhysRevA.102.062612)

## About the author

[Diksha Dhawan](https://pennylane.ai/profile/ddhawan)

Developing Tools to Simulate Chemistry Using Quantum Computers

**Total running time of the script:** (0 minutes 7.224 seconds)

Share demo

[Ask a question on the forum](https://discuss.pennylane.ai/c/demos/25)

### Related Demos

[Qubit tapering](https://pennylane.ai/qml/demos/tutorial_qubit_tapering)

[Adaptive circuits for quantum chemistry](https://pennylane.ai/qml/demos/tutorial_adaptive_circuits)

[Modelling chemical reactions on a quantum computer](https://pennylane.ai/qml/demos/tutorial_chemical_reactions)

[How to quantum just-in-time compile VQE with Catalyst](https://pennylane.ai/qml/demos/tutorial_how_to_quantum_just_in_time_compile_vqe_catalyst)

[Differentiable Hartree-Fock](https://pennylane.ai/qml/demos/tutorial_differentiable_HF)

[Givens rotations for quantum chemistry](https://pennylane.ai/qml/demos/tutorial_givens_rotations)

[VQE in different spin sectors](https://pennylane.ai/qml/demos/tutorial_vqe_spin_sectors)

[Seeing quantum phase transitions with quantum computers](https://pennylane.ai/qml/demos/tutorial_quantum_phase_transitions)

[Optimization of molecular geometries](https://pennylane.ai/qml/demos/tutorial_mol_geo_opt)

[How to use Catalyst with Lightning-GPU](https://pennylane.ai/qml/demos/how_to_catalyst_lightning_gpu)
