# Bounding the subspace dimension

> Fuente: <https://github.com/Qiskit/documentation/tree/main/docs/addons/qiskit-addon-sqd/guides/choose-subspace-dimension>

In this walkthrough, we will show the effect of the subspace dimension in the [self-consistent configuration recovery technique](https://arxiv.org/abs/2405.05068).

*A priori*, we do not know what is the correct subspace dimension to obtain a target level of accuracy. However, we do know that increasing the subspace dimension increases the accuracy of the method. Therefore, we can study the accuracy of the predictions as a function of the subspace dimension.

Specify the molecule and its properties.

Generate some random bitstrings to proxy QPU samples.

Call SQD with increasing batch sizes.

This plot shows that increasing the subspace dimension leads to more accurate results.

## Setting an explicit bound with `max_dim`

In the sweep above, the subspace dimension was controlled only indirectly. `samples_per_batch` sets how many bitstrings are drawn into each batch, but the dimension of the resulting subspace is determined by how many *distinct* spin-alpha and spin-beta strings those bitstrings contain, and the pool of configurations available for subsampling grows from one configuration recovery iteration to the next. That is why the subspace dimensions on the horizontal axis above are irregular numbers that we did not pick.

The `max_dim` argument of `diagonalize_fermionic_hamiltonian` bounds the dimension directly. It limits the number of CI strings retained in each spin sector, and since the subspace is spanned by the Cartesian product of the two sectors, its dimension is the product of the two sector dimensions:

- `max_dim=d` limits both sectors to `d` strings, so the subspace dimension is at most `d ** 2`.
- `max_dim=(d_a, d_b)` limits the spin-alpha and spin-beta sectors separately, so the subspace dimension is at most `d_a * d_b`. When `symmetrize_spin=True`, the two limits must be equal.
- `max_dim=None`, the default, imposes no limit.

When a batch contains more strings than the limit allows, the least important ones are discarded: the strings passed via `include_configurations` are kept first, followed by the strings carried over from the previous iteration (see `carryover_threshold`), and the remaining slots are filled with the sampled strings in decreasing order of how often they were sampled.

Because `max_dim` caps the size of the largest diagonalization that the eigenstate solver will be asked to perform, it is a convenient way to keep the solver within a runtime and memory budget: choose `samples_per_batch` generously, and let `max_dim` decide how large the subspace is allowed to grow.

Below, we repeat the study, this time holding `samples_per_batch` fixed and increasing `max_dim`.

The subspace dimension is now exactly `max_dim ** 2` in every run: it was chosen rather than discovered. Plotting both sweeps together shows that the accuracy is governed by the subspace dimension itself, whichever argument was used to arrive at it. The two curves need not coincide exactly, though. The `max_dim` runs draw 600 bitstrings per batch and then keep the most frequently sampled strings, so at a given dimension they can retain a better set of configurations than a run that reached that dimension by sampling fewer bitstrings in the first place.
