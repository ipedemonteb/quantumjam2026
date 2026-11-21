# Quantum bits, gates, and circuits

> Fuente: <https://quantum.cloud.ibm.com/learning/en/courses/utility-scale-quantum-computing/bits-gates-and-circuits>

> Solo las celdas de texto del notebook original; sin código.


<Admonition type="note">

Kifumi Numata (19 Apr 2024)

Click [here](https://ibm.ent.box.com/public/static/vee9e1kkxxiih5g8yqdhoo6t0o3dw7xf.zip) to download the pdf of the original lecture. Note that some code snippets might become deprecated since these are static images.

*Approximate QPU time to run this experiment is 5 seconds.*

</Admonition>

## 1. Introduction
Bits, gates, and circuits are the basic building blocks of quantum computing. You will learn quantum computation with the circuit model using quantum bits and gates, and also review the superposition, measurement, and entanglement.

In this lesson you will learn:
- Single-qubit gates
- Bloch sphere
- Superposition
- Measurement
- Two-qubit gates and entanglement state

At the end of this lecture, you will learn about circuit depth, which is essential for utility-scale quantum computing.

## 2. Computation as a diagram

When using qubits or bits, we need to manipulate them in order to turn the inputs we have into the outputs we need. For the simplest programs with very few bits, it is useful to represent this process in a diagram known as a *circuit diagram*.

The bottom-left figure is an example of a classical circuit, and the bottom-right figure is an example of a quantum circuit. In both cases, the inputs are on the left and the outputs are on the right, while the operations are represented by symbols. The symbols used for the operations are called “gates”, mostly for historical reasons.

## 3. Single-qubit quantum gate

### 3.1 Quantum state and Bloch sphere

A qubit's state is represented as a superposition of $|0\rangle$ and $|1\rangle$. An arbitrary quantum state is represented as

$$
|\psi\rangle =\alpha|0\rangle+ \beta|1\rangle
$$

where $\alpha$ and $\beta$ are complex numbers such that $|\alpha|^2+|\beta|^2=1$.

$|0\rangle$ and $|1\rangle$ are vectors in the two-dimensional complex vector space:

$$
|0\rangle = \begin{pmatrix}
1 \\0
\end{pmatrix},
|1\rangle = \begin{pmatrix}
0\\1
\end{pmatrix}
$$

Therefore, an arbitrary quantum state is also represented as

$$
|\psi\rangle = \alpha\begin{pmatrix}
1 \\ 0
\end{pmatrix} + \beta\begin{pmatrix}0\\
1
\end{pmatrix} = \begin{pmatrix}
\alpha \\ \beta
\end{pmatrix}
$$

From this, we can see that the state of a quantum bit is a unit vector in a two-dimensional complex inner product space with an orthonormal basis of $|0\rangle$ and $|1\rangle$. It is normalized to 1.

$$
\langle\psi|\psi\rangle = \begin{pmatrix}
\alpha^* & \beta^*
\end{pmatrix}
\begin{pmatrix}
\alpha \\
\beta
\end{pmatrix} = 1
$$

$ |\psi\rangle =\begin{pmatrix}
\alpha \\ \beta
\end{pmatrix}$ is also called the statevector.

A single-qubit quantum state is also represented as

$$
|\psi\rangle
=\cos\frac{\theta}{2}|0\rangle+e^{i\varphi}\sin\frac{\theta}{2}|1\rangle
=\left( \begin{pmatrix} \cos\frac{\theta}{2}\\ e^{i\varphi}\sin\frac{\theta}{2}
\end{pmatrix}\right)
$$

where $\theta$ and $\varphi$ are the angles of the Bloch sphere in the following figure.

In the next few code cells, we will build up basic calculations from constituent pieces in Qiskit. We'll construct an empty circuit and then add quantum operations, discussing the gates and visualizing their effects as we go.
You can run the cell by "Shift" + "Enter". Import the libraries first.

#### Prepare the quantum circuit
We will create and draw a single-qubit circuit.

#### X gate

The X gate is a $\pi$ rotation around the $x$ axis of the Bloch sphere.
Applying the X gate to $|0\rangle$ results in $|1\rangle$, and applying the X gate to $|1\rangle$ results in $|0\rangle$, so it is an operation similar to the classical NOT gate, and is also known as bit flip. The matrix representation of the X gate is below.

$$
X = \begin{pmatrix}
0 & 1 \\
1 & 0 \\
\end{pmatrix}
$$

In IBM Quantum&reg;, the initial state is set to $|0\rangle$, so the quantum circuit above in matrix representation is

$$
X|0\rangle=  \begin{pmatrix}
0 & 1 \\
1 & 0
\end{pmatrix}
\begin{pmatrix}
1 \\ 0
\end{pmatrix}
 =\begin{pmatrix}
0 \\ 1
\end{pmatrix} = |1\rangle
$$

Next, let's run this circuit using a statevector simulator.

Vertical vector is displayed as row vector, with complex numbers (the imaginary part is indexed by $j$ ).

#### H gate
The Hadamard gate is a $\pi$ rotation around an axis halfway between the $x$ and $z$ axes on the Bloch sphere. Applying the H gate to $|0\rangle$ creates a superposition state such as $\frac{|0\rangle + |1\rangle}{\sqrt{2}}$. The matrix representation of the H gate is below.

$$
H = \frac{1}{\sqrt{2}}\begin{pmatrix}
1 & 1 \\
1 & -1 \\
\end{pmatrix}
$$

This is
$$
H|0\rangle= \frac{1}{\sqrt{2}} \begin{pmatrix}
1 & 1 \\
1 & -1
\end{pmatrix}
\begin{pmatrix}
1 \\0
\end{pmatrix}
 =\frac{1}{\sqrt{2}}\begin{pmatrix}
1 \\
1
\end{pmatrix}
=\begin{pmatrix}
0.707 \\
0.707
\end{pmatrix}
=\frac{1}{\sqrt{2}}(|0\rangle+|1\rangle)
$$

This superposition state is so common and important, that it is given its own symbol:

$$
|+\rangle \equiv \frac{1}{\sqrt{2}}(|0\rangle+|1\rangle).
$$

By applying the $H$ gate on the $|0\rangle$, we created a superposition of $|0\rangle$ and $|1\rangle$ where measurement in the computational basis (along z in the Bloch sphere picture) would give you each state with equal probabilities.

#### $|-\rangle$ state

You might have guessed that there is a corresponding  $|-\rangle$ state:
$$
|-\rangle \equiv \frac{|0\rangle -|1\rangle}{\sqrt{2}}.
$$
To create this state, first apply an X gate to make $|1\rangle$, then apply an H gate.

This is

$$
H|1\rangle= \frac{1}{\sqrt{2}} \begin{pmatrix}
1 & 1 \\\
1 & -1
\end{pmatrix}
\begin{pmatrix}
0 \\\
1
\end{pmatrix}
 =\frac{1}{\sqrt{2}}\begin{pmatrix}
1 \\\
-1
\end{pmatrix}
=\begin{pmatrix}
0.707 \\\
-0.707
\end{pmatrix}
=\frac{1}{\sqrt{2}}(|0\rangle-|1\rangle) = |-\rangle
$$

Applying the $H$ gate on $|1\rangle$ results in an equal superposition of $|0\rangle$ and $|1\rangle$, but the sign of $|1\rangle$ is negative.

### 3.2 Single-qubit quantum state and unitary evolution

The actions of all the gates we have seen so far have been *unitary*, which means they can be represented by a unitary operator. In other words, the output state can be obtained by acting on the initial state with a unitary matrix:

$$
|\psi^{'}\rangle = U|\psi\rangle
$$

A unitary matrix is a matrix satisfying

$$
U^{\dagger}U =U U^{\dagger} = I.
$$

In terms of quantum computer operation, we would say that applying a quantum gate to the qubit evolves the quantum state. Common single-qubit gates include the following.

Pauli gates:

$$
X = \begin{pmatrix}
0 & 1 \\
1 & 0 \\
\end{pmatrix}
= |0\rangle \langle 1|+|1\rangle \langle 0|
$$

$$
Y = \begin{pmatrix}
0 & -i \\
i & 0 \\
\end{pmatrix}
= -i|0\rangle \langle 1|+i|1\rangle \langle 0|
$$

$$
Z = \begin{pmatrix}
1 & 0 \\
0 & -1 \\
\end{pmatrix}
= |0\rangle \langle 0|-|1\rangle \langle 1|
$$

where the outer product was calculated as follows:
$$
|0\rangle \langle 0|=
\begin{bmatrix}
1 \\
0
\end{bmatrix}
\begin{bmatrix}
1 & 0
\end{bmatrix}
=\begin{bmatrix}
1 & 0 \\
0 & 0 \\
\end{bmatrix}, \quad
|1\rangle \langle 0|=
\begin{bmatrix}
0 \\
1
\end{bmatrix}
\begin{bmatrix}
1 & 0
\end{bmatrix}
=\begin{bmatrix}
0 & 0 \\
1 & 0 \\
\end{bmatrix}, \quad
$$

$$
|0\rangle \langle 1|=
\begin{bmatrix}
1 \\
0
\end{bmatrix}
\begin{bmatrix}
0 & 1
\end{bmatrix}
=\begin{bmatrix}
0 & 1 \\
0 & 0 \\
\end{bmatrix}, \quad
|1\rangle \langle 1|=
\begin{bmatrix}
0 \\
1
\end{bmatrix}
\begin{bmatrix}
0 & 1
\end{bmatrix}
=\begin{bmatrix}
0 & 0 \\
0 & 1 \\
\end{bmatrix}, \quad
$$

Other typical single-qubit gates:
$$
H= \frac{1}{\sqrt{2}}\begin{bmatrix}
1 & 1 \\
1 & -1 \\
\end{bmatrix},\quad
S = \begin{bmatrix}
1 & 0 \\
0 & i \\
\end{bmatrix}, \quad
T = \begin{bmatrix}
1 & 0 \\
0 & exp(i\pi/4) \\
\end{bmatrix}
$$

$$
R_x(\theta) = e^{-i\theta X/2} = cos\frac{\theta}{2}I - i sin \frac{\theta}{2}X = \begin{bmatrix}
cos\frac{\theta}{2} &  -i sin \frac{\theta}{2} \\
-i sin \frac{\theta}{2} & cos\frac{\theta}{2} \\
\end{bmatrix}
$$

$$
R_y(\theta) = e^{-i\theta Y/2} = cos\frac{\theta}{2}I - i sin \frac{\theta}{2}Y = \begin{bmatrix}
cos\frac{\theta}{2} &  - sin \frac{\theta}{2} \\
sin \frac{\theta}{2} & cos\frac{\theta}{2} \\
\end{bmatrix}
$$

$$
R_z(\theta) = e^{-i\theta Z/2} = cos\frac{\theta}{2}I - i sin \frac{\theta}{2}Z = \begin{bmatrix}
e^{-i\theta /2} &  0 \\
0 & e^{i\theta /2} \\
\end{bmatrix}
$$

The meaning and use of these are described in more detail in the [Basics of Quantum Information](https://quantum.cloud.ibm.com/learning/courses/basics-of-quantum-information) course.

### Exercise 1

Use Qiskit to create quantum circuits that prepare the states described below. Then run each circuit using the statevector simulator and display the resulting state on the Bloch sphere. As a bonus, see if you can anticipate what the final state should be based on intuition about the gates and rotations in the Bloch sphere.

(1) $XX|0\rangle$

(2) $HH|0\rangle$

(3) $HZH|0\rangle$

Tips: Z gate can be used by

    qc.z(0)

__Solution:__

### 3.3 Measurement

Measurement is theoretically a very complicated topic. But in practical terms, making a measurement along $z$ (as all IBM&reg; quantum computers do) simply forces the qubit’s state $\alpha|0\rangle+\beta|1\rangle \quad (s.t.|\alpha|^2+|\beta|^2=1)$ either to $|0\rangle$ or to $|1\rangle$, and we observe the outcome.
- $|\alpha|^2$ is the probability we will get $|0\rangle$ when we measure.
- $|\beta|^2$ is the probability we will get $|1\rangle$ when we measure.

So, $\alpha$ and $\beta$ are called probability amplitudes. (see "Born rule")

For example, $\frac{\sqrt{2}}{2}|0\rangle+\frac{\sqrt{2}}{2}|1\rangle$ has an equal probability of becoming $|0\rangle$ or $|1\rangle$ upon measurement. $\frac{\sqrt{3}}{2}|0\rangle-\frac{1}{2}i|1\rangle$ has a 75% chance of becoming $|0\rangle$.

#### Qiskit Aer Simulator
Next, let's measure a circuit that prepares the equal probability superposition above.
We should add the measurement gates, as the Qiskit Aer simulator simulates an ideal (with no noise) quantum hardware by default. Note: The Aer simulator can also apply a noise model based on real quantum computer. We will return to noise models later.

We are now ready to run our circuit on the Aer simulator. In this example, we will apply the default shots=1024, which means we will measure 1024 times. Then we will plot those counts in a histogram.

We see that 0s and 1s were measured with a probability of almost 50% each. Although noise has not been simulated here, the states are still probabilistic. So while we expect roughly a 50-50 distribution, we will rarely find exactly that. Just as 100 flips of a coin would rarely yield exactly 50 instances of each side.

## 4. Multi-qubit quantum gate and entanglement

### 4.1 Multi-qubit quantum circuit

We can create a two-qubit quantum circuit with following code. We will apply an H gate to each qubit.

#### Note: Qiskit bit ordering

Qiskit uses **Little Endian** notation when ordering qubits and bits, meaning **qubit 0 is the rightmost bit** in the bitstrings. Example: $|01\rangle$ means q0 is $|1\rangle$ and q1 is $|0\rangle$. Be careful because some literature in quantum computing use the Big Endian notation (qubit 0 is the leftmost bit) and a great deal of quantum mechanics literature does, too.

Another thing to notice is that when representing a quantum circuit, $|q_0\rangle$ is always placed at the top of the circuit.

With this in mind, the quantum state of the above circuit can be written as a tensor product of single-qubit quantum state.

$
|q1\rangle \otimes|q0\rangle = (a|0\rangle+b|1\rangle) \otimes (c|0\rangle+d|1\rangle)
$

$
= ac|0\rangle|0\rangle+ad|0\rangle|1\rangle+bc|1\rangle|0\rangle+bd|1\rangle|1\rangle
$

$
= ac|00\rangle+ad|01\rangle+bc|10\rangle+bd|11\rangle
$

( $|ac|^2+ |ad|^2+ |bc|^2+ |bd|^2=1$ )

The initial state of Qiskit is $|0\rangle|0\rangle=|00\rangle$, so by applying $H$ to each qubit, it changes to a state of equal superposition.

$H|0\rangle \otimes H|0\rangle=\frac{1}{\sqrt{2}}(|0\rangle+|1\rangle) \otimes \frac{1}{\sqrt{2}}(|0\rangle+|1\rangle) = \frac{1}{2}(|00\rangle+|01\rangle+|10\rangle+|11\rangle)$

$$
=\frac{1}{2}\left( \begin{pmatrix} 1 \\ 1 \end{pmatrix} \otimes \begin{pmatrix} 1 \\ 1 \end{pmatrix}\right) = \frac{1}{2}\begin{pmatrix} 1 \\ 1 \\ 1 \\ 1 \end{pmatrix}=\frac{1}{2}\left(\begin{pmatrix} 1 \\ 0 \\ 0 \\ 0 \end{pmatrix}+\begin{pmatrix} 0 \\ 1 \\ 0 \\ 0 \end{pmatrix}+\begin{pmatrix} 0 \\ 0 \\ 1 \\ 0 \end{pmatrix}+\begin{pmatrix} 0 \\ 0 \\ 0 \\ 1 \end{pmatrix}\right)
$$

The measurement rule is also same as a single qubit case, the probability of measuring $|00\rangle$ is $|ac|^2$.

Next, let's measure this circuit.

Now, we will use a Aer simulator, again, to experimentally verify that the relative probabilities of all possible output states are roughly equal.

As expected, the states $|00\rangle$, $|01\rangle$, $|10\rangle$, $|11\rangle$ were measured almost 25% each.

### 4.2 Multi-qubit quantum gates
#### CNOT gate

A CNOT("controlled NOT" or CX) gate is a two-qubit gate, meaning its action involves two qubits at once: the control qubit and the target qubit. A CNOT flips the target qubit only when the control qubit is $|1\rangle$.

| Input (target,control) | Output (target,control) |
|:-----------:|:------------:|
| 00          | 00           |
| 01          | 11           |
| 10          | 10           |
| 11          | 01           |

Let us first simulate the action of this two-qubit gate when q0 and q1 are both $|0\rangle$, and obtain the output statevector. The Qiskit syntax used is ```qc.cx(control qubit, target qubit)```.

As expected, applying a CNOT gate on $|00\rangle$ did not change the state, since the control qubit was in the $|0\rangle$ state.

Let's get back to our CNOT operation. This time we will apply a CNOT gate to $|01\rangle$ and see what happens.

By applying a CNOT gate, the $|01\rangle$ state has now become $|11\rangle$.

Let us verify these results by running the circuit on a simulator.

The results should show you that $|11\rangle$ has been measured with 100% probability.

### 4.3 Quantum entanglement and execution on a real quantum device

Let's start by introducing a specific entangled state which is particularly important in quantum computation, then we'll define the term "entangled":

$$
\frac{1}{\sqrt{2}}|00\rangle + \frac{1}{\sqrt{2}}|11\rangle
$$
and this state is called a **Bell state**.

An entangled state is a state $|\psi_{AB}\rangle$ consisting of quantum states $|\psi_A\rangle$ and $|\psi_B\rangle$ that cannot be represented by a tensor product of individual quantum states.

If $|\psi_{AB}\rangle$ below has two states $|\psi\rangle_A$ and $|\psi\rangle_B$;

$$
|\psi_{AB}\rangle = \frac{1}{\sqrt{2}}(|00\rangle +|11\rangle) = \frac{1}{\sqrt{2}}(|0\rangle_A|0\rangle_B +|1\rangle_A|1\rangle_B)
$$

$$
|\psi\rangle_A = a_0|0\rangle+a_1|1\rangle
$$
$$
|\psi\rangle_B = b_0|0\rangle+b_1|1\rangle
$$

the tensor product of these two states is the following

$$
|\psi\rangle _A\otimes |\psi\rangle _B = a_0 b_0|00\rangle+a_0 b_1|01\rangle+a_1 b_0|10\rangle+a_1 b_1|11\rangle
$$

but there are no coefficients $a_0$, $a_1$, $b_0$, and $b_1$ to satisfy these two equations. Therefore, $|\psi_{AB}\rangle$ is not represented by a tensor product of individual quantum state, $|\psi\rangle_A$ and $|\psi\rangle_B$, and this means that $|\psi_{AB}\rangle =  \frac{1}{\sqrt{2}}(|00\rangle +|11\rangle)$ is entangled state.

Let us create the Bell state and run it on a real quantum computer. Now we will follow the four steps to writing a quantum program, called **Qiskit patterns**:

    1. Map problem to quantum circuits and operators
    2. Optimize for target hardware
    3. Execute on target hardware
    4. Post-process the results

#### Step 1. Map problem to quantum circuits and operators

In a quantum program, quantum circuits are the native format in which to represent quantum instructions. When creating a circuit, you'll usually create a new QuantumCircuit object, then add instructions to it in sequence.

The following code cell creates a circuit that produces a Bell state, the specific two-qubit entangled state from above.

#### Step 2. Optimize for target hardware

Qiskit converts abstract circuits to QISA (Quantum Instruction Set Architecture) circuits that respect the constraints of the target hardware and optimizes circuit performance. So before the optimization, we will specify the target hardware.

If you do not have `qiskit-ibm-runtime`, you will need to install this first. For more information, [check out the API reference](https://quantum.cloud.ibm.com/docs/api/qiskit-ibm-runtime/runtime-service).

We will specify the target hardware.

Transpiling the circuit is yet another complex process. Very briefly, this rewrites the circuit into a logically equivalent one using "native gates" (gates that a particular quantum computer can implement) and maps the qubits in your circuit to optimal real qubits on the target quantum computer. For more on transpilation, see this [documentation](https://quantum.cloud.ibm.com/docs/api/qiskit/transpiler#overview).

You can see that in the transpilation the circuit was rewritten using new gates. For more information, refer to the [ECRGate](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.library.ECRGate#ecrgate) documentation.

#### Step 3. Execute the target circuit

Now, we will run the target circuit on the real device.

Execution on the real device might require waiting in a queue, since quantum computers are valuable resources, and very much in demand. The job_id is used to check the execution status and results of the job later.

You can also check the job status from your IBM Quantum dashboard：https://quantum.cloud.ibm.com/workloads

#### Step 4. Post-process the results

Finally, we must post-process our results to create outputs in the expected format, like values or graphs.

As you can see, $|00\rangle$ and $|11\rangle$ are the most frequently observed. There are a few results other than the expected data, and they are due to noise and qubit decoherence. We will learn more about errors and noise in quantum computers in the later lessons of this course.

### 4.4 GHZ state

The concept of entanglement can be extended to systems of more than two qubits. The GHZ state (Greenberger-Horne-Zeilinger state) is a maximally entangled state of three or more qubits. The GHZ state for three qubits is defined as

$$
\frac{1}{\sqrt 2}(|000\rangle + |111\rangle)
$$

It can be created with the following quantum circuit.

The "depth" of a quantum circuit is a useful and common metric to describe quantum circuits. Trace a path through the quantum circuit, moving left to right, only changing qubits when they are connected by a multi-qubit gate. Count the number of gates along that path. The maximum number of gates for any such path through a circuit is the depth. In modern noisy quantum computers, low-depth circuits have fewer errors and are likely to return good results. Very deep circuits are not.

Using `QuantumCircuit.depth()`, we can check the depth of our quantum circuit. The depth of the above circuit is 4. The top qubit has only three gates including the measurement. But there is a path from the top qubit down to either qubit 1 or qubit 2 which involves another CNOT gate.

### Exercise 2

The GHZ state of an 8-qubit system is

$$
\frac{1}{\sqrt 2}(|00000000\rangle + |11111111\rangle)
$$

Write code to prepare this state with the shallowest possible circuit. The depth of the shallowest quantum circuit is 5, including the measurement gates.

__Solution__:

## 5. Summary

You have learned quantum computation with the circuit model using quantum bits and gates, and you have reviewed superposition, measurement, and entanglement. You also have learned the method to execute the quantum circuit on the real quantum device.

In the final exercise to create a GHZ circuit, you have tried to reduce the circuit depth, which is an important factor for obtaining a utility scale solution in a noisy quantum computer.  In the later lessons of this course, you will learn about noise and about error mitigation methods in detail. In this lesson, as an introduction, we considered reducing the circuit depth in an ideal device, but in reality, we must consider the constraints of real device, such as qubit connectivity.  You will learn more about this in subsequent lessons in this course.
