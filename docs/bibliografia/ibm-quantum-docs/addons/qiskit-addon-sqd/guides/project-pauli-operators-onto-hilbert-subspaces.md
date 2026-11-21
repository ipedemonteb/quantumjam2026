# Project Pauli operators onto Hilbert subspaces

> Fuente: <https://github.com/Qiskit/documentation/tree/main/docs/addons/qiskit-addon-sqd/guides/project-pauli-operators-onto-hilbert-subspaces>

We show different ways of projecting a weighted linear combination of Pauli strings
into a subspace defined by a subset of size $d$ computational basis states. The
projected operator is stored as a $d \times d$ ``scipy.sparse.coo_matrix``.

As an example, we consider the Hamiltonian of the one-dimensional Heisenberg model with periodic
boundary conditions and $L = 22$ spins:
$$
H = \sum_{\langle i, j \rangle}\left( \sigma^x_i\sigma^x_j + \sigma^y_i\sigma^y_j + \sigma^z_i\sigma^z_j \right).
$$

This package provides two tools to perform this projection:

- ``qiskit_addon_sqd.qubit.matrix_elements_from_pauli()``: a lower-level function that returns the non-zero matrix elements of a Pauli string and the corresponding indices of the non-zero elements.

- ``qiskit_addon_sqd.qubit.project_operator_to_subspace()``: a higher-level function that directly returns a ``scipy.sparse`` matrix.

This guide shows how to use these two tools to produce the same sparse operator.

### Subspace definition

For this example we generate length-22 random bitstrings. For the projection
functions to work as expected, it is essential that the bitstrings that define
the subspace are unique and sorted in ascending order according to their unsigned
integer representation.

This can be achieved with the ``qiskit_addon_sqd.qubit.sort_and_remove_duplicates()``
function.

### First method: nonzero matrix elements and indices

### Higher-level implementation

Check that both implementations yield the same `coo_matrix`:
