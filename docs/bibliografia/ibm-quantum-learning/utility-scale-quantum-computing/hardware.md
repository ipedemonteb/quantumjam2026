# Hardware

> Fuente: <https://quantum.cloud.ibm.com/learning/en/courses/utility-scale-quantum-computing/hardware>

> Solo las celdas de texto del notebook original; sin código.


<Admonition type="note">

Masao Tokunari and Tamiya Onodera (14 June 2024)

This course is based on a live course delivered at the University of Tokyo.

This lesson's lecture pdf was split into two parts. [Download part 1](https://ibm.ent.box.com/public/static/ruz8wf353hncenmaywjlfjilflaumnzt.zip) and [download part 2](https://ibm.ent.box.com/public/static/tg8vv00ern2bmxmm033xt9oe0fcvwamc.zip). Note that some code snippets might become deprecated since these are static images.

</Admonition>

## 1. Introduction

This lesson explores modern quantum computing hardware.

We will start by verifying some versions and importing some relevant packages.

## 2. Backend and Target

Qiskit provides an API to obtain the information, both static and dynamic, about a quantum device. We use a Backend instance to interface with a device, which includes a Target instance, an abstract machine model that summarizes the pertinent features such as its instruction set architecture (ISA) and any properties or constraints associated with it.
Let us use these backend instances to get some of the information you see on the [Compute resources](https://quantum.cloud.ibm.com/computers) page
on IBM Quantum&reg; Platform.   First, we create a backend instance for a device of interest.  In the following, we pick "ibm_kyoto" , "ibm_kawasaki" or the least busy Eagle machine. Your access to QPUs might differ; update the backend name accordingly.

We start with some basic (static) information about the device.

### 2.1 Exercise

Try to get the basic information about a Heron device, "ibm_strasbourg". Try this on your own, but code has been added below for you to check yourself.

### 2.2 Coupling map

We now draw the coupling map of the device. As you can see, nodes are qubits which are numbered. Edges indicate pairs to which you can directly apply the 2-qubit entangling gate.  The topology is called a "heavy-hex lattice".

## 3. Qubit properties

The Eagle device has 127 qubits.   Let us obtain the properties of some of them.

Let us calculate the median of T1 times of the qubits.   Compare the result to the one shown for the device on [IBM Quantum Platform](https://quantum.cloud.ibm.com/).

### 3.1 Exercise

Pease calculate the median of T2 times of the qubits. Try this on your own, but code has been added below for you to check yourself.

###  3.2 Gate and readout errors

We now turn to gate errors. To begin with, we study the data structure of the target instance. It is a dictionary whose keys are operation names.

Its values are also dictionaries.  Let us look at some of the items of the value (dictionary) for the 'sx' operation.

Let us do the same for the 'ecr' and 'measure' operations.

As you can see, the errors of readout tend to be larger than those of the 2-qubit operation, which in turn tend to be larger than the 1-qubit operation.

Having understood the data structures, we are ready to calculate the median errors for the 'sx' and the 'ecr' gates. Again, compare the results with the ones shown for the device on [IBM Quantum Platform](https://quantum.cloud.ibm.com/).

## 4. Appendix

A popular feature of Qiskit is its visualization capability. It includes circuit visualizers, state and distribution visualizers, and target visualizer.   You already used the first two in the previous jupyter notebooks.   Let us use some capabilities of the target visualizer.
