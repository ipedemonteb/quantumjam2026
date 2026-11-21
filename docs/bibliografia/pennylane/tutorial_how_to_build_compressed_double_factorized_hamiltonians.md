# How to build compressed double-factorized Hamiltonians

> Fuente: <https://pennylane.ai/qml/demos/tutorial_how_to_build_compressed_double_factorized_hamiltonians>

[Utkarsh Azad](https://pennylane.ai/profile/whatsis)

Published: March 05, 2025. Last updated: July 22, 2026.

Compressed double factorization offers a powerful approach to overcome key limitations in
quantum chemistry simulations. Specifically, it tackles the runtime’s dependency on the
Hamiltonian’s one-norm and the shot requirements linked to the number of terms [[1]](#cdf).
In this tutorial, we will learn how to construct the electronic Hamiltonian in the compressed
double-factorized form using tensor contractions. We will also show how this technique allows
having a linear combination of unitaries (LCU) representation suitable for error-corrected
algorithms, which facilitates efficient simulations via linear-depth circuits with
[Givens rotations](https://arxiv.org/abs/1711.04789).

## Constructing the electronic Hamiltonian

The Hamiltonian of a molecular system in the second-quantized form can be expressed as a
sum of the one-body and two-body terms as follows:

\[H = \mu + \sum\_{\sigma, pq} h\_{pq} a^\dagger\_{\sigma, p} a\_{\sigma, q} + \frac{1}{2} \sum\_{\sigma \tau, pqrs} g\_{pqrs} a^\dagger\_{\sigma, p} a^\dagger\_{\tau, q} a\_{\tau, r} a\_{\sigma, s},\]

where the tensors \(h\_{pq}\) and \(g\_{pqrs}\) are the one- and two-body integrals,
\(a^\dagger\) and \(a\) are the creation and annihilation operators, \(\mu\) is the
nuclear repulsion energy constant, \(\sigma \in {\uparrow, \downarrow}\) represents the spin,
and \(p, q, r, s\) are the orbital indices. In PennyLane, we can obtain \(\mu\),
\(h\_{pq}\) and \(g\_{pqrs}\) using the [`electron_integrals()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.qchem.electron_integrals.html#pennylane.qchem.electron_integrals "(in PennyLane v0.45)") function:

```python
import pennylane as qp
import numpy as np

import warnings
warnings.filterwarnings(action="ignore", category=np.exceptions.ComplexWarning)

symbols = ["H", "H", "H", "H"]
geometry = qp.math.array([[0., 0., -0.2], [0., 0., -0.1], [0., 0., 0.1], [0., 0., 0.2]])

mol = qp.qchem.Molecule(symbols, geometry)
nuc_core, one_body, two_body = qp.qchem.electron_integrals(mol)()

print(f"One-body and two-body tensor shapes: {one_body.shape}, {two_body.shape}")
```

```python
One-body and two-body tensor shapes: (4, 4), (4, 4, 4, 4)
```

In the above expression of \(H\), the two-body tensor \(g\_{pqrs}\)
can be rearranged to define \(V\_{pqrs}\) in the [chemist notation](http://vergil.chemistry.gatech.edu/notes/permsymm/permsymm.pdf),
which leads to a one-body offset term \(\sum\_{s} V\_{pssq}\). This
allows us to rewrite the Hamiltonian as:

\[H\_{\text{C}} = \mu + \sum\_{\sigma \in {\uparrow, \downarrow}} \sum\_{pq} T\_{pq} a^\dagger\_{\sigma, p} a\_{\sigma, q} + \sum\_{\sigma, \tau \in {\uparrow, \downarrow}} \sum\_{pqrs} V\_{pqrs} a^\dagger\_{\sigma, p} a\_{\sigma, q} a^\dagger\_{\tau, r} a\_{\tau, s},\]

with the transformed one-body terms \(T\_{pq} = h\_{pq} - 0.5 \sum\_{s} g\_{pqss}\).
We can obtain the \(V\_{pqrs}\) and \(T\_{pq}\) tensors as:

```python
two_chem = 0.5 * qp.math.swapaxes(two_body, 1, 3)  # V_pqrs
one_chem = one_body - 0.5 * qp.math.einsum("pqss", two_body)  # T_pq
```

A key feature of this representation is that the modified two-body terms can be factorized
into a sum of low-rank terms, which can be used to efficiently simulate the Hamiltonian [[2]](#cdf2).
We will see how to do this with the double-factorization methods in the next section.

## Double factorizing the Hamiltonian

The double factorization of a Hamiltonian can be described as a Hamiltonian manipulation
technique based on decomposing \(V\_{pqrs}\) into symmetric tensors \(L^{(t)}\)
called *factors*, such that \(V\_{pqrs} = \sum\_t^T L\_{pq}^{(t)} L\_{rs}^{(t) {\dagger}}\)
and the rank \(T \leq N^2\), where \(N\) is the number of orbitals. We can do this
by performing an eigenvalue or a pivoted Cholesky decomposition of the modified two-body
tensor. Moreover, each of the \(L^{(t)}\) can be further eigendecomposed as
\(L^{(t)}\_{pq} = \sum\_{i} U\_{pi}^{(t)} W\_i^{(t)} U\_{qi}^{(t)}\) to perform a second
tensor factorization. This enables us to express the two-body tensor \(V\_{pqrs}\) in
the following double-factorized form in terms of orthonormal core tensors \(Z^{(t)}\)
and symmetric leaf tensors \(U^{(t)}\) [[2]](#cdf2):

\[V\_{pqrs} \approx \sum\_t^T \sum\_{ij} U\_{pi}^{(t)} U\_{qi}^{(t)} Z\_{ij}^{(t)} U\_{rj}^{(t)} U\_{sj}^{(t)},\]

where \(Z\_{ij}^{(t)} = W\_i^{(t)} W\_j^{(t)}\). This decomposition is referred
to as the *explicit* double factorization (XDF) and decreases the number of terms
in the qubit basis from \(O(N^4)\) to \(O(N^3)\), assuming the rank of the
second tensor factorization to be \(O(N)\). In PennyLane, this can be done using the
[`factorize()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.qchem.factorize.html#pennylane.qchem.factorize "(in PennyLane v0.45)") function, where one can choose the decomposition method for
the first tensor factorization (`cholesky`), truncate the resulting factors by discarding
the ones with individual contributions below a specified threshold (`tol_factor`), and
optionally control the ranks of their second factorization (`tol_eigval`) as shown below:

```python
factors, _, _ = qp.qchem.factorize(two_chem, cholesky=True, tol_factor=1e-5)
print("Shape of the factors: ", factors.shape)

approx_two_chem = qp.math.tensordot(factors, factors, axes=([0], [0]))
assert qp.math.allclose(approx_two_chem, two_chem, atol=1e-5)
```

```python
Shape of the factors:  (10, 4, 4)
```

## Performing block-invariant symmetry shift

We can further improve the double-factorization by employing the block-invariant
symmetry shift (BLISS) technique, which modifies the Hamiltonian’s action on the
undesired electron-number subspace [[3]](#bliss). It helps decrease the one-norm and
the spectral range of the Hamiltonian. In PennyLane, this symmetry shift can be
done using the [`symmetry_shift()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.qchem.symmetry_shift.html#pennylane.qchem.symmetry_shift "(in PennyLane v0.45)") function, which returns
the symmetry-shifted integral tensors and core constant:

```python
core_shift, one_shift, two_shift = qp.qchem.symmetry_shift(
    nuc_core, one_chem, two_chem, n_elec = mol.n_electrons
) # symmetry-shifted terms of the Hamiltonian
```

Then we can use these shifted terms to obtain a double-factorized representation of
the Hamiltonian that has a lower one-norm than the original one. For instance, we can
compare the improvement in the one-norm of the shifted Hamiltonian over the original one
by accessing the [`DoubleFactorization`](https://docs.pennylane.ai/en/stable/code/api/pennylane.estimator.qpe_resources.DoubleFactorization.html#pennylane.estimator.qpe_resources.DoubleFactorization "(in PennyLane v0.45)")’s `lamb` attribute:

```python
from pennylane.estimator.qpe_resources import DoubleFactorization as DF

DF_chem_norm = DF(one_chem, two_chem, chemist_notation=True).lamb
DF_shift_norm =  DF(one_shift, two_shift, chemist_notation=True).lamb
print(f"Decrease in one-norm: {DF_chem_norm - DF_shift_norm}")
```

```python
Decrease in one-norm: 0.6545730540098926
```

## Compressing the double factorization

In many practical scenarios, the double factorization method can be further optimized by
performing a numerical tensor-fitting of the decomposed two-body terms to obtain \(V^\prime\)
such that the approximation error \(||V - V^\prime||\) remains below a desired threshold
[[1]](#cdf). This is referred to as the *compressed* double factorization (CDF) as it reduces the
number of terms in the factorization of the two-body term from \(O(N^3)\) to \(O(N)\)
and achieves lower approximation errors than the truncated XDF. Compression can be done by
beginning with \(O(N)\) random core and leaf tensors and optimizing them based on the
following cost function \(\mathcal{L}\) in a greedy manner:

\[\mathcal{L}(U, Z) = \frac{1}{2} \bigg|V\_{pqrs} - \sum\_t^T \sum\_{ij} U\_{pi}^{(t)} U\_{pj}^{(t)} Z\_{ij}^{(t)} U\_{qk}^{(t)} U\_{ql}^{(t)}\bigg|\_{\text{F}} + \rho \sum\_t^T \sum\_{ij} \bigg|Z\_{ij}^{(t)}\bigg|^{\gamma},\]

where \(|\cdot|\_{\text{F}}\) denotes the Frobenius norm, \(\rho\) is a constant
scaling factor, and \(|\cdot|^\gamma\) specifies the optional L1 and L2 [regularization](https://en.wikipedia.org/wiki/Regularization_(mathematics)#L1_and_L2_Regularization)
that improves the energy variance of the resulting representation. In PennyLane, this
compression can be done by using the `compressed=True` keyword argument in the
[`factorize()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.qchem.factorize.html#pennylane.qchem.factorize "(in PennyLane v0.45)") function. The regularization term will be included
if the `regularization` keyword argument is set to either `"L1"` or `"L2"`:

```python
_, two_body_cores, two_body_leaves = qp.qchem.factorize(
    two_shift, tol_factor=1e-2, cholesky=True, compressed=True, regularization="L2"
) # compressed double-factorized shifted two-body terms with "L2" regularization
print(f"Two-body tensors' shape: {two_body_cores.shape, two_body_leaves.shape}")

approx_two_shift = qp.math.einsum(
    "tpk,tqk,tkl,trl,tsl->pqrs",
    two_body_leaves, two_body_leaves, two_body_cores, two_body_leaves, two_body_leaves
) # computing V^\prime and comparing it with V below
assert qp.math.allclose(approx_two_shift, two_shift, atol=1e-2)
```

```python
Two-body tensors' shape: ((6, 4, 4), (6, 4, 4))
```

While the previous shape output for the factors `(10, 4, 4)` meant we had \(10\) two-body
terms in our factorization, the current shape output `(6, 4, 4)` indicates that we have
\(6\) terms. This means that the number of terms in the factorization has decreased almost
by half, which is quite significant!

## Constructing the double-factorized Hamiltonian

We can eigendecompose the one-body tensor to obtain similar orthonormal \(U^{(0)}\) and
symmetric \(Z^{(0)}\) tensors for the one-body term and use the compressed factorization
of the two-body term described in the previous section to express the Hamiltonian in the
double-factorized form as:

\[H\_{\text{CDF}} = \mu + \sum\_{\sigma \in {\uparrow, \downarrow}} U^{(0)}\_{\sigma} \left( \sum\_{p} Z^{(0)}\_{p} a^\dagger\_{\sigma, p} a\_{\sigma, p} \right) U\_{\sigma}^{(0)\ \dagger} + \sum\_t^T \sum\_{\sigma, \tau \in {\uparrow, \downarrow}} U\_{\sigma, \tau}^{(t)} \left( \sum\_{pq} Z\_{pq}^{(t)} a^\dagger\_{\sigma, p} a\_{\sigma, p} a^\dagger\_{\tau, q} a\_{\tau, q} \right) U\_{\sigma, \tau}^{(t)\ \dagger}.\]

This Hamiltonian can be easily mapped to the qubit basis via [Jordan-Wigner transformation](https://pennylane.ai/demos/tutorial_mapping.html "(in PennyLane vNone)") (JWT) using
\(a\_p^\dagger a\_p = n\_p \mapsto 0.5 \* (1 - z\_p)\), where \(n\_p\) is the number
operator and \(z\_p\) is the Pauli-Z operation acting on the qubit corresponding to
orbital \(p\). The mapped form naturally gives rise to a measurement grouping, where
the terms within the basis transformation \(U^{(i)}\) can be measured simultaneously.
These can be obtained with the [`basis_rotation()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.qchem.basis_rotation.html#pennylane.qchem.basis_rotation "(in PennyLane v0.45)") function, which
performs the double-factorization and JWT automatically.

Another advantage of the double-factorized form is the efficient simulation of the Hamiltonian
evolution. Before discussing it in the next section, we note that mapping a two-body term to
the qubit basis will result in two additional one-qubit Pauli-Z terms. We can simplify their
simulation circuits by accounting for these additional terms directly in the one-body tensor
using a correction `one_body_extra`. We can then decompose the corrected one-body terms into
the orthonormal \(U^{\prime(0)}\) and symmetric \(Z^{\prime(0)}\) tensors instead:

```python
two_core_prime = (qp.math.eye(mol.n_orbitals) * two_body_cores.sum(axis=-1)[:, None, :])
one_body_extra = qp.math.einsum(
    'tpk,tkk,tqk->pq', two_body_leaves, two_core_prime, two_body_leaves
) # one-body correction

# factorize the corrected one-body tensor to obtain the core and leaf tensors
one_body_eigvals, one_body_eigvecs = qp.math.linalg.eigh(one_shift + one_body_extra)
one_body_cores = qp.math.expand_dims(qp.math.diag(one_body_eigvals), axis=0)
one_body_leaves = qp.math.expand_dims(one_body_eigvecs, axis=0)

print(f"One-body tensors' shape: {one_body_cores.shape, one_body_leaves.shape}")
```

```python
One-body tensors' shape: ((1, 4, 4), (1, 4, 4))
```

We can now specify the Hamiltonian programmatically in the (compressed)
double-factorized form as a `dict` object with the following three keys:
`nuc_constant` (\(\mu\)),
`core_tensors` (\(\left[ Z^{\prime(0)}, Z^{(t\_1)}, \ldots, Z^{(t\_T)} \right]\)), and
`leaf_tensors` (\(\left[ U^{\prime(0)}, U^{(t\_1)}, \ldots, U^{(t\_T)} \right]\)):

```python
cdf_hamiltonian = {
    "nuc_constant": core_shift[0],
    "core_tensors": qp.math.concatenate((one_body_cores, two_body_cores), axis=0),
    "leaf_tensors": qp.math.concatenate((one_body_leaves, two_body_leaves), axis=0),
} # CDF Hamiltonian
```

## Simulating the double-factorized Hamiltonian

To simulate the time evolution of the CDF Hamiltonian,
we will first need to learn how to apply the unitary operations
represented by the exponentiated leaf and core tensors. The former can be done using the
[`BasisRotation`](https://docs.pennylane.ai/en/stable/code/api/pennylane.BasisRotation.html#pennylane.BasisRotation "(in PennyLane v0.45)") operation, which implements the unitary transformation
\(\exp \left( \sum\_{pq}[\log U]\_{pq} (a^\dagger\_p a\_q - a^\dagger\_q a\_p) \right)\)
using the [Givens rotation networks](https://docs.pennylane.ai/en/stable/code/api/pennylane.math.decomposition.givens_decomposition.html)
that can be efficiently implemented on quantum hardware. The `leaf_unitary_rotation`
function below does this for a leaf tensor:

```python
def leaf_unitary_rotation(leaf, wires):
    """Applies the basis rotation transformation corresponding to the leaf tensor."""
    basis_mat = qp.math.kron(leaf, qp.math.eye(2)) # account for spin
    qp.BasisRotation(unitary_matrix=basis_mat, wires=wires)
```

Similarly, the unitary transformation for the core tensors can be applied efficiently
via the `core_unitary_rotation` function defined below. The function uses the
[`RZ`](https://docs.pennylane.ai/en/stable/code/api/pennylane.RZ.html#pennylane.RZ "(in PennyLane v0.45)") and [`IsingZZ`](https://docs.pennylane.ai/en/stable/code/api/pennylane.IsingZZ.html#pennylane.IsingZZ "(in PennyLane v0.45)") gates for implementing
the diagonal and entangling phase rotations for the one- and two-body core tensors,
respectively, and [`GlobalPhase`](https://docs.pennylane.ai/en/stable/code/api/pennylane.GlobalPhase.html#pennylane.GlobalPhase "(in PennyLane v0.45)") for the corresponding global phases:

```python
import itertools as it

def core_unitary_rotation(core, body_type, wires):
    """Applies the unitary transformation corresponding to the core tensor."""
    if body_type == "one_body":  # implements one-body term
        for wire, cval in enumerate(qp.math.diag(core)):
            for sigma in [0, 1]:
                qp.RZ(-cval, wires=2 * wire + sigma)
        qp.GlobalPhase(qp.math.sum(core), wires=wires)

    if body_type == "two_body":  # implements two-body term
        for odx1, odx2 in it.product(range(len(wires) // 2), repeat=2):
            cval = core[odx1, odx2] / 4.0
            for sigma, tau in it.product(range(2), repeat=2):
                if odx1 != odx2 or sigma != tau:
                    qp.IsingZZ(cval, wires=[2*odx1+sigma, 2*odx2+tau])
        gphase = 0.5 * qp.math.sum(core) - 0.25 * qp.math.trace(core)
        qp.GlobalPhase(-gphase, wires=wires)
```

We can now use these functions to approximate the evolution operator \(e^{-iHt}\) for
a time \(t\) with the Suzuki-Trotter product formula, which uses symmetrized products
\(S\_m\) defined for an order \(m \in [1, 2, 4, \ldots, 2k \in \mathbb{N}]\)
and repeated multiple times [[4]](#trotter). In general, this can be easily implemented for
standard non-factorized Hamiltonians using the [`TrotterProduct`](https://docs.pennylane.ai/en/stable/code/api/pennylane.TrotterProduct.html#pennylane.TrotterProduct "(in PennyLane v0.45)") operation,
which defines these products recursively, leading to an exponential scaling in its complexity
with the number of terms in the Hamiltonian and making it inefficient for larger system sizes.

The exponential scaling can be improved to a great extent by working with the compressed
double-factorized form of the Hamiltonian as it allows reducing the number of terms in the
Hamiltonian from \(O(N^4)\) to \(O(N)\). While doing this is not directly supported
in PennyLane in the form of a template, we can still implement the first-order Trotter
step using the following `CDFTrotterStep()` function that uses the CDF Hamiltonian
with the `leaf_unitary_rotation` and `core_unitary_rotation` functions defined earlier.
We can then use the [`trotterize()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.trotterize.html#pennylane.trotterize "(in PennyLane v0.45)") function to implement any higher-order
Suzuki-Trotter products. It is crucial to wrap these steps in [`prod()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.prod.html#pennylane.prod "(in PennyLane v0.45)"); this ensures
the sequence of operators are preserved as a single block which prevents
[`trotterize()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.trotterize.html#pennylane.trotterize "(in PennyLane v0.45)") from re-ordering or reversing the internal terms.

```python
@qp.prod
def block(time, leaf, core, body_type, wires):
    # apply the basis rotation for leaf tensor
    leaf_unitary_rotation(leaf, wires)
    # apply the rotation for core tensor scaled by the time-step
    core_unitary_rotation(time * core, body_type, wires)
    # revert the change-of-basis for leaf tensor
    leaf_unitary_rotation(leaf.conjugate().T, wires)

def CDFTrotterStep(time, cdf_ham, wires):
    """Implements a first-order Trotter step for a CDF Hamiltonian.

    Args:
        time (float): time-step for a Trotter step.
        cdf_ham (dict): dictionary describing the CDF Hamiltonian.
        wires (list): list of integers representing the qubits.
    """
    cores, leaves = cdf_ham["core_tensors"], cdf_ham["leaf_tensors"]
    for bidx, (core, leaf) in enumerate(zip(cores, leaves)):
        # Note: only the first term is one-body, others are two-body
        body_type = "two_body" if bidx else "one_body"
        block(time, leaf, core, body_type, wires)
```

We now use this function to simulate the evolution of the \(H\_4\) Hamiltonian
described in the compressed double-factorized form for a given number of
steps `n_steps` and starting from a Hartree-Fock state `hf_state`
with the following circuit that applies a second-order Trotter product:

```python
time, circ_wires = 1.0, range(2 * mol.n_orbitals)
hf_state = qp.qchem.hf_state(electrons=mol.n_electrons, orbitals=len(circ_wires))

@qp.qnode(qp.device("lightning.qubit", wires=circ_wires))
def cdf_circuit(n_steps, order):
    qp.BasisState(hf_state, wires=circ_wires)
    qp.trotterize(CDFTrotterStep, n_steps, order)(time, cdf_hamiltonian, circ_wires)
    qp.GlobalPhase(cdf_hamiltonian["nuc_constant"], wires=circ_wires)
    return qp.state()

circuit_state = cdf_circuit(n_steps=10, order=2)
```

We now test the accuracy of the Hamiltonian simulation by evolving the
Hartree-Fock state analytically ourselves and testing the fidelity
of the `evolved_state` with the `circuit_state`:

```python
from pennylane.math import fidelity_statevector
from scipy.linalg import expm

# Evolve the state vector |0...0> to the |HF> state of the system
init_state = qp.math.array([1] + [0] * (2**len(circ_wires) - 1))
hf_state_vec = qp.matrix(qp.BasisState(hf_state, wires=circ_wires)) @ init_state

H = qp.qchem.molecular_hamiltonian(mol)[0] # original Hamiltonian
evolved_state = expm(-1j * qp.matrix(H) * time) @ hf_state_vec # e^{-iHt} @ |HF>

print(f"Fidelity of two states: {fidelity_statevector(circuit_state, evolved_state)}")
```

```python
Fidelity of two states: 0.998041507415773
```

As we can see, the fidelity of the evolved state from the circuit is close to
\(1.0\), which indicates that the evolution of the CDF Hamiltonian sufficiently
matches that of the original one.

## Conclusion

Compressed double-factorized representation for the Hamiltonians serves three key purposes.
First, it provides for a more compact representation of the Hamiltonian that can be stored
and manipulated easier. Second, it allows more efficient simulations of the Hamiltonian
time evolution because the number of terms is reduced quadratically. Third, the compact
representation can be further manipulated to reduce the one-norm of the Hamiltonian, which
helps reduce the simulation cost when using block encoding or qubitization techniques.
Overall, employing CDF-based Hamiltonians for quantum chemistry problems provides a
relatively promising path to reducing the complexity of fault-tolerant quantum algorithms.

## References

[1]
([1](#id1),[2](#id5))

Oumarou Oumarou, Maximilian Scheurer, Robert M. Parrish, Edward G. Hohenstein, and Christian Gogolin,
“Accelerating Quantum Computations of Chemistry Through Regularized Compressed Double Factorization”,
[Quantum 8, 1371](https://doi.org/10.22331/q-2024-06-13-1371), 2024.

[2]
([1](#id2),[2](#id3))

Jeffrey Cohn, Mario Motta, and Robert M. Parrish,
“Quantum Filter Diagonalization with Compressed Double-Factorized Hamiltonians”,
[PRX Quantum 2, 040352](https://journals.aps.org/prxquantum/abstract/10.1103/PRXQuantum.2.040352), 2021.

[[3](#id4)]

Ignacio Loaiza, and Artur F. Izmaylov,
“Block-Invariant Symmetry Shift: Preprocessing technique for second-quantized Hamiltonians to improve their decompositions to Linear Combination of Unitaries”,
[arXiv:2304.13772](https://arxiv.org/abs/2304.13772), 2023.

[[4](#id6)]

Sergiy Zhuk, Niall Robertson, and Sergey Bravyi,
“Trotter error bounds and dynamic multi-product formulas for Hamiltonian simulation”,
[arXiv:2306.12569](https://arxiv.org/abs/2306.12569), 2023.

## About the author

[Utkarsh Azad](https://pennylane.ai/profile/whatsis)

Utkarsh is a quantum physicist and computer scientist. He currently works as a senior quantum scientist at Xanadu. When he's not untangling qubits there, you'll find him observing fractals and writing poetry.

**Total running time of the script:** (0 minutes 11.602 seconds)

Share demo

[Ask a question on the forum](https://discuss.pennylane.ai/c/demos/25)

### Related Demos

[Building molecular Hamiltonians](https://pennylane.ai/qml/demos/tutorial_quantum_chemistry)

[Fermionic operators](https://pennylane.ai/qml/demos/tutorial_fermionic_operators)

[X-ray absorption spectroscopy simulation in the time-domain](https://pennylane.ai/qml/demos/tutorial_xas)

[Resource estimation for quantum chemistry](https://pennylane.ai/qml/demos/tutorial_resource_estimation)

[Efficient simulation of Clifford circuits](https://pennylane.ai/qml/demos/tutorial_clifford_circuit_simulations)

[How to track algorithmic error using PennyLane](https://pennylane.ai/qml/demos/tutorial_error_prop)

[Compilation of quantum circuits](https://pennylane.ai/qml/demos/tutorial_circuit_compilation)

[Introducing tensor networks for quantum practitioners](https://pennylane.ai/qml/demos/tutorial_tensor_network_basics)

[Quantum teleportation](https://pennylane.ai/qml/demos/tutorial_teleportation)

[Estimating observables with classical shadows in the Pauli basis](https://pennylane.ai/qml/demos/tutorial_diffable_shadows)
