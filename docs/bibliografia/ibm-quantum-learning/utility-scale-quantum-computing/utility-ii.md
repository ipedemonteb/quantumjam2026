# Utility-scale experiment II

> Fuente: <https://quantum.cloud.ibm.com/learning/en/courses/utility-scale-quantum-computing/utility-ii>

> Solo las celdas de texto del notebook original; sin código.


<Admonition type="note">

Yukio Kawashima (12 July 2024)

[Download the pdf](https://ibm.ent.box.com/s/bipgoms7gr6b6vhkoc1uw6oi4wsanfoq) of the original lecture. Note that some code snippets might become deprecated since these are static images.

*Approximate QPU time to run this experiment is 2 m 30 s.*

(Note that this notebook used texts, illustration, and codes from a now-deprecated [tutorial notebook](https://github.com/qiskit-community/qiskit-algorithms/blob/main/docs/tutorials/13_trotterQRTE.ipynb) for Qiskit Algorithms.)

</Admonition>

## 1. Introduction and review of time-evolution

This notebook follows the methods and techniques of lesson 7. Our goal is to numerically solve the time-dependent Schrödinger equation. As discussed in lesson 7, Trotterization consists in the successive application of a quantum gate or gates, chosen to approximate the time evolution of a system for a time slice. We repeat that discussion here for convenience. Feel free to skip to the code cells below if you have recently reviewed lesson 7.

Following from the Schrödinger equation, the time evolution of a system initially in the state $\vert\psi(0)\rangle$ takes the form:

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

## 2. Defining the transverse-field Ising Hamiltonian

We here consider the 1-D transverse-field Ising model.

First, we will create a function that takes in the system parameters $N$, $J$, and $h$, and returns our Hamiltonian as a `SparsePauliOp`. A [SparsePauliOp](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.quantum_info.SparsePauliOp) is a sparse representation of an operator in terms of weighted [Pauli](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.quantum_info.Pauli) terms.

### 2.1 Activity 1
Construct a function to build a transverse-field Ising Hamiltonian (see the equation above) with arguments of "the number of qubits", "J parameter", and "h parameter". Try this on your own using previous examples. Scroll down for the solution.

__Solution:__

We will start investigating the time evolution of a quantum system, while keeping track of magnetization.
We here compare the results of the Statevector and Matrix Product State simulators.

#### Define the Hamiltonian
The system that we now consider has a size of $N=20$.

#### Set the parameters of the time-evolution simulation
Here we will consider the Lie–Trotter (first order).

#### Prepare the quantum circuit (Initial state)
Create an initial state. We will start from the ground state, which is a ferromagnetic state (all up or all down). Here, we use an example of all ups (which is all '0').

#### Prepare the quantum circuit 2 (Single circuit for time evolution)
We here construct a circuit for a single time step using Lie–Trotter.
The Lie product formula (first order) is implemented in the [LieTrotter](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.synthesis.LieTrotter) class. A first-order formula consists of the approximation stated in the introduction, where the matrix exponential of a sum is approximated by a product of matrix exponentials:

$$
e^{H_1+H_2} \approx e^{H_1} e^{H_2}
$$
Let us count the operations for this circuit.

#### Set the operators to be measured
Let us define a *magnetization operator* $\sum_i Z_i  / N$.

#### Perform time-evolution simulation
We will monitor the magnetization (expectation value of the magnetization operator). We will use Statevector and MPS simulators and compare the results.

#### Plot the time evolution of the observables
We plot the expectation values we measured against time. Confirm that the results from statevector and matrix product space simulators agree.

We will start investigating the time evolution of a quantum system, while keeping track of properties.
We here compare the results of the Matrix Product State simulator and the actual quantum device.

### 2.2 Activity 2

#### Define the Hamiltonian
The system that we now consider has a size of $N=70$. Note that the other conditions are the same from the 20-qubit problem. Try this on your own; scroll down for the solution.

__Solution:__

### 2.3 Activity 3

Create an initial state. We will start from the ground state, which is a ferromagnetic state (all up or all down). Here, we use an example of all ups (which is all '0'). Try this on your own; scroll down for the solution.

__Solution:__

### 2.4 Activity 4

#### Prepare the quantum circuit 2 (Single circuit for time evolution) for the 70-qubit problem
We here construct a circuit for a single time step using Lie–Trotter.
Exactly as in the 20-qubit case, the Lie product formula (first order) is implemented in the [LieTrotter](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.synthesis.LieTrotter) class. Again, the first-order formula consists of the approximation stated above:

$$
e^{H_1+H_2} \approx e^{H_1} e^{H_2}
$$

Try this yourself, building from the example of the 20-qubit case. As before, count the operations for this circuit.

__Solution:__

### 2.5 Activity 5

#### Set the operators to be measured
We define a *magnetization operator* exactly analogous to the one from the 20-qubit case: $\sum_i Z_i  / N$. Try this yourself by modifying the 20-qubit solution.

__Solution:__

### 2.6 Activity 6

#### Perform time-evolution simulation
We will monitor the magnetization (expectation value of the magnetization operator). We will use the MPS simulator to get the reference value to compare the results computed from the hardware. You have used the MPS simulator before in this tutorial. Modify that example where necessary to fit this new calculation.

__Solution:__

As in all previous lessons, we will implement the Qiskit patterns framework. The lesson up to this point has been focused on creating the correct quantum circuits to describe our problem. This is effectively Step 1.

#### Step 2: Optimize for target hardware

We start by defining the target backend.

We transpile the circuits and gather them in a list. This might take a few minutes.

#### Step 3: Execute on target hardware

We will define the Runtime Estimator and construct the list of PUBs. We must also apply the layout to the operators to be measured.

We are now ready to run the job.

#### Step 4: Post-process results

We will first get the results.

Now we must extract the expectation values from these results.

We will use this for comparison below. First, let us see if we can optimize our circuits even further.

## 3. Solution using a real quantum computer II

Let us return to Qiskit patterns step 1, and see if we can reduce the depth of our circuit.

###  3.1 Step 1. Map the problem to quantum circuits and operators

#### Activity 7

Construct a time-evolution circuit. Use your knowledge from previous lessons to try to reduce the depth of the circuit.

__Solution:__

This was very successful. We can now proceed with the remaining Qiskit patterns steps.

###  3.2 Step 2. Optimize for target hardware

Transpile the circuits and gather them in a list. Once again, this might take a few minutes.

Define the Runtime Estimator and construct the list of PUBs.

### 3.3 Step 3. Execute on target hardware
Run the job.

Get the results.

### 3.4 Step 4. Post-processing
Extract the expectation values from the results.

Transform the list into numpy arrays for plotting.

Now let us plot the results and compare the hardware (default and shallow circuit) results with the MPS simulator. How does the error in the real hardware influence the results?

Congratulations! You have moved one step further in your utility-scale quantum journey. There is only one lesson left!
