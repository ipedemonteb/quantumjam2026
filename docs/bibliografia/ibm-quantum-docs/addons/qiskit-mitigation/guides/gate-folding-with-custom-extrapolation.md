# Zero-noise extrapolation with gate folding and custom extrapolation

> Fuente: <https://github.com/Qiskit/documentation/tree/main/docs/addons/qiskit-mitigation/guides/gate-folding-with-custom-extrapolation>

Zero-noise extrapolation (ZNE) is a technique for mitigating quantum noise in observable expectation value calculations. It works by executing a quantum circuit at increasing noise scales, taking expectation values with respect to those noise scales, and extrapolating to estimate a zero-noise expectation value. Both the noise amplification and extrapolation stages can be implemented in different ways. This guide amplifies the noise with "digital gate folding", which means that two-qubit gates are replaced with equivalent sequences of the gate and its inverse. For example, replacing a unitary $U$ with $U U^† U$ would yield a noise amplification factor of 3. You can also implement amplification with probabilistic error amplification (PEA), which needs an additional step of learning a noise model and is covered in the [probabilistic error amplification](https://quantum.cloud.ibm.com/docs/addons/qiskit-mitigation/guides/pea-with-noise-learning) guide. This guide extrapolates using a couple of built-in fitting strategies (linear and exponential), and it also demonstrates how to implement your own custom fitting function.

Keep in mind, while ZNE can be effective at mitigating quantum noise for a lower sampling cost than other methods, it comes with no bounds on the bias.

The workflow is as follows:
1. Specify a circuit and observable
2. Compute exact expectation values using Qiskit's statevector simulator
3. Compute noisy, unmitigated expectation values
4. Prepare a ZNE program with digital gate folding and sample circuits of varying noise scales
5. Extrapolate to the zero-noise limit with built-in and custom fitting functions
6. Compare the mitigated expectation values

### Specify a circuit and observable

Calculate the site-averaged magnetization $\langle Z \rangle_{\text{avg}} = \frac{1}{N} \sum_{i=1}^{N} \langle Z_i \rangle$ of a Trotterized transverse-field Ising model (TFIM) on eight qubits in a ring topology. You will sweep several values of the strength of the transverse field and plot the magnetization as a function of the field strength.

### Compute exact expectation values using Qiskit's statevector simulator

Use Qiskit's ``Statevector`` class to compute the exact expectation value of $Z_i$ on each site for every value of $\theta$.

### Compute noisy, unmitigated expectation values

A ``QuantumProgram`` contains a quantum circuit and a samplex in a format suitable for the [Executor primitive](https://quantum.cloud.ibm.com/docs/ibm-quantum-compute/get-started-with-executor). `MitigationTask.prepare` builds a ``QuantumProgram`` from the circuit, the observables, and the parameter values, and boxes the circuit with the given boxing options. You set the ``measure_annotations`` boxing option to ``"change_basis"``, which rotates the measurements into the required bases, and add ``add_tags: "unique_box"`` so the simulator can map a noise model onto the boxes of the circuit. The program is Pauli-twirled by default, which on hardware turns coherent noise into the Pauli noise that the mitigation methods assume. `num_randomizations` sets how many twirled instances of each circuit are sampled and `shots_per_randomization` sets how many shots each instance receives, so their product is the shot budget per circuit.

A user with QPU access would execute the program with an `Executor` built from a backend of the `QiskitRuntimeService`. Here, you will pass an `AerSimulator` to the `Executor`, which runs the program locally, and use its `layer_noise_model` simulator option to inject a random Pauli-Lindblad noise model on every layer of entangling gates, generated with `random_pauli_lindblad_noise` from `qiskit-mitigation` with an error per layered gate (EPLG) of ``0.003``, typical of current Heron QPUs.

### Prepare a ZNE program with digital gate folding and sample circuits of varying noise scales

Prepare a ZNE program containing circuits of increasing noise scales. Each noise factor represents the multiple of entangling gates that the circuit contains (noise factor of ``3.0`` holds three times more entangling gates than the original circuit). Each noise factor's circuit is twirled with the same number of randomizations and shots as the unmitigated program.

Draw the first Trotter step of the twirled template with noise factor 1 and with noise factor 3 to visualize the amplification. For noise factor 3.0, every layer of the circuit is replaced by the layer, its inverse, and the layer again.

Finally, run the program on the noisy simulator. Its results feed the extrapolation in the next step.

### Extrapolate to the zero-noise limit with built-in and custom fitting functions

Now that you have data for each noise scale, you can fit a function to the data and extrapolate back to the zero-noise value to estimate an expectation value of the noise-free observable. There are many ways to fit data, and the right choice of function depends on the nature of the data being sampled. ``GateFolding.postprocess`` provides several built-in extrapolation functions, including ``linear``, ``exponential``, and ``double_exponential``. The `postprocess` method takes a list of extrapolation methods, evaluates them in order, and returns the first value with physically-valid values and finite variance. This means the order in which you specify the extrapolators has a big impact on which extrapolator is chosen. Submitting ``fallback`` as an extrapolator means if no valid answers were found, the expectation value of the smallest noise factor will be chosen and returned. If ``fallback`` is not submitted and no extrapolator yields a physically-valid value, the result with the smallest ``std`` is returned. Under Pauli noise an observable decays exponentially with the noise factor, so with 30 layers (15 Trotter steps, 2 layers per step) of entangling gates the exponential extrapolator is the natural choice; you can also extrapolate linearly, which is a common choice when the decay is small.

To use a custom fitting function, pass the `"custom"` extrapolator together with a `custom_fit` tuple containing the fitting function, a list with an initial guess for each of its parameters, and bounds. These are forwarded to ``scipy.optimize.curve_fit``. Post-processing can be repeated with different extrapolators without re-executing the program. Here you use a custom square-root fitting function. To visualize the extrapolation, plot the site-averaged magnetization calculated at each noise factor for $\theta = 0.15\pi$, the three fits, and the site average of the extrapolated expectation values at the zero-noise point. The three data points look nearly linear, yet the linear extrapolation lands visibly below the exact value. As predicted, the exponential fit most-effectively estimates the noiseless expectation value.

### Compare the mitigated expectation values

Plot the site-averaged magnetization of each method across the sweep across Ising rotation angles. Exponential extrapolation recovers the exact magnetization within its error bars, while linear extrapolation removes much of the bias but consistently undershoots, because the true decay is exponential. The square-root fit overshoots badly.
