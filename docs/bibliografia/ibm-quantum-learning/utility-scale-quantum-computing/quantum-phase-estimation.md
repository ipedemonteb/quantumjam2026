# Quantum algorithms: Phase estimation

> Fuente: <https://quantum.cloud.ibm.com/learning/en/courses/utility-scale-quantum-computing/quantum-phase-estimation>

> Solo las celdas de texto del notebook original; sin código.


<Admonition type="note">

Kento Ueda (15 May 2024)

This notebook provides the fundamental concepts and implementation of the Quantum Fourier Transformation (QFT) and Quantum Phase Estimation (QPE).

[Download the pdf](https://ibm.ent.box.com/public/static/srgnll6u8ame7gk186pkthq7erc7l6rw.zip) of the original lecture. Note that some code snippets might become deprecated since these are static images.

*Approximate QPU time to run this experiment is 7 seconds.*

</Admonition>

## 1. Introduction

**Quantum Fourier Transformation (QFT)**

The Quantum Fourier Transformation is the quantum counterpart of the classical discrete Fourier transform. It is a linear transformation applied to the quantum states, mapping computational bases into their Fourier basis representations. The QFT plays a key role in many quantum algorithms, offering an efficient method to extract periodicity information from quantum states.
The QFT can be implemented with $O(N^2)$ operations with quantum gates such as Hadamard gates and Control-Phase gates for $N$ qubits, enabling exponential speedup over classical Fourier transformation.

- **Applications**: It is a foundational part in quantum algorithms such as Shor's algorithm for factoring large integers and discrete logarithm.

**Quantum Phase Estimation (QPE)**

Quantum Phase Estimation is a quantum algorithm used to estimate the phase associated with an eigenvector of a unitary operator. This algorithm provides a bridge between the abstract mathematical properties of quantum states and their computational applications.

- **Applications**: It can solve problems such as finding eigenvalues of unitary matrices and simulating quantum systems.

Together, QFT and QPE form the essential backbone of many quantum algorithms solving problems that are infeasible for classical computers. By the end of this notebook, you will gain an understanding of how these techniques are implemented.

## 2. Basic of Quantum Fourier Transformation (QFT)

From the analogy with the discrete Fourier transform, the QFT acts on a quantum state $\vert X\rangle = \sum_{j=0}^{N-1} x_j \vert j \rangle$ for $N$ qubits and maps it to the quantum state $\vert Y\rangle = \sum_{k=0}^{N-1} y_k \vert k \rangle$.

$$
QFT_{N}: \vert j \rangle \mapsto \frac{1}{\sqrt{N}}\sum_{k=0}^{N-1}\omega_N^{jk} \vert k \rangle
$$

where $\omega_N^{jk} = e^{2\pi i \frac{jk}{N}}$.

Or the unitary matrix representation:

$$
U_{QFT} = \frac{1}{\sqrt{N}} \sum_{j=0}^{N-1} \sum_{k=0}^{N-1} \omega_N^{jk} \vert k \rangle \langle j \vert
$$

### 2.1. Intuition <a id="intuition"></a>

The quantum Fourier transform (QFT) transforms between two bases, the computational (Z) basis, and the Fourier basis. But what does the Fourier basis mean in this context? You likely recall that the Fourier transform $F(\omega)$ of a function $f(x)$ describes the convolution of $f(x)$ onto a sinusoidal function with frequency $\omega$. In Layman's terms: the Fourier transform is a function describing how much of each frequency $\omega$ we would need to build up a function $f(x)$ out of sine functions (or cosine functions). To get a better sense for what the QFT means in this context, consider the stepped images below which show a number encoded in binary, using four qubits:

In the computational basis, we store numbers in binary using the states $|0\rangle$ and $|1\rangle$.

Note the frequency with which the different qubits change; the leftmost qubit flips with every increment in the number, the next with every 2 increments, the third with every 4 increments, and so on.

If we apply a quantum Fourier transform to these states, we map
$$
|\text{State in Computational Basis}\rangle \quad \xrightarrow[]{\text{QFT}} \quad |\text{State in Fourier Basis}\rangle
$$

$$
\text{QFT}|x\rangle = |\widetilde{x}\rangle
$$

(We often denote states in the Fourier basis using the tilde (~)).

In the Fourier basis, we store numbers using different rotations around the Z-axis:

IFRAME

The number we want to store dictates the angle at which each qubit is rotated around the Z-axis. In the state $|\widetilde{0}\rangle$, all qubits are in the state $|{+}\rangle$. As seen in the example above, to encode the state $|\widetilde{5}\rangle$ on 4 qubits, we rotated the leftmost qubit by $\tfrac{5}{2^n} = \tfrac{5}{16}$ full turns ($\tfrac{5}{16}\times 2\pi$ radians). The next qubit is turned double this ($\tfrac{10}{16}\times 2\pi$ radians, or $10/16$ full turns), this angle is then doubled for the qubit after, and so on.

Again, note the frequency with which each qubit changes. The leftmost qubit (`qubit 0`) in this case has the lowest frequency, and the rightmost the highest.

### 2.2 Example: 1-qubit QFT

Let's consider the case of $N = 2^1 = 2$.

The unitary matrix can be written:

$$
\begin{aligned}
U_{QFT} & = \frac{1}{\sqrt{2}} \sum_{j=0}^{1} \sum_{k=0}^{1} \omega_2^{jk} \vert k \rangle \langle j \vert
\\
& = \frac{1}{\sqrt{2}} (\omega_2^{0} \vert 0 \rangle \langle 0 \vert + \omega_2^{0} \vert 0 \rangle \langle 1 \vert + \omega_2^{0} \vert 1 \rangle \langle 0 \vert + \omega_2^{1} \vert 1 \rangle \langle 1 \vert)
\\
& = \frac{1}{\sqrt{2}} (\vert 0 \rangle \langle 0 \vert + \vert 0 \rangle \langle 1 \vert + \vert 1 \rangle \langle 0 \vert - \vert 1 \rangle \langle 1 \vert)
\\
& = H
\end{aligned}
$$

This operation is the result of applying the Hadamard gate ($H$).

### 2.3 Product representation of QFT

Let's generalize a transformation for $N = 2^n$, $QFT_{N}$ acting on the state $\vert x \rangle = \vert x_1\ldots x_n \rangle$.
$$
\begin{aligned}
QFT_N\vert x \rangle & = \frac{1}{\sqrt{N}} \sum_{y=0}^{N-1}\omega_N^{xy} \vert y \rangle
\\
& = \frac{1}{\sqrt{N}} \sum_{y=0}^{N-1} e^{2 \pi i xy / 2^n} \vert y \rangle ~\text{since}\: \omega_N^{xy} = e^{2\pi i \frac{xy}{N}} \:\text{and}\: N = 2^n
\\
& = \frac{1}{\sqrt{N}} \sum_{y=0}^{N-1} e^{2 \pi i \left(\sum_{k=1}^n y_k/2^k\right) x} \vert y_1 \ldots y_n \rangle \:\text{rewriting in fractional binary notation}\: y = y_1\ldots y_n, y/2^n = \sum_{k=1}^n y_k/2^k
\\
& = \frac{1}{\sqrt{N}} \sum_{y=0}^{N-1} \prod_{k=1}^n e^{2 \pi i x y_k/2^k } \vert y_1 \ldots y_n \rangle \:\text{after expanding the exponential of a sum to a product of exponentials,}
\\
& = \frac{1}{\sqrt{N}} \bigotimes_{k=1}^n  \left(\vert0\rangle + e^{2 \pi i x /2^k } \vert1\rangle \right) \:\text{after rearranging the sum and products, and expanding}
\sum_{y=0}^{N-1} = \sum_{y_1=0}^{1}\sum_{y_2=0}^{1}\ldots\sum_{y_n=0}^{1}
\\
& = \frac{1}{\sqrt{N}}
\left(\vert0\rangle + e^{\frac{2\pi i}{2}x} \vert1\rangle\right)
\otimes
\left(\vert0\rangle + e^{\frac{2\pi i}{2^2}x} \vert1\rangle\right)
\otimes
\ldots
\otimes
\left(\vert0\rangle + e^{\frac{2\pi i}{2^{n-1}}x} \vert1\rangle\right)
\otimes
\left(\vert0\rangle + e^{\frac{2\pi i}{2^n}x} \vert1\rangle\right)
\end{aligned}
$$

### 2.4 Example: Circuit construction of 3 qubits QFT

From the above description, it might not be clear how to construct a QFT circuit. For now, simply note that we expect three qubits to have phases that evolve at different "rates". Understand exactly how this is translated into a circuit is left as an exercise to the reader. There are multiple diagrams and examples in the lecture pdf. Additional resources include [this lesson](https://quantum.cloud.ibm.com/learning/courses/fundamentals-of-quantum-algorithms/phase-estimation-and-factoring/introduction) from the Fundamentals of quantum algorithms course.

We will demonstrate QFT using simulators only, and thus we will not use the Qiskit patterns framework until we move on to quantum phase estimation.

We try to apply QFT to $|5\rangle$ as an example.

First, we confirm the binary notation of the integer 5 and create the circuit encoding the state 5:

We check the quantum states using the Aer simulator:

Finally, we add QFT and view the final state of our qubits:

We can see out QFT function has worked correctly. Qubit 0 has been rotated by $\tfrac{5}{8}$ of a full turn, qubit 1 by $\tfrac{10}{8}$ full turns (equivalent to $\tfrac{1}{4}$ of a full turn), and qubit 2 by $\tfrac{20}{8}$ full turns (equivalent to $\tfrac{1}{2}$ of a full turn).

### 2.5 Exercise: QFT

(1) Implement QFT of 4 qubits.

(2) Apply QFT to $|14\rangle$, simulate and plot the statevector using the Bloch sphere.

#### Solution of the exercise: QFT

(1)

(2)

## 3. Basics of Quantum Phase Estimation (QPE)

Given a unitary operation $U$, the QPE estimates $\theta$ in $U\vert\psi \rangle =e^{\boldsymbol{2\pi i} \theta }|\psi \rangle$ since $U$ is unitary, all of its eigenvalues have a norm of 1.

### 3.1 Procedure

#### 1. Setup
$\vert\psi\rangle$ is in one set of qubit registers. An additional set of $n$ qubits form the counting register on which we will store the value $2^n\theta$:

$$
|\psi_0\rangle = \lvert 0 \rangle^{\otimes n} \lvert \psi \rangle
$$

#### 2. Superposition

Apply a $n$-bit Hadamard gate operation $H^{\otimes n}$ on the counting register:

$$
|\psi_1\rangle = {\frac {1}{2^{\frac {n}{2}}}}\left(|0\rangle +|1\rangle \right)^{\otimes n} \lvert \psi \rangle
$$

#### 3. Controlled Unitary operations

We need to introduce the controlled unitary $CU$ that applies the unitary operator $U$ on the target register only if its corresponding control bit is $|1\rangle$. Since $U$ is a unitary operator with eigenvector $|\psi\rangle$ such that $U|\psi \rangle =e^{\boldsymbol{2\pi i} \theta }|\psi \rangle$, this means:

$$
U^{2^{j}}|\psi \rangle =U^{2^{j}-1}U|\psi \rangle =U^{2^{j}-1}e^{2\pi i\theta }|\psi \rangle =\cdots =e^{2\pi i2^{j}\theta }|\psi \rangle
$$

### 3.2 Example: T-gate QPE

Let's use $T$ gate as an example of QPE and estimate its phase $\theta$.

$$
T|1\rangle =
\begin{pmatrix}
1 & 0\\
0 & e^\frac{i\pi}{4}\\
\end{pmatrix}
\begin{pmatrix}
0\\
1\\
\end{pmatrix}
= e^\frac{i\pi}{4}|1\rangle
$$

We expect to find:

$$
\theta = \frac{1}{8}
$$

where

$$
T|1\rangle = e^{2i\pi\theta}|1\rangle
$$

We initialize $\vert\psi\rangle = \vert1\rangle$ of the eigenvector of $T$ gate by applying an $X$ gate:

Next, we apply Hadamard gates to the counting qubits:

We perform the controlled unitary operations:

We apply the inverse quantum Fourier transformation to convert the state of the counting register, then measure the counting register:

We can simulate using Aer simulator:

We see we get one result (`001`) with certainty, which translates to the decimal: `1`. We now need to divide our result (`1`) by $2^n$ to get $\theta$:

$$
\theta = \frac{1}{2^3} = \frac{1}{8}
$$

Shor's algorithm allows us to factorize a number by building a circuit with $\theta$ unknown and obtaining $\theta$.

### 3.3 Exercise

Estimate $\theta = 1/3$ using 3 qubits for counting and a qubit for an eigenvector.

$P|1\rangle = e^{i\lambda}|1\rangle$. Since we want to implement $U|1\rangle = e^{2\pi i \tfrac{1}{3}}|1\rangle$, we need to set $\lambda = \tfrac{2 \pi}{3}$.

#### Solution of the exercise: $\theta = 1/3$

## 4. Execution using the IBM Quantum&reg; Sampler primitive

We will perform QPE using the real quantum device and follow 4 steps of Qiskit patterns.

    1. Map the problem to a quantum-native format
    2. Optimize the circuits
    3. Execute the target circuit
    4. Post-process the results

### 4.1 Step 1: Map problem to quantum circuits and operators

### 4.2 Step 2: Optimize for target hardware

### 4.3 Step 3: Execute on target hardware

### 4.4 Step 4: Post-process the results
