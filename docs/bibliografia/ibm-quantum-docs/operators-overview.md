# Operadores: visión general

> Fuente: <https://quantum.cloud.ibm.com/docs/en/qiskit/operators-overview>

> Documentación de IBM Quantum Platform (repositorio <https://github.com/Qiskit/documentation>). Solo texto, sin las celdas de código.

# Overview of operator classes

<Accordion>
<AccordionItem title="Package versions">

The code on this page was developed using the following requirements.
We recommend using these versions or newer.

```
qiskit[all]~=2.6.2
```
</AccordionItem>
</Accordion>

In Qiskit, quantum operators are represented using classes from the [`quantum_info`](https://quantum.cloud.ibm.com/docs/api/qiskit/quantum_info) module. The most important operator class is [`SparsePauliOp`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.quantum_info.SparsePauliOp), which represents a general quantum operator as a linear combination of Pauli strings. `SparsePauliOp` is the class most commonly used to represent quantum observables. The rest of this page explains how to use `SparsePauliOp` and other operator classes.

## SparsePauliOp

The [`SparsePauliOp`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.quantum_info.SparsePauliOp) class represents a linear combination of Pauli strings. There are several ways to initialize a `SparsePauliOp`, but the most flexible way is to use the [`from_sparse_list`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.quantum_info.SparsePauliOp#from_sparse_list) method, as demonstrated in the following code cell. The `from_sparse_list` accepts a list of `(pauli_string, qubit_indices, coefficient)` triplets.

`SparsePauliOp` supports arithmetic operations, as demonstrated in the following code cell.

## Pauli

The [`Pauli`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.quantum_info.Pauli) class represents a single Pauli string with an optional phase coefficient from the set $\set{+1, i, -1, -i}$. A `Pauli` can be initialized by passing a string of characters from the set `{"I", "X", "Y", "Z"}`, optionally prefixed by one of `{"", "i", "-", "-i"}` to represent the phase coefficient.

The following code cell demonstrates the use of some attributes and methods.

`Pauli` objects possess a number of other methods to manipulate the operators such as determining its adjoint, whether it (anti)commutes with another `Pauli`, and computing the dot product with another `Pauli`. Refer to the [API documentation](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.quantum_info.Pauli) for more info.

## Operator

The [`Operator`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.quantum_info.Operator) class represents a general linear operator. Unlike `SparsePauliOp`, `Operator` stores the linear operator as a dense matrix. Because the memory required to store a dense matrix scales exponentially with the number of qubits, the `Operator` class is only suitable for use with a small number of qubits.

You can initialize an `Operator` by directly passing a Numpy array storing the matrix of the operator. For example, the following code cell creates a two-qubit Pauli XX operator:

The operator object stores the underlying matrix, and the input and output dimension of subsystems.

* `data`: To access the underlying Numpy array, you can use the `Operator.data` property.
* `dim`: To return the total input and output dimension of the operator, you can use the `Operator.dim` property. *Note: the output is returned as a tuple* `(input_dim, output_dim)`, *which is the reverse of the shape of the underlying matrix.*

The operator class also keeps track of subsystem dimensions, which can be used for composing operators together. These can be accessed using the `input_dims` and `output_dims` functions.

For $2^N$ by $2^M$ operators, the input and output dimensions are automatically assumed to be M-qubit and N-qubit:

If the input matrix is not divisible into qubit subsystems, then it will be stored as a single-qubit operator. For example, for a $6\times6$ matrix:

The input and output dimension can also be manually specified when initializing a new operator:

You can also extract just the input or output dimensions of a subset of subsystems using the `input_dims` and `output_dims` functions:

## Next steps

<Admonition type="tip" title="Recommendations">
  - Learn how to [specify observables in the Pauli basis](https://quantum.cloud.ibm.com/docs/qiskit/specify-observables-pauli).
  - See an example of using operators in the [Combine error mitigation options with the Estimator primitive](https://quantum.cloud.ibm.com/docs/tutorials/combine-error-mitigation-techniques) tutorial.
  - Read more [in-depth coverage of the Operator class](https://quantum.cloud.ibm.com/docs/qiskit/operator-class).
  - Explore the [Operator API](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.quantum_info.Operator#operator) reference.
</Admonition>
