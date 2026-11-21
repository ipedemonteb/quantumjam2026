# Simulators

> Fuente: <https://github.com/Qiskit/qiskit-aer/blob/main/docs/tutorials/1_aersimulator.ipynb>

## Introduction

This notebook shows how to import the *Qiskit Aer* simulator backend and use it to run ideal (noise free).

## The AerSimulator

1. `AerSimulator.available_devices()` : Return the available simulation devices.
2. `AerSimulator.available_methods()` : Return the available simulation methods.

## Simulating a Quantum Circuit

The basic operation runs a quantum circuit and returns a counts dictionary of measurement outcomes. Here we run a simple circuit that prepares a 2-qubit Bell-state $\left|\psi\right\rangle = \frac{1}{\sqrt{2}}\left(\left|0,0\right\rangle + \left|1,1 \right\rangle\right)$
and measures both qubits.

### Returning measurement outcomes for each shot

The `Simulator` also supports returning a list of measurement outcomes for each individual shot. This is enabled by setting the keyword argument `memory=True` in the run.

### Aer Simulator Options

The `AerSimulator` backend supports a variety of configurable options which can be updated using the set_options method. See the AerSimulator API documentation for additional details.

### Simulation Method

The `AerSimulator` supports a variety of simulation methods, each of which supports a different set of instructions. The method can be set manually using `simulator(method=value)` option, or a simulator backend with a preconfigured method can be obtained directly from the `AerSimulator` 

When simulating ideal circuits, changing the method between the exact simulation methods `stabilizer`, `statevector`, `density_matrix` and `matrix_product_state` should not change the simulation result (other than usual variations from sampling probabilities for measurement outcomes)

### Simulation Method Option

The simulation method is set using the method kwarg. A list supported simulation methods can be returned using available_methods(), these are

1.  `"automatic"`: Default simulation method. Select the simulation method automatically based on the circuit and noise model.

2.  `"statevector"`: A dense statevector simulation that can sample measurement outcomes from ideal circuits with all measurements at end of the circuit. For noisy simulations each shot samples a randomly sampled noisy circuit from the noise model.
    
    
3. `"density_matrix"`: A dense density matrix simulation that may sample measurement outcomes from noisy circuits with all measurements at end of the circuit.
    
4. `"stabilizer"`: An efficient Clifford stabilizer state simulator that can simulate noisy Clifford circuits if all errors in the noise model are also Clifford errors.
    
    
5. `"extended_stabilizer"`: An approximate simulated for Clifford + T circuits based on a state decomposition into ranked-stabilizer state. The number of terms grows with the number of non-Clifford (T) gates.
    
    
6. `"matrix_product_state"`: A tensor-network statevector simulator that uses a Matrix Product State (MPS) representation for the state. This can be done either with or without truncation of the MPS bond dimensions depending on the simulator options. The default behaviour is no truncation.
    
    
7. `"unitary"`: A dense unitary matrix simulation of an ideal circuit. This simulates the unitary matrix of the circuit itself rather than the evolution of an initial quantum state. This method can only simulate gates, it does not support measurement, reset, or noise.
    
8.  `"superop"`: A dense superoperator matrix simulation of an ideal or noisy circuit. This simulates the superoperator matrix of the circuit itself rather than the evolution of an initial quantum state. This method can simulate ideal and noisy gates, and reset, but does not support measurement.

#### Automatic Simulation Method

The default simulation method is automatic which will automatically select a one of the other simulation methods for each circuit based on the instructions in those circuits. A fixed simulation method can be specified by by adding the method name when getting the backend, or by setting the method option on the backend.

### GPU Simulation
The `statevector`, `density_matrix` and `unitary` simulators support running on a NVidia GPUs. For these methods the simulation device can also be manually set to CPU or GPU using `simulator = AerSimmulator(method='statevector',device='GPU')` backend option.

## Installing GPU Support

In order to install and run the GPU supported simulators on Linux, you need CUDA® 11.2 or newer previously installed. CUDA® itself would require a set of specific GPU drivers. Please follow CUDA® installation procedure in the NVIDIA® [web](https://www.nvidia.com/drivers).

If you want to install our GPU supported simulators, you have to install this other package:

```python
pip install qiskit-aer-gpu
```

The package above is for CUDA&reg 12, so if your system has CUDA® 11 installed, install separate package:

```python
pip install qiskit-aer-gpu-cu11
```

This will overwrite your current `qiskit-aer` package installation giving you the same functionality found in the canonical `qiskit-aer` package, plus the ability to run the GPU supported simulators: `statevector`, `density matrix`, and `unitary`.

Note: This package is only available on x86_64 Linux. For other platforms that have CUDA support, you will have to build from source. You can refer to the [contributing guide](https://github.com/Qiskit/qiskit-aer/blob/main/CONTRIBUTING.md#building-with-gpu-support) for instructions on doing this.

### Simulation Precision

One of the available simulator options allows setting the float precision for the `statevector`, `density_matrix`, `unitary` and `superop` methods. This is done using the `set_precision="single"` or `precision="double"` (default) option:

Setting the simulation precision applies to both CPU and GPU simulation devices. Single precision will halve the required memory and may provide performance improvements on certain systems.

## Custom Simulator Instructions

### Saving the simulator state

The state of the simulator can be saved in a variety of formats using custom simulator instructions.

| Circuit method | Description |Supported Methods | 
|----------------|-------------|------------------|
| `save_state` | Save the simulator state in the native format for the simulation method | All | 
| `save_statevector` | Save the simulator state as a statevector | `"automatic"`, `"statevector"`, `"matrix_product_state"`, `"extended_stabilizer"`|
| `save_stabilizer` | Save the simulator state as a Clifford stabilizer | `"automatic"`, `"stabilizer"`| 
| `save_density_matrix` | Save the simulator state as a density matrix | `"automatic"`, `"statevector"`, `"matrix_product_state"`, `"density_matrix"` |
| `save_matrix_product_state` | Save the simulator state as a a matrix product state tensor | `"automatic"`, `"matrix_product_state"`|
| `save_unitary` | Save the simulator state as unitary matrix of the run circuit | `"automatic"`, `"unitary"`|
| `save_superop` | Save the simulator state as superoperator matrix of the run circuit | `"automatic"`, `"superop"`|

Note that these instructions are only supported by the Aer simulator and will result in an error if a circuit containing them is run on a non-simulator backend such as an IBM Quantum device.

### Saving the final statevector
To save the final statevector of the simulation we can append the circuit with the `save_statevector` instruction. Note that this instruction should be applied before any measurements if we do not want to save the collapsed post-measurement state

### Saving the circuit unitary

To save the unitary matrix for a `QuantumCircuit` we can append the circuit with the `save_unitary` instruction. Note that this circuit cannot contain any measurements or resets since these instructions are not supported on for the `"unitary"` simulation method

### Saving multiple states

We can also apply save instructions at multiple locations in a circuit. Note that when doing this we must provide a unique label for each instruction to retrieve them from the results

### Setting the simulator to a custom state

The `AerSimulator` allows setting a custom simulator state for several of its simulation methods using custom simulator instructions

| Circuit method | Description |Supported Methods | 
|----------------|-------------|------------------|
| `set_statevector` | Set the simulator state to the specified statevector | `"automatic"`, `"statevector"`, `"density_matrix"`|
| `set_stabilizer` | Set the simulator state to the specified Clifford stabilizer | `"automatic"`, `"stabilizer"`| 
| `set_density_matrix` | Set the simulator state to the specified  density matrix | `"automatic"`, `"density_matrix"` |
| `set_unitary` | Set the simulator state to the specified  unitary matrix | `"automatic"`, `"unitary"`, `"superop"`|
| `set_superop` | Set the simulator state to the specified superoperator matrix | `"automatic"`, `"superop"`|

**Notes:**
* These instructions must be applied to all qubits in a circuit, otherwise an exception will be raised.
* The input state must also be a valid state (statevector, density matrix, unitary etc) otherwise an exception will be raised.
* These instructions can be applied at any location in a circuit and will override the current state with the specified one. Any classical register values (e.g. from preceding measurements) will be unaffected
* Set state instructions are only supported by the Aer simulator and will result in an error if a circuit containing them is run on a non-simulator backend such as an IBM Quantum device.

#### Setting a Custom Statevector

The set_statevector instruction can be used to set a custom Statevector state. The input statevector must be valid ($|\langle\psi|\psi\rangle|=1$)

#### Using the initialize instruction

It is also possible to initialize the simulator to a custom statevector using the `initialize` instruction. Unlike the `set_statevector` instruction this instruction is also supported on real device backends by unrolling to reset and standard gate instructions.

#### Setting a custom density matrix

The `set_density_matrix` instruction can be used to set a custom `DensityMatrix` state. The input density matrix must be valid ($Tr[\rho]=1, \rho \ge 0$)

#### Setting a custom stabilizer state

The `set_stabilizer` instruction can be used to set a custom `Clifford` stabilizer state. The input stabilizer must be a valid `Clifford`.

#### Setting a custom unitary

The `set_unitary` instruction can be used to set a custom unitary `Operator` state. The input unitary matrix must be valid ($U^\dagger U=\mathbb{1}$)
