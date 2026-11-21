# Examples and applications

> Fuente: <https://quantum.cloud.ibm.com/learning/en/courses/variational-algorithm-design/examples-and-applications>

> Solo las celdas de texto del notebook original; sin código.


During this lesson, we'll explore some variational algorithm examples and how to apply them:

- How to write a custom variational algorithm
- How to apply a variational algorithm to find minimum eigenvalues
- How to utilize variational algorithms to solve application use cases

Note that the Qiskit patterns framework can be applied to all the problems we introduce here. However, to avoid repetition, we will only explicitly call out the framework steps in one example case, run on real hardware.

## Problem definitions

Imagine that we want to use a variational algorithm to find the eigenvalue of the following observable:

$$
\hat{O}_1 = 2 II - 2 XX + 3 YY - 3 ZZ,
$$

This observable has the following eigenvalues:

$$
\left\{
\begin{array}{c}
\lambda_0 = -6 \\
\lambda_1 = 4 \\
\lambda_2 = 4 \\
\lambda_3 = 6
\end{array}
\right\}
$$

And eigenstates:

$$
\left\{
\begin{array}{c}
|\phi_0\rangle = \frac{1}{\sqrt{2}}(|00\rangle + |11\rangle)\\
|\phi_1\rangle = \frac{1}{\sqrt{2}}(|00\rangle - |11\rangle)\\
|\phi_2\rangle = \frac{1}{\sqrt{2}}(|01\rangle - |10\rangle)\\
|\phi_3\rangle = \frac{1}{\sqrt{2}}(|01\rangle + |10\rangle)
\end{array}
\right\}
$$

## Custom VQE

We'll first explore how to construct a VQE instance manually to find the lowest eigenvalue for $\hat{O}_1$. This will incorporate a variety of techniques that we have covered throughout this course.

We will start debugging on local simulators.

We now set an initial set of parameters:

We can minimize this cost function to calculate optimal parameters

Because this toy problem uses only two qubits, we can check this by using NumPy's linear algebra eigensolver.

As you can see, the result is extremely close to the ideal.

## Experimenting to improve speed and accuracy

### Add reference state

In the previous example we have not used any reference operator $U_R$. Now let us think about how the ideal eigenstate $\frac{1}{\sqrt{2}}(|00\rangle + |11\rangle)$ can be obtained. Consider the following circuit.

We can quickly check that this circuit gives us the desired state.

Now that we have seen how a circuit preparing the solution state looks like, it seems reasonable to use a Hadamard gate as a reference circuit, so that the full ansatz becomes:

For this new circuit, the ideal solution could be reached with all the parameters set to $0$, so this confirms that the choice of reference circuit is reasonable.

Now let us compare the number of cost function evaluations, optimizer iterations and time taken with those of the previous attempt.

Using our optimal parameters to calculate the minimum eigenvalue:

Depending on your specific system, this may or may not result in an improvement in speed or accuracy in this very small scale example. The point is that starting with physically-motivated reference states becomes increasingly important in improving speed and accuracy as problems scale.

### Change the initial point

Now that we have seen the effect of adding the reference state, we will go into what happens when we choose different initial points $\vec{\theta_0}$. In particular we will use $\vec{\theta_0}=(0,0,0,0,6,0,0,0)$ and $\vec{\theta_0}=(6,6,6,6,6,6,6,6,6)$.

Remember that, as discussed when the reference state was introduced, the ideal solution would be found when all the parameters are $0$, so the first initial point should give fewer evaluations.

Adjusting initial point to $\vec{\theta_0}=(6,6,6,6,6,6,6,6,6)$:

By experimenting with different initial points, you might be able to achieve convergence faster and with fewer function evaluations.

### Experimenting with different optimizers

We can adjust the optimizer using SciPy `minimize`'s `method` argument, with more options [found here](https://docs.scipy.org/doc/scipy/reference/generated/scipy.optimize.minimize.html). We originally used a constrained minimizer (`COBYLA`). In this example, we'll explore using an unconstrained minimizer (`BFGS`) instead

## VQD example

Here we implement the Qiskit patterns framework, explicitly.

### Step 1: Map classical inputs to a quantum problem

Now instead of looking for only the lowest eigenvalue of our observables, we will look for all $4$, (where $k=4$).

Remember that the cost functions of VQD are:

$$
C_{l}(\vec{\theta}) :=
\langle \psi(\vec{\theta}) | \hat{H} | \psi(\vec{\theta})\rangle +
\sum_{j=0}^{l-1}\beta_j |\langle \psi(\vec{\theta})| \psi(\vec{\theta^j})\rangle  |^2
\quad \forall l\in\{1,\cdots,k\}=\{1,\cdots,4\}
$$

This is particularly important because a vector $\vec{\beta}=(\beta_0,\cdots,\beta_{k-1})$ (in this case $(\beta_0, \beta_1, \beta_2, \beta_3)$) must be passed as an argument when we define the `VQD` object.

Also, in Qiskit's implementation of VQD, instead of considering the effective observables described in the previous notebook, the fidelities $|\langle \psi(\vec{\theta})| \psi(\vec{\theta^j})\rangle  |^2$ are calculated directly via the `ComputeUncompute` algorithm, that leverages a `Sampler` primitive to sample the probability of obtaining $|0\rangle$ for the circuit
$U_A^\dagger(\vec{\theta})U_A(\vec{\theta^j})$. This works precisely because this probability is

$$
\begin{aligned}

p_0

& = |\langle 0|U_A^\dagger(\vec{\theta})U_A(\vec{\theta^j})|0\rangle|^2 \\[1mm]

& = |\big(\langle 0|U_A^\dagger(\vec{\theta})\big)\big(U_A(\vec{\theta^j})|0\rangle\big)|^2 \\[1mm]

& = |\langle \psi(\vec{\theta}) |\psi(\vec{\theta^j}) \rangle|^2 \\[1mm]

\end{aligned}
$$

Let's start by examining the following observable:

$$
\hat{O}_2 := 2 II - 3 XX + 2 YY - 4 ZZ
$$

This observable has the following eigenvalues:

$$
\left\{
\begin{array}{c}
\lambda_0 = -7 \\
\lambda_1 = 3\\
\lambda_2 = 5 \\
\lambda_3 = 7
\end{array}
\right\}
$$

And eigenstates:

$$
\left\{
\begin{array}{c}
|\phi_0\rangle = \frac{1}{\sqrt{2}}(|00\rangle + |11\rangle)\\
|\phi_1\rangle = \frac{1}{\sqrt{2}}(|00\rangle - |11\rangle)\\
|\phi_2\rangle = \frac{1}{\sqrt{2}}(|01\rangle + |10\rangle)\\
|\phi_3\rangle = \frac{1}{\sqrt{2}}(|01\rangle - |10\rangle)
\end{array}
\right\}
$$

We'll be using the following function to calculate the overlap penalty. Note that this is still part of mapping the problem to quantum circuits. However, as discussed in the previous lesson, this function calculates the overlap between a current variational circuit and the optimized circuit from a previous, lower-energy/cost state obtained. The new circuit being generated also has to be transpiled to run on real hardware. We have seen this function before, used on a simulator. Here, we must already consider the transpiling and related optimization for when we use a real backend, hence the lines around `if realbackend == 1`. This is mixing a bit of step 2, but we will call out step 2 explicitly later.

Now we add VQD's cost function. Note that compared to the previous lesson, we now have two additional arguments (`realbackend` and `backend`) to help us with transpilation when we use real backends.

Once again, we will use simulators for debugging, and then move on to real hardware.

Here we introduce the number of states we wish to calculate, the penalties, and a set of initial parameters, x0.

We will now test the algorithm using simulators:

These results are fairly close to the expected ones except for approximation error and global phase. We could adjust the tolerance on the classical optimizer and/or the penalties for statevector overlap to obtain more precise values.

### Change betas

As mentioned in the previous lesson, the values of $\vec{\beta}$ should be bigger than the difference between eigenvalues. Let us see what happens when they do not satisfy that condition with $\hat{O}_2$

$$
\hat{O}_2 = 2 II - 3 XX + 2 YY - 4 ZZ
$$

with eigenvalues

$$
\left\{
\begin{array}{c}
\lambda_0 = -7 \\
\lambda_1 = 3\\
\lambda_2 = 5 \\
\lambda_3 = 7
\end{array}
\right\}
$$

This time, the optimizer returns the same state $|\phi_0\rangle = \frac{1}{\sqrt{2}}(|00\rangle + |11\rangle)$ as a proposed solution to all eigenstates: which is clearly wrong. This happens because the betas were too small to penalize the minimum eigenstate in the successive cost functions. Therefore, it was not excluded from the effective search space in later iterations of the algorithm, and always chosen as the best possible solution.

We recommend experimenting with the values of $\vec{\beta}$, and ensuring they are bigger than the difference between eigenvalues.

### Step 2: Optimize problem for quantum execution

To run this on real hardware, we must optimize the quantum circuits for our quantum computer of choice. For our purposes here, we will simply use the least busy backend.

We will transpile our circuit using a preset pass manager and optimization level 3.

### Step 3: Execute using IBM Quantum&reg; primitives

Taking care to reset our betas to sufficiently high values, we can now run our calculation on real quantum hardware.

### Step 4: Post-process, return result in classical format

Our output is structurally similar to what has been discussed in previous lessons and examples. But there is something problematic in the results above, from which we can derive a cautionary message for the context of excited states. To limit computing time used on this learning example, we set a maximum number of iterations for classical optimizer that was potentially too low: 200 iterations. A previous calculation above, on a simulator, failed to converge in 200 iterations. Here, ours did converge... but to what tolerance? We have not specified a tolerance for COBYLA to consider itself "converged". A glance at the function value and comparison with previous runs tells us that COBYLA was not close to converging to the precision we require.

There is another issue: the energy of the first excited state appears to be lower than the energy of the ground state! See if you can explain how this could happen. Hint: it is related to the convergence point we just addressed. This behavior is explained in detail below after VQD is applied to the H2 molecule.

## Quantum chemistry: ground state and excited energy solver

Our objective is to minimize the expectation value of the observable representing energy (Hamiltonian $\hat{\mathcal{H}}$):

$$
\min_{\vec\theta} \langle\psi(\vec\theta)|\hat{\mathcal{H}}|\psi(\vec\theta)\rangle
$$

We now set an initial set of parameters:

We can minimize this cost function to calculate optimal parameters, and we can check our code first by using a local simulator.

The minimum value of the cost function (-1.857...) is the ground state energy of the H2 molecule, in units of hartrees.

### Excited States

We can also leverage VQD to solve for $k=2$ total states (the ground state and the first excited state).

We'll add our overlap calculation:

### Real hardware and a final cautionary message

To run this on real hardware, we must optimize the quantum circuits for our quantum computer of choice. For our purposes here, we will simply use the least busy backend.

We will use a preset pass manager for transpilation, and we will maximally optimize our circuit using optimization level 3.

Because VQD is highly iterative, we will carry out all steps inside a Batch, such that our jobs will only be queued at the beginning, and not between every parameter update. Nothing else changes about the syntax for the cost function or estimator.

The ground state energy obtained (-1.83 hartrees) is not too far from the correct value (-1.85 hartrees). However, the excited state energy is quite a bit off. This is similar to the erroneous behavior we saw earlier in this lesson. The energy reported for the excited state is nearly the same as that for the ground state. In the previous case, we even saw an excited state energy that was _lower_ than the reported ground state energy.

It is not possible for a variational calculation to yield an energy that is lower than the true ground state energy. In the earlier instance, the ground state energy we obtained was not very close to the true ground state. Since we did not obtain the true ground state energy in that case, there is no contradiction. In the present case, the ground state energy was fairly close to the correct value, and yet the excited state energy seems strangely close to that same value.

To understand better how this happened, recall that the way we find an excited state is by requiring that the variational state be orthogonal to the ground state (using the overlap circuits and penalty terms). If we fail to obtain an accurate ground state energy (or are off by a few percent), then we also fail to obtain an accurate ground state vector! So when we require that the excited state be orthogonal to the first state we found, we were not imposing orthogonality with the true ground state, but rather with some approximation of it (sometimes a poor approximation of it). Thus, the excited state was not forced to be orthogonal to the true ground state, and our energy estimates for the excited states were actually quite close to the ground state energy.

This will always be a concern in VQD. But in principle, this can be corrected by increasing the maximum number of iterations for the classical optimizer, imposing lower tolerance for the classical optimizer, and possibly also trying a different ansatz if we are habitually missing the true ground state. As we have seen, one may also need to modify the overlap penalties (betas). But that is really a separate issue. No penalty for overlap will keep you away from the true ground state, if you haven't found a very good estimate of the true ground state for the overlap circuit.

## Optimization: max-cut

The maximum cut (max-cut) problem is a combinatorial optimization problem that involves dividing the vertices of a graph into two disjoint sets such that the number of edges between the two sets is maximized. More formally, given an undirected graph $G=(V,E)$, where $V$ is the set of vertices and $E$ is the set of edges, the max-cut problem asks to partition the vertices into two disjoint subsets, $S$ and $T$, such that the number of edges with one endpoint in $S$ and the other in $T$ is maximized.

We can apply max-cut to solve a various problems, such as clustering, network design, and phase transitions. We'll start by creating a problem graph:

This problem can be expressed as a binary optimization problem. For each node $0 \leq i < n$, where $n$ is the number of nodes of the graph (in this case $n=4$), we will consider the binary variable $x_i$. This variable will have the value $1$ if node $i$ is one of the groups that we'll label $1$ and $0$ if it's in the other group, that we'll label as $0$. We will also denote as $w_{ij}$ (element $(i,j)$ of the adjacency matrix $w$) the weight of the edge that goes from node $i$ to node $j$. Because the graph is undirected, $w_{ij}=w_{ji}$. Then we can formulate our problem as maximizing the following cost function:

$$
\begin{aligned}
C(\vec{x})
& =\sum_{i,j=0}^n w_{ij} x_i(1-x_j)\\[1mm]

& = \sum_{i,j=0}^n w_{ij} x_i - \sum_{i,j=0}^n w_{ij} x_ix_j\\[1mm]

& = \sum_{i,j=0}^n w_{ij} x_i - \sum_{i=0}^n \sum_{j=0}^i 2w_{ij} x_ix_j
\end{aligned}
$$

To solve this problem with a quantum computer, we are going to express the cost function as the expected value of an observable. However, the observables that Qiskit admits natively consist of Pauli operators, that have eigenvalues $1$ and $-1$ instead of $0$ and $1$. That's why we are going to make the following change of variable:

Where $\vec{x}=(x_0,x_1,\cdots ,x_{n-1})$. We can use the adjacency matrix $w$ to comfortably access the weights of all the edge. This will be used to obtain our cost function:

$$
z_i = 1-2x_i \rightarrow x_i = \frac{1-z_i}{2}
$$

This implies that:

$$
\begin{array}{lcl} x_i=0 & \rightarrow & z_i=1 \\ x_i=1 & \rightarrow & z_i=-1.\end{array}
$$

So the new cost function we want to maximize is:

$$
\begin{aligned}
C(\vec{z})
& = \sum_{i,j=0}^n w_{ij} \bigg(\frac{1-z_i}{2}\bigg)\bigg(1-\frac{1-z_j}{2}\bigg)\\[1mm]

& = \sum_{i,j=0}^n \frac{w_{ij}}{4} - \sum_{i,j=0}^n \frac{w_{ij}}{4} z_iz_j\\[1mm]

& = \sum_{i=0}^n \sum_{j=0}^i \frac{w_{ij}}{2} -  \sum_{i=0}^n \sum_{j=0}^i \frac{w_{ij}}{2} z_iz_j
\end{aligned}
$$

Moreover, the natural tendency of a quantum computer is to find minima (usually the lowest energy) instead of maxima so instead of maximizing $C(\vec{z})$ we are going to minimize:

$$
-C(\vec{z}) =  \sum_{i=0}^n \sum_{j=0}^i \frac{w_{ij}}{2} z_iz_j -  \sum_{i=0}^n \sum_{j=0}^i \frac{w_{ij}}{2}
$$

Now that we have a cost function to minimize whose variables can have the values $-1$ and $1$, we can make the following analogy with the Pauli $Z$:

$$
z_i \equiv Z_i = \overbrace{I}^{n-1}\otimes ... \otimes \overbrace{Z}^{i} \otimes ... \otimes \overbrace{I}^{0}
$$

In other words, the variable $z_i$ will be equivalent to a $Z$ gate acting on qubit $i$. Moreover:

$$
Z_i|x_{n-1}\cdots x_0\rangle = z_i|x_{n-1}\cdots x_0\rangle \rightarrow \langle x_{n-1}\cdots x_0 |Z_i|x_{n-1}\cdots x_0\rangle = z_i
$$

Then the observable we are going to consider is:

$$
\hat{H} = \sum_{i=0}^n \sum_{j=0}^i \frac{w_{ij}}{2} Z_iZ_j
$$

to which we will have to add the independent term afterwards:

$$
\texttt{offset} = - \sum_{i=0}^n \sum_{j=0}^i \frac{w_{ij}}{2}
$$

The operator is a linear combination of terms with Z operators on nodes connected by an edge (recall that the 0th qubit is farthest right): $IIZZ + IZIZ + IZZI + ZIIZ + ZZII$. Once the operator is constructed, the ansatz for the QAOA algorithm can easily be built by using the `QAOAAnsatz` circuit from the Qiskit circuit library.

We now set an initial set of random parameters:

Any classical optimizer can be used to minimize the cost function. On a real quantum system, an optimizer designed for non-smooth cost function landscapes usually does better. Here we use the [COBYLA routine](https://docs.scipy.org/doc/scipy/reference/optimize.minimize-cobyla.html#optimize-minimize-cobyla) from SciPy via the minimize function.

Because we are iteratively executing many calls to Runtime, we make use of a batch to execute all calls within a single block. Moreover, for QAOA, the solution is encoded in the output distribution of the ansatz circuit bound with the optimal parameters from the minimization. Therefore, we will need a Sampler primitive, and will instantiate it with the same session

And run our minimization routine:

The solution vector of parameter angles (`x`), when plugged into the ansatz circuit, yields the graph partitioning that we were looking for.

## Summary

With this lesson, you have learned:

- How to write a custom variational algorithm
- How to apply a variational algorithm to find minimum eigenvalues
- How to utilize variational algorithms to solve application use cases

Proceed to the final lesson to take your assessment and earn your badge!
