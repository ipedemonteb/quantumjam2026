# Construir circuitos

> Fuente: <https://quantum.cloud.ibm.com/docs/en/qiskit/construct-circuits>

> Documentación de IBM Quantum Platform (repositorio <https://github.com/Qiskit/documentation>). Solo texto, sin las celdas de código.

# Construct circuits

<Accordion>
<AccordionItem title="Package versions">

The code on this page was developed using the following requirements.
We recommend using these versions or newer.

```
qiskit[all]~=2.6.2
```
</AccordionItem>
</Accordion>

This page takes a closer look at the [`QuantumCircuit`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.QuantumCircuit) class in the Qiskit SDK, including some more advanced methods you can use to create quantum circuits.

## What is a quantum circuit?

A simple quantum circuit is a collection of qubits and a list of instructions that act on those qubits. To demonstrate, the following cell creates a new circuit with two new qubits, then displays the circuit's [`qubits`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.QuantumCircuit#qubits) attribute, which is a list of [`Qubits`](https://quantum.cloud.ibm.com/docs/api/qiskit/circuit#qiskit.circuit.Qubit) in order from the least significant bit $q_0$ to the most significant bit $q_n$.

Multiple `QuantumRegister` and `ClassicalRegister` objects can be combined to create a circuit. Every [`QuantumRegister`](https://quantum.cloud.ibm.com/docs/api/qiskit/circuit#qiskit.circuit.QuantumRegister) and [`ClassicalRegister`](https://quantum.cloud.ibm.com/docs/api/qiskit/circuit#qiskit.circuit.ClassicalRegister) can also be named.

You can find a qubit's index and register by using the circuit's [`find_bit`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.QuantumCircuit#qiskit.circuit.QuantumCircuit.find_bit) method and its attributes.

Adding an instruction to the circuit appends the instruction to the circuit's [`data`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.QuantumCircuit#data) attribute. The following cell output shows `data` is a list of [`CircuitInstruction`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.CircuitInstruction) objects, each of which has an `operation` attribute, and a `qubits` attribute.

The easiest way to view this information is through the [`draw`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.QuantumCircuit#draw) method, which returns a visualization of a circuit. See [Visualize circuits](https://quantum.cloud.ibm.com/docs/qiskit/visualize-circuits) for different ways of displaying quantum circuits.

Circuit instruction objects can contain "definition" circuits that describe the instruction in terms of more fundamental instructions. For example, the [X-gate](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.library.XGate) is defined as a specific case of the [U3-gate](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.library.U3Gate), a more general single-qubit gate.

Instructions and circuits are similar in that they both describe operations on bits and qubits, but they have different purposes:

- Instructions are treated as fixed, and their methods will usually return new instructions (without mutating the original object).
- Circuits are designed to be built over many lines of code, and [`QuantumCircuit`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.QuantumCircuit) methods often mutate the existing object.

### What is circuit depth?

The [depth()](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.QuantumCircuit#qiskit.circuit.QuantumCircuit.depth) of a quantum circuit is a measure of the number of “layers” of quantum gates, executed in parallel, it takes to complete the computation defined by the circuit. Because quantum gates take time to implement, the depth of a circuit roughly corresponds to the amount of time it takes the quantum computer to execute the circuit. Thus, the depth of a circuit is one important quantity used to measure if a quantum circuit can be run on a device.

The rest of this page illustrates how to manipulate quantum circuits.

## Build circuits

Methods such as [`QuantumCircuit.h`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.QuantumCircuit#h) and [`QuantumCircuit.cx`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.QuantumCircuit#cx) add specific instructions to circuits. To add instructions to a circuit more generally, use the [`append`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.QuantumCircuit#append) method. This takes an instruction and a list of qubits to apply the instruction to. See the [Circuit Library API documentation](https://quantum.cloud.ibm.com/docs/api/qiskit/circuit_library) for a list of supported instructions.

To combine two circuits, use the [`compose`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.QuantumCircuit#compose) method. This accepts another [`QuantumCircuit`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.QuantumCircuit) and an optional list of qubit mappings.

<Admonition type="note">
    The [`compose`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.QuantumCircuit#compose) method returns a new circuit and does **not** mutate either circuit it acts on. To mutate the circuit on which you're calling the [`compose`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.QuantumCircuit#compose) method, use the argument `inplace=True`.
</Admonition>

You might also want to compile circuits into instructions to keep your circuits organized. You can convert a circuit to an instruction by using the [`to_instruction`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.QuantumCircuit#to_instruction) method, then append this to another circuit as you would any other instruction. The circuit drawn in the following cell is functionally equivalent to the circuit drawn in the previous cell.

If your circuit is unitary, you can convert it to a [`Gate`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.Gate)  by using the [`to_gate`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.QuantumCircuit#to_gate) method. [`Gate`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.Gate) objects are specific types of instructions that have some extra features, such as the [`control`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.Gate#control) method, which adds a quantum control.

To see what's going on, you can use the [`decompose`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.QuantumCircuit#decompose) method to expand each instruction into its definition.

<Admonition type="note">
    The [`decompose`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.QuantumCircuit#decompose) method returns a new circuit and does **not** mutate the circuit it acts on.
</Admonition>

<span id="measure-qubits"></span>
## Measure qubits

Measurements are used to sample the states of individual qubits and transfer the results to a classical register. Note that if you are submitting circuits to a [Sampler](https://quantum.cloud.ibm.com/docs/ibm-quantum-compute/get-started-with-sampler) primitive, measurements are required. However, circuits submitted to an [Estimator](https://quantum.cloud.ibm.com/docs/ibm-quantum-compute/get-started-with-estimator) primitive must not contain measurements.

Qubits can be measured using three methods: [`measure`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.QuantumCircuit#qiskit.circuit.QuantumCircuit.measure), [`measure_all`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.QuantumCircuit#measure_all) and [`measure_active`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.QuantumCircuit#measure_active). To learn how to visualize measured results, see the [Visualize results](https://quantum.cloud.ibm.com/docs/qiskit/visualize-results) page.

1. `QuantumCircuit.measure` : measures each qubit in the first argument onto the classical bit given as the second argument. This method allows full control over where the measurement result is stored.

2. `QuantumCircuit.measure_all` : takes no argument and can be used for quantum circuits without pre-defined classical bits. It creates classical wires and stores measurement results in order. For example, measurement of  qubit $q_i$ is stored in cbit $meas_i$). It also adds a barrier before the measurement.

3. `QuantumCircuit.measure_active` : similar to `measure_all`, but measures only qubits that have operations.

## Parameterized circuits

Many near-term quantum algorithms involve executing many variations of a quantum circuit. Since constructing and optimizing large circuits can be computationally expensive, Qiskit supports **parameterized** circuits. These circuits have undefined parameters, and their values do not need to be defined until just before executing the circuit. This lets you move circuit construction and optimization out of the main program loop.  The following cell creates and displays a parameterized circuit.

The following cell creates many variations of this circuit and displays one of the variations.

You can find a list of a circuit's undefined parameters in its `parameters` attribute.

### Change a parameter's name

By default, parameter names for a parameterized circuit are prefixed by `x`- for example, `x[0]`. You can change the names after they are defined, as shown in the following example.

## Next steps

<Admonition type="tip" title="Recommendations">
  -  To learn about near-term quantum algorithms, take the [Variational algorithm design](https://quantum.cloud.ibm.com/learning/courses/variational-algorithm-design) course.
  -  See an example of circuits being used in the [Grover's Algorithm](https://quantum.cloud.ibm.com/docs/tutorials/grovers-algorithm) tutorial.
  -  Work with simple circuits using [IBM Quantum&reg; Composer](https://quantum.cloud.ibm.com/docs/guides/composer).
</Admonition>
