# Optimization loops

> Fuente: <https://quantum.cloud.ibm.com/learning/en/courses/variational-algorithm-design/optimization-loops>

> Solo las celdas de texto del notebook original; sin código.


During this lesson, we will learn how to use an *optimizer* to iteratively explore the parameterized quantum states of our ansatz:

- Bootstrap an optimization loop
- Understand trade-offs while using local and global optimizers
- Explore barren plateaus and how to avoid them

At a high level, optimizers are central to exploring our search space. The optimizer uses cost function evaluations to select the next set of parameters in a variational loop, and repeats the process until it reaches a stable state. At this stage, an optimal set of parameter values $\vec\theta^*$ is returned.

## Local and Global Optimizers

We'll first set up our problem before exploring each optimizer class. We will start with a circuit containing eight variational parameters:

### Local Optimizers

Local optimizers search for a point that minimizes the cost function starting at an initial point(s) $C(\vec{\theta_0})$ and move to different points based on what they observe in the region they are currently evaluating on successive iterations. This implies that the convergence of these algorithms will usually be fast, but can be heavily dependent on the initial point. Local optimizers are unable to see beyond the region where they are evaluating and can be especially vulnerable to local minima, reporting convergence when they find one and ignoring other states with more favorable evaluations.

### Global optimizers

Global optimizers search for the point that minimizes the cost function over several regions of its domain (that is, non-local), evaluating it iteratively (that is, at iteration $i$) over a set of parameter vectors $\Theta_i := \\{ {\vec\theta_{i,j} | j \in \mathcal{J}_\text{opt}^i} \\}$ determined by the optimizer. This makes them less susceptible to local minima and somewhat independent of initialization, but also significantly slower to converge to a proposed solution.

### Bootstrapping Optimization

*Bootstrapping*, or setting the initial value for parameters $\vec\theta$ based on a prior optimization, can help our optimizer converge on a solution faster. We refer to this as the initial point $\vec\theta_0$, and $|\psi(\vec\theta_0)\rangle = U_V(\vec\theta_0)|\rho\rangle$ as the initial state. This initial state differs from our reference state $|\rho\rangle$, as the former focuses on initial parameters set during our optimization loop, while the latter focuses on using known "reference" solutions. They may coincide if $U_V(\vec\theta_0) \equiv I$ (that is, the identity operation).

When local optimizers converge to non-optimal local minima, we can try bootstrapping the optimization globally and refine the convergence locally. While this requires setting up two variational workloads, it allows the optimizer to find a more optimal solution than the local optimizer alone.

## Gradient-Based and Gradient-Free Optimizers

### Gradient-Based

For our cost function $C(\vec\theta)$, if we have access to the gradient of the function $\vec{\nabla} C(\vec\theta)$ starting from an initial point, the simplest way to minimize the function is to update the parameters towards the direction of steepest descent of the function. That is, we update the parameters as $\vec\theta_{n+1} = \vec\theta_n - \eta \vec{\nabla} C(\vec\theta)$, where $\eta$ is the learning rate - a small, positive <DefinitionTooltip definition="A hyperparameter is a parameter that we use to control our algorithm. The term hyper distinguishes it from the parameters (θ) that our algorithm is trying to find.">hyperparameter</DefinitionTooltip> that controls the size of the update. We continue doing this until we converge to a <DefinitionTooltip definition="A local minimum is the lowest point of the function, for a small range of values of theta. In contrast, a global minimum is the lowest point, anywhere in our function (that is, for any value of θ).">local minimum</DefinitionTooltip> of the cost function, $C({\vec\theta^*})$.

We can use this cost function and an optimizer to calculate optimal parameters

The main disadvantages of this type of optimization are the convergence speed, which can be very slow, and there is no guarantee to achieve the optimal solution.

### Gradient-Free

Gradient-free optimization algorithms do not require gradient information and can be useful in situations where computing the gradient is difficult, expensive, or too noisy. They also tend to be more robust in finding global optima, whereas gradient-based methods tend to converge to local optima. We'll explore a few instances where a gradient-free optimizer can help avoid barren plateaus. However, gradient-free methods require higher computational resources, especially for problems with high-dimensional search spaces.

Here's an example that uses the [`COBYLA`](https://docs.scipy.org/doc/scipy/reference/optimize.minimize-cobyla.html#optimize-minimize-cobyla) optimizer instead:

## Barren Plateaus

In fact, the cost landscape can be quite complicated, as shown by the hills and valleys in the example below. The optimization method navigates us around the cost landscape, searching for the minimum, as shown by the black points and lines. We can see that two of the three searches end up in a local minimum of the landscape, rather than a global one.

Regardless of the type of optimization method used, if the cost landscape is relatively flat, it can be challenging for the method to determine the appropriate direction to search. This scenario is referred to as a <DefinitionTooltip definition="When gradients of parametrized quantum circuits become exponentially small with respect to the number of qubits, making optimization difficult and potentially impossible.">barren plateau,</DefinitionTooltip> where the cost landscape becomes progressively flatter (and thus more challenging to determine the direction to the minimum). For a broad range of parameterized quantum circuits, the probability that the gradient along any reasonable direction is non-zero to some fixed precision decreases exponentially as the number of qubits increases.

While this area is still under active research, we have a few recommendations to improve optimization performance:

- **Bootstrapping** can help the optimization loop avoid getting stuck in a parameter space where the gradient is small.
- **Experimenting with hardware-efficient ansatz**: Since we're using a noisy quantum system as a black-box oracle, the quality of those evaluations can affect the optimizer's performance. Using hardware-efficient ansatz, such as [`EfficientSU2`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.library.EfficientSU2), may avoid producing exponentially small gradients.
- **Experimenting with error suppression and error mitigation**:  the IBM Quantum&reg; primitives provide a simple interface to experiment with various values for `optimization_level` and `resilience_setting`, respectively. This can reduce the impact of noise and make the optimization process more efficient.
- **Experimenting with gradient-free optimizers**: Unlike gradient-based optimization algorithms, optimizers such as `COBYLA` do not rely on gradient information to optimize the parameters and are therefore less likely to be affected by the barren plateau.

## Summary

With this lesson, you learned how to define your optimization loop:

- Bootstrap an optimization loop
- Understand trade-offs while using local and global optimizers
- Explore barren plateaus and how to avoid them

Our high-level variational workload is complete:

Next, we'll explore specific variational algorithms with this framework in mind.
