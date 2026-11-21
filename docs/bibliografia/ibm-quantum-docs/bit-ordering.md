# Orden de bits

> Fuente: <https://quantum.cloud.ibm.com/docs/en/qiskit/bit-ordering>

> Documentación de IBM Quantum Platform (repositorio <https://github.com/Qiskit/documentation>). Solo texto, sin las celdas de código.

<Accordion>
<AccordionItem title="Package versions">

The code on this page was developed using the following requirements.
We recommend using these versions or newer.

```
qiskit[all]~=2.6.2
```
</AccordionItem>
</Accordion>

# Bit-ordering in the Qiskit SDK

If you have a set of $n$ bits (or qubits), you'll usually label each bit $0
\rightarrow n-1$. Different softwares and resources must choose how they order
these bits both in computer memory and when displayed on-screen.

## Qiskit conventions

Here's how the Qiskit SDK orders bits in different scenarios.

### Primitives

By default, Qiskit follows the little-endian bit ordering convention. However, the default for [`BitArray`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.primitives.BitArray#to_bool_array) is `big` (endian), which causes some differences in primitive output, depending on whether the primitive changes this setting. For example, the IBM&reg; Quantum Compute Service Sampler and Estimator primitives return big-endian results, but Executor returns little-endian results.

### Quantum circuits

The `QuantumCircuit` class stores its qubits in a list
(`QuantumCircuit.qubits`). The index of a qubit in this list defines the
qubit's label.

### Circuit diagrams

On a circuit diagram, qubit $0$ is the topmost qubit, and qubit $n-1$ the
bottommost qubit. You can change this with the `reverse_bits` argument of
`QuantumCircuit.draw` (see [Change ordering in
Qiskit](#change-ordering-in-qiskit)).

### Integers

When interpreting bits as a number, bit $0$ is the least significant bit, and
bit $n-1$ the most significant. This is helpful when coding because each bit has
the value $2^\text{label}$ (label being the qubit's index in
`QuantumCircuit.qubits`). For example, the following circuit execution ends
with bit $0$ being `0`, and bit $1$ being `1`. This is interpreted as the
decimal integer `2` (measured with probability `1.0`).

### Strings

When displaying or interpreting a list of bits (or qubits) as a string, bit
$n-1$ is the leftmost bit, and bit $0$ is the rightmost bit. This is because we
usually write numbers with the most significant digit on the left, and in
Qiskit, bit $n-1$ is interpreted as the most significant bit.

For example, the following cell defines a `Statevector` from a string of
single-qubit states. In this case, qubit $0$ is in state $|+\rangle$, and
qubit $1$ in state $|0\rangle$.

This occasionally causes confusion when interpreting a string of bits, as you
might expect the leftmost bit to be bit $0$, whereas it usually represents bit
$n-1$.

### Statevector matrices

When representing a statevector as a list of complex numbers (amplitudes),
Qiskit orders these amplitudes such that the amplitude at index $x$ represents
the computational basis state $|x\rangle$.

### Gates

Each gate in Qiskit can interpret a list of qubits in its own way, but
controlled gates usually follow the convention `(control, target)`.

For example, the following cell adds a controlled-X gate where qubit $0$ is
the control and qubit $1$ is the target.

Following all the previously mentioned conventions in Qiskit, this CX-gate
performs the transformation $|01\rangle \leftrightarrow |11\rangle$, so has the
following matrix.

$$
\begin{pmatrix}
 1 & 0 & 0 & 0 \\
 0 & 0 & 0 & 1 \\
 0 & 0 & 1 & 0 \\
 0 & 1 & 0 & 0 \\
\end{pmatrix}
$$

## Change ordering in Qiskit

To draw a circuit with qubits in reversed order (that is, qubit $0$ at the
bottom), use the `reverse_bits` argument. This only affects the generated
diagram and does not affect the circuit; the X-gate still acts on qubit $0$.

You can use the `reverse_bits` method to return a new circuit with the
qubits' labels reversed (this does not mutate the original circuit).

Note that in this new circuit, the X-gate acts on qubit $1$.

## Next steps

<Admonition type="tip" title="Recommendations">
  -  See an example of using circuits in the [Grover's Algorithm](https://quantum.cloud.ibm.com/docs/tutorials/grovers-algorithm) tutorial.
  -  Explore the [QuantumCircuit API](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.QuantumCircuit#quantumcircuit-class) reference.
</Admonition>
