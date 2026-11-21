# Dynamical decoupling

> Fuente: <https://quantum.cloud.ibm.com/docs/en/qiskit/dynamical-decoupling-pass-manager>

> Documentación de IBM Quantum Platform (repositorio <https://github.com/Qiskit/documentation>). Solo texto, sin las celdas de código.

# Create a pass manager for dynamical decoupling

<Accordion>
<AccordionItem title="Package versions">

The code on this page was developed using the following requirements.
We recommend using these versions or newer.

```
qiskit[all]~=2.6.2
qiskit-ibm-runtime~=0.52.0
```
</AccordionItem>
</Accordion>

This page demonstrates how to use the [`PadDynamicalDecoupling`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.transpiler.passes.PadDynamicalDecoupling) pass to add an error suppression technique called _dynamical decoupling_ to the circuit.

Dynamical decoupling works by adding pulse sequences (known as _dynamical decoupling sequences_) to idle qubits to flip them around the Bloch sphere, which cancels the effect of noise channels, thereby suppressing decoherence. These pulse sequences are similar to refocusing pulses used in nuclear magnetic resonance. For a full description, see [A Quantum Engineer's Guide to Superconducting Qubits](https://arxiv.org/abs/1904.06560).

Because the `PadDynamicalDecoupling` pass only operates on scheduled circuits and involves gates that are not necessarily basis gates of our target, you will need the [`ALAPScheduleAnalysis`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.transpiler.passes.ALAPScheduleAnalysis) and [`BasisTranslator`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.transpiler.passes.BasisTranslator) passes as well.

Get the `target` information from the `backend` and save the operation names as `basis_gates` because the `target` will need to be modified to add timing information for the gates used in dynamical decoupling.

<Admonition type="note">
The  `FakeSherbrooke` mock backend from `qiskit_ibm_runtime` is used in these examples, but you can try it on any Qiskit-compatible real or fake backend.  Your results might be different.
</Admonition>

Create an `efficient_su2` circuit as an example. First, transpile the circuit to the backend because dynamical decoupling pulses need to be added after the circuit has been transpiled and scheduled. Dynamical decoupling often works best when there is a lot of idle time in the quantum circuits - that is, there are qubits that are not being used while others are active. This is the case in this circuit because the two-qubit `ecr` gates are applied sequentially in this ansatz.

A dynamical decoupling sequence is a series of gates that compose to the identity and are spaced regularly in time. For example, start by creating a simple sequence called XY4 consisting of four gates.

Because of the regular timing of dynamical decoupling sequences, information about the `YGate` must be added to the `target` because it is *not* a basis gate, whereas the `XGate` is. We know *a priori* that the `YGate` has the same duration and error as the `XGate`, however, so we can just retrieve those properties from the `target` and add them back for the `YGate` objects. This is also why the `basis_gates` were saved separately, since we are adding the `YGate` instruction to the `target` although it is not an actual basis gate of `ibm_fez`.

Ansatz circuits such as `efficient_su2` are parameterized, so they must have value bound to them before being sent to the backend. Here, assign random parameters.

Next, execute the custom passes. Instantiate the `PassManager` with `ALAPScheduleAnalysis` and `PadDynamicalDecoupling`.  Run `ALAPScheduleAnalysis` first to add timing information about the quantum circuit before the regularly-spaced dynamical decoupling sequences can be added. These passes are run on the circuit with `.run()`.

Use the visualization tool [`timeline_drawer`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.visualization.timeline_drawer) to see the circuit's timing and confirm that a regularly-spaced sequence of `XGate` objects and `YGate` objects appear in the circuit.

Lastly, because the `YGate` is not an actual basis gate of our backend, manually apply the `BasisTranslator` pass (this is a default pass, but it is executed before scheduling, so it needs to be applied again). The session equivalence library is a library of circuit equivalences that allows the transpiler to decompose circuits into basis gates, as also specified as an argument.

Now, `YGate` objects are absent from our circuit, and there is explicit timing information in the form of `Delay` gates. This transpiled circuit with dynamical decoupling is now ready to be sent to the backend.

## Next steps

<Admonition type="tip" title="Recommendations">
    - To learn how to use the `generate_preset_passmanager` function instead of writing your own passes, start with the [Transpilation default settings and configuration options](defaults-and-configuration-options) topic.
    - Try the [Compare transpiler settings](https://quantum.cloud.ibm.com/docs/qiskit/circuit-transpilation-settings#compare-transpiler-settings) guide.
    - See the [Transpile API documentation](https://docs.quantum-computing.ibm.com/api/qiskit/transpiler).
</Admonition>
