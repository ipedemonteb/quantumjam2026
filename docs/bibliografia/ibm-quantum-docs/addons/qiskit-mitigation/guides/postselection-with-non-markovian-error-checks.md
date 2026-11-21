# Postselection with non-Markovian error checks

> Fuente: <https://github.com/Qiskit/documentation/tree/main/docs/addons/qiskit-mitigation/guides/postselection-with-non-markovian-error-checks>

This guide explains what non-Markovian error checks are and how to implement them in software with ``qiskit-mitigation``. You will start with a small, two-qubit example to visualize the checks and discuss how they work. After you have built up some intuition, you will try a 20-qubit example where you implement checks and compare various postselection strategies.

#### What are non-Markovian error checks?
Non-Markovian error checks are measurement-based tests of whether a qubit's state is likely corrupted by a non-Markovian error source. This test is done by placing a bit-flip gate with extended duration (``xslow`` or a series of $N$ ``rx`` gates with angle $\frac{\pi}{N}$) on each qubit at the beginning of a circuit, followed by a regular ``XGate`` and measuring to ensure the state successfully flipped from $|0\rangle \mapsto |1\rangle \mapsto |0\rangle$. This test can also be performed at the end of the circuit after each terminal measurement to ensure the device can successfully flip the measured state of the qubit from $|x\rangle \mapsto |x\oplus1\rangle$. Samples associated with failed checks may be considered unreliable, and postselecting only samples that pass all checks can boost the fidelity of the noisy distribution.

#### Strategies for postselecting based on non-Markovian error checks
- **Node-based postselection**: Postselect only samples for which each qubit passed its check(s). This is the strictest strategy and generally results in more samples being discarded.
- **Edge-based postselection**: For each edge in the qubits' coupling graph, ensure at least one qubit passes the check(s). This strategy is more lenient; if a qubit fails a check, the sample may still be kept if all its neighbors pass their checks.

#### Spectator qubits
One can specify "spectator" ancilla qubits that are adjacent to the qubits used to execute the original circuit. Non-Markovian error checks can be placed on these spectators, providing more coverage against the non-Markovian noise these checks are designed to detect.

### Part 1. Visualize non-Markovian error checks

Before demonstrating the technique on a QPU, you will create a small, two-qubit circuit and add checks to visualize how it works. Start with a Bell state transpiled to the ``ibm_kingston`` backend QPU.

Add some non-Markovian error checks to the beginning of the circuit. **Checks will only be placed on qubits that are terminated with a measurement**. These checks ensure the device can successfully flip the qubit's initial state from $|0\rangle \mapsto |1\rangle \mapsto |0\rangle$, and these checks' measurements are read out in a new classical register called ``meas_pre``.

Similarly, you can add checks to the end of the circuit after each terminal measurement. These checks ensure the device can flip the qubit's state from $|x\rangle \mapsto |x\oplus1\rangle$, and their measurements are read out in a new classical register called ``meas_ps``.

As mentioned in the introduction, you can use ancilla qubits that are adjacent to the data qubits as "spectators" to provide more error coverage. Add pre-circuit and post-circuit spectator checks. You can see that since physical qubit ``2`` on ``ibm_kingston`` is adjacent to data qubit ``1``, it has been added as a spectator, and pre- and post-circuit checks have been added to it. The spectator measurements have been added to new classical registers called ``spec_pre`` and ``spec``.

A circuit such as this contains all possible non-Markovian error checks, so sampling from this circuit gives users the ability to postselect based on any combination of [pre/post]-circuit checks and [node/edge]-based postselection strategy. See Part 2 of this guide to see how it works on quantum hardware.

### Part 2: Demonstrate non-Markovian error checks on a QPU and compare postselection strategies

Now that you have an understanding of what non-Markovian error checks are and how they are implemented in software, you can run a larger example on a QPU and see how it works.

First, prepare a circuit. The choice of circuit isn't very important; you only need a circuit for which you can easily verify the output. Here we choose a 20-qubit, 1D mirrored Ising circuit. This circuit is non-trivial to execute on hardware and should be affected by non-Markovian errors, which provides the opportunity to demonstrate the effectiveness of the non-Markovian error checks. Also, the mirrored structure allows us to trivially compare the noisy expectation value calculations against exact values.

In this experiment, we are calculating observable expectation values. The choice of observable $O$ isn't important either, so we simply choose the average single-site magnetization $O=\frac{1}{N}\sum_i\langle Z_i\rangle$.

Now we add pre- and post-circuit checks on every qubit, including the seven adjacent spectator qubits. When you add all possible checks to a circuit, you can decide which postselection strategy to use during postprocessing.

Use the ``Executor`` primitive to sample the circuit containing the checks.

The ``PostSelector`` class knows about the `creg` structure of the checks, so it can associate each bit in the samples to its associated circuit measurement. Its `compute_mask` method can be used to create a mask over a sequence of samples, given the postselection strategy (node or edge) and the type of non-Markovian error checks to look at (pre- or post-circuit). To combine pre- and post-circuit strategies into a single mask, their masks can be calculated independently and then combined with the ``AND`` operation. Here we use the ``PostSelector`` to create masks for all of the various strategies and look at the results using every permutation of strategies available.

In the visualization below, we see how postselection strategy affects postselection rate, as well as the quality of answer. As expected, the strategies involving node-based postselection resulted in the lowest postselection rates. The edge-based strategies are more lenient and tend to result in higher postselection rates. Users should experiment with the various strategies on their problem to determine the right balance between postselection rate and quality of sampled distribution. In this example, using node-based postselection with the pre- and post-circuit checks resulted in the best answer with a postselection rate of ``.028%``. Some of the strategies did not outperform the raw circuit. You can also see that adding the checks but not using any of them (bar labeled "no selection" in chart below) performs the worst.
