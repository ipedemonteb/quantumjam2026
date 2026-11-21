# Quantum algorithms: Variational quantum algorithms

> Fuente: <https://quantum.cloud.ibm.com/learning/en/courses/utility-scale-quantum-computing/variational-quantum-algorithms>

> Solo las celdas de texto del notebook original; sin código.


<Admonition type="note">

Takashi Imamichi (24 May 2024)

[Download the pdf](https://ibm.ent.box.com/s/blnffu0pd7yzxarq3zc3w0jv90365ny2) of the original lecture. Note that some code snippets might become deprecated since these are static images.

*Approximate QPU time to run this experiment is 9 minutes (tested on an Eagle processor).*

(this notebook might not evaluate in the time allowed on the Open Plan. Please use quantum computing resources wisely.)

</Admonition>

## 1. Introduction

This tutorial provides an overview of a hybrid quantum-classical algorithm, specifically focusing on the variational quantum eigensolver (VQE) and the quantum approximate optimization algorithm (QAOA). The primary objective of these algorithms is to tackle optimization problems by employing quantum circuits with parameterized quantum gates.

Despite the advancements in quantum computing, the presence of noise in current quantum devices makes it challenging to extract meaningful results from deep quantum circuits. To overcome this challenge, VQE and QAOA adopt a hybrid quantum-classical approach, which involves iteratively executing relatively short quantum circuits using quantum computation and optimizing the parameters of the target parametrized quantum circuits using classical computation.

QAOA has the potential to provide the optimal solutions to the target problems at a utility scale, thanks to the application of various error mitigation and suppression techniques. VQE has many applications (like quantum chemistry) in which it is less scalable. But there have been a number of eigenvalue-related approaches that have emerged to complement and augment VQE, including Krylov subspace diagonalization and sampling-based quantum diagonalization (SQD). Understanding VQE is an important first step in understanding the wide range of classical-quantum hybrid algorithms that have emerged.

This module describes the fundamental concepts and implementation of VQE and QAOA. Further tutorials will explore advanced topics and techniques for scaling up these algorithms.

You require the following library in your environment to run this notebook.
If you have not installed it yet, you can install it by un-commenting and running the following cell.

## 2. Computing the minimum eigenvalue of a simple Hamiltonian

We will start by applying VQE to a very simple case, to see how it works. We will compute the minimum eigenvalue of Pauli $Z$ matrix with VQE. We will start by importing some general packages.

We now define the operator of interest and view it in matrix form.

It is easy to obtain the eigenvalues classically, so we can check our work. This might become difficult as we scale toward utility. Here we use numpy.

To obtain eigenvalues using a variational quantum algorithm, we construct a circuit with gates that take variational parameters:

If we want to estimate the expectation value of an operator (like $Z$), we should use Estimator. If we want to look at the states of the system, we use Sampler.

We can compute counts of bitstrings 0 and 1 with random parameter values `[1, 2, 3]` using Sampler.

We know that we can compute the expectation value of Z by $\langle Z \rangle = p_0 - p_1$ with probabilities $\{0: p_0, 1: p_1\}$.

This circuit worked, but the parameter values chosen did not correspond to a very low-energy (or low-eigenvalue) state. The eigenvalue obtained is quite a bit higher than the minimum. The result is similar when using estimator.

Note that Estimator takes quantum circuits without measurements.

We will need to search through parameters and find those that yield the lowest eigenvalue.
We make a function to receive parameter values of the variational form and return the expectation value $\langle Z \rangle$.

Let's apply SciPy's `minimize` function to find the minimum eigenvalue of Z.

### 2.1 Exercise

Compute the minimum eigenvalue of $Z \otimes Z$ with VQE.

#### Solutions of the exercise

We define the operator of interest and view it in matrix form.

To obtain eigenvalues using a variational quantum algorithm, we construct a circuit with gates that take variational parameters:

If we want to estimate the expectation value of an operator (like $Z \otimes Z$), we would use Estimator. If we want to look at the states of the system, we use Sampler.

This circuit worked, but the parameter values chosen did not correspond to a very low-energy (or low-eigenvalue) state. The eigenvalue obtained is quite a bit higher than the minimum. The result is similar when using estimator.

We will need to search through parameters and find those that yield the lowest eigenvalue.

We obtained an eigenvalue extremely close to the minimum given to us from numpy.

## 3. Quantum Optimization with Qiskit patterns

In this how-to we will learn about Qiskit patterns and quantum approximate optimization. A Qiskit pattern is an intuitive, repeatable set of steps for implementing a quantum computing workflow:

We will apply the patterns to the context of **combinatorial optimization** and show how to solve the **max-cut** problem using the **Quantum Approximate Optimization Algorithm (QAOA)**, a hybrid (quantum-classical) iterative method.

Note that this QAOA part is based on "Part 1: Small-scale QAOA" of the [Quantum approximate optimization algorithm](https://quantum.cloud.ibm.com/docs/tutorials/quantum-approximate-optimization-algorithm) tutorial. See the tutorial to learn how to scale it up.

### 3.1 (Small-scale) Qiskit pattern for optimization

This part will use a small-scale max-cut problem to illustrate the steps required to solve an optimization problem using a quantum computer.

The max-cut problem is an optimization problem that is hard to solve (more specifically, it is an NP-hard problem) with a number of different applications in clustering, network science, and statistical physics. This tutorial considers a graph of nodes connected by edges and aims to partition the nodes into two sets by "cutting" edges, such that the number of edges cut is maximized.

To give some context before mapping this problem to a quantum algorithm, you can better understand how the max-cut problem becomes a classical combinatorial optimization problem by first considering the minimization of a function $f(x)$

$$
\min_{x\in \{0, 1\}^n}f(x),
$$

where the input $x$ is a vector whose components correspond to each node of a graph.  Then, constrain each of these components to be either $0$ or $1$ (which represent being included or not included in the cut). This small-scale example case uses a graph with $n=5$ nodes.

You could write a function of a pair of nodes $i,j$ which indicates whether the corresponding edge $(i,j)$ is in the cut. For example, the function $x_i + x_j - 2 x_i x_j$ is 1 only if one of either $x_i$ or $x_j$ are 1 (which means that the edge is in the cut) and zero otherwise. The problem of maximizing the edges in the cut can be formulated as

$$
\max_{x\in \{0, 1\}^n} \sum_{(i,j)} x_i + x_j - 2 x_i x_j,
$$

which can be rewritten as a minimization of the form

$$
\min_{x\in \{0, 1\}^n} \sum_{(i,j)}  2 x_i x_j - x_i - x_j.
$$

The minimum of $f(x)$ in this case is when the number of edges traversed by the cut is maximal. As you can see, there is nothing relating to quantum computing yet. You need to reformulate this problem into something that a quantum computer can understand.

Initialize your problem by creating a graph with $n=5$ nodes.

### 3.2 Step 1. Map classical inputs to a quantum problem

The first step of the pattern is to map the classical problem (graph) into quantum **circuits** and **operators**. To do this, there are three main steps to take:

1. Utilize a series of mathematical reformulations, to represent this problem using the Quadratic Unconstrained Binary Optimization (QUBO) problems notation.
2. Rewrite the optimization problem as a Hamiltonian for which the ground state corresponds to the solution which minimizes the cost function.
3. Create a quantum circuit which will prepare the ground state of this Hamiltonian via a process similar to quantum annealing.

**Note:** In the QAOA methodology, you ultimately want to have an operator (**Hamiltonian**) that represents the **cost function** of our hybrid algorithm, as well as a parametrized circuit (**Ansatz**) that represents quantum states with candidate solutions to the problem. You can sample from these candidate states and then evaluate them using the cost function.

#### Graph &rarr; optimization problem

The first step of the mapping is a notation change, The following expresses the problem in QUBO notation:

$$
\min_{x\in \{0, 1\}^n}x^T Q x,
$$

where $Q$ is a $n\times n$ matrix of real numbers, $n$ corresponds to the number of nodes in your graph, $x$ is the vector of binary variables introduced above, and $x^T$ indicates the transpose of the vector $x$.

```
Problem name: maxcut

Minimize
  2*x_1*x_2 + 2*x_1*x_3 + 2*x_2*x_3 + 2*x_2*x_4 + 2*x_3*x_5 + 2*x_4*x_5 - 2*x_1
  - 3*x_2 - 3*x_3 - 2*x_4 - 2*x_5

Subject to
  No constraints

  Binary variables (5)
    x_1 x_2 x_3 x_4 x_5
```

#### Optimization problem &rarr; Hamiltonian

You can then reformulate the QUBO problem as a **Hamiltonian** (here, a matrix that represents the energy of a system):

$$
H_C=\sum_{ij}Q_{ij}Z_iZ_j + \sum_i b_iZ_i.
$$

**Reformulation steps from the QAOA problem to the Hamiltonian**

To demonstrate how the QAOA problem can be rewritten in this way, first replace the binary variables $x_i$ to a new set of variables $z_i\in\{-1, 1\}$ via

$$
x_i = \frac{1-z_i}{2}.
$$

Here you can see that if $x_i$ is $0$, then $z_i$ must be $1$. When the $x_i$'s are substituted for the $z_i$'s in the optimization problem ($x^TQx$), an equivalent formulation can be obtained.

$$
x^TQx=\sum_{ij}Q_{ij}x_ix_j \\ =\frac{1}{4}\sum_{ij}Q_{ij}(1-z_i)(1-z_j) \\=\frac{1}{4}\sum_{ij}Q_{ij}z_iz_j-\frac{1}{4}\sum_{ij}(Q_{ij}+Q_{ji})z_i + \frac{n^2}{4}.
$$

Now if we define $b_i=-\sum_{j}(Q_{ij}+Q_{ji})$, remove the prefactor, and the constant $n^2$ term, we arrive at the two equivalent formulations of the same optimization problem.

$$
min_{x\in\{0,1\}^n} x^TQx\Longleftrightarrow \min_{z\in\{-1,1\}^n}z^TQz + b^Tz
$$

Here, $b$ depends on $Q$. Note that to obtain $z^TQz + b^Tz$ we dropped the factor of 1/4 and a constant offset of $n^2$ which do not play a role in the optimization.

Now, to obtain a quantum formulation of the problem, promote the $z_i$ variables to a Pauli $Z$ matrix, such as a $2\times 2$ matrix of the form

$$
Z_i = \begin{pmatrix}1 & 0 \\ 0 & -1\end{pmatrix}.
 $$

When you substitute these matrices in the optimization problem above, you obtain the following Hamiltonian

$$
H_C=\sum_{ij}Q_{ij}Z_iZ_j + \sum_i b_iZ_i.
$$

*Also recall that the $Z$ matrices are embedded in the quantum computer's computational space, that is, a Hilbert space of size $2^n\times 2^n$. Therefore, you should understand terms such as $Z_iZ_j$ as the tensor product $Z_i\otimes Z_j$ embedded in the $2^n\times 2^n$ Hilbert space. For example, in a problem with five decision variables the term $Z_1Z_3$ is understood to mean $I\otimes Z_3\otimes I\otimes Z_1\otimes I$ where $I$ is the $2\times 2$ identity matrix.*

This Hamiltonian is called the <b>cost function Hamiltonian</b>. It has the property that its ground state corresponds to the solution that <b>minimizes the cost function $f(x)$</b>.
Therefore, to solve your optimization problem you now need to prepare the ground state of $H_C$ (or a state with a high overlap with it) on the quantum computer. Then, sampling from this state will, with a high probability, yield the solution to $\min~f(x)$.

#### Hamiltonian &rarr; quantum circuit

The Hamiltonian $H_C$ contains the quantum definition of your problem. Now you can create a quantum circuit that will help *sample* good solutions from the quantum computer. The QAOA is inspired by quantum annealing and applies alternating layers of operators in the quantum circuit.

The general idea is to start in the ground state of a known system, $H^{\otimes n}|0\rangle$ above, and then steer the system into the ground state of the cost operator that you are interested in. This is done by applying the operators $\exp\{-i\gamma_k H_C\}$ and $\exp\{-i\beta_k H_m\}$ with angles $\gamma_1,...,\gamma_p$ and $\beta_1,...,\beta_p~$.

The quantum circuit that you generate is **parametrized** by $\gamma_i$ and $\beta_i$, so you can try out different values of $\gamma_i$ and $\beta_i$ and sample from the resulting state.

In this case we will try an example with 1 QAOA layer that contains two parameters: $\gamma_1$ and $\beta_1$.

### 3.3 Step 2. Optimize circuits for quantum hardware execution

The circuit above contains a series of abstractions useful to think about quantum algorithms, but not possible to run on the hardware. To be able to run on a QPU, the circuit needs to undergo a series of operations that make up the **transpilation** or **circuit optimization** step of the pattern.

The Qiskit library offers a series of **transpilation passes** that cater to a wide range of circuit transformations. You need to make sure that your circuit is **optimized** for your purpose.

Transpilation might involves several steps, such as:

* **Initial mapping** of the qubits in the circuit (such as decision variables) to physical qubits on the device.
* **Unrolling** of the instructions in the quantum circuit to the hardware-native instructions that the backend understands.
* **Routing** of any qubits in the circuit that interact to physical qubits that are adjacent with one another.
* **Error suppression** by adding single-qubit gates to suppress noise with dynamical decoupling.

More information about transpilation is available in our [documentation](https://quantum.cloud.ibm.com/docs/qiskit/transpile).

The following code transforms and optimizes the abstract circuit into a format that is ready for execution on one of devices accessible through the cloud using the **Qiskit IBM&reg; Runtime service**.

Note that you can test your programs locally by "local mode" before sending them to real quantum computers.
More information about the local mode is available in the [documentation](https://quantum.cloud.ibm.com/docs/ibm-quantum-compute/local-testing-mode).

### 3.4 Step 3. Execute using IBM Quantum&reg; primitives

In the QAOA workflow, the optimal QAOA parameters are found in an iterative optimization loop, which runs a series of circuit evaluations and uses a classical optimizer to find the optimal $\beta_k$ and $\gamma_k$ parameters. This execution loop is executed via the following steps:

1. Define the initial parameters
2. Instantiate a new `Batch` containing the optimization loop and the primitive used to sample the circuit
3. Once an optimal set of parameters is found, execute the circuit a final time to obtain a final distribution which will be used in the post-process step.

#### Define circuit with initial parameters
We start with arbitrary chosen parameters.

#### Define backend and execution primitive
Use the **IBM Quantum primitives** to interact with IBM backends. The two primitives are Sampler and Estimator, and the choice of primitive depends on what type of measurement you want to run on the quantum computer. For the minimization of $H_C$, use Estimator since the measurement of the cost function is simply the expectation value of $\langle H_C \rangle$.

#### Run

The primitives offer a variety of [execution modes](https://quantum.cloud.ibm.com/docs/ibm-quantum-compute/execution-modes) to schedule workloads on quantum devices, and a QAOA workflow runs iteratively in a session.

You can plug the sampler-based cost function into the SciPy minimizing routine to find the optimal parameters.

The optimizer was able to reduce the cost and find better parameters for the circuit.

Once you have found the optimal parameters for the circuit, you can assign these parameters and sample the final distribution obtained with the optimized parameters. Here is where the *Sampler* primitive should be used since it is the probability distribution of bitstring measurements which correspond to the optimal cut of the graph.

**Note:** This means preparing a quantum state $\psi$ in the computer and then measuring it. A measurement will collapse the state into a single computational basis state - for example, `010101110000...` - which corresponds to a candidate solution $x$ to our initial optimization problem ($\max f(x)$ or $\min f(x)$ depending on the task).

### 3.5 Step 4. Post-process, return result in classical format

The post-processing step interprets the sampling output to return a solution for your original problem. In this case, you are interested in the bitstring with the highest probability as this determines the optimal cut. The symmetries in the problem allow for four possible solutions, and the sampling process will return one of them with a slightly higher probability, but you can see in the plotted distribution below that four of the bitstrings are distinctively more likely than the rest.

#### Visualize best cut

From the optimal bit string, you can then visualize this cut on the original graph.

And calculate the value of the cut. The solution is not optimal due to noise (the cut value of the optimal solution is 5).

This concludes the small-scale QAOA tutorial.
You will learn how to adapt QAOA at a utility-scale in "Part 2: scale it up!" of the [Quantum approximate optimization algorithm](https://quantum.cloud.ibm.com/docs/tutorials/quantum-approximate-optimization-algorithm) tutorial.
