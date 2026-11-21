# Quantum teleportation and superdense coding

> Fuente: <https://quantum.cloud.ibm.com/learning/en/courses/utility-scale-quantum-computing/teleportation>

> Solo las celdas de texto del notebook original; sin código.


<Admonition type="note">

Kifumi Numata (26 Apr 2024)

[Download the pdf](https://ibm.ent.box.com/public/static/ws8x00xu0pksjzixyyspxzrilvt36iff.zip) of the original lecture. Note that some code snippets might become deprecated since these are static images.

*Approximate QPU time to run this experiment is 10 seconds.*

</Admonition>

## 1. Introduction

To solve any utility-scale quantum problem, we will need to move information around on a quantum computer from one qubit to another. There are well-known protocols for doing this, but some of the most foundational were cast in the context of sending information between distant parties. Throughout this lesson, we will sometimes use language consistent with this context, such as "distant friends sending information". But keep in mind that these protocols have broader significance in quantum computing. In this lesson we consider the following quantum communication protocols:
- **Quantum teleportation**
    Using a shared entangled state (sometimes called an e-bit) to send an unknown quantum state to a distant friend, requiring supplemental classical communication.
- **Quantum superdense coding**
    How to send two bits of information by sending a single qubit to a distant friend (again using prior shared entangled qubits).

For more background relevant to these topics, we recommend lesson 4 in Basics of Quantum Information on [Entanglement in action](https://quantum.cloud.ibm.com/learning/courses/basics-of-quantum-information/entanglement-in-action/introduction).

In the above description, an "unknown quantum state" simply refers to a state of the form described in the previous lesson:
$$
|\psi\rangle =\alpha|0\rangle+\beta|1\rangle
$$
where $\alpha$ and $\beta$ are complex numbers such that $|\alpha|^2+|\beta|^2 = 1$.  This allows us to write the quantum state as
$$
|\psi\rangle =\cos\frac{\theta}{2}|0\rangle+e^{i\varphi}\sin\frac{\theta}{2}|1\rangle=
\left(
\begin{matrix}
\cos\frac{\theta}{2}\\
e^{i\varphi}\sin\frac{\theta}{2}
\end{matrix}
\right)
$$
Since we want to be able to transfer the information in any random quantum state, generating such a state is where we will begin this lesson.

## 2. Density matrices

We can also write the quantum state $|\psi \rangle$ as its density matrix. This form is useful for denoting probabilistic mixture
of pure quantum states. In the case of a single qubit, we can write

$$
|\psi \rangle \langle \psi| \equiv  \rho = \left(
\begin{pmatrix}
\cos\frac{\theta}{2}\\
e^{i\varphi}\sin\frac{\theta}{2}
\end{pmatrix}
\right)
\left(
\begin{pmatrix}
\cos\frac{\theta}{2} & e^{-i\varphi}\sin\frac{\theta}{2}
\end{pmatrix}
\right)
=\frac{1}{2}\left(\begin{pmatrix}
1+\cos\theta & e^{-i\varphi}\sin\theta\\
e^{-i\varphi}\sin\theta & 1-\cos\theta
\end{pmatrix}\right)
$$

Note that the density matrix $\rho$ is a linear summation of Pauli matrices, as below,

$$
\rho = \frac{1}{2}\bigl( \textbf{I} + (\sin{\theta}\cos{\varphi})\textbf{X}+  (\sin{\theta}\sin{\varphi})\textbf{Y} +  (\cos{\theta})\textbf{Z} \bigr)
$$

Or, in general,

$$
\rho = \frac{1}{2}(\textbf{I} + r_{x}\textbf{X}+ r_{y}\textbf{Y} + r_{z}\textbf{Z})
$$

where
$r_{x}^2+r_{y}^2+r_{z}^2=1$.

And, the Bloch vector is $\textbf{r} = (r_{x}, r_{y}, r_{z})$.

Now, let's make an arbitrary quantum state using random numbers.

We can show this Bloch vector on the Bloch sphere.

## 3. Quantum state tomography

If you only measure the quantum state in the computational basis ($|0 \rangle$ and  $|1 \rangle$), the phase information (the complex number information) will be lost. But if we have many copies of $|\psi \rangle$ by repeating the preparation process (we can't clone states, but we can repeat preparation processes), we can estimate the value of $r_{x}, r_{y}, r_{z}$ by performing *quantum state tomography* for density matrix $\rho$. Given the form:

$$
\rho = \frac{1}{2}(\textbf{I} + r_{x}\textbf{X}+ r_{y}\textbf{Y} + r_{z}\textbf{Z})
$$

it holds that

$$
Tr(\textbf{X} \rho) =  r_{x}, \quad Tr(\textbf{Y} \rho) =  r_{y}, \quad Tr(\textbf{Z} \rho) =  r_{z}
$$

In $r_{z}$ case,

$$
Tr(\textbf{Z} \rho) =  \langle 0|\textbf{Z} \rho|0 \rangle +  \langle 1|\textbf{Z} \rho|1 \rangle
$$
$$
= \langle 0|(|0 \rangle\langle 0|-|1 \rangle\langle 1|) \rho|0 \rangle +\langle 1|(|0 \rangle\langle 0|-|1 \rangle\langle 1|) \rho|1 \rangle
$$
$$
=\langle 0|\rho|0 \rangle- \langle 1| \rho|1 \rangle
$$
$$
=\langle 0|\psi\rangle\langle \psi|0 \rangle -  \langle 1| \psi\rangle\langle \psi|1 \rangle
$$
$$
=|\alpha|^2-|\beta|^2
$$

The last transformation of the equation is for $|\psi \rangle  =\alpha|0\rangle+\beta|1\rangle$. Therefore, we can obtain $r_{z}$ by probability of $|0 \rangle$  - Probability of $|1 \rangle$.

### Estimate $r_z$ value

In order to estimate $r_z$, we create a quantum state and measure it. We then repeat the preparation and measurement many times. Finally we use the statistics of the measurement to estimate the probabilities above and thus estimate $r_z$.

For creating the random quantum state, we will use the general unitary gate $U$ with the parameters $ \theta, \varphi$. (Refer to [U-gate](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.library.UGate) for more information.)

Using the `AerSimulator`, we will measure it in the computational basis to estimate $r_z$.

Using the quantum state tomography method, we estimated the $r_z$ value. In this case, since we chose a parameter for the "random" state, we know the value of $r_z$ and can check our work. But by its very nature, utility-scale work is not always so trivial to check. We will discuss more about checking quantum results later in this course. For now, simply note that our estimation was reasonably accurate.

### Exercise 1: Estimate $r_x$ value
Recall that IBM&reg; quantum computers measure along the $z$-axis (sometimes stated "in the $z$ basis" or "in the computational basis"). However, by using rotations before the measurement, we can measure the quantum state's projection on the x-axis, also. To be more precise, if we rotate our system such that things that did point along $x$ now point along $z$, then we can keep the same measurement hardware along $z$, but learn about the state that was just along $x$ a moment ago. This is how most quantum computers (and all IBM quantum computers) perform measurements along multiple axes.

With this understanding, try writing code to estimate the value of $r_x$, using quantum state tomography.

__Solution__:

### Exercise 2: Estimate $r_y$ value
Using the same logical arguments as before, we can rotate the system prior to measurement to learn about the $r_y$.
Try writing code yourself to estimate the value of $r_y$ using the quantum state tomography. You could start with the previous example, but make different rotations. (For more information about the various gates used, including ```sdg```, refer [to the API reference](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.library.SdgGate).)

__Solution__:

We have now estimated all components of $\vec{r}$ and can write out the full vector.

You obtained the estimation of the original random vector fairly accurately using this quantum state tomography method.

## 4. Quantum teleportation

Let us consider the situation when a character Alice wants to send an unknown quantum state $|\psi \rangle$ to her friend Bob, who is far away. Assume they can only communicate with classical communication (like using email or a phone). Alice cannot copy the quantum state (due to the no-cloning theorem). If she repeated the same preparation process many times, she could build up statistics as we just did. But what if there is only a single unknown state? This state might have emerged from a physical process you want to study. Or it could be part of a larger quantum computation. In that case, how could Alice send the state to Bob? She can, if she and Bob share a valuable quantum resource: a shared entangled state, like the Bell state introduced in the previous lesson: $\frac {|00\rangle + |11\rangle}{\sqrt 2}$. You might sometimes also see this referred to as an "EPR pair" or an "e-bit" (a fundamental unit of entanglement). If Alice shares such an entangled state with Bob, she can *teleport* the unknown quantum state to Bob by performing a series of quantum operations and sending him two bits of classical information.

### 4.1 The protocol of Quantum teleportation
**Assumption**: Alice has an unknown quantum state $|\psi \rangle$ to be sent to Bob. Alice and Bob shares a 2-qubit entangled state, or e-bit, each having one of the qubits physically at their location.

Here we outline the procedure without explanation. These will be implemented in detail below.
1. Alice entangles $|\psi \rangle$  with her part of the e-bit using the CNOT gate.
2. Alice applies a Hadamard gate to $|\psi \rangle$, and measures both her qubits in the computational basis.
3. Alice sends Bob her measurement results (either “00”, “01”, “10”, or “11”)
4. Bob performs a *correction* operator based on Alice’s two-bit of information on his part of the e-bit pair.
    - If “00”, Bob does nothing
    - If “01”, Bob applies X gate
    - If “10”, Bob applies Z gate
    - If “11”, Bob applies iY = ZX gate
5. Bob's part of the e-bit becomes $|\psi \rangle$.

This is also worked out in more detail in [Basics of Quantum Information](https://quantum.cloud.ibm.com/learning/courses/basics-of-quantum-information/entanglement-in-action/introduction). But the situation will become more clear as we instantiate this in Qiskit.

### 4.2 Quantum circuit simulating the quantum teleportation

As always, we will apply the Qiskit patterns framework. This subsection will focus on mapping only.

### Step 1: Map problem to quantum circuits and operators

To describe the scenario above, we need a circuit with three qubits: two for the entangled pair shared by Alice and Bob, and one for the unknown quantum state $|\psi\rangle$.

At the start, Alice has an unknown quantum state $|\psi \rangle$. We will create this using the $U$ gate.

We can visualize the state we've created, but only because we know what parameters were used in the $U$ gate. If this state had emerged from a complicated quantum process, the state would not be knowable without running the process to create the state many times, and collecting statistics as in tomography.

Before this protocol even begins, we assume Alice and Bob have a shared entangled pair. If Alice and Bob are truly in different locations, they might have set up the shared state *before* the unknown state $|\psi\rangle$ was ever created. Because those things are happening on different qubits, there order here won't matter, and this order is convenient for visualization.

Next, Alice entangles $|\psi \rangle$ with her part of the shared e-bit, using the $CX$ gate and $H$ gate, and measures them in the computational basis.

Alice sends Bob her measurement results (either “00”, “01”, “10”, or “11”), and Bob performs a correction operator based on Alice’s two bits of information on his part of the shared e-bit. Then, Bob's becomes $|\psi \rangle$.

You have completed a quantum teleportation circuit! Let's see the output state of this circuit using the statevector simulator.

You can see that the quantum state created by the $U$-gate of qubit 0 (the qubit originally holding the secret state) has been transferred to qubit 2 (Bob's qubit).

You can run above cell a few times to make sure. You might notice that the qubits 0 and 1 change states, but qubit 2 is always in the state $|\psi\rangle $.

### 4.3 Execute it and confirm the result by applying U inverse

Above, we checked visually that the teleported state looked correct. Another way to check if the quantum state has been teleported correctly, is to apply the inverse of the $U$ gate on Bob's qubit so that we can measure '0'. That is, since $U^{-1}U$ is the identity, if Bob's qubit is in the state created from $U|0\rangle$, then applying the inverse should yield $U^{-1}U|0\rangle=|0\rangle$.

We will execute the circuit first using the AerSimulator, before moving on to a real quantum comptuer.

Recall that in little endian notation, qubit 2 is the left-most (or bottom-most, in the column labels) qubit. Note that the left- and bottom-most qubit in the column labels is a 0 for all possible outcomes. This shows we have a 100% chance of measuring $q_2$ in the state $|0\rangle $. This is the expected result, and indicates the teleportation protocol has worked properly.

### 4.4 Teleportation on a real quantum computer

Next, we will perform teleportation on a real quantum computer. Using the dynamic circuit function, we can operate mid-circuit using measurement outcomes, implementing in real-time the conditionals operations in the teleportation circuit. For solving problems with real quantum computers, we will follow the four steps of Qiskit patterns.

    1. Map problem to quantum circuits and operators
    2. Optimize for target hardware
    3. Execute on target hardware
    4. Post-process the results

### Exercise 3: Build the teleportation circuit

Try building the whole teleportation circuit from scratch to test your understanding. Scroll back up if you need a reminder.

__Solution__:

As a reminder, applying the inverse of the $U$ gate is just so we can verify the expected behavior. It isn't part of sending the state to Bob, and we would not use that inverse $U$ gate if the only goal was to transfer quantum information.

### Step 2: Optimize for target hardware

To run on hardware, import `QiskitRuntimeService` and load your saved credentials. Select the backend with the fewest number of jobs in the queue.

Let's see the coupling map of the device that you selected.

Different devices might have different coupling maps, and each device has some qubits and couplers that are more performant than others. Finally, different quantum computers might have different *native gates* (gates the hardware can execute). Transpiling the circuit rewrites the abstract quantum circuit using gates the target quantum computer can execute, and selects the optimal mapping to physical qubits (among other things). Transpilation is a rich and complicated topic. For more on transpilation, see the [API reference](https://quantum.cloud.ibm.com/docs/api/qiskit/transpiler#overview).

### Step 3: Execute the circuit.

Using the `Sampler` Runtime primitive, we will execute the target circuit.

You can also check the job status from your [IBM Quantum&reg; dashboard](https://quantum.cloud.ibm.com/workloads).

If you see `'DONE'` is displayed, you can get the result by executing below cell.

### Step 4: Post-process the results

You can interpret the results above directly. Or, using `marginal_count`, you can trace out Bob's results on qubit 2.

As we see here, there are a few results in which we measured $|1 \rangle$. These are due to noise and errors. In particular, dynamic circuits tend to have a higher error rate because of the time-consuming measurement in the middle of the circuit.

### 4.5 Key takeaways on quantum teleportation

We can transport a quantum state to a distant friend by sharing a pair of entangled qubits (an e-bit).

1. Can quantum teleportation send the quantum state faster than light?
	No, because Alice has to tell Bob the measurement results in a classical way.

2. Would quantum teleportation break the "no cloning theorem", which forbids copying of a quantum state?
	No, because the original quantum state given to Alice on one of her qubits was lost in measurement. It collapsed to a $|0\rangle$ or $|1\rangle$.

## 5. Superdense coding

Almost the same setup can be used for a different purpose. Suppose Alice wants to send Bob two bits of classical information, but she has no means of classical communication with Bob. She does, however, share an entangled pair with Bob and she is allowed to send her qubit to Bob's location. Notice the contrast with the quantum teleportation protocol. In teleportation, classical communication _was_ available to the friends, and the goal was to send a quantum state. Here, classical communication is not accessible and they use the transfer of a qubit to share two bits of classical information.

### 5.1 The protocol of superdense coding

**Assumption**: Alice has two bits of information, say, $a_1a_2 \in \{00, 01, 10, 11\}$. Alice and Bob share an entangled pair (e-bit), but they cannot communicate classically.

1. Alice performs one of the following operations on her part of e-bit.
    - If $a_1a_2 = 00$, she does nothing
    - If $a_1a_2 = 01$, she applies Z gate
    - If $a_1a_2 = 10$, she applies X gate
    - If $a_1a_2 = 11$, she applies Z gate and X gate.
2. Alice sends her part of the e-bit to Bob's location.
3. Bob applies a CNOT gate with the qubit from Alice as control and his qubit as target, then applies H gate to the qubit from Alice, and measures the two qubits. The possible starting states and results of Bob's operations are:
$$
\frac {|00\rangle + |11\rangle}{\sqrt 2} \rightarrow CX_{01}\otimes H_0 \rightarrow |00\rangle
$$
$$
\frac {|00\rangle - |11\rangle}{\sqrt 2} \rightarrow CX_{01}\otimes H_0 \rightarrow |01\rangle
$$
$$
\frac {|10\rangle + |01\rangle}{\sqrt 2} \rightarrow CX_{01}\otimes H_0 \rightarrow |10\rangle
$$
$$
\frac {|10\rangle - |01\rangle}{\sqrt 2} \rightarrow CX_{01}\otimes H_0 \rightarrow -|11\rangle
$$

Note that a negative sign of $-|11\rangle$ is global phase, so it is not measurable.

### 5.2 Quantum circuit simulating the superdense coding

Based on the protocol of superdense coding, you can build the superdense coding circuit as below. Try to change the message, `msg`, which Alice wants to transform to Bob.

Qiskit pattern steps are identified in the code comments.

You can see that Bob received the message that Alice wanted to send to him.

Next, let's try it with a real quantum computer.

The result is what we expected. Note that superdense coding on a real quantum computer showed fewer errors than in the case of quantum teleportation on a real quantum computer. One reason for this might be that quantum teleportation uses dynamic circuits, and superdense coding does not. We will learn more about errors in quantum circuits in later lessons.

## 6. Summary

In this session, we have implemented two quantum protocols. Although the scenarios for both involving distant friends are somewhat removed from quantum computing on a single QPU, they have applications in quantum computing, and help us understand the transfer of quantum information better.

- **Quantum teleportation**: Although we cannot copy quantum states, we can teleport unknown quantum states by having shared entanglement.
- **Quantum superdense coding**: A shared entangled pair, and transfer of one qubit, enable the communication of two bits of classical information.
