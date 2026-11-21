# Quickstart

> Fuente: <https://github.com/Qiskit/documentation/tree/main/docs/addons/qiskit-addon-sqd/guides/quickstart>

This guide demonstrates a minimal working example of the `qiskit-addon-sqd` package. We use sample-based quantum diagonalization (SQD) to refine noisy samples taken from a quantum circuit that approximates the ground state of a chemistry Hamiltonian. Ground state energies are approximated by diagonalizing the Hamiltonian in subspaces formed by the refined samples.

For more explanatory end-to-end workflows that run on quantum hardware, check out the tutorials:

* [Sample-based quantum diagonalization](https://quantum.cloud.ibm.com/docs/tutorials/sample-based-quantum-diagonalization): chemistry Hamiltonian workflow
* [Sample-based Krylov quantum diagonalization](https://quantum.cloud.ibm.com/docs/tutorials/sample-based-krylov-quantum-diagonalization): fermionic lattice model workflow

## 1. Prepare the inputs for SQD

First, we define the chemistry Hamiltonian and quantum circuit that approximates its ground state. The system studied in this example is N₂ at equilibrium geometry in STO-3G basis with two core orbitals frozen. This system has ``8`` spatial orbitals and ``10`` electrons, which means the quantum circuit is defined on ``16`` qubits, where qubits ``0-7`` represent spin-up orbitals and qubits ``8-15`` represent spin-down orbitals. Since this is a closed-shell system with ``10`` electrons, we know each physically-valid sample should have hamming weight ``10``, where the hamming weight of both the left and right halves of the bitstring is ``5``.

## 2. Generate noisy samples

In a real workflow you would design an ansatz circuit, optimize it for hardware, and sample it on the QPU. Here we skip that and draw ``10,000`` uniformly random bitstrings instead. While our samples contain no information about the actual ground state, we will see that the SQD protocol can still recover the true ground state by iteratively refining these samples, diagonalizing, and using the energies at each iteration to inform the next round of bitstring refinement. We can eventually recover the exact ground state in this manner because the subspace containing the ground state is small enough to calculate exactly. Specifically, since we know each half of each bitstring (``8`` bits) should have hamming weight ``5``, we know the full Hilbert subspace of the system is size $\binom{8}{5}^2=3136$.

## 3. Post-process with SQD

The objective of the SQD algorithm is to refine noisy samples taken from a QPU and ultimately diagonalize the Hamiltonian in a subspace spanned by those refined samples. This is done iteratively as follows:

- Refine samples by postselecting only those which have correct particle number for both the spin-up and spin-down subsystems
- Diagonalize in small subspaces spanned by the refined samples and collect information about the subspaces that yield the the best (lowest) energies.
- For each iteration:
    - Refine the noisy samples by probabilistically flipping bits in samples with incorrect particle number. The probabilities are calculated using the subspace information from the most recent diagonalization.
    - Diagonalize in small subspaces spanned by the refined samples
    - Collect information about the subspaces yielding the best (lowest) energies

We can see from the output that the algorithm converges to the exact ground state energy after ``6`` iterations and that the diagonalization is performed over the full Hilbert subspace of dimension $\binom{8}{5}^2=3136$. Of course, diagonalizing over the full subspace is usually not feasible, and therefore, systems with ground states having sparse support are the most likely to benefit from subspace diagonalization techniques such as SQD.

For more information on the diagonalize_fermionic_hamiltonian function, visit the [API docs](https://quantum.cloud.ibm.com/docs/api/qiskit-addon-sqd/fermion#diagonalize_fermionic_hamiltonian).
