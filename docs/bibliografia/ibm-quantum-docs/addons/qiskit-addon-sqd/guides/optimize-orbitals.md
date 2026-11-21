# Improve an SQD estimate with orbital optimization

> Fuente: <https://github.com/Qiskit/documentation/tree/main/docs/addons/qiskit-addon-sqd/guides/optimize-orbitals>

Sample-based quantum diagonalization (SQD) approximates a ground-state energy by
diagonalizing the Hamiltonian in a fixed subspace of electronic configurations. That
estimate depends on the orbital basis in which the Hamiltonian is expressed, and
*orbital optimization* (OO) exploits this freedom to lower the energy without enlarging
the subspace.

This guide runs SQD on an $N_2$ molecule and then improves the result with orbital
optimization, using [`ffsim`](https://qiskit-community.github.io/ffsim/) to represent
the Hamiltonian and find the energy-minimizing orbital rotation.

## Run SQD

We build the molecular integrals for $N_2$ in the molecular-orbital (MO) basis, generate
uniform random samples, and run SQD to obtain a ground-state approximation.

## Optimize the orbitals

Orbital optimization searches for an orbital rotation that lowers the variational energy

$$
E = \langle \psi | \mathcal{U}^\dagger\, H\, \mathcal{U} | \psi \rangle
$$

of the SQD ground-state approximation $|\psi\rangle$. An orbital rotation is specified by
an $N \times N$ unitary matrix $\mathbf{U}$ ($N$ is the number of spatial orbitals), which
acts on the many-body state through the operator

$$
\mathcal{U} = \exp\left[\sum_{pq, \sigma} \log(\mathbf{U})_{pq}\, a^\dagger_{p\sigma} a_{q\sigma}\right].
$$

`ffsim.optimize_orbitals` returns the **matrix** $\mathbf{U}$, and applying it to the
orbital basis (via `hamiltonian.rotated`) is equivalent to applying $\mathcal{U}$ to the
state. See the
[ffsim orbital-rotation explanation](https://qiskit-community.github.io/ffsim/explanations/orbital-rotation.html)
for details.

Since rotating the orbitals changes the Hamiltonian seen by the subspace, we alternate
two steps until the energy stops improving:

1. **Diagonalize** the Hamiltonian in the current basis over the fixed set of
   configurations.
2. **Optimize the orbitals** by finding the rotation that minimizes the energy of the
   resulting state, then rotate the integrals into the new basis.

We delegate the orbital-rotation step to
[`ffsim.optimize_orbitals`](https://qiskit-community.github.io/ffsim/api/ffsim.html#ffsim.optimize_orbitals),
which finds the energy-minimizing rotation from the one- and two-body reduced density
matrices (RDMs) of the state. See
[Sec. II A 4](https://arxiv.org/pdf/2405.05068) for details.

### Why orbital optimization helps here

The SCF molecular-orbital (MO) basis is stationary with respect to orbital rotations
for the *full*-CI problem. But SQD works in a small truncated subspace (here a few
hundred CI strings out of roughly 19 million full-CI determinants), for which the MO
basis is generally not optimal, so rotating the orbitals lowers the energy the subspace
can represent.

### Alternate diagonalization and orbital optimization

We keep the diagonalization subspace **fixed** to the configurations discovered by SQD
above, so that each iteration isolates the effect of rotating the orbitals. Each
iteration:

1. **Diagonalizes** the Hamiltonian over the fixed subspace in the current basis, using
   PySCF's selected-CI solver.
2. **Builds the RDMs** of the resulting state, which is all `ffsim.optimize_orbitals`
   needs.
3. **Optimizes the orbitals**: `ffsim.optimize_orbitals` returns the energy-minimizing
   rotation, which we apply to the integrals to move into the improved basis.

We record the energy *before* each optimization step. Because the basis improves every
iteration, this sequence decreases monotonically toward the best energy achievable in
the fixed subspace.

### Compare the results

Orbital optimization improves the fixed-subspace estimate, closing much of the gap to
the exact energy while staying above it.
