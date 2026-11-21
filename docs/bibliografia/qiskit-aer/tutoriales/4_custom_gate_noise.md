# Applying noise to custom unitary gates

> Fuente: <https://github.com/Qiskit/qiskit-aer/blob/main/docs/tutorials/4_custom_gate_noise.ipynb>

## Introduction

This notebook shows how to add custom unitary gates to a quantum circuit, and use them for noise simulations in Qiskit Aer.

## Creating matrix operators

We can use the `Operator` class in `qiskit.quantum_info` to represent arbitrary matrix operators. If the operator is unitary it can then be added to a quantum circuit and used for simulation on Qiskit Aer.

Lets create two operators below for a CNOT gate and an iSWAP gate:

$$\mbox{CNOT} = \left(\begin{array} 
& 1 & 0 & 0 & 0 \\ 
0 & 0 & 0 & 1 \\ 
0 & 0 & 1 & 0 \\ 
0 & 1 & 0 & 0
\end{array}\right), \quad
\mbox{iSWAP} = \left(\begin{array} 
& 1 & 0 & 0 & 0 \\ 
0 & 0 & i & 0 \\ 
0 & i & 0 & 0 \\ 
0 & 0 & 0 & 1
\end{array}\right)$$

**Note:** The matrix is specified with respect to the tensor product $U_{b}\otimes U_{a}$ for qubits specified by list `[a, b]`.

## Using operators in circuits

Let us demonstrate how these can be used in a circuit. We will consider an example of implementing a CNOT gate decomposed in terms of single-qubit gates and the iSWAP gate as follows.

Note that we have assigned an optional *label* of `"iswap"` to the unitary when it is inserted. This allows us to identify this unitary in a Qiskit Aer `NoiseModel` so that we can add errors to these custom unitary gates in noisy circuit simulations.

We can confirm this circuit returns the correct output using the `Operator` class as a simulator for the circuit:

And to confirm the output is correct we can compute the average gate fidelity:

## Creating a custom unitary in a noise model

The Qiskit Aer `AerSimulator` supports simulation of arbitrary unitary operators directly as specified by the `"unitary"` in the basis gates.

This allows us to add noise models to arbitrary unitaries in our simulation when we identify them using the optional `label` argument of `QuantumCircuit.unitary`.

We will now do this by creating a `NoiseModel` that includes a quantum error channel on our custom iSWAP gate. For our example we will create a 2-qubit error consisting of two single-qubit amplitude damping channels with different damping parameters. For now we will assume all the other circuit instructions are ideal.

Note that when we add an error to a custom label such as `"iswap"` the `NoiseModel` does not know what gate this label is supposed to apply to, so we must manually add the desired gate string to the noise model `basis_gates`. This ensures that the compiler will unroll to the correct basis gates for the noise model simulation. This can done using the `NoiseModel.add_basis_gates` function:

By default the basis gates of a noise model are `['cx','id','u3']` plus any standard `AerSimulator` basis gates that are added to the noise model.

## Simulating a custom unitary noise model

Let us first take our previous CX circuit and add an initial Hadamard gate and final measurement to create a Bell-state preparation circuit that we may simulator on the `AerSimulator` both for the ideal and noisy case:

### Ideal output

Let's first see the ideal output. Since this generates a Bell-state we expect two peaks for 00 and 11.

### Noisy circuit execution

Finally, let's now simulate it with our custom noise model. Since there is a small amplitude damping error on the two-qubit gates we expect small additional peaks for the 01 and 10 outcome probabilities.
