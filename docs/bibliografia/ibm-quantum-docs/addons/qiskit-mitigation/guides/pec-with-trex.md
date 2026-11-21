# PEC with TREX

> Fuente: <https://github.com/Qiskit/documentation/tree/main/docs/addons/qiskit-mitigation/guides/pec-with-trex>

#  PEC with TREX

[Probabilistic error cancellation (PEC)](https://arxiv.org/pdf/1612.02058) is a technique for mitigating quantum noise in observable expectation value calculations. It lets you compute an unbiased estimate of the expectation values. This technique works by executing an ensemble of noisy circuits injected with the inverse of a learned noise model. The noise model is then approximated to a Pauli channel by using Pauli twirling (also known as [randomized compiling](https://journals.aps.org/pra/abstract/10.1103/PhysRevA.94.052325)). Such noise models can be learned efficiently and can be mitigated by using PEC (see [Probabilistic error cancellation with sparse Pauli-Lindblad models on noisy quantum
processors](https://arxiv.org/pdf/2201.09866) for more details).

[Twirled Readout Error eXtinction (TREX)](https://arxiv.org/pdf/2012.09738) is a technique that mitigates measurement errors and is useful for estimating Pauli observable expectation values. It relies on measurement twirling (randomly injecting an `X` gate before the measurement and flipping the measured result), which diagonalizes the readout-error transfer matrix and makes it easy to invert. A rescaling term is learned from the diagonal noise channel by measuring twirled calibration circuits that were initialized in the zero state.

This guide shows how to use PEC to mitigate gates noise and combine it with TREX to also mitigate measurement noise when estimating observables' expectation values.

The workflow follows:
1. Specify a circuit and observable.
2. Compute exact expectation values by using Qiskit's statevector simulator.
3. Compute noisy, unmitigated expectation values.
4. Learn the entangling layers' noise by using qiskit-noise-learning.
5. Prepare a PEC + TREX program and add a TREX calibration circuit to it.
6. Compare the mitigated expectation values.

### Specify a circuit and observable

Prepare a mirror circuit of a Trotterized time evolution of a linear transverse-field Ising model on eight qubits. Mirror the circuit to cancel the circuit unitary and form an identity circuit. This lets you easily compute each observable's ideal expectation value. In addition, mirroring doubles the circuit depth, which in turn doubles the noise's effect.

Use the angle $\theta= \frac{\pi}{2}$ to keep all the gates in the circuit from the Clifford group, allowing faster simulation by using the `stabilizer` simulator.

### Compute noisy, unmitigated expectation values

A [`QuantumProgram`](https://quantum.cloud.ibm.com/docs/ibm-quantum-compute/executor-input-output#inputs-quantum-programs) contains a quantum circuit and a [samplex](https://quantum.cloud.ibm.com/docs/addons/samplomatic/guides/samplex-io) in a format suitable for the [Executor](https://quantum.cloud.ibm.com/docs/ibm-quantum-compute/get-started-with-executor) primitive. `MitigationTask.prepare` builds a `QuantumProgram` from the circuit, the observables and the parameter values, and boxes the circuit with the given boxing options. Set the ``measure_annotations`` boxing option to ``"change_basis"`` to rotate the measurements into the required bases, and add ``add_tags: "unique_box"`` so the simulator can map a noise model onto the circuit's boxes. The program is Pauli twirled by default, which on hardware turns coherent noise into the Pauli noise that the mitigation methods assume. `num_randomizations` sets how many twirled instances of each circuit are sampled and `shots_per_randomization` sets how many shots each instance receives, so their product is the shot limit per circuit.

If you have QPU access, you can execute the program with an `Executor` built from a backend of the `QiskitRuntimeService`.  This examples uses an `AerSimulator` to run the program locally. Its `layer_noise_model` simulator option injects a random Pauli-Lindblad noise model on every layer of entangling gates, generated with `random_pauli_lindblad_noise` from `qiskit-mitigation` with an error per layered gate (EPLG) of ``0.003``, typical of current Heron QPUs.

### Learn the entangling layers' noise

PEC starts by learning the twirled noise model of each layer of entangling gates in the circuit. If you assume a Markovian noise model, the depth of the circuit is assumed to not affect the noise channel of a given entangling layer.  Therefore, only the noise model of each unique layer of entangling gates should be learned. The circuit used in this guide can be split into two unique layers. Designing circuits to have a minimal set of unique entangling layers is important if you want to learn a noise model, since the unique layers must be learned independently. If you have too many unique layers in your circuit, noise learning can become infeasible due to the sampling cost of learning many layers.

`qiskit-noise-learning` is used to learn the noise. The learner repeats each layer _`fragment_depths`_ times in its learning circuits, twirls each circuit _`num_randomizations`_ times, and fits the decay of the measured fidelities to a Pauli-Lindblad model. These parameters can effect the accuracy of the learned model. The more accurate the learned noise model is, the more accurate the noise cancellation will be.
The following code draws the learned noise model with the two layers merged into one map. Each qubit is a pie of its weight-1 X, Y and Z rates summed over the two layers, and each edge shows the learned weight-2 rates. For example, a rate of ``3e-4`` means that error occurs on roughly three of every 10,000 uses of the layer.

Readout noise mitigation is done in post-processing by using TREX, as opposed to the **gate** noise model, which is required for the program preparation in order to inject the anti-noise that corresponds to the learned noise model.
Therefore, the readout noise can be either executed and learned when learning the gates' noise, or when executing the mitigated program. Learning the readout noise alongside the gate noise might be beneficial for learning a self-consistent noise model (see [Disambiguating Pauli noise in quantum computers](https://arxiv.org/pdf/2505.22629) for example). In cases where the gate noise and the readout noise are separated in the noise model, it is recommended that you learn the readout noise when executing the mitigated program to avoid drift in the noise between the when it was learned and executed.

In this guide, the readout noise is learned while executing the mitigated program by using TREX calibration circuit.

### Prepare a combined PEC and TREX program

Here we prepare both a `TREX` and a `PEC` task, and add the `TREX` task as a variable to the `PEC` task. This ensures that all the required properties needed for TREX mitigation are added to the PEC mitigated item (like measurement twirling). The injected noise is sampled once per randomization, so the statistical error of PEC is controlled by the number of randomizations rather than the shots per randomization. Thus, many randomizations are used - each with few shots - keeping the total number of shots the same as for the unmitigated program.

The TREX calibration circuit is added to the program in order to learn the readout noise while executing the program. The TREX calibration circuit is very shallow, which makes additional randomizations for it to be relatively cheap and allows the readout noise to be learned more accurately.

### Examine shot overhead, execute the program, and post-process

PEC returns an unbiased expectation value estimation, with a cost of large shot overhead. The required shot overhead can be approximated by calculating the circuit gamma factor, which reflects the effect of the learned noise model on the circuit. By default, the number of randomization of the PEC task is scaled by the approximate amount of shot overhead required to have an unbiased estimation (~$\gamma^2$). To avoid this automatic scale, you can set the parameter `scale_randomizations_by_gamma` to `False`. The shots overhead is capped by the `max_sampling_overhead` parameter.

You should review the number of shots required by PEC to reach unbiased estimation before execution to decide whether this amount is affordable, as this scales exponentially in the noise rates and circuit depth.

### Compare the mitigated expectation values

Finally, plot the expectation value of each observable. PEC + TREX recovers the exact expectation values within its error bars, while the unmitigated result is biased well below it.
