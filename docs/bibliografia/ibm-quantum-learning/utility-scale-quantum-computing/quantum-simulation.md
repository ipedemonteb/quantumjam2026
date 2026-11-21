# Quantum simulation

> Fuente: <https://quantum.cloud.ibm.com/learning/en/courses/utility-scale-quantum-computing/quantum-simulation>

> Solo las celdas de texto del notebook original; sin código.


<Admonition type="note">

Yukio Kawashima (May 30, 2024)

[Download the pdf](https://ibm.ent.box.com/s/kzzsmxhw38vph1ioohczaet53euwi310) of the original lecture. Note that some code snippets might become deprecated since these are static images.

*Approximate QPU time to run this experiment is 7 seconds.*

(This notebook is mostly taken from a now-deprecated [tutorial notebook](https://github.com/qiskit-community/qiskit-algorithms/blob/main/docs/tutorials/13_trotterQRTE.ipynb) for Qiskit Algorithms.)

</Admonition>

## 1. Introduction

As a real time evolution technique, Trotterization consists in the successive application of a quantum gate or gates, chosen to approximate the time evolution of a system for a time slice. Following from the Schrödinger equation, the time evolution of a system initially in the state $\vert\psi(0)\rangle$ takes the form:

$$
\vert \psi(t) \rangle = e^{-i H t} \vert \psi(0) \rangle \text{,}
$$

where $H$ is the time-independent Hamiltonian governing the system. We consider a Hamiltonian that can be written as a weighted sum of Pauli terms $H=\sum_j a_j P_j$, with $P_j$ representing a tensor product of Pauli terms acting on $n$ qubits. In particular, these Pauli terms might commute with one another, or they might not. Given a state at time $t=0$, how do we obtain the system's state at a later time $|\psi(t)\rangle$ using a quantum computer? The exponential of an operator can be most easily understood through its Taylor series:

$$
e^{-i H t} = 1-iHt-\frac{1}{2}H^2t^2+...
$$

Some very basic exponentials, like $e^{iZ}$ can be implemented easily on quantum computers using a compact set of quantum gates. Most Hamiltonians of interest will not have just a single term, but will instead have many terms. Note what happens if $H = H_1+H_2$:

$$
e^{-i H t} = 1-i(H_1+H_2)t-\frac{1}{2}(H_1+H_2)^2t^2+...
$$

When $H_1$ and $H_2$ commute, we have the familiar case (which is also true for numbers, and variables $a$ and $b$ below):

$$
e^{-i (a+b) t} = e^{-i a t}e^{-i b t}
$$

But when operators do not commute, terms cannot be rearranged in the Taylor series to simplify in this way. Thus, expressing complicated Hamiltonians in quantum gates is a challenge.

One solution is to consider very small time $t$, such that the first-order term in the Taylor expansion dominates. Under that assumption:

$$
e^{-i (H_1+H_2) t} \approx 1-i(H_1+H_2)t \approx (1-i H_1 t)(1-i H_2 t) \approx e^{-i H_1 t}e^{-i H_2 t}
$$

Of course, we might need to evolve our state for a longer time. That is accomplished by using many such small steps in time. This process is called Trotterization:

$$
\vert \psi(t) \rangle \approx \left(\prod_j e^{-i a_j P_j t/r} \right)^r \vert\psi(0) \rangle \text{,}
$$

Here $t/r$ is the time slice (evolution step) that we are choosing. As a result, a gate to be applied $r$ times is created. A smaller timestep leads to a more accurate approximation. However, this also leads to deeper circuits which, in practice, leads to more error accumulation (a non-negligible concern on near-term quantum devices).

Today, we will study the time evolution of the [Ising model](https://en.wikipedia.org/wiki/Ising_model) on linear lattices of $N=2$ and $N=6$ sites. These lattices consist of an array of spins $\sigma_i$ that interact only with their nearest neighbors. These spins can have two orientations: $\uparrow$ and $\downarrow$, which correspond to a magnetization of $+1$ and $-1$ respectively.

$$
H = - J \sum_{i=0}^{N-2} Z_i Z_{i+1} - h \sum_{i=0}^{N-1} X_i  \text{,}
$$

where $J$ describes the interaction energy, and $h$ the magnitude of an external field (in the x-direction above, but we will modify this). Let us write this expression using Pauli matrices, and considering that the external field has an angle $\alpha$ with respect to the transversal direction,

$$
H = -J \sum_{i=0}^{N-2} Z_i Z_{i+1} -h \sum_{i=0}^{N-1} (\sin\alpha Z_i + \cos\alpha X_i) \text{.}
$$

This Hamiltonian is useful in that it allows us to easily study the effects of an external field. In the computational basis, the system will be encoded as follows:

| Quantum state            | Spin representation                        |
|:------------------------:|:------------------------------------------:|
| $\lvert 0 0 0 0 \rangle$ | $\uparrow\uparrow\uparrow\uparrow$         |
| $\lvert 1 0 0 0 \rangle$ | $\downarrow\uparrow\uparrow\uparrow$       |
| $\ldots$                 | $\ldots$                                   |
| $\lvert 1 1 1 1 \rangle$ | $\downarrow\downarrow\downarrow\downarrow$ |

We will start investigating the time evolution of such a quantum system. More specifically, we will visualize the time-evolution of certain properties of the system like magnetization.

### 1.1 Requirements

Before starting this tutorial, be sure you have the following installed:

- Qiskit SDK v1.2 or later ( `pip install qiskit` )
- Qiskit Runtime v0.50.0 or later ( `pip install qiskit-ibm-runtime` )
- Numpy v1.24.1 or later < 2 ( `pip install numpy` )

### 1.2 Import the libraries

Note that some libraries that might be useful (MatrixExponential, QDrift) are included even though they are not used in this current notebook. You can try them out if you have time!

## 2. Mapping your problem

### 2.1 Defining the transverse-field Ising Hamiltonian

We here consider the 1-D transverse-field Ising model.

First, we will create a function that takes in the system parameters $N$, $J$, $h$ and $\alpha$, and returns our Hamiltonian as a `SparsePauliOp`. A [SparsePauliOp](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.quantum_info.SparsePauliOp) is a sparse representation of an operator in terms of weighted [Pauli](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.quantum_info.Pauli) terms.

#### Define the Hamiltonian
The system that we now consider has a size of $N=6$, $J=0.2$, $h=1.2$ and $\alpha=\frac{\pi}{8.0}$ as an example.

### 2.2 Set the parameters of the time-evolution simulation
Here we will consider three different Trotterization techniques:
* Lie–Trotter (first order)
* second-order Suzuki–Trotter
* fourth-order Suzuki–Trotter

The latter two will be used in the exercise, and in the appendix.

### 2.3 Prepare the quantum circuit 1 (Initial state)
Create an initial state. Here we will start with a spin configuration of $\uparrow\uparrow\downarrow\downarrow\uparrow\uparrow$
.

### 2.4 Prepare the quantum circuit 2 (Single circuit for time evolution)
We here construct a circuit for a single time step using Lie–Trotter.

The Lie product formula (first-order) is implemented in the [LieTrotter](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.synthesis.LieTrotter) class. A first-order formula consists of the approximation stated in the introduction, where the matrix exponential of a sum is approximated by a product of matrix exponentials:

$$
e^{H_1+H_2} \approx e^{H_1} e^{H_2}
$$

As previously mentioned, very deep circuits lead to the accumulation of errors, and cause problems for modern quantum computers. Because two-qubit gates have higher error rates than single-qubit gates, a quantity of particular interest is the two-qubit circuit depth. What really matters is the two-qubit circuit depth after transpilation (since that is the circuit the quantum computer actually executes). But let us get in the habit of counting the operations for this circuit, even now using the simulator.

### 2.5 Set the operators to measure
Let us define a *magnetization operator* $\sum_i \langle Z_i \rangle / N$, and a *mean spin correlation operator* $\sum_i \langle Z_i Z_{i+1} \rangle/ (N - 1)$.

### 2.6 Perform time-evolution simulation
We will monitor the energy (expectation value of the Hamiltonian), magnetization (expectation value of the magnetization operator), and mean spin correlation (expectation value of the mean spin correlation operator). Qiskit's `StatevectorEstimator` (EstimatorV2) primitive estimates expectation values of observables, $\langle\psi\vert\hat{O}\vert\psi\rangle$.

### 2.7 Plot the time evolution of the observables
We plot the expectation values we measured against time.

## 3. Exercise 1. Perform simulation using second-order Suzuki–Trotter
Now let's try performing simulation with second-order Suzuki–Trotter following the example of Lie–Trotter shown above.

The second-order Suzuki-Trotter can be used in Qiskit by means of the [SuzukiTrotter class](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.synthesis.SuzukiTrotter). Using this formula, a second order decomposition is:

$$
e^{H_1+H_2} \approx e^{H_1/2}e^{H_2}e^{H_1/2}
$$

### 3.1 Construct a circuit for a single time step
Use product_formula_st2 (SuzukiTrotter(order=2)) and construct a circuit for a single time step using second-order Suzuki–Trotter. Also, count the number of gates and depth of the circuit and compare with Lie–Trotter.

### 3.2 Perform time-evolution simulation
Perform time evolution using second-order Suzuki–Trotter.

### 3.3 Plot the second-order Suzuki–Trotter results

### 3.4 Compare with exact results
The data below is the precomputed exact results from the classical computer.

## 4. Executing on the quantum hardware
We next run the time-evolution simulation on the quantum hardware. We will work on a smaller problem, lattice size N=2. We vary the $\alpha$ parameter and see the difference in dynamics of the wavefunction.

### 4.1  Step 1. Map classical inputs to a quantum problem

Pick the initial setting of the simulation:

Then set the initial circuit:

The initial spin configuration will be "down-up"

Now compute the reference value using an ideal statevector simulator.

We have prepared a system initially with a sequence of spins $\downarrow\uparrow$, which corresponds to $\vert\psi(0)\rangle = \vert10\rangle$. After letting it evolve for $t=1.6$ under a transversal field ($\alpha=0^\circ$), we are almost guaranteed to measure $\uparrow\downarrow$, that is, have a spin swap. (Note that the labels are interpreted from right to left). If the field is longitudinal ($\alpha=\pm90^\circ$), we will have no evolution, therefore we will measure the system as it was initially prepared, $\downarrow\uparrow$. With intermediate angles, at $\alpha=\pm45^\circ$, we will be able to measure all combinations will different probabilities, being a spin swap the most likely with a probability of 67%.

#### Construct circuit for HW experiment

### 4.2 Step 2. Optimize for target hardware
We specify a backend.

Then we transpile the circuit for the selected backend.

Check out the circuit.

### 4.3 Step 3. Execute with IBM Quantum&reg; primitives

Qiskit's `Sampler` (V2) primitive provides the counts of measured bitstrings.

Save the results

### 4.4 Step 4. Post-process results
Construct the histogram of the bitstrings, which corresponds to analyzing the wavefunction, and compare them with the ideal values shown above.

We here show an example for constructing a circuit using higher-order (fourth-order) Suzuki–Trotter.
Now let's try constructing a circuit simulation with fourth-order Suzuki–Trotter following the examples shown above.

The fourth-order Suzuki–Trotter can be used in Qiskit by means of the [SuzukiTrotter class](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.synthesis.SuzukiTrotter). The fourth-order can be evaluated using the following recursion relation. Note that the order of Suzuki–Trotter is denoted as "2k" in the following equations.

$$
\hat{U}_{ST(2k)}\left(t\right) = \left[ \hat{U}_{ST(2k-2)}\left(p_k t\right) \right]^2 \hat{U}_{ST(2k-2)}\left( (1- 4 p_k) t\right)\left[ \hat{U}_{ST(2k-2)}\left(p_k t\right) \right]^2
$$
$$
p_k = 1 / \left(4-4^{\frac{1}{2k-1}}\right)
$$

#### Construct a circuit for a single time step
Use product_formula_st4 (SuzukiTrotter(order=4)) and construct a circuit for a single time step using fourth-order Suzuki–Trotter. Also, count the number of gates and depth of the circuit and compare with Lie–Trotter and second-order Suzuki–Trotter.
