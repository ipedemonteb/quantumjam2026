# Understand open-shell versus closed-shell options and the effect on subspace construction

> Fuente: <https://github.com/Qiskit/documentation/tree/main/docs/addons/qiskit-addon-sqd/guides/select-open-closed-shell>

In this guide, we will show how to choose subspace dimensions in the `qiskit_addon_sqd` package to post-process quantum samples using the [self-consistent configuration recovery technique](https://arxiv.org/abs/2405.05068).

More importantly, this guide also highlights some differences in the behavior in the subspace construction when run in `open_shell = False` or `open_shell = True` modes:

- `open_shell = False` only works when the number of spin-up and spin-down electrons is the same.

- `open_shell = True` must be used when the number of spin-up and spin-down electrons is different. It can also be used when the number of spin-up and spin-down electrons is the same. However, in this last case, there is a difference in the sizes of the subspaces generated between `open_shell = False` and `open_shell = True`, as discussed in this guide.

**NOTE:** Some of the electronic-configuration (bitstring) manipulations in this package have as a goal to preserve the total spin symmetry $S^2$. Standard Selected Configuration Interaction (SCI) solvers cannot impose $S^2$ conservation exactly. Consequently, they do so approximately via a Lagrange multiplier.

The choice of electronic configurations entering the eigenstate solver can also have a strong effect in the conservation of spin. For example, in a (2-electron, 2-orbital) system, one can sample the configuration $|1001\rangle$ (having a single spin-up excitation over the RHF state $|0101\rangle$), which is a linear combination of the open-shell singlet and triplet states, respectively $(|1001\rangle ± |0110\rangle) /\sqrt{2}$. If the configuration |0110⟩ is not sampled, one can construct neither eigenfunction of total spin, leading to spin contamination or redundancy (the configuration |1001⟩ is involved in a CI calculation, but has coefficient 0 in the CI vector). Given that a single sample $|1001\rangle$ is generated in the quantum computer, this is how the `sqd` package handles this situation:

- `open_shell = False`:

    1. The $1001$ bitstring is split in half, representing spin-up and spin-down configurations: $10$ (up) and $01$ (down).

    2. The list of unique spin-polarized configurations is constructed: $\mathcal{U} = [01, 10]$.

    3. We then consider all possible combinations of $\mathcal{U}$ elements to form the basis: $\left \{ |0101\rangle, |0110\rangle , |1001\rangle , |1010\rangle \right \}$, which contains the singlet and triplet states.

- `open_shell = True`:

    1. Contrary to the `open_shell = False` case, we do not combine the halves of the bitstring to form the basis.

### Closed-shell

This example shows how the bitstrings are manipulated in a (2-electron, 4-orbital) system.

Specify by hand a dictionary of measurement outcomes:

Transform the counts `dict` into a bitstring matrix and probability array for post-processing:

Subsample a single batch of size two:

- ``n_batches = 1``: Number of batches of configurations used by the different calls to the eigenstate solver
- ``samples_per_batch = 2``: Number of unique configurations to include in each batch

Obtain decimal representation of the spin-up and spin-down bitstrings used by the eigenstate solver.

The first element in the tuple corresponds to the decimal representation of the spin-up configurations, while the second element in the tuple corresponds to the decimal representation of the spin-down configurations:

Note that while the number of samples per batch is two, and the sampled bitstrings are: $00010010$ and $01001000$, four electronic configurations are generated per spin-species. In this case, the set of unique spin-polarized configurations is given by:
$$
\mathcal{U} = \{ 0001, 0010, 0100, 1000 \}
$$
whose base-10 decimal representation is
$$
\mathcal{U}_{10} = \{ 1, 2, 4, 8 \}
$$

Basis of the subspace:

The eigenstate solver takes all possible pairs of spin-up and spin-down bitstrings to construct the basis $\mathcal{B}$ of the subspace:

- Element 1: $|00010001\rangle$

- Element 2: $|00010010\rangle$

- Element 3: $|00010100\rangle$

- Element 4: $|00011000\rangle$

- Element 5: $|00100001\rangle$

- Element 6: $|00100010\rangle$

- Element 7: $|00100100\rangle$

- Element 8: $|00101000\rangle$

- Element 9: $|01000001\rangle$

- Element 10: $|01000010\rangle$

- Element 11: $|01000100\rangle$

- Element 12: $|01001000\rangle$

- Element 13: $|10000001\rangle$

- Element 14: $|10000010\rangle$

- Element 15: $|10000100\rangle$

- Element 16: $|10001000\rangle$

**The subspace dimension is upper-bounded by**:  $2 \cdot$ (`samples_per_batch`)$^2$.

### Open-shell

This example shows how the bitstrings are manipulated in a (2-electron, 4-orbital) system.

Specify by hand a dictionary of measurement outcomes:

Transform the counts `dict` into a bitstring matrix and probability array for post-processing:

Subsample a single batch of size two:

- ``n_batches = 1``: Number of batches of configurations used by the different calls to the eigenstate solver
- ``samples_per_batch = 2``: Number of unique configurations to include in each batch

Obtain decimal representation of the spin-up and spin-down bitstrings used by the eigenstate solver.

The first element in the tuple corresponds to the decimal representation of the spin-up configurations, while the second element in the tuple corresponds to the decimal representation of the spin-down configurations:

If we specify that `open_shell = True`, we do not include all unique half-bitstrings as spin-up and spin-down configurations, thus yielding a smaller basis than when specifying `open_shell = False`.

Basis of the subspace:

The eigenstate solver takes all possible pairs of spin-up and spin-down bitstrings to construct the basis $\mathcal{B}$ of the subspace:

- Element 1: $|00010010\rangle$

- Element 2: $|00011000\rangle$

- Element 3: $|01000010\rangle$

- Element 4: $|01001000\rangle$

**The subspace dimension is upper-bounded by**:  (`samples_per_batch`)$^2$.
