# Medir qubits

> Fuente: <https://quantum.cloud.ibm.com/docs/en/qiskit/measure-qubits>

> Documentación de IBM Quantum Platform (repositorio <https://github.com/Qiskit/documentation>). Solo texto, sin las celdas de código.

# Measure qubits

<Accordion>
<AccordionItem title="Package versions">

The code on this page was developed using the following requirements.
We recommend using these versions or newer.

```
qiskit[all]~=2.6.2
```
</AccordionItem>
</Accordion>

To get information about a qubit's state, you can _measure_ it onto a [classical bit](https://quantum.cloud.ibm.com/docs/api/qiskit/circuit#qiskit.circuit.Clbit). In Qiskit, measurements are performed in the computational basis, that is, the single-qubit Pauli-$Z$ basis. Therefore, a measurement yields 0 or 1, depending on the overlap with the Pauli-$Z$ eigenstates $|0\rangle$ and $|1\rangle$:

$$
|q\rangle \xrightarrow{measure}\begin{cases}
      0 (\text{outcome}+1), \text{with probability } p_0=|\langle q|0\rangle|^{2}\text{,} \\
      1 (\text{outcome}-1), \text{with probability } p_1=|\langle q|1\rangle|^{2}\text{.}
    \end{cases}
$$

## Apply a measurement to a circuit

There are several ways to apply measurements to a circuit:

### `QuantumCircuit.measure` method

Use the [`measure`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.QuantumCircuit#measure) method to measure a [`QuantumCircuit`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.QuantumCircuit#quantumcircuit-class).

Examples:

### `Measure` class

The Qiskit [Measure](https://quantum.cloud.ibm.com/docs/api/qiskit/circuit#qiskit.circuit.Measure) class measures the specified qubits.

### `QuantumCircuit.measure_all` method

To measure all qubits into the corresponding classical bits, use the [`measure_all`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.QuantumCircuit#measure_all) method. By default, this method adds new classical bits in a `ClassicalRegister` to store these measurements.

### `QuantumCircuit.measure_active` method

To measure all qubits that are not idle, use the [`measure_active`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.QuantumCircuit#measure_active) method. This method creates a new `ClassicalRegister` with a size equal to the number of non-idle qubits being measured.

## Next steps

<Admonition type="tip" title="Recommendations">
- [`Measure`](https://quantum.cloud.ibm.com/docs/api/qiskit/circuit#qiskit.circuit.Measure) class
- [`measure_all`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.QuantumCircuit#measure_all) method
- [`measure_active`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.QuantumCircuit#measure_active) method
- [`random_circuit`](https://quantum.cloud.ibm.com/docs/api/qiskit/circuit_random#qiskit.circuit.random.random_circuit) method
- [Mid-circuit measurements](https://quantum.cloud.ibm.com/docs/ibm-quantum-compute/execute-dynamic-circuits#midcircuit) (Available only when using IBM Quantum&reg; Compute Service.)
</Admonition>
