# PEC with SLC

> Fuente: <https://github.com/Qiskit/documentation/tree/main/docs/addons/qiskit-mitigation/guides/pec-with-slc>

#  PEC with SLC

[Probabilistic error cancellation (PEC)](https://arxiv.org/pdf/1612.02058) is a technique for mitigating quantum noise in observable expectation value calculations. It lets you compute an unbiased estimate of the expectation values. This technique works by executing an ensemble of noisy circuits injected with the inverse of a learned noise model. The noise model is then approximated to a Pauli channel by using Pauli twirling (also known as [randomized compiling](https://journals.aps.org/pra/abstract/10.1103/PhysRevA.94.052325)). Such noise models can be learned efficiently and can be mitigated by using PEC (see [Probabilistic error cancellation with sparse Pauli-Lindblad models on noisy quantum
processors](https://arxiv.org/pdf/2201.09866) for more details).

PEC requires exponential shot overhead to compute an unbiased estimate. [Shaded Lightcones (SLC)](https://arxiv.org/abs/2409.04401) is a technique that uses classical resources to bound the sensitivity to errors throughout the circuit. Using these bounds, the user can controllably tune the bias in the observable estimation.

This guide shows how to use PEC combined with SLC to mitigate gate noise with reduced shot overhead compared to vanilla PEC.

The workflow follows:
1. Specify a circuit and observable.
2. Compute noisy, unmitigated expectation values.
3. Compute forward and backward bounds on the bias.
4. Learn the entangling layers' noise by using qiskit-noise-learning.
5. Use the learned noise to merge the computed bounds into a local scales matrix.
6. Choose the desired bias bound based on the shot overhead-bias trade-off.
7. Prepare a PEC + SLC program, execute the program, and post-process.
8. Compare the mitigated expectation values and shot overhead.

### Specify a circuit and observable

Prepare a mirror circuit of a Trotterized time evolution of a 1D Ising chain Hamiltonian on eight qubits. Mirror the circuit to cancel its unitary and form an identity circuit, so each observable's ideal expectation value is known to be 1 without the need to compute it. In addition, mirroring doubles the circuit depth, which in turn doubles the noise's effect.

Use the angle $\theta= \frac{\pi}{4}$ to make the dynamics non-Clifford.

### Compute noisy, unmitigated expectation values

A [`QuantumProgram`](https://quantum.cloud.ibm.com/docs/ibm-quantum-compute/executor-input-output#inputs-quantum-programs) contains a quantum circuit and a [samplex](https://quantum.cloud.ibm.com/docs/addons/samplomatic/guides/samplex-io) in a format suitable for the [Executor](https://quantum.cloud.ibm.com/docs/ibm-quantum-compute/get-started-with-executor) primitive. `MitigationTask.prepare` builds a `QuantumProgram` from the circuit, the observables and the parameter values, and boxes the circuit with the given boxing options. Set the ``measure_annotations`` boxing option to ``"change_basis"`` to rotate the measurements into the required bases, and add ``add_tags: "unique_box"`` so the simulator can map a noise model onto the circuit's boxes. The program is Pauli twirled by default, which on hardware turns coherent noise into the Pauli noise that the mitigation methods assume. `num_randomizations` sets how many twirled instances of each circuit are sampled and `shots_per_randomization` sets how many shots each instance receives, so their product is the shot limit per circuit.

If you have QPU access, you can execute the program with an `Executor` built from a backend of the `QiskitRuntimeService`. This example uses an `AerSimulator` to run the program locally. Its `layer_noise_model` simulator option injects noise from a given Pauli-Lindblad noise model on every layer of entangling gates. Here we generate a random Pauli-Lindblad noise model with an error per layered gate (EPLG) of ``0.01``, almost an order of magnitude higher than typical current Heron QPUs, to magnify the effect of using SLC also on a small scale problem.

### Compute forward and backward bounds on the bias

Before spending any QPU time on noise learning, SLC uses classical simulation to bound each potential error's contribution to the observable's bias. This is done in two complementary passes:

- **Forward propagation**: each Pauli error is propagated forward through the remainder of the circuit and its commutator with the observable is evaluated. An error that anti-commutes with the observable is the only kind that can bias the result, so this pass produces an upper bound on each error's forward impact.
- **Backward propagation**: each error is propagated backward to the start of the circuit and its commutator with the initial state is evaluated. Because the circuit starts in the all-zero state, errors that commute with it cannot affect the outcome, tightening the bound from the other direction.

The two bounds together form a tight bracket around every error's worst-case contribution to the bias. In the next step these bounds are merged with the learned noise rates to rank which errors are worth correcting and which can be safely left alone. The `inject_noise_strategy="individual_modification"` boxing option is required here so that each `InjectNoise` annotation in the boxed circuit has a unique identity that the SLC bounds can be attached to.

For larger-scale problems, these computations may demand substantial classical computational resources.

### Learn the entangling layers' noise

In order to compute a final estimation of how much each error impacts on the expectation value's bias, as well as how expensive it would be to correct it, we learn the noise rates and apply them to the predicted noise bounds we computed before.

PEC (as well as PEC+SLC) assumes a twirled noise model of each layer of entangling gates in the circuit. If you assume a Markovian noise model, the depth of the circuit is assumed to not affect the noise channel of a given entangling layer. Therefore, only the noise model of each unique layer of entangling gates should be learned. The circuit used in this guide can be split into two unique layers. Designing circuits to have a minimal set of unique entangling layers is important if you want to learn a noise model, since the unique layers must be learned independently. If you have too many unique layers in your circuit, noise learning can become infeasible due to the sampling cost of learning many layers.

`qiskit-noise-learning` is used to learn the noise. The learner repeats each layer _`fragment_depths`_ times in its learning circuits, twirls each circuit _`num_randomizations`_ times, and fits the decay of the measured fidelities to a Pauli-Lindblad model. These parameters can affect the accuracy of the learned model. The more accurate the learned noise model is, the more accurate the noise cancellation will be.

The following code draws the learned noise model with the two layers merged into one map. Each qubit is a pie of its weight-1 X, Y and Z rates summed over the two layers, and each edge shows the learned weight-2 rates. For example, a rate of ``3e-4`` means that error occurs on roughly three of every 10,000 uses of the layer.

### Use the learned noise to merge the computed bounds into local scales matrix

With both the classical bounds (from the previous step) and the learned noise rates in hand, we can now compute a *local scales matrix* — a per-error weight that determines how aggressively PEC should cancel each individual noise term.

The key idea of SLC is that not all errors need to be fully cancelled. An error whose forward and backward bounds are both small has a negligible effect on the observable regardless of its rate, so it can be left partially or fully un-mitigated. `merge_bounds` merges the classical bounds with the learned Pauli-Lindblad rates, than `compute_local_scales` assigns each error a scale between 0 (completely ignored) and 1 (fully cancelled), subject to a user-specified `bias_tolerance`. Errors with a large estimated bias contribution receive a scale close to 1 (full PEC treatment), while errors with a small contribution receive a lower scale, reducing the sampling overhead they carry.

SLC exposes a continuous knob between the two extremes — vanilla PEC (zero bias, highest overhead) and no mitigation at all (zero overhead, full noise bias). The `bias_tolerance` parameter controls this knob: setting it to `0` recovers full PEC, while larger values allow more residual bias in exchange for a lower sampling overhead γ².

This step sweeps `bias_tolerance` across a range of values and computes the resulting sampling overhead for each. Plotting these points against the full-PEC overhead helps you choose a working point that fits your shot budget. For example, tolerating a 5 % residual bias may reduce the sampling overhead by an order of magnitude compared with full PEC, making the computation feasible on today's QPUs where it would otherwise not be.

### Choose desired bias bound based on shot overhead-bias trade-off

In this guide we choose a bias tolerance of 5%. Note that this bias calculation is based on the learned noise model, which might not be perfectly aligned with the real noise of the device.

### Prepare a PEC + SLC program, execute the program, and post-process

With the local scales chosen, we can build the full PEC+SLC execution program. The `PEC.prepare` call constructs a `QuantumProgram` that encodes the anti-noise injection strategy into the circuit's box annotations. Passing `noise_gain="slc_local_scales"` instructs the executor to use the per-error weights set by `set_slc_local_scales`, rather than applying the same full inverse-noise gain to every error as vanilla PEC would.

To produce a fair comparison, a second `PEC` task is prepared with `noise_gain=0`, which corresponds to full PEC cancellation with no SLC bias allowance. Both programs are added to the same `QuantumProgram` so they share a single execution job — their circuits are interleaved and executed together, meaning any hardware drift affects both equally.

After the job completes, `postprocess` converts the raw measurement bitstrings into expectation values, applying the appropriate PEC rescaling factor γ for each task.

### Compare the mitigated expectation values and shot overhead

The ideal expectation value of the mirrored circuit is 1 by construction, so the bias of any estimate is simply `|1 - result|`. This final cell prints the bias and total shot count for three scenarios side-by-side:

- **Unmitigated**: the raw noisy expectation value with no error cancellation applied.
- **Full PEC**: zero-bias error cancellation using the complete inverse noise model on every layer, at the full γ² sampling overhead.
- **PEC+SLC**: error cancellation guided by the shaded-lightcone local scales, tolerating the chosen `bias_tolerance` in exchange for a substantially lower shot count.

Comparing the three rows shows the concrete benefit of SLC: the mitigated bias of PEC+SLC stays well below the unmitigated bias while the total number of shots is significantly smaller than what full PEC required.
