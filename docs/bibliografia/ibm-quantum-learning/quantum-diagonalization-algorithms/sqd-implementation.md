# SQD for energy estimation of a chemistry Hamiltonian

> Fuente: <https://quantum.cloud.ibm.com/learning/en/courses/quantum-diagonalization-algorithms/sqd-implementation>

> Solo las celdas de texto del notebook original; sin código.


In this lesson, we will apply SQD to estimate the ground state energy of a molecule.

In particular, we will discuss the following topics using the $4$-step Qiskit pattern approach:

1. Step 1: Map problem to quantum circuits and operators
    - Setup the molecular Hamiltonian for $N_2$.
    - Explain the chemistry-inspired and hardware-friendly local unitary cluster Jastrow (LUCJ) [\[1\]](#references)
2. Step 2: Optimize for target hardware
    - Optimize gate counts and layout of the ansatz for hardware execution
3. Step 3: Execute on target hardware
    - Run the optimized circuit on a real QPU to generate samples of the subspace.
4. Step 4: Post-process results
    - Introduce the self-consistent configuration recovery loop [\[2\]](#references)
        - Post-process the full set of bitstring samples, using prior knowledge of particle number and the average orbital occupancy calculated on the most recent iteration.
        - Probabilistically create batches of subsamples from recovered bitstrings.
        - Project and diagonalize the molecular Hamiltonian over each sampled subspace.
        - Save the minimum ground state energy found across all batches and update the avg orbital occupancy.

We will use several software packages throughout the lesson.
- `PySCF` to define the molecule and setup the Hamiltonian.
- `ffsim` package to construct the LUCJ ansatz.
- `Qiskit` for transpiling the ansatz for hardware execution.
- `Qiskit IBM Runtime` to execute the circuit on a QPU and collect samples.
- `Qiskit addon SQD` configuration recovery and ground state energy estimation using subspace projection and matrix diagonalization.

## 1. Map problem to quantum circuits and operators

### Molecular Hamiltonian

A molecular Hamiltonian takes the generic form:

$$
\hat{H} = \sum_{ \substack{pr\\\sigma} } h_{pr} \, \hat{a}^\dagger_{p\sigma} \hat{a}_{r\sigma}
+
\sum_{ \substack{prqs\\\sigma\tau} }
\frac{(pr|qs)}{2} \,
\hat{a}^\dagger_{p\sigma}
\hat{a}^\dagger_{q\tau}
\hat{a}_{s\tau}
\hat{a}_{r\sigma}
$$

$\hat{a}^\dagger_{p\sigma}$/$\hat{a}_{p\sigma}$ are the fermionic creation/annihilation operators associated to the $p$-th basis set element and the spin $\sigma$. $h_{pr}$ and $(pr|qs)$ are the one- and two-body electronic integrals. Using pySCF, we will define the molecule and compute the one- and two-body integrals of the Hamiltonian for basis set `6-31g`.

In this lesson, we will use Jordan-Wigner (JW) transformation to map a fermionic wavefunction to a qubit wavefunction so that it can be prepared using a quantum circuit. The JW transformation maps the Fock space of fermions in M spatial orbitals onto the Hilbert space of 2M qubits, that is, a spatial orbital is split into two _spin orbitals_, one associated with a spin up ($\alpha$) electron and another with spin down ($\beta$). A spin orbital can be occupied or unoccupied. Usually, when we refer to number of orbitals, we will be using number of _spatial_ orbitals. The number of spin orbitals will be double. In quantum circuits, we will represent each spin orbital with one qubit. Thus, a set of qubits will represent spin-up or $\alpha$-orbitals, and another set will represent spin-down or $\beta$-orbitals. For example, $N_2$ molecule for `6-31g` basis set has $16$ spatial orbitals (that is, $16$ $\alpha$ + $16$ $\beta$ = $32$ spin orbitals). Thus, we will need a $32$-qubit quantum circuit (we may need extra ancilla qubits as discussed later). The qubits are measured in computational basis to generate bitstrings, which represent electronic configurations or (Slater) determinants. Throughout this lesson, we will use the terms bitstrings, configurations, and determinants interchangeably. The bitstrings tell us electron occupancy in spin orbitals: a $1$ in a bit position means the corresponding spin orbital is occupied, while a $0$ means the spin orbital is empty. As electronic s … [línea truncada]

### 1.1 Quantum circuit for sample generation: The LUCJ ansatz

In this lesson, we will use the local unitary coupled cluster Jastrow (LUCJ) [\\[1\\]](#references) ansatz for quantum state preparation and subsequent sampling. First, we will explain different building blocks of the full UCJ ansatz and the approximations made in the local version of it. Next, by using ffsim package, we will construct the LUCJ ansatz and optimize it using Qiskit transpiler for hardware execution.

The UCJ ansatz has the following form (for a product of $L$ layers or repetitions of the UCJ operator.)

$$
|\psi\rangle = \prod_{\mu=1}^{L}{(e^{K^{\mu}} \times {e^{iJ^{\mu}}} \times {e^{-K^{\mu}}})} |\Phi_{0}\rangle
$$

where, $\vert \Phi_{0} \rangle$ is a reference state, typically taken as the Hartree-Fock (HF) state. As the Hartree-Fock state is defined as having the lowest numbered orbitals occupied, the HF state preparation will involve applying X gates to set qubits corresponding to occupied orbitals to one. For example, the HF state preparation block for 4 spatial orbitals and 2 up- and 2 down-spin may look like the following:

A single repetition of the UCJ operator ${(e^{K^{(\mu)}} \times {e^{iJ^{(\mu)}}} \times {e^{-K^{(\mu)}}})}$ consists of a diagonal Coulomb evolution ($e^{iJ^{(\mu)}}$) sandwiched by orbital rotations ($e^{K^{(\mu)}}$ and $e^{-K^{(\mu)}}$).

Orbital rotation blocks work on a single spin species ($\alpha$ (up-spin)/$\beta$ (down-spin)). For each electron species, orbital rotation consists of a layer of single-qubit $R_{z}$ gates followed by a sequence of 2-qubit Given's rotation gates ($XX + YY$ gates).

The 2-qubit gates act on adjacent spin-orbitals (nearest neighbor qubits), and therefore, are implementable on IBM&reg; QPUs without the need for SWAP gates.

The $e^{iJ^{(\mu)}}$, also known as the diagonal Coulomb operator, consists of three blocks. Two of them work on same spin sectors ($e^{iJ_{\alpha \alpha}^{(\mu)}}$ and $e^{iJ_{\beta \beta}^{(\mu)}}$), and one works between two spin sectors ($e^{iJ_{\alpha \beta}^{(\mu)}}$).

All the blocks in $e^{iJ^{(\mu)}}$ consists of number-number gates $U_{nn}(\phi)$ [\[1\]](#references). A $U_{nn}(\phi)$ gate can be further broken down into a $R_{ZZ}(\frac{\phi}{2})$ gate followed by two single-qubit $Rz(-\frac{\phi}{2})$ gates acting on two separate qubits.

Same-spin components ($J_{\alpha \alpha}$ and $J_{\beta \beta}$) have $U_{nn}$ gates between all possible pairs of qubits. However, as superconducting QPUs have restrictive connectivity, qubits must be swapped to realize gates between non-adjacent qubits.

For example, consider the following $e^{iJ_{\alpha \alpha}^{(\mu)}}$ (or $e^{iJ_{\beta \beta}^{(\mu)}}$) block for $N = 4$ spatial orbitals. For a linear qubit connectivity, the last three gates are not directly implementable as they work between non-adjacent qubits (for example, Q0 and Q2 are not directly connected). Therefore, we need SWAP gates to make them adjacent (following figure shows an example with $3$ SWAP gates).

Next, the $J_{\alpha \beta}$ implements gates between same indexed orbitals from different spin sectors (for example, between $0\alpha$ and $0\beta$). Similarly, if the qubits are not physically adjacent on a QPU, these gates will also require SWAPs.

From the above discussion, the UCJ ansatz faces some hurdles for HW execution as it needs SWAP gates due to non-adjacent qubit interactions. The local variant of the UCJ ansatz, LUCJ, addresses this challenge by removing some $U_{nn}$ from the diagonal Coulomb operator.

In the same electron species blocks, $J_{\alpha \alpha}$ and $J_{\beta \beta}$), we only keep the $U_{nn}$ gates compatible with nearest-neighbor connectivity and remove gates between non-adjacent qubits in the LUCJ version. Following figure shows the LUCJ block after removal of non-adjacent gates.

Next, the LUCJ version of the $J_{\alpha \beta}$ block that works between different electron species can take different shape based on the device topology.

Here, also, the LUCJ version gets rid of non-compatible gates. The figure below shows variants of the $J_{\alpha \beta}$ block for different qubit topology including grid, hexagonal, heavy-hex, and linear.

- **Square**: we can have $U_{nn}$ gates between all $\alpha$ and $\beta$ orbitals without any SWAPs, and therefore, do not need to remove any $U_{nn}$ gates.
- **Heavy-hex**: The $\alpha$-$\beta$ interactions are kept between every $4$-th indexed (such as the 0th, 4th, and 8th) spin orbitals and are _ancilla_ mediated, that is, we need ancilla qubits between the linear chains representing $\alpha$ and $\beta$ orbitals. This arrangement needs a limited number of SWAPs.
- **Hexagonal**: Every other orbital, such as 0th, 2nd, and 4th indexed orbitals, becomes nearest neighbors when $\alpha$ and $\beta$ are laid out in two adjacent linear chains.
- **Linear**: Only one $\alpha$ and one $\beta$ orbital are connected, which means the $J_{\alpha \beta}$ block will have only one gate.

While removing gates from the UCJ ansatz to construct the LUCJ version makes it more HW compatible, the ansatz loses some expressivity. Therefore, more repetitions ($L$) of the modified UCJ operator may be needed when using the LUCJ ansatz.

### 1.2 LUCJ ansatz initialization

The LUCJ is a parameterized ansatz, and we need to initialize the parameters before hardware execution. One way to initialize ansatz is by using `t1` and `t2` amplitudes from classical coupled cluster singles and doubles (CCSD) method, where `t1` amplitudes are the coefficient of single excitation operators and `t2` amplitudes are for double excitation operators.

Note that while initializing the LUCJ ansatz with `t1` and `t2` amplitudes generate decent results, the ansatz parameters may need further optimization.

### 1.3 Constructing the LUCJ ansatz using `ffsim`

We will use the [ffsim](https://github.com/qiskit-community/ffsim/tree/main) package to create and initialize the ansatz with `t1` and `t2` amplitudes computed above. Since our molecule has a closed-shell Hartree-Fock state, we will use the spin-balanced variant of the UCJ ansatz, [UCJOpSpinBalanced](https://qiskit-community.github.io/ffsim/api/ffsim.html#ffsim.UCJOpSpinBalanced).

As IBM hardware has a heavy-hex topology, we will adopt the _zig-zag_ pattern used in [\[1\]](#references) and explained above for qubit interactions. In this pattern, orbitals (qubits) with the same spin are connected with a line topology (red and blue circles). Due to the heavy-hex topology, orbitals for different spins have connections between every 4th orbital, that is, the 0th, 4th, 8th, and so on (purple circles).

The LUCJ ansatz with repeated layers can be optimized by merging some adjacent blocks. Consider a case for `n_reps=2`. The two orbital rotation blocks in the middle can be merged into a single orbital rotation block. The `ffsim` package has a pass manager named `ffsim.qiskit.PRE_INIT` to optimize the circuit by merging such adjacent blocks.

## 2. Optimize for target hardware

First, we fetch a backend of our choice. We will optimize our circuit for the backend, and then execute the optimized circuit on the same backend to generate samples for the subspace.

Next, we recommend the following steps to optimize the ansatz and make it hardware-compatible.

- Select physical qubits (`initial_layout`) from the target hardware that adheres to the zig-zag pattern (two linear chains with ancilla qubit in-between them) described above. Laying out qubits in this pattern leads to an efficient hardware-compatible circuit with less gates.
- Generate a staged pass manager using the [`generate_preset_pass_manager`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.transpiler.generate_preset_pass_manager) function from Qiskit with your choice of `backend` and `initial_layout`.
- Set the `pre_init` stage of your staged pass manager to `ffsim.qiskit.PRE_INIT`. `ffsim.qiskit.PRE_INIT` includes Qiskit transpiler passes that decompose gates into orbital rotations and then merges the orbital rotations, resulting in fewer gates in the final circuit.
- Run the pass manager on your circuit.

## 3. Execute on target hardware

After optimizing the circuit for hardware execution, we are ready to run it on the target hardware and collect samples for ground state energy estimation. As we only have one circuit, we will use the `qiskit-ibm-runtime` [Job execution mode](https://quantum.cloud.ibm.com/docs/ibm-quantum-compute/execution-modes) and execute our circuit.

## 4. Post-process results

The post-processing part of the SQD workflow can be summarized using the following diagram.

Sampling the LUCJ ansatz in the computational basis generates a pool of noisy configurations $\tilde{\mathcal{\chi}}$, which are used in the post-processing routine. It involves a method called (details discussed later) _configuration recovery_ to probabilistically correct configurations with incorrect electron numbers. Configurations only with correct electron numbers $\tilde{\mathcal{\chi}}_{R}$ are then subsampled and distributed into multiple batches based on the frequency of appearance of each unique configuration. Each batch of samples defines a subspace ($\mathcal{S^{(k)}}$). Next, the molecular Hamiltonian, $H$, is projected onto subspaces:
$$
H_{\mathcal{S}^{(k)}} = P_{\mathcal{S}^{(k)}} H _{\mathcal{S}^{(k)}} \text{ with } P_{\mathcal{S}^{(k)}} = \sum_{x \in \mathcal{S}^{(k)}} \vert x \rangle \langle x \vert
$$

Each projected Hamiltonian $H_{\mathcal{S}^{(k)}}$ is then fed into an Eigensolver, where it is diagonalized to compute eigenvalues and eigenvectors to reconstruct an eigenstate. In this lesson, we project and diagonalize the Hamiltonian using the `qiskit-addon-sqd` package which uses the Davidson's method from PySCF for diagonalization.

$$
H_{\mathcal{S}^{(k)}} \vert \psi^{(k)} \rangle = E^{(k)} \vert \psi^{(k)} \rangle
$$

We then collect the lowest eigenvalue (energy) from the batches, and also compute average orbital occupancy, $\text{n}$. The average occupancy information is used in the configuration recovery step to probabilistically correct noise configurations.

Next, we explain the self-consistent configuration recovery loop in detail and show concrete code examples to implement the above-mentioned steps to estimate the ground state energy of $N_2$ Hamiltonian.

### 4.1 Configuration recovery: overview

Each bit in a bitstring (Slater determinant) represents a spin orbital. The right half of a bitstring represents spin-up orbitals, and the left half represents spin-down orbitals. A `1` means the orbital is occupied by an electron, and a `0` means the orbital is empty. We know the correct number of particles (both up-spin electron and down-spin electron) a priori. Suppose we have a determinant $x$ with $N_x$ electrons (that is, there are $N_x$ numbers of $1$s in the bitstring) in it. The correct number of particles is $N$. If $N_x \neq N$, then we know that the bitstring is corrupted by noise. The self-consistent configuration routine attempts to correct the bitstring by probabilistically flipping $|N_x - N|$ bits by leveraging average orbital occupancy information. The average orbital occupancy ($n$) tells us how likely an orbital be occupied by an electron. If $N_x < N$, we have fewer electrons and need to flip some $0$s to $1$s and vice versa.

The probability of flipping can be $|x[i] - avg\_occupancy[i]|$ for `i`-th spin orbital. In [\[2\]](#references), the authors used a weighted probability of flipping using modified ReLU function.

$$
\begin{align}
    w(y) = \begin{cases}

    \delta \frac{y}{h} & \text{if }  y \leq h\\ \nonumber

    \delta + (1 - \delta) \frac{y - h}{1 - h} & \text{if } y > h

\end{cases}
\end{align}
$$

Here $h$ defines the location of "corner" of the ReLU function, and the parameter $\delta$ defines the value of the ReLU function at the corner. For $\delta = 0$, $w$ becomes true ReLU function, and for $\delta >0$, it becomes _modified_ ReLU. In the paper, the authors used $\delta = 0.01$ and $h =$ number of alpha (or beta) particles/number of alpha (or beta) spin orbitals $= N/M$ (filling factor).

The average orbital occupancy ($n$) is not known a priori. The first iteration of the ground state estimation starts with configurations with only correct particle numbers in both spin species. After the first iteration, we have an estimate of the ground state, and using the estimate, we can construct the first guess of $n$. This guess of $n$ is used to recover configurations, run the next iteration of ground state estimation, and self-consistently refine the guess of $n$. The process repeats until the a stopping criterion is met.

Consider the following example for $N = 2$ and $x = |1000\rangle$ ($N_x = 1$). We need to flip one of the 0s to 1 to correct it for particle numbers, and the choices are `1100`, `1010`, and `1001`. Based on the probability of flipping, one of the choices will be selected as _recovered configuration_ (or the bitstring with correct number of particles).

Suppose in the first iteration we run two batches, and the estimated ground states from them are:

$$
\begin{align}\nonumber
    \text{Batch0: } \vert \psi \rangle &= 0.8 \times \vert 1001 \rangle + 0.6 \times \vert 0110 \rangle \\ \nonumber
    \text{Batch1: } \vert \psi \rangle &= \frac{1}{\sqrt{3}} \left( \vert 1001 \rangle + \vert 0101 \rangle + \vert 0110 \rangle \right) \nonumber
\end{align}
$$

Using the computational basis states and their amplitudes, we can compute probability of electron occupancies (in short _occupancies_) per spin-orbital (qubit) (note that probability = |amplitude|$^2$). Below we tabulate qubit-wise occupancies for each bitstring appearing in the estimated ground state and compute total orbital occupancy for a batch. Note that, as per Qiskit ordering convention, the right most bit represents qubit-0 (Q0), and the left most bit represents Q3.

Occupancy (Batch0):
|           |    Q3    |    Q2    |    Q1    |    Q0    |
|:---------:|:--------:|:--------:|:--------:|:--------:|
|    1001   |   0.64   |    0.0   |    0.0   |   0.64   |
|    0110   |    0.0   |   0.36   |   0.36   |    0.0   |
| **n** _(Batch0)_ | **0.64** | **0.36** | **0.36** | **0.64** |

Occupancy (Batch1)
|           |    Q3    |    Q2    |    Q1    |    Q0    |
|:---------:|:--------:|:--------:|:--------:|:--------:|
|    1001   |    0.33   |   0.00   |   0.00   |    0.33   |
|    0101   |    0.0   |   0.33   |   0.00   |    0.33   |
|    0110   |    0.0   |   0.33   |   0.33   |    0.00   |
| **n** _(Batch1)_ | **0.33** | **0.66** | **0.33** | **0.66** |

Occupancy (average across batches)
|           |    Q3    |    Q2    |    Q1    |    Q0    |
|:---------:|:--------:|:--------:|:--------:|:--------:|
| **n** _(Batch0)_ | 0.64 | 0.36 | 0.36 | 0.64 |
| **n** _(Batch1)_ | 0.33 | 0.66 | 0.33 | 0.66 |
| **n** _(average)_ | **0.49** | **0.51** | **0.35** | **0.65** |

Using the average orbital occupancy computed above, we can find the probabilities of flip for different orbitals in the configuration $x = \vert 1000 \rangle$. As the orbital represented by Q3 is already occupied and need not to be flipped, we set its p(flip) to $0$. For the remaining orbitals, which are unoccupied, the probability of flip is $\vert x[i] - \text{n}[i] \vert$ each. Along with p(flip), we also compute the probability weight associated with flipping using the modified ReLU function described above.

Probability of flip ($x = \vert 1000 \rangle$, $\delta = 0.01$, $h = N/M = 2/4 = 0.50$)
|           |    Q3    |    Q2    |    Q1    |    Q0    |
|:---------:|:--------:|:--------:|:--------:|:--------:|
| p(flip) ($\vert x[i] - \text{n}[i] \vert$) | 0 | 0.51 | 0.35 | 0.65 |
| w(p(flip)) | 0 | 0.03 | 0.007 | 0.31 |

Finally, using weighted probabilities above, we can flip one of the unoccupied Q2, Q1, and Q0 orbitals. Based on the values above, Q0 will be flipped most likely, and a possible recovered configuration can be $\vert \text{1001} \rangle$.

The complete self-consistent configuration recovery process can be summarized as follows:

**First iteration:** Suppose the bitstrings (configurations or Slater determinants) generated by the quantum computer form a set $\widetilde{\chi}$, which includes both configurations with correct ($\widetilde{\chi}_{correct}$) and incorrect ($\widetilde{\chi}_{incorrect}$) number of particles in each spin sector.
1. Configurations from ($\widetilde{\chi}_{correct}$) are randomly sampled to create batches $(\mathcal{S}^{(1)}, \cdots, \mathcal{S}^{(K)})$ of vectors for subspace projection. The number of batches and samples in each batch are user defined parameters. The larger the number of samples in each batch, the larger the subspace dimension and more computationally demanding the diagonalization becomes. On the other hand, too small number of samples may miss the ground state support vectors and lead to incorrect estimation.
2. Run the eigenstate solver (that is, projection onto subspace and diagonalization) on the batches and obtain approximate eigenstates. $|\psi^{(1)}\rangle, \cdots, |\psi^{(K)}\rangle$.
3. From the approximate eigenstates construct the first guess for $n$.

**Subsequent iterations:**
1. Using $n$ correct the configurations with wrong particle number in $\widetilde{\chi}_{incorrect}$. Suppose we name them $\widetilde{\chi}_{correct\_new}$. Then, $\widetilde{\chi}_{recovered} (\widetilde{\chi}_{R}) = \widetilde{\chi}_{correct} \cup \widetilde{\chi}_{correct\_new}$ forms the new set of configurations with correct particle numbers.
2. $\widetilde{\chi}_{R}$ is sampled to create batches $\mathcal{S}^{(1)}, \cdots, \mathcal{S}^{(K)}$.
3. Eigenstate solver runs with new batches and generates new estimates of ground states $|\psi^{(1)}\rangle, \cdots, |\psi^{(K)}\rangle$.
4. From the approximate eigenstates construct refined guess for $n$.
5. If the stopping criterion is not met, go back to step `2.1`.

### 4.2 Ground state estimation

First, we will transform the counts into a bitstring matrix and probability array for post-processing.

Each row in the matrix represents one unique bitstring. Since qubits are indexed from the right of a bitstring in Qiskit, column ``0`` represents qubit ``N-1``, and column ``N-1`` represents qubit ``0``, where ``N`` is the number of qubits.

The alpha orbitals are represented in the column index range ``(N, N/2]`` (right half), and the beta orbitals are represented in the column range ``(N/2, 0]`` (left half).

There are a few user-controlled options which are important for this technique:

- ``iterations``: Number of self-consistent configuration recovery iterations
- ``n_batches``: Number of batches of configurations used by the different calls to the eigenstate solver
- ``samples_per_batch``: Number of unique configurations to include in each batch
- ``max_davidson_cycles``: Maximum number of Davidson cycles run by each eigensolver

### 4.3 Discussion of results

The first plot shows that after a few iterations we estimate the ground state energy within ~24 mH (chemical accuracy is typically accepted to be 1 kcal/mol $\approx$ 1.6 mH). The second plot shows the average occupancy of each spatial orbital after the final iteration. We can see that both the spin-up and spin-down electrons occupy the first five orbitals with high probability in our solutions.

Although the estimated ground state energy is decent, it is not within the chemical accuracy limit ($\pm \approx 1.6$ mH). This gap can be attributed to the small subspace dimension we used above for projection and diagonalization. As we used `samples_per_batch=500`, the subspace is spanned by max $500$ vectors, which is missing vectors from ground state support. Increasing the `samples_per_batch` parameter should improve the accuracy at the expense of more classical compute resources and runtime.

#### Exercise for the reader
Progressively increase the `samples_per_batch` parameter (for example, from $1000$ to $10000$ at a step of $1000$; permitted my your computer's memory) and compare the estimated ground state energies.

## References

\[1] M. Motta et al., “Bridging physical intuition and hardware efficiency for correlated electronic states: the local unitary cluster Jastrow ansatz for electronic structure” (2023). [Chem. Sci., 2023, 14, 11213](https://pubs.rsc.org/en/content/articlehtml/2023/sc/d3sc02516k).

\[2] J. Robledo-Moreno et al., "Chemistry Beyond Exact Solutions on a Quantum-Centric Supercomputer" (2024). [arXiv:quant-ph/2405.05068](https://arxiv.org/abs/2405.05068).
