# Quantum algorithms: Grover Search and applications

> Fuente: <https://quantum.cloud.ibm.com/learning/en/courses/utility-scale-quantum-computing/grovers-algorithm>

> Solo las celdas de texto del notebook original; sin código.


<Admonition type="note">

Atsushi Matsuo (May 10, 2024)

[Download the pdf](https://ibm.ent.box.com/public/static/3s99zptw6c7nrfzmneogs4y7ezrx5nbh.zip) of the original lecture. Note that some code snippets might become deprecated since these are static images.

*Approximate QPU time to run this experiment is 2 seconds.*

</Admonition>

## 1. Introduction to Grover's algorithm
This notebook is the fourth in a series of lectures on the Path to Utility in Quantum Computing. In this notebook, we will learn about Grover's algorithm.

Grover's algorithm is one of the most well-known quantum algorithms due to its quadratic speedup over classical search methods. In classical computing, searching an unsorted database of $N$ items requires $O(N)$ time complexity, meaning that in the worst case, one might have to examine each item individually. However, Grover's algorithm allows us to achieve this search in $O(\sqrt{N})$ time, leveraging the principles of quantum mechanics to identify the target item more efficiently.

The algorithm uses amplitude amplification, a process that increases the probability amplitude of the correct answer state in a quantum superposition, allowing it to be measured with higher probability. This speedup makes Grover's algorithm valuable in various applications beyond simple database search, especially when the dataset size is large. Detailed explanations of the algorithm is provided in the [Grover's algorithm notebook](https://quantum.cloud.ibm.com/learning/courses/fundamentals-of-quantum-algorithms/grover-algorithm/introduction).

### The Basic Structure of Grover's Algorithm

Grover's algorithm comprises four main components:
1. **Initialization**: Setting up the superposition over all possible states.
2. **Oracle**: Applying an oracle function that marks the target state by flipping its phase.
3. **Diffusion Operator**: Applying a series of operations to amplify the probability of the marked state.

Each of these steps plays a critical role in making the algorithm work efficiently. Detailed explanations for each step are provided later.

## 2. Implementing Grover's Algorithm

### 2.1 Preparation
Import the necessary libraries and set up the environment for running the quantum circuit.

### Step 1: Map problem to quantum circuits and operators

Consider a list of 4 elements, where our goal is to identify the index of an element that meets a specific condition. For instance, we want to find the index of the element equal to 2. In this example, the quantum state $|01\rangle$ represents the index of the element that satisfies this condition, as it points to the position where the value 2 is located.

### Step 2: Optimize for target hardware

### 1: Initialization

In the initialization step, we create a superposition of all possible states. This is achieved by applying a Hadamard gate to each qubit in an n-qubit register, which will result in an equal superposition of $2^n$ states. Mathematically, this can be represented as:

$$
\frac{1}{\sqrt{N}} \sum_{x=0}^{N-1} |x\rangle
$$

where $N = 2^n$ is the total number of possible states. We also change the state of the ancilla bit to $|-\rangle$.

### 2: Oracle

The oracle is a key part of Grover's algorithm. It marks the target state by applying a phase shift, typically flipping the sign of the amplitude associated with that state. The oracle is often problem-specific and constructed based on the criteria for identifying the target state. In mathematical terms, the oracle applies the following transformation:

$
f(x) =
\begin{cases}
1, & \text{if } x = x_{\text{target}} \\
0, & \text{otherwise}
\end{cases}
$

This phase flip is achieved by applying a negative sign to the amplitude of the target state via phase kickback.

### 3: Diffusion Operator

The amplitude amplification process is what differentiates Grover's algorithm from a classical search. After the oracle has marked the target state, we apply a series of operations that increase the amplitude of this marked state, making it more likely to be observed upon measurement. This process is achieved through the **Diffusion operator**, which effectively performs an inversion about the average amplitude. The mathematical operation is as follows:

$
D = 2|\psi\rangle\langle\psi| - I
$

where $D$ is the diffusion operator, $I$ is the identity matrix, and $|\psi\rangle$ is the equal superposition state. The combination of the oracle and the diffusion operator is applied approximately $\sqrt{N}$ times to achieve maximum probability for measuring the marked state.

### 2.2 A 2-qubit Grover search example.

### 2.3 Experiment with Simulators
### Step 3: Executing the circuit.

### Step 4: Post-processing the results.

We got the correct answer $|01\rangle$. Note that be careful with the order of qubits

## 3. Experiment with Real Devices

### Step 2: Optimize for target hardware

By transpiling the circuit, it was converted to a circuit using the native basis gates of the device.

### Step 3: Executing the circuit.

### Step 4: Post-processing the results.

## 4. A 3-qubit Grover Search

Now, let's try a 3-qubit Grover search example.

This time, $|111\rangle$ is the "good" state.

$|0111\rangle$ is observed with the highest probability, as expected. Note that two iterations are optimal in this case. However, the probability of obtaining the correct answer is not 100%, which is usual in Grover's search.

#### What happens if we iterate 3 times?

Now, let's try iterating 3 times.

$|0111\rangle$ is still observed with the highest probability, though the probability of obtaining the correct answer has slightly decreased.

#### How about 4 times?

Now, let's try iterating 4 times.

$|0111\rangle$ is observed with the lowest probability, and the probability of obtaining the correct answer has decreased further.
This demonstrates the importance of choosing the optimal number of iterations for Grover's algorithm to achieve the best results.
