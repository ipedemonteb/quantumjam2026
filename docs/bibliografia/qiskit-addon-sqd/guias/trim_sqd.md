# Leverage trim SQD for improved configuration selection

> Fuente: <https://github.com/Qiskit/qiskit-addon-sqd/blob/main/docs/guides/trim_sqd.ipynb>

The default behavior of [`diagonalize_fermionic_hamiltonian`](../apidocs/qiskit_addon_sqd.fermion.rst) is to diagonalize each subsampled batch and keep the best result. **Trim SQD** instead treats the batches as candidates to be screened: each is diagonalized, *trimmed* down to the configurations carrying the largest weight, and the survivors of all the batches are merged and diagonalized together. That merged diagonalization is the one whose energy the iteration reports, and its own trimmed output seeds the next iteration.

The trim SQD implementation is based on joint research from
the Cleveland Clinic Foundation, RIKEN, and IBM&reg;. If you use this feature in
your research, also cite the paper. You can find the citation in the
`CITATION.bib` file, with citation key `merz2026crossing`.

For more details on the SQD code used in this example, see the [chemistry Hamiltonian tutorial](https://quantum.cloud.ibm.com/docs/tutorials/sample-based-quantum-diagonalization).

## Set up the molecule

## Run the loop

One trim SQD iteration does the following:

1. **Screening round.** Partition the bitstrings into batches.  Diagonalize each batch and keep the `trim_ratio` fraction of its CI strings, per spin sector, ranked by weight.
2. **Merged round.** Diagonalize the merged survivors once. This is the result the iteration reports, and its own trimmed strings seed the next iteration.

The loop's `sci_solver` performs both rounds, and defaults to this package's PySCF solver.

Enable trim SQD by passing the `TrimPolicy` as follows:

## Check whether screening is helping

Screening has the most to offer when the sampled configurations greatly outnumber what can be diagonalized at once, so that ranking a larger pool genuinely finds configurations a single batch would have missed. It has the least to offer when a subspace of the affordable size already captures most of the wavefunction.

Screening depends on the batches differing from one another. `TrimPolicy` manages this by modifying the behavior of `diagonalize_fermionic_hamiltonian` to draw one pool of `samples_per_batch * num_batches` bitstrings and partitioning it among the batches, so no bitstring appears in more than one.

## Bound the subspace

A subspace here is spanned by the *Cartesian product* of a spin-alpha and a spin-beta CI string array.

Trimming ranks configurations, but the carryover is two per-spin string lists. Keeping the 150 highest-weight configurations of a subspace typically involves close to 150 distinct alpha strings and 150 distinct beta strings, whose product spans roughly 22,500 configurations, not 150. So the subspace handed to the next iteration is generally much larger than the set that was ranked, and it grows quadratically in what you retain.

Trimming and carrying over are bounded separately, because they happen at different points: trimming shrinks each batch of the screening round, while the carryover is what crosses into the next iteration.

Four arguments bound it, and it is useful to set at least one:

- **`trim_ratio`** is the fraction of each batch's strings, per spin sector, that survive screening. Lower values shrink the merged subspace but discard configurations the next iteration must rediscover by sampling.
- **`max_strings_per_trim`** caps the strings each batch contributes, per sector, regardless of the ratio. Useful with `symmetrize_spin`, which merges both spin sectors into one list and so roughly doubles what each batch offers. This bound is **per batch**: the merged subspace can hold up to `num_batches` times as many strings, less whatever the batches had in common, which in practice is not much.
- **`carryover_threshold`**, **`carryover_ratio`**, and **`max_carryover`** bound the strings that seed the next iteration, applied to the merged subspace as a whole rather than per batch. `carryover_threshold` is the amplitude cutoff that `StandardPolicy` uses, with the same default; the other two bound the count, which the cutoff alone does not.
- **`max_dim`**, on `diagonalize_fermionic_hamiltonian` itself, bounds each spin sector of every subspace the loop diagonalizes, including the merged one. It acts as a backstop and applies to whatever the policy returns, after the carryover is merged with fresh samples.

The run above sets `max_strings_per_trim=250` and `max_dim=250` together, so neither what each batch contributes nor the subspace built from it can run away.

## Use an external eigensolver

You can use trim SQD with an external eigensolver by passing the `sci_solver` argument:

```python
from sbd.sbd_solver import create_sbd_solver

result = diagonalize_fermionic_hamiltonian(
    hcore,
    eri,
    bit_array,
    samples_per_batch=300,
    norb=num_orbitals,
    nelec=(num_elec_a, num_elec_b),
    num_batches=5,
    policy=TrimPolicy(trim_ratio=0.1),
    sci_solver=create_sbd_solver(sbd_config={"method": 0, "eps": 1e-10}),
    seed=rng,
)
```

The prior snippet requires the `sbd-eigensolver` package to be installed from PyPI.

## Distribute the work

With `TrimPolicy`, the loop calls `sci_solver` twice per iteration: once with all the batches, and once with the merged subspace. Both calls go through the ordinary `sci_solver` interface, which [this package's multi-process support](hpc_acceleration.ipynb) invokes collectively on every MPI rank.

Two levels of parallelism are potentially available, and they are independent:

- **Within a diagonalization.** A solver such as SBD can spread a single diagonalization across ranks.
- **Across the batches.** A solver could, in principle, diagonalize the batches concurrently.

Given a set of batches, the solver determines how to delegate work to its worker processes.
