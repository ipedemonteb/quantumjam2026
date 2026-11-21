# Scale SQD chemistry workflows with Fulqrum

> Fuente: <https://github.com/Qiskit/qiskit-addon-sqd/blob/main/docs/guides/integrate_fulqrum.ipynb>

[Fulqrum](https://github.com/Qiskit/fulqrum) is a software package that computes eigenvalues and eigenvectors of Hamiltonians projected into a subspace. It constructs a portable representation of the projected Hamiltonian that you can pass to an eigenvalue solver of your choice, including standard off-the-shelf solvers. These solvers can provide a much faster alternative to the default PySCF solver that the SQD addon uses for diagonalization. For information on how to install and use Fulqrum, see the [Fulqrum documentation](https://qiskit.github.io/fulqrum/).

Fulqrum's `addon_sqd_support` module builds a solver that [`diagonalize_fermionic_hamiltonian`](../apidocs/qiskit_addon_sqd.fermion.rst) accepts directly, so you pass the same integrals to both and Fulqrum handles the projection and diagonalization.

For more details on the SQD code used in this example, see the [chemistry Hamilton tutorial](https://quantum.cloud.ibm.com/docs/tutorials/sample-based-quantum-diagonalization).

## Use a different eigensolver

Because Fulqrum exposes the projected Hamiltonian as a standard [`scipy.sparse.linalg.LinearOperator`](https://docs.scipy.org/doc/scipy/reference/generated/scipy.sparse.linalg.LinearOperator.html), you can diagonalize it with any eigensolver of your choosing rather than being tied to `scipy.sparse.linalg.eigsh`. This makes it straightforward to substitute a solver that is better suited to your problem size or hardware.

Pass the eigensolver you want as the `eigensolver` argument. As an example, this guide demonstrates [PRIMME](https://github.com/primme/primme), a high-performance eigensolver library. Its Python interface, `primme.eigsh`, follows a calling convention similar to `scipy.sparse.linalg.eigsh`, so you can use it as a direct replacement.
