# Circuit library (ansatz)

> Fuente: <https://quantum.cloud.ibm.com/docs/en/qiskit/circuit-library>

> Documentación de IBM Quantum Platform (repositorio <https://github.com/Qiskit/documentation>). Solo texto, sin las celdas de código.

# Circuit library

<Accordion>
<AccordionItem title="Package versions">

The code on this page was developed using the following requirements.
We recommend using these versions or newer.

```
qiskit[all]~=2.6.2
```
</AccordionItem>
</Accordion>

The Qiskit SDK includes a library of popular circuits to use as building blocks in your own programs. Using pre-defined circuits saves time researching, writing code, and debugging. The library includes popular circuits in quantum computing, circuits that are difficult to simulate classically, and circuits useful for quantum hardware benchmarking.

This page lists the different circuit categories the library provides. For a full list of circuits, see the [circuit library API documentation](https://quantum.cloud.ibm.com/docs/api/qiskit/circuit_library).

## Standard gates

The circuit library also includes standard quantum gates. Some are more fundamental gates (such as the `UGate`), and others are multi-qubit gates that usually need building from single- and two-qubit gates. To add imported gates to your circuit, use the `append` method; the first argument is the gate, and the next argument is a list of qubits to apply the gate to.

For example, the following code cell creates a circuit with a Hadamard gate and a multi-controlled-X gate.

See [Standard gates](https://quantum.cloud.ibm.com/docs/api/qiskit/circuit_library#standard-gates) in the circuit library API documentation.

## N-local circuits

These circuits alternate layers of single-qubit rotation gates with layers of multi-qubit entangling gates.

This family of circuits is popular in variational quantum algorithms because they can produce a wide range of quantum states. Variational algorithms adjust the gate parameters to find states that have certain properties (such as states that represent a good solution to an optimization problem). For this purpose, many circuits in the library are **parameterized**, which means you can define them without fixed values.

The following code cell imports a `n_local` circuit, in which the entangling gates are two-qubit gates. This circuit interleaves blocks of parameterized single-qubit gates, followed by entangling blocks of two-qubit gates. The following code creates a three-qubit circuit, with single-qubit RX-gates and two-qubit CZ-gates.

You can get a list-like object of the circuit's parameters from the `parameters` attribute.

You can also use this to assign these parameters to real values using a dictionary of the form `{ Parameter: number }`. To demonstrate, the following code cell assigns each parameter in the circuit to `0`.

For more information, see [N-local gates](https://quantum.cloud.ibm.com/docs/api/qiskit/circuit_library#n-local-circuits) in the circuit library API documentation or take the [Variational algorithm design course](https://quantum.cloud.ibm.com/learning/courses/variational-algorithm-design) in IBM Quantum&reg; Learning.

## Data-encoding circuits

These parameterized circuits encode data onto quantum states for processing by quantum machine learning algorithms. Some circuits supported by Qiskit are:
 - Amplitude encoding, which encodes each number into the amplitude of a basis state. This can store $2^n$ numbers in a single state, but can be costly to implement.
 - Basis encoding, which encodes an integer $k$ by preparing the corresponding basis state $|k\rangle$.
 - Angle encoding, which sets each number in the data as a rotation angle in a parameterized circuit.

The best approach depends upon the specifics of your application. On current quantum computers, however, we often use angle-encoding circuits such as the `zz_feature_map`.

See [Data encoding circuits](https://quantum.cloud.ibm.com/docs/api/qiskit/circuit_library#data-encoding-circuits) in the circuit library API documentation.

## Time-evolution circuits

These circuits simulate a quantum state evolving in time. Use time-evolution circuits to investigate physical effects such as heat transfer or phase transitions in a system. Time-evolution circuits are also a fundamental building block of chemistry wave functions (such as unitary coupled-cluster trial states) and of the QAOA algorithm we use for optimization problems.

Read the [`PauliEvolutionGate` API documentation](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.library.PauliEvolutionGate).

## Benchmarking and complexity-theory circuits

Benchmarking circuits give us a sense of how well our hardware is actually working, and complexity-theory circuits help us understand how difficult the problems we want to solve are.

For example, the "quantum volume" benchmark measures how accurately a quantum computer executes a type of random quantum circuit. The score of the quantum computer increases with the size of the circuit it can reliably run. This takes into account all aspects of the computer, including qubit count, instruction fidelity, qubit connectivity, and the software stack transpiling and post-processing results. Read more about quantum volume in the original [quantum volume paper](https://arxiv.org/abs/1811.12926).

The following code shows an example of a quantum volume circuit built in Qiskit that runs on four qubits (the `unitary` blocks are randomized two-qubit gates).

The circuit library also includes circuits believed to be hard to simulate classically, such as instantaneous quantum polynomial (iqp) circuits. These circuits sandwich certain diagonal gates (in the computational basis) between blocks of Hadamard gates.

Other circuits include `grover_operator` for use in Grover's algorithm, and the `fourier_checking` circuit for the Fourier checking problem. See these circuits in [Particular quantum circuits](https://quantum.cloud.ibm.com/docs/api/qiskit/circuit_library#particular-quantum-circuits) in the circuit library API documentation.

## Arithmetic circuits

Arithmetic operations are classical functions, such as adding integers and bit-wise operations. These may be useful with algorithms such as amplitude estimation for finance applications, and in algorithms like the HHL algorithm, which solves linear systems of equations.

As an example, let’s try adding two three-bit numbers using a "ripple-carry" circuit to perform in-place addition (`FullAdderGate`). This adder adds two numbers (we'll call them "A" and "B") and writes the result to the register that held B. In the following example, A=2 and B=3.

Simulating the circuit shows that it outputs `5` for all `1024` shots (i.e. is measured with probability `1.0`).

See [Arithmetic](https://quantum.cloud.ibm.com/docs/api/qiskit/circuit_library#arithmetic) in the circuit library API documentation.

## Next steps

<Admonition type="tip" title="Recommendations">
  -  Learn advanced methods for creating circuits in the [Construct circuits](https://quantum.cloud.ibm.com/docs/qiskit/construct-circuits) topic.
  -  See an example of circuits being used in the [Grover's Algorithm](https://quantum.cloud.ibm.com/docs/tutorials/grovers-algorithm) tutorial.
  -  Review the [circuit library API](https://quantum.cloud.ibm.com/docs/api/qiskit/circuit_library) reference.
</Admonition>
