# Quantum natural gradient

> Fuente: <https://pennylane.ai/qml/demos/tutorial_quantum_natural_gradient>

[Josh Izaac](https://pennylane.ai/profile/josh)

Published: October 10, 2019. Last updated: July 23, 2026.

This example demonstrates the quantum natural gradient optimization technique
for variational quantum circuits, originally proposed in
[Stokes et al. (2019)](https://arxiv.org/abs/1909.02108).

## Background

The most successful class of quantum algorithms for use on near-term noisy quantum hardware
is the so-called variational quantum algorithm. As laid out in the
[Concepts section](https://pennylane.ai/glossary/#variational-circuits), in variational quantum algorithms
a low-depth parametrized quantum circuit ansatz is chosen, and a problem-specific
observable measured. A classical optimization loop is then used to find
the set of quantum parameters that *minimize* a particular measurement expectation value
of the quantum device. Examples of such algorithms include the [variational quantum
eigensolver (VQE)](https://pennylane.ai/demos/tutorial_vqe.html "(in PennyLane vNone)"), the
[quantum approximate optimization algorithm (QAOA)](https://arxiv.org/abs/1411.4028),
and [quantum neural networks (QNN)](https://pennylane.ai/demos/quantum_neural_net.html "(in PennyLane vNone)").

Most recent demonstrations
of variational quantum algorithms have used gradient-free classical optimization
methods, such as the Nelder-Mead algorithm. However, the parameter-shift rule
(as implemented in PennyLane) allows the user to automatically compute
analytic gradients of quantum circuits. This opens up the possibility to train
quantum computing hardware using gradient descent—the same method used to train
deep learning models.
Though one caveat has surfaced with gradient descent — how do we choose the optimal
step size for our variational quantum algorithms, to ensure successful and
efficient optimization?

### The natural gradient

In standard gradient descent, each optimization step is given by

\[\theta\_{t+1} = \theta\_t -\eta \nabla \mathcal{L}(\theta),\]

where \(\mathcal{L}(\theta)\) is the cost as a function of
the parameters \(\theta,\) and \(\eta\) is the learning rate
or step size. In essence, each optimization step calculates the
steepest descent direction around the local value of \(\theta\_t\)
in the parameter space, and updates \(\theta\_t\rightarrow \theta\_{t+1}\)
by this vector.

The problem with the above approach is that each optimization step
is strongly connected to a *Euclidean geometry* on the parameter space.
The parametrization is not unique, and different parametrizations can distort
distances within the optimization landscape.

For example, consider the following cost function \(\mathcal{L},\) parametrized
using two different coordinate systems, \((\theta\_0, \theta\_1),\) and
\((\phi\_0, \phi\_1):\)

Performing gradient descent in the \((\theta\_0, \theta\_1)\) parameter
space, we are updating each parameter by the same Euclidean distance,
and not taking into account the fact that the cost function might vary at a different
rate with respect to each parameter.

Instead, if we perform a change of coordinate system (re-parametrization)
of the cost function, we might find a parameter space where variations in \(\mathcal{L}\)
are similar across different parameters. This is the case with the new parametrization
\((\phi\_0, \phi\_1);\) the cost function is unchanged,
but we now have a nicer geometry in which to perform gradient descent, and a more
informative stepsize. This leads to faster convergence, and can help avoid optimization
becoming stuck in local minima. For a more in-depth explanation,
including why the parameter space might not be best represented by a Euclidean space,
see [Yamamoto (2019)](https://arxiv.org/abs/1909.05074).

However, what if we avoid gradient descent in the parameter space altogether?
If we instead consider the optimization problem as a
probability distribution of possible output values given an input
(i.e., [maximum likelihood estimation](https://en.wikipedia.org/wiki/Likelihood_function)),
a better approach is to perform the gradient descent in the *distribution space*, which is
dimensionless and invariant with respect to the parametrization. As a result,
each optimization step will always choose the optimum step-size for every
parameter, regardless of the parametrization.

In classical neural networks, the above process is known as
*natural gradient descent*, and was first introduced by
[Amari (1998)](https://www.mitpressjournals.org/doi/abs/10.1162/089976698300017746).
The standard gradient descent is modified as follows:

\[\theta\_{t+1} = \theta\_t - \eta F^{-1}\nabla \mathcal{L}(\theta),\]

where \(F\) is the [Fisher information matrix](https://en.wikipedia.org/wiki/Fisher_information#Matrix_form).
The Fisher information matrix acts as a metric tensor, transforming the
steepest descent in the Euclidean parameter space to the steepest descent in the
distribution space.

### The quantum analog

In a similar vein, it has been shown that the standard Euclidean geometry
is sub-optimal for optimization of quantum variational algorithms
[(Harrow and Napp, 2019)](https://arxiv.org/abs/1901.05374).
The space of quantum states instead possesses a unique invariant metric
tensor known as the Fubini-Study metric tensor \(g\_{ij},\) which can be used to
construct a quantum analog to natural gradient descent:

\[\theta\_{t+1} = \theta\_t - \eta g^{+}(\theta\_t)\nabla \mathcal{L}(\theta),\]

where \(g^{+}\) refers to the pseudo-inverse.

Note

It can be shown that the Fubini-Study metric tensor reduces
to the Fisher information matrix in the classical limit.

Furthermore, in the limit where \(\eta\rightarrow 0,\)
the dynamics of the system are equivalent to imaginary-time
evolution within the variational subspace, as proposed in
[McArdle et al. (2018)](https://arxiv.org/abs/1804.03023).

## Block-diagonal metric tensor

A block-diagonal approximation to the Fubini-Study metric tensor
of a variational quantum circuit can be evaluated on quantum hardware.

Consider a variational quantum circuit

\[U(\mathbf{\theta})|\psi\_0\rangle = V\_L(\theta\_L) W\_L V\_{L-1}(\theta\_{L-1}) W\_{L-1}
\cdots V\_{\ell}(\theta\_{\ell}) W\_{\ell} \cdots V\_{0}(\theta\_{0}) W\_{0} |\psi\_0\rangle\]

where

* \(|\psi\_0\rangle\) is the initial state,
* \(W\_\ell\) are layers of non-parametrized quantum gates,
* \(V\_\ell(\theta\_\ell)\) are layers of parametrized quantum gates
  with \(n\_\ell\) parameters \(\theta\_\ell = \{\theta^{(\ell)}\_0, \dots, \theta^{(\ell)}\_n\}.\)

Further, assume all parametrized gates can be written in the form
\(X(\theta^{(\ell)}\_{i}) = e^{i\theta^{(\ell)}\_{i} K^{(\ell)}\_i},\)
where \(K^{(\ell)}\_i\) is the *generator* of the parametrized operation.

For each parametric layer \(\ell\) in the variational quantum circuit
the \(n\_\ell\times n\_\ell\) block-diagonal submatrix
of the Fubini-Study tensor \(g\_{ij}^{(\ell)}\) is calculated by:

\[g\_{ij}^{(\ell)} = \langle \psi\_{\ell-1} | K\_i K\_j | \psi\_{\ell-1} \rangle
- \langle \psi\_{\ell-1} | K\_i | \psi\_{\ell-1}\rangle
\langle \psi\_{\ell-1} |K\_j | \psi\_{\ell-1}\rangle\]

where

\[| \psi\_{\ell-1}\rangle = V\_{\ell-1}(\theta\_{\ell-1}) W\_{\ell-1} \cdots V\_{0}(\theta\_{0}) W\_{0} |\psi\_0\rangle.\]

(that is, \(|\psi\_{\ell-1}\rangle\) is the quantum state prior to the application
of parameterized layer \(\ell\)), and we have \(K\_i \equiv K\_i^{(\ell)}\) for brevity.

Let’s consider a small variational quantum circuit example coded in PennyLane:

```python
import numpy as np
import pennylane as qp
from pennylane import numpy as pnp

dev = qp.device("lightning.qubit", wires=3)

@qp.qnode(dev, interface="autograd", diff_method="parameter-shift")
def circuit(params):
    # |psi_0>: state preparation
    qp.RY(np.pi / 4, wires=0)
    qp.RY(np.pi / 3, wires=1)
    qp.RY(np.pi / 7, wires=2)

    # V0(theta0, theta1): Parametrized layer 0
    qp.RZ(params[0], wires=0)
    qp.RZ(params[1], wires=1)

    # W1: non-parametrized gates
    qp.CNOT(wires=[0, 1])
    qp.CNOT(wires=[1, 2])

    # V_1(theta2, theta3): Parametrized layer 1
    qp.RY(params[2], wires=1)
    qp.RX(params[3], wires=2)

    # W2: non-parametrized gates
    qp.CNOT(wires=[0, 1])
    qp.CNOT(wires=[1, 2])

    return qp.expval(qp.PauliY(0))

# Use pennylane.numpy for trainable parameters
params = pnp.array([0.432, -0.123, 0.543, 0.233])
```

The above circuit consists of 4 parameters, with two distinct parametrized
layers of 2 parameters each.

(Note that in this example, the first non-parametrized layer \(W\_0\)
is simply the identity.) Since there are two layers, each with two parameters,
the block-diagonal approximation consists of two
\(2\times 2\) matrices, \(g^{(0)}\) and \(g^{(1)}.\)

To compute the first block-diagonal \(g^{(0)},\) we create subcircuits consisting
of all gates prior to the layer, and observables corresponding to
the *generators* of the gates in the layer:

```python
g0 = np.zeros([2, 2])

def layer0_subcircuit(params):
    """This function contains all gates that
    precede parametrized layer 0"""
    qp.RY(np.pi / 4, wires=0)
    qp.RY(np.pi / 3, wires=1)
    qp.RY(np.pi / 7, wires=2)
```

We then post-process the measurement results in order to determine \(g^{(0)},\)
as follows.

We can see that the diagonal terms are simply given by the variance:

```python
@qp.qnode(dev, interface="autograd")
def layer0_diag(params):
    layer0_subcircuit(params)
    return qp.var(qp.PauliZ(0)), qp.var(qp.PauliZ(1))

# calculate the diagonal terms
varK0, varK1 = layer0_diag(params)
g0[0, 0] = varK0 / 4
g0[1, 1] = varK1 / 4
```

The following two subcircuits are then used to calculate the
off-diagonal covariance terms of \(g^{(0)}:\)

```python
@qp.qnode(dev, interface="autograd")
def layer0_off_diag_single(params):
    layer0_subcircuit(params)
    return qp.expval(qp.PauliZ(0)), qp.expval(qp.PauliZ(1))

@qp.qnode(dev, interface="autograd")
def layer0_off_diag_double(params):
    layer0_subcircuit(params)
    ZZ = np.kron(np.diag([1, -1]), np.diag([1, -1]))
    return qp.expval(qp.Hermitian(ZZ, wires=[0, 1]))

# calculate the off-diagonal terms
exK0, exK1 = layer0_off_diag_single(params)
exK0K1 = layer0_off_diag_double(params)

g0[0, 1] = (exK0K1 - exK0 * exK1) / 4
g0[1, 0] = (exK0K1 - exK0 * exK1) / 4
```

Note that, by definition, the block-diagonal matrices must be real and
symmetric.

We can repeat the above process to compute \(g^{(1)}.\) The subcircuit
required is given by

```python
g1 = np.zeros([2, 2])

def layer1_subcircuit(params):
    """This function contains all gates that
    precede parametrized layer 1"""
    # |psi_0>: state preparation
    qp.RY(np.pi / 4, wires=0)
    qp.RY(np.pi / 3, wires=1)
    qp.RY(np.pi / 7, wires=2)

    # V0(theta0, theta1): Parametrized layer 0
    qp.RZ(params[0], wires=0)
    qp.RZ(params[1], wires=1)

    # W1: non-parametrized gates
    qp.CNOT(wires=[0, 1])
    qp.CNOT(wires=[1, 2])
```

Using this subcircuit, we can now generate the submatrix \(g^{(1)}.\)

```python
@qp.qnode(dev, interface="autograd")
def layer1_diag(params):
    layer1_subcircuit(params)
    return qp.var(qp.PauliY(1)), qp.var(qp.PauliX(2))
```

As previously, the diagonal terms are simply given by the variance,

```python
varK0, varK1 = layer1_diag(params)
g1[0, 0] = varK0 / 4
g1[1, 1] = varK1 / 4
```

while the off-diagonal terms require covariance between the two
observables to be computed.

```python
@qp.qnode(dev, interface="autograd")
def layer1_off_diag_single(params):
    layer1_subcircuit(params)
    return qp.expval(qp.PauliY(1)), qp.expval(qp.PauliX(2))

@qp.qnode(dev, interface="autograd")
def layer1_off_diag_double(params):
    layer1_subcircuit(params)
    X = np.array([[0, 1], [1, 0]])
    Y = np.array([[0, -1j], [1j, 0]])
    YX = np.kron(Y, X)
    return qp.expval(qp.Hermitian(YX, wires=[1, 2]))

# calculate the off-diagonal terms
exK0, exK1 = layer1_off_diag_single(params)
exK0K1 = layer1_off_diag_double(params)

g1[0, 1] = (exK0K1 - exK0 * exK1) / 4
g1[1, 0] = g1[0, 1]
```

Putting this altogether, the block-diagonal approximation to the Fubini-Study
metric tensor for this variational quantum circuit is

```python
from scipy.linalg import block_diag

g = block_diag(g0, g1)
print(np.round(g, 8))
```

```python
[[ 0.125       0.          0.          0.        ]
 [ 0.          0.1875      0.          0.        ]
 [ 0.          0.          0.24973433 -0.01524701]
 [ 0.          0.         -0.01524701  0.20293623]]
```

PennyLane contains a built-in function for computing the Fubini-Study metric
tensor, [`metric_tensor()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.metric_tensor.html#pennylane.metric_tensor "(in PennyLane v0.45)"), which
we can use to verify this result:

```python
print(np.round(qp.metric_tensor(circuit, approx="block-diag")(params), 8))
```

```python
[[ 0.125       0.          0.          0.        ]
 [ 0.          0.1875      0.          0.        ]
 [ 0.          0.          0.24973433 -0.01524701]
 [ 0.          0.         -0.01524701  0.20293623]]
```

As opposed to our manual computation, which required 6 different quantum
evaluations, the PennyLane Fubini-Study metric tensor implementation
requires only 2 quantum evaluations, one per layer. This is done by
automatically detecting the layer structure, and noting that every
observable that must be measured commutes, allowing for simultaneous measurement.

Therefore, by combining the quantum natural gradient optimizer with the analytic
parameter-shift rule to optimize a variational circuit with \(d\) parameters
and \(L\) parametrized layers, a total of \(2d+L\) quantum evaluations
are required per optimization step.

Note that the [`metric_tensor()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.metric_tensor.html#pennylane.metric_tensor "(in PennyLane v0.45)") function also supports computing the diagonal
approximation to the metric tensor:

```python
print(qp.metric_tensor(circuit, approx='diag')(params))
```

```python
[[0.125      0.         0.         0.        ]
 [0.         0.1875     0.         0.        ]
 [0.         0.         0.24973433 0.        ]
 [0.         0.         0.         0.20293623]]
```

Furthermore, the returned metric tensor is **full differentiable**; include it
in your cost function, and train or optimize its value!

## Quantum natural gradient optimization

PennyLane provides an implementation of the quantum natural gradient
optimizer, [`QNGOptimizer`](https://docs.pennylane.ai/en/stable/code/api/pennylane.QNGOptimizer.html#pennylane.QNGOptimizer "(in PennyLane v0.45)"). Let’s compare the optimization convergence
of the QNG Optimizer and the [`GradientDescentOptimizer`](https://docs.pennylane.ai/en/stable/code/api/pennylane.GradientDescentOptimizer.html#pennylane.GradientDescentOptimizer "(in PennyLane v0.45)") for the simple variational
circuit above.

```python
steps = 200
init_params = pnp.array([0.432, -0.123, 0.543, 0.233], requires_grad=True)
```

Performing vanilla gradient descent:

```python
gd_cost = []
opt = qp.GradientDescentOptimizer(0.01)

theta = init_params
for _ in range(steps):
    theta = opt.step(circuit, theta)
    gd_cost.append(circuit(theta))
```

Performing quantum natural gradient descent:

```python
qng_cost = []
opt = qp.QNGOptimizer(0.01)

theta = init_params
for _ in range(steps):
    theta = opt.step(circuit, theta)
    qng_cost.append(circuit(theta))
```

Plotting the cost vs optimization step for both optimization strategies:

```python
from matplotlib import pyplot as plt

plt.style.use("seaborn-v0_8")
plt.plot(gd_cost, "b", label="Vanilla gradient descent")
plt.plot(qng_cost, "g", label="Quantum natural gradient descent")

plt.ylabel("Cost function value")
plt.xlabel("Optimization steps")
plt.legend()
plt.show()
```

## References

1. Shun-Ichi Amari. “Natural gradient works efficiently in learning.”
   [Neural computation 10.2, 251-276](https://www.mitpressjournals.org/doi/abs/10.1162/089976698300017746), 1998.
2. James Stokes, Josh Izaac, Nathan Killoran, Giuseppe Carleo.
   “Quantum Natural Gradient.” [arXiv:1909.02108](https://arxiv.org/abs/1909.02108), 2019.
3. Aram Harrow and John Napp. “Low-depth gradient measurements can improve
   convergence in variational hybrid quantum-classical algorithms.”
   [arXiv:1901.05374](https://arxiv.org/abs/1901.05374), 2019.
4. Naoki Yamamoto. “On the natural gradient for variational quantum eigensolver.”
   [arXiv:1909.05074](https://arxiv.org/abs/1909.05074), 2019.

## About the author

[Josh Izaac](https://pennylane.ai/profile/josh)

Josh is a theoretical physicist, software tinkerer, and occasional baker. At Xanadu, he contributes to the development and growth of Xanadu’s open-source quantum software products.

**Total running time of the script:** (0 minutes 4.655 seconds)

Share demo

[Ask a question on the forum](https://discuss.pennylane.ai/c/demos/25)

### Related Demos

[Quantum gradients with backpropagation](https://pennylane.ai/qml/demos/tutorial_backprop)

[Accelerating VQEs with quantum natural gradient](https://pennylane.ai/qml/demos/tutorial_vqe_qng)

[The stochastic parameter-shift rule](https://pennylane.ai/qml/demos/tutorial_stochastic_parameter_shift)

[Optimizing noisy circuits with Cirq](https://pennylane.ai/qml/demos/tutorial_noisy_circuit_optimization)

[Barren plateaus in quantum neural networks](https://pennylane.ai/qml/demos/tutorial_barren_plateaus)

[Frugal shot optimization with Rosalin](https://pennylane.ai/qml/demos/tutorial_rosalin)

[Plugins and hybrid computation](https://pennylane.ai/qml/demos/plugins_hybrid)

[3-qubit Ising model in PyTorch](https://pennylane.ai/qml/demos/tutorial_isingmodel_PyTorch)

[Doubly stochastic gradient descent](https://pennylane.ai/qml/demos/tutorial_doubly_stochastic)

[PyTorch and noisy devices](https://pennylane.ai/qml/demos/pytorch_noise)
