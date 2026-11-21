# Error suppression and tailoring

> Fuente: <https://quantum.cloud.ibm.com/learning/en/courses/tools-for-quantum-advantage/error-suppression>

> Solo las celdas de texto del notebook original; sin código.


Error suppression can refer to any technique that anticipates and tries to avoid certain types of noise and errors. This is easiest to explain through concrete examples, but keep in mind that these methods are not limited to the examples shown here, and new methods are continually being explored. Sometimes it is not possible to suppress errors, but it is possible to affect how they accumulate. If we can make errors accumulate more slowly, we might describe this as suppressing the overall error, but it is more accurately viewed as noise tailoring. In this lesson we cover canonical examples of error suppression (dynamical decoupling) and of noise tailoring/shaping (Pauli twirling).

This video gives an overview of error suppression, including some valuable animations for picturing how they work. The text below adds more detail and explores some types of error suppression using Qiskit.

## Dynamical decoupling

Let us begin with a very simple state on a single qubit, and introduce a simple noise model. This is insufficient to completely explain dynamical decoupling, but it gives us a clear example. Suppose we have a qubit prepared in a superposition state using a Hadamard gate:

$$
|\psi\rangle = H|0\rangle = \frac{1}{\sqrt{2}}\left( |0\rangle +|1\rangle \right).
$$

This state is visualized on the Bloch sphere as shown below on the left. In the ideal case with zero noise, this qubit would remain in this state until the next operation is carried out. However, we know from the previous lesson that this is not what we observe. Noise causes the quantum information to degrade.

Noise or environmental coupling can cause the relative phase between the basis states to change. That is, the probabilities of $|0\rangle$ and $|1\rangle$ do not change, as the absolute values of their coefficients do not change. Rather, the phases of the amplitudes change, altering their real and imaginary components. To make this discussion more concrete, let us consider one type of interaction that can cause this: coupling to a magnetic field oriented in the Z direction: $\vec{B} = (0,0,B_0)$.

Consider what happens to the state $|+\rangle$ as time passes:

$$
|\psi(t)\rangle = e^{-iHt/\hbar}|\psi(0)\rangle \rightarrow e^{-iZ\omega_B t/2}|\psi(0)\rangle
$$

Here we have used the fact that a magnetic field in the Z direction causes precession about the Z axis with a frequency $\omega_B$ that depends on the effective magnetic moment and magnetic field strength. The details are less important than the fact that this interaction causes evolution about the Z axis, resulting in opposite phase accumulation for the two computational basis states. Applying this operator to each term in $|\psi\rangle$, we find the following:

$$
|\psi(t)\rangle = e^{-iZ\omega_B t/2}\frac{1}{\sqrt{2}}\left( |0\rangle +|1\rangle \right)
=\frac{1}{\sqrt{2}}\left( e^{-i\omega_B t/2}|0\rangle +e^{i\omega_B t/2}|1\rangle \right)
$$

This time-dependent phase corresponds to precession about the Z axis in the Bloch sphere picture. This is shown in the right half of the figure above.

If we knew that this interaction were occurring in a controlled way, we could predict it. To model this type of noise, we instead consider a distribution of possible magnetic field strengths, each occurring with some classical probability (other sources of noise would need to be modeled differently). We need to consider what happens when there is a non-zero classical probability that the state has not rotated at all, and also some probability that it has rotated by a small amount, or even by a large amount. This distribution of possible rotations is the reason for the spreading of the state in the Bloch sphere picture below. If there is more such dephasing noise, the phase will be less well-defined. In the limit of strong dephasing, the qubit becomes completely dephased, corresponding to the loss of the quantum coherence stored in the state.

Of course, in an experiment we have no idea what random coupling will occur. What can we do about this?

Suppose that the environmental coupling remains approximately constant over a time interval $2t_0$. Consider what would happen if we followed this prescription:

* Allow the phase to change for time $t_0$
* Apply an X gate to the qubit
* Allow the same environmental coupling to occur for a further time $t_0$
* Apply a second X gate

After the initial time evolution, we would have exactly the state above. Applying the first X gate we have:

$$
X|\psi(t_0)\rangle = \frac{1}{\sqrt{2}}\left( e^{-i\omega_B t_0/2}|1\rangle +e^{i\omega_B t_0/2}|0\rangle \right)
$$

Now when the second interval of $t_0$ passes, the same interaction takes place. But now the amplitudes are associated with the opposite Z eigenstates, meaning the sign of the rotation about the Z axis has switched. After allowing the system to evolve in time for another $t_0$ we have the state:

$$
e^{-iZ\omega_B (t-t_0)/2}\frac{1}{\sqrt{2}}\left( e^{-i\omega_B t_0/2}|1\rangle +e^{i\omega_B t_0/2}|0\rangle \right)
=\frac{1}{\sqrt{2}}\left( e^{-i\omega_B (t-t_0)/2}e^{i\omega_B t_0/2}|1\rangle +e^{i\omega_B (t-t_0)/2}e^{-i\omega_B t_0/2}|0\rangle \right)
$$
And inserting $t = 2t_0$ we have:
$$
|\psi(2t_0)\rangle=\frac{1}{\sqrt{2}}\left(|1\rangle +|0\rangle \right)
$$

Applying the final X gate does nothing in this case, but it is generally necessary:

$$
|\psi(2t_0)\rangle = \frac{1}{\sqrt{2}}\left(|0\rangle +|1\rangle \right) = |\psi(t=0)\rangle
$$

We have recovered the original quantum state, including its relative phase. This process is an especially simple example of dynamical decoupling.

More generally, __dynamical decoupling__ (DD) involves inserting some single-qubit gates to reduce the effect of interactions with systems outside the qubit (decoupling it from the environment). The complete refocusing of all possible phase histories back to the original state, as shown above, is somewhat idealized, but it is still a possible scenario. Let's discuss when DD is useful and what caveats exist.

#### Check your understanding

In the text above, we stepped through the effect of an `XX` DD sequence on the initial state $|+\rangle$. Check whether the same steps above also return the state $|+i\rangle$ back to its initial state under the same assumptions of a slowly-varying magnetic field along the z direction.

<Accordion>
<AccordionItem title="Answer">

$$
|\psi(t)\rangle = e^{-iZ\omega_B t/2}\frac{1}{\sqrt{2}}\left( |0\rangle +i|1\rangle \right)
=\frac{1}{\sqrt{2}}\left( e^{-i\omega_B t/2}|0\rangle +i e^{i\omega_B t/2}|1\rangle \right)
$$

After the initial time evolution, we would have exactly the state above. Applying the first X gate we have:

$$
X|\psi(t_0)\rangle = \frac{1}{\sqrt{2}}\left( e^{-i\omega_B t_0/2}|1\rangle +i e^{i\omega_B t_0/2}|0\rangle \right)
$$

Now when the second interval of $t_0$ passes, the same interaction takes place. But now the amplitudes are associated with the opposite Z eigenstates, meaning the sign of the rotation about the Z axis has switched. After allowing the system to evolve in time for another $t_0$ we have the state:

$$
e^{-iZ\omega_B (t-t_0)/2}\frac{1}{\sqrt{2}}\left( e^{-i\omega_B t_0/2}|1\rangle +i e^{i\omega_B t_0/2}|0\rangle \right)
=\frac{1}{\sqrt{2}}\left( e^{-i\omega_B (t-t_0)/2}e^{i\omega_B t_0/2}|1\rangle +i e^{i\omega_B (t-t_0)/2}e^{-i\omega_B t_0/2}|0\rangle \right)
$$
And inserting $t = 2t_0$ we have
$$
|\psi(2t_0)\rangle=\frac{1}{\sqrt{2}}\left(|1\rangle +i |0\rangle \right)
$$

Applying the final X gate, we have:

$$
|\psi(2t_0)\rangle = \frac{1}{\sqrt{2}}\left(|0\rangle +i |1\rangle \right) = |\psi(t=0)\rangle = |+i\rangle
$$

</AccordionItem>
</Accordion>

### When to use DD

The first and most obvious caveat is that we assumed a purely dephasing channel in our treatment. Real-world interactions typically produce a mixture of dephasing and other error mechanisms. In the treatment above, we chose to apply X gates specifically. This is referred to as an `XX` sequence in dynamical decoupling. This particular sequence is appropriate for purely dephasing errors. But there are other sequences that might be more broadly applicable, like `XY4` (shown in the circuit diagram below) and the more complex `XY8`.

Another caveat is that dynamical decoupling adds single-qubit gates, which can add single-qubit errors due to gate imperfections or even crosstalk. These single-qubit error rates are typically much lower than multi-qubit gate errors, so this is usually not a major concern, but it is something to keep in mind if many qubits are employing DD many times throughout your circuit.

DD is useful when the external coupling has time to affect the state of the qubit. Because qubits are painstakingly well isolated and external couplings should be weak, this type of noise is most noticeable when a qubit sits idle for long periods. For short idle times, the effect of DD could be to add single-qubit gate errors while suppressing very little noise; the fidelity of your circuit could actually be reduced.

__Key takeaway__: Use dynamical decoupling when qubits remain idle for sufficiently long periods, and pay attention to the type of DD sequence being used.

## Dynamical decoupling using Qiskit

Let us explore the use of DD by examining the case of several qubits prepared in the $|+\rangle$ state, which then remain idle for a long time. In the absence of errors, preparing the multi-qubit state $|\psi\rangle = |+\rangle^{\otimes N}$ and then applying a Hadamard gate before measurement (thereby measuring in the X basis) should always yield 0. With noise, the measurement outcome will be 0 only a fraction of the time rather than with 100% probability. We calculate the average `X` expectation value across multiple qubits. That is, we are interested in the following:

$$
f\equiv \frac{1}{N}\sum_{j=0}^{N-1}{\langle\Psi | X_j |\Psi\rangle}
$$

where $X_j \equiv III..X...II$ with the `X` operator in the $j^{th}$ position from the right and $|\Psi\rangle$ is the state of the entire system.

This circuit contains intentional delays, which is somewhat contrived for a benchmark. However, it is very common for real circuits to contain qubits that sit idle during part of the execution. You can think of this as a simplified model of a more complex circuit in which some qubits remain idle for part of the computation. This type of benchmarking based on the evolution of $|+\rangle$ states is often referred to as _Ramsey benchmarking_.

We begin by loading the necessary packages and configuring the service.

Now we define some helper functions. First, we want to address the point about long idle times. What exactly does "long" mean in this context? We could simply report the idle time in microseconds. However, it is useful to know how many two-qubit gates could be executed during that same interval. This makes the idle times more directly indicative of the circuit depth that could have been executed during the same period. The first helper function gets the two-qubit gate native to the backend and determines the duration of that gate.

The second function simply creates a Ramsey circuit (one with qubits in the $|+\rangle$ state), implements a delay, rotates using an H gate, and then measures. Recall that a Hadamard gate (H) maps $|+\rangle$ to $|0\rangle$, so measuring $|0\rangle$ in the `Z` basis after the Hadamard corresponds to the qubit having been in $|+\rangle$ immediately before the Hadamard.

Our final function converts the raw counts of 0 and 1 measurement outcomes into an expectation value of `X`.

Now we specify the details of our test, including the number of qubits and the gate sequence to be used in DD (in this case `XX`). Note especially that we set the optimization level to zero. In practice, you would often select a higher optimization level; here we use level 0 to ensure that the effects of the errors targeted by DD remain visible. Finally, we determine the characteristic time for two-qubit gates on this backend and print some relevant times.

We now construct our circuits and transpile them for our chosen backend.

We should visualize at least one circuit to ensure we have coded our circuit with the desired states and delays. It might be easier to visualize the pre-transpiled circuit `qc`, or you might check the transpiled one `qc_isa`.

#### Execute

We're finally ready to execute on hardware. We use Sampler to obtain many measurements of each qubit, and we will use it twice: once with DD explicitly turned off, and once with DD turned on and using the `XX` gate sequence.

We can extract the counts from the various circuits.

#### Post-processing

We now have the counts from the measurement, but we want to turn that into the expectation value of `X` and then average those expectation values across all the qubits we used, to learn about the preservation of phase information. For that we use our `counts_to_x_expectations` function defined earlier.

Finally, let's plot our results.

As you can see, with no explicit delay the expectation values are indeed near 1, which we would expect if all phase information were preserved. If all phase information were lost, there would be no preference for the final rotation to produce $|0\rangle$ rather than $|1\rangle$, and the average expectation value would approach zero. In the data, we see that as delay times increase, the average expectation value of `X` decreases, starting to approach zero. Note that DD has been very effective here; the expectation values with DD are typically more than 20% better (closer to 1) than the values without DD. But also note that the first delayed data point corresponds to a delay roughly equivalent to 100 two-qubit gate operations. This reinforces the point that DD is most useful when qubits remain idle for relatively long periods.

#### Check your understanding

If we apply DD using `XY4` to the same circuit as before, do you expect it to yield results that are much better, much worse, or about the same, as DD using `XX`? Explain.

<Accordion>
<AccordionItem title="Answer">

About the same, perhaps slightly worse. The circuit we used had states rotated into the XY plane. This state stores information primarily in its phase, making it especially sensitive to dephasing errors rather than T1 relaxation. XY4 might help with a wider variety of errors, but XX is already optimized to help the circuit we are using. XY4 might be just as good, but would not add anything substantial, or the fact that XY4 contains more gates might allow additional gate errors to make the results slightly worse.

</AccordionItem>
</Accordion>

The last result used the simplest DD gate sequence `XX`. Let's see how to implement a more complex sequence, `XY4`. We define a Sampler in the next section.

Here we see that `XY4` is not appreciably different from `XX`. It might be very slightly worse due to additional gates in the `XY4` sequence, but more importantly, we already explained why `XX` would have the desired effect in preserving phase specifically for a state like $|+\rangle$. There is no reason to think that for such an initial state, a different sequence would improve results.

#### Check your understanding

Verify that the `XY4` sequence leaves the state unchanged up to a global phase.

<Accordion>
<AccordionItem title="Answer">

$$
\begin{aligned}
YXYX|+\rangle & = YXYX(|0\rangle+|1\rangle)\\
& = YXY(|0\rangle+|1\rangle)\\
& = YX(i|1\rangle-i|0\rangle)\\
& = Y(i|0\rangle-i|1\rangle)\\
& = (-|0\rangle-|1\rangle)\\
& =-|+\rangle
\end{aligned}
$$

</AccordionItem>
</Accordion>

## Pauli twirling

We should begin by noting that Pauli twirling is often used not as an error-suppression technique, but as an error-shaping technique: it makes noise/errors behave differently, sometimes more predictably, to enable other methods. Although Pauli twirling does not *prevent* errors, it might prevent their coherent accumulation.

In a quantum circuit, multiple different sources of error add together. The errors can add in different ways, notably _coherently_ and _incoherently_. Coherent accumulation of errors means that noise or imperfect implementations all tend to drive errors in the same direction across multiple layers and gates. An example would be coherent over-rotation when applying a rotation gate.

Consider an ideal rotation gate, such as $R_x(\theta_0)$, which rotates about the X axis by exactly $\theta_0$. Of course, gate implementation is not perfect, and the actual rotation might be $\theta_0+\Delta\theta$ for one implementation, and it could even be the case that $\Delta\theta$ is always the same sign, and possibly similar in magnitude across many applications of $R_x(\theta)$. Thus repeated application of rotation gates can result in coherent accumulation of these many over-rotations (or under-rotations), $\Delta \theta$.

Incoherent error accumulation is just the opposite: errors in random directions with random signs, such that errors in different layers do not always interfere additively, but sometimes cancel or add in quadrature. Clearly incoherent errors accumulate more slowly in terms of the overall effect on the state of the qubit. A toy diagram of this is shown in the figure below. This is a simplification. Real quantum errors are not restricted to a two-dimensional Cartesian space; not all error contributions will have the same magnitude, and there are more complexities. But the intuition of a picture like this is useful: coherent errors tend to accumulate faster than incoherent ones.

One can often obtain higher-fidelity results by turning coherent error accumulation into incoherent error accumulation. A primary way of accomplishing this is called __Pauli twirling__.

Pauli twirling refers to adding combinations of Pauli gates $P \in \{X, Y, Z, I\}$ before and after a desired gate operation $U$ in such a way that $P_1 U P_2 = U$. Here, $P_1$ and $P_2$ are not single Paulis, but collections of Pauli operators often acting on multiple qubits. You might sometimes see it stated that the action of the extra Pauli gates is "equivalent to the identity". But this is imprecise and potentially confusing. The Pauli gates are separated by $U$ and the goal is to leave the logical action of all gates equal to $U$. Sometimes $U$ is called the "payload" to distinguish this intended operation from the gates added for suppression. Some examples of Pauli twirling around a CNOT gate are shown below.

Let's walk through just one example to verify that twirling leaves the logical effect of the payload unchanged.

Without loss of generality, let the two-qubit states involving $q_0$ and $q_1$ be:

$$
|\psi_\text{init}\rangle = a|00\rangle + b|01\rangle + c|10\rangle + d|11\rangle
$$

As always, we are using the qubit ordering convention $|q_1,q_0\rangle$. Applying a CX gate with $q_1$ as the target yields

$$
CX|\psi_\text{init}\rangle = |\psi_\text{final}\rangle = a|00\rangle + b|11\rangle + c|10\rangle + d|01\rangle
$$

Now let us consider the third circuit shown, using X gates for Pauli twirling. We could simply multiply the matrices together and verify that they yield a CNOT matrix. Alternatively, we can track the operation on an arbitrary quantum state through the circuit, as we do below. The states at different points in the circuit have been labeled a-d.

$$
|\psi_a\rangle = a|00\rangle + b|01\rangle + c|10\rangle + d|11\rangle\\
|\psi_b\rangle = a|01\rangle + b|00\rangle + c|11\rangle + d|10\rangle\\
|\psi_c\rangle = a|11\rangle + b|00\rangle + c|01\rangle + d|10\rangle\\
|\psi_d\rangle = a|00\rangle + b|11\rangle + c|10\rangle + d|01\rangle
$$

This is exactly $|\psi_\text{final}\rangle$ that we obtained before with no twirling. Indeed, this twirled gate sequence leaves the logical action of the payload unchanged. However, if different valid twirling sequences are selected randomly from layer to layer, coherent error accumulation can be converted into effectively stochastic (incoherent) error accumulation. To be clear, one does not choose a single twirling pattern and use it throughout the circuit. Instead, different valid twirling sequences are selected for different layers. An example with many entangling layers might look like this.

#### Check your understanding

Verify that the Pauli twirling in the fourth panel in the figure above also leaves the logical effect of the CNOT unchanged.

<Accordion>
<AccordionItem title="Answer">

We follow the example above and show that the action on any arbitrary two-qubit state is equivalent to a CNOT operation. We will refer to the labeled points in this diagram.

$$
\begin{aligned}
|\psi_a\rangle & = a|00\rangle + b|01\rangle + c|10\rangle + d|11\rangle\\
|\psi_b\rangle & = ai|11\rangle + bi|10\rangle - ci|01\rangle - di|00\rangle\\
|\psi_c\rangle & = ai|01\rangle + bi|10\rangle - ci|11\rangle - di|00\rangle\\
|\psi_d\rangle & = ai(+1)(-i)|00\rangle + bi(-1)(i)|11\rangle - ci(-1)(-i)|10\rangle - di(+1)(i)|01\rangle\\
|\psi_d\rangle & = a|00\rangle + b|11\rangle + c|10\rangle + d|01\rangle
\end{aligned}
$$

This is equivalent to the action of a CNOT with qubit 0 as the control and qubit 1 as the target.

</AccordionItem>
</Accordion>

Can you come up with a Pauli twirling sequence for the CNOT gate which is not shown above?

<Accordion>
<AccordionItem title="Answer">

Yes, there are many others. One example is $Z_t$ before the CNOT, and a $Z_t$ and $Z_c$ after the CNOT.

</AccordionItem>
</Accordion>

### When to use Pauli twirling

As presented here, Pauli twirling is applied only to multi-qubit gates. Applying a similar protocol to single-qubit gates would require different logic and is generally not useful in practice. Pauli twirling itself uses several single-qubit gates (the Pauli gates). The additional Pauli gates would likely introduce more error than would be gained by randomizing any coherent error accumulation. Error rates associated with two-qubit gates are much larger than those associated with single-qubit gates. Further, some single-qubit gates are non-Clifford, which cannot be fully twirled. This is why Qiskit includes Pauli twirling options that automatically twirl around two-qubit gates, and not around single-qubit gates.

This was implicit in the figure above: Pauli twirling was implemented around the CX gates, but not around the Hadamard gate.

Let's see two examples of Pauli twirling in action.

### Pauli twirling to suppress coherent accumulation

To observe how Pauli twirling can turn coherent error accumulation into slower incoherent accumulation, we want a circuit and observable that function as a coherent-error stress test. The sole purpose is to make coherently accumulating two‑qubit errors visible, and then show how Pauli twirling converts that coherent buildup into stochastic decay.

CNOT (or CZ) gates are a common source of coherent errors. The simplest experiment we can do in this case is to initialize a state (say $|+\rangle$), apply layers of paired CNOT gates (using the fact that two CNOTs yield an identity), and check how errors accumulate as the number of layers increases, both with and without Pauli twirling.

The observable of interest is $\langle X \rangle$ on a single qubit, which we plot as a function of the number of repetitions of CNOT pairs.

Because we have rotated our basis before measurements, a measurement of $|0\rangle$ corresponds to the state having been in $|+\rangle$ just before the final Hadamard gate, and similar for $|1\rangle$ and $|-\rangle$. Therefore, our expectation value $\langle X \rangle$ can be simply calculated from the counts of $|0\rangle$ minus the counts of $|1\rangle$.

We select a reasonable number of CNOT layers over which to allow the error to accumulate, build our circuits, then transpile them.

Keep in mind that each layer consists of more than one two-qubit gate. Monitor the transpiled, two-qubit depth by using the function below.

Now we run the jobs.

Finally, we visualize these results.

We can clearly see that the twirled circuit yields an expectation value closer to the ideal $\langle X \rangle = 1$. This example served its purpose, but let's move onto something more useful: twirling in the production of highly entangled states.

## Pauli twirling in GHZ state preparation

The previous example showed a compelling case for Pauli twirling in destroying the coherent accumulation of errors associated with CNOT gates. GHZ state production uses many CNOT gates to produce highly entangled states useful for many quantum computing applications. Let's explore how Pauli twirling helps in this context, with GHZ states of increasing size.

Now we build our circuits and transpile them. In this case, we don't have any artificially repeated gates that reduce to the identity. So we can allow the pass manager to do a bit more optimizing for us. We'll set it to level three.

We can see that the optimizer mapped our abstract circuit to qubits 123, 124, 136, 142, and 143.

To understand why, let's look at a map of the layout of our backend (in this image, `ibm_fez`, but you can do equivalent analyses on any backend).

We see that the qubits were selected in a chain to minimize swap gates and thus circuit depth. Further, each CZ gate implemented in the circuit is between adjacent qubits. Finally, all five qubits have relatively low error rates, including readout-assignment error rates. You can check these error rates on any backend on the [Compute resources](https://quantum.cloud.ibm.com/computers) page. Finding such a layout is not difficult for a simple linear chain, but as problems become more complex, the optimization of the circuit layout becomes more difficult and more valuable.

Now we configure our Sampler primitive. We turn off other suppression/mitigation tools to focus on Pauli twirling.

Finally, we run our jobs. You can optionally print the job ID numbers for later retrieval.

We extract the counts of each computational basis state measured for all the circuits, both with and without twirling.

We know the ideal distribution of a GHZ state is that in which half the shots return $|0\rangle^{\otimes N}$ and the other half return $|1\rangle^{\otimes N}$. Build this for comparison.

We now use the Hellinger fidelity as a measure of the quality of our final state.

Finally we plot our results.

The results using Pauli twirling are no better (and even slightly worse) than without twirling. What happened?

Two things happened. First, Pauli twirling does not reduce the total amount of noise &mdash; rather, it reshapes coherent, systematic errors into stochastic Pauli‑type errors, so that error growth becomes predictable and modelable. There was never any promise of error reduction, except in special cases.

Secondly, in GHZ circuits, some coherent errors can partially cancel or act like benign phase shifts because of the symmetry of the GHZ construction; twirling removes this accidental protection and replaces it with uncorrelated stochastic Pauli noise, so GHZ fidelity becomes slightly worse under twirling.

This second claim requires some explanation. The claim is not that GHZ circuits are protected from __all__ kinds of coherent error accumulation, only some kinds &mdash; and that in those cases the protection is destroyed by twirling. Specifically, let's consider coherent over-rotation associated with the CX gates. Let us call the real CX gate with over-rotation $\tilde{CX}$:

$$
\tilde{CX}\equiv e^{-i\epsilon K} \cdot CX
$$

where $K$ is any product of Pauli operators, like $X$, $Z$, $Z \otimes X$, $Z^{\otimes N}$, etc. For general states, any of these over-rotations could affect measurement statistics (and thus measures of state fidelity). A subset of these, however, leaves many standard GHZ observables unchanged, including operators such as $Z_i Z_j$ and $Z^{\otimes N}$. In the context of preparing a GHZ state, the relevant over-rotation errors of this type would be:

$$
\tilde{CX}\equiv e^{-i\epsilon Z_c Z_t} \cdot CX
$$

The preparation of the entire $N$-qubit GHZ state would look like:

$$
|\psi_\text{GHZ}\rangle=\prod_{j=0}^{N-2}{e^{-i\epsilon Z_j Z_{j+1}} \cdot CX_{j,j+1}}H^{\otimes N}|0^{\otimes N}\rangle
$$

After preparing the GHZ state, the state is ideally:

$$
|\text{GHZ}^{\otimes N}\rangle=\frac{1}{\sqrt{2}}\left(|0\dots 0\rangle + |1\dots 1\rangle\right).
$$

This state is a simultaneous eigenstate of a large set of Pauli operators, including the following:

$$
Z_i Z_j \quad \text{for all } i \neq j,
$$

with eigenvalue $+1$. As a result, an operator of the form $e^{-i\epsilon Z_i Z_j}$ acts on the GHZ state as multiplication by the phase factor $e^{-i\epsilon}$, which does not affect standard GHZ observables such as parity, collective $X^{\otimes N}$, or computational‑basis populations.
Thus, although the over‑rotation errors $e^{-i\epsilon Z_j Z_{j+1}}$ are coherent and systematic, they are effectively invisible to the measurements used to assess GHZ fidelity. In this sense, the GHZ circuit enjoys an accidental coherence protection: certain coherent CX errors commute with the structure of the state being prepared and therefore do not degrade measured performance.

Pauli twirling fundamentally changes this situation. Twirling does not preserve the coherent over‑rotation error as a deterministic $Z_jZ_{j+1}$ process. Instead, it converts the coherent error channel into an effective stochastic Pauli channel. As a result, the error channel now includes terms such as $X$, $Y$, $X \otimes Z$, and $Y \otimes X$, which do not commute with the GHZ stabilizers.

When these stochastic Pauli errors occur, they create real bit‑flip and phase‑flip faults on individual qubits or pairs of qubits. These errors take the state out of the GHZ stabilizer subspace, reduce interference between $|0\dots 0\rangle$ and $|1\dots 1\rangle$, and directly lower GHZ fidelity and multi‑qubit parity signals. In other words, Pauli twirling removes the coherent structure of the error but also removes the symmetry‑based cancellation that previously made those errors benign. The result is a slightly worse GHZ state &mdash; not because twirling adds noise, but because it converts a mostly harmless coherent error into genuinely damaging stochastic errors.

This example highlights an important lesson: Pauli twirling is not a universal improvement strategy. It is most beneficial when coherent errors accumulate across a circuit in a manner destructive to the required fidelity. In highly symmetric circuits like GHZ state preparation, some coherent errors are naturally aligned with the state’s stabilizers, and deliberately randomizing them can eliminate this accidental protection.

#### Combine methods

One can in principle combine Pauli twirling with dynamical decoupling. We have not used DD in this case for two reasons: firstly there should not be any extremely long idle periods in this circuit. Secondly, GHZ states do not store most of their information in single-qubit phase coherence, particularly if we are observing the fidelity only in terms of bitstring counts, and not in terms of the phase between the desired bitstrings $|0\rangle^{\otimes N}$ and $|1\rangle^{\otimes N}$.

If we were to extend the GHZ preparation to 100+ qubits, then the delays in measuring the first/early qubits might indeed be long enough that DD could be useful. This is especially true when we take into account the transpiled depth of the circuit.

## Pauli twirling in RTZ echo structure

Our final example of Pauli twirling in the context of reducing coherent error accumulation uses a circuit with layers of X-CZ-X-CZ combinations. This is a well-known gate sequence that is often used to cancel coherent ZZ error terms in two-qubit gates, even without twirling. But with twirling, we can reduce or randomize other forms of coherent error accumulation.

We'll start by defining a function to build the RTZ-like circuits with a varying number of layers.

Now we build circuits with increasing layers, up to some reasonable total transpiled two-qubit depth.

At the high end, some of these are quite deep. Let's use the AerSimulator with no noise model to obtain the ideal states at the end of each of these circuits. We can then can benchmark our results from real quantum computers using the Hellinger fidelity.

Now we define a Sampler with twirling, and one without twirling.

Now we run our jobs.

We get the counts from each of the runs on a real quantum computer.

Now we find the Hellinger fidelity by comparing each of these runs to the noise-free AerSimulator results.

Now we visualize our results.

Throughout this lesson, we have examined cases in which Pauli twirling is used to limit coherent error accumulation, a context in which it might be described as *error suppression*. However, Pauli twirling is often more useful as a tool for reshaping error behavior, converting coherent errors into a form that is more predictable and easier to model. The usefulness of this will become more apparent in the context of error-mitigation techniques such as zero-noise extrapolation (ZNE), which rely on reasonably predictable noise scaling. This is discussed in the next lesson.
