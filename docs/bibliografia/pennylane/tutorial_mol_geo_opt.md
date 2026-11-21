# Optimization of molecular geometries

> Fuente: <https://pennylane.ai/qml/demos/tutorial_mol_geo_opt>

[Alain Delgado Gran](https://pennylane.ai/profile/adgran)

Published: June 29, 2021. Last updated: April 17, 2026.

Predicting the most stable arrangement of atoms in a molecule is one of the most important tasks
in quantum chemistry. Essentially, this is an optimization problem where the total energy of the
molecule is minimized with respect to the positions of the atomic nuclei. The molecular
geometry obtained from this calculation is in fact the starting point for many simulations of
molecular properties. If the geometry is inaccurate, then any calculations that rely on it may
also be inaccurate.

Since the nuclei are much heavier than the electrons, we can treat them as point particles
clamped to their positions. Under this assumption, the total energy of the molecule \(E(x)\)
depends on the nuclear coordinates \(x,\) which define the potential energy surface.
Solving the stationary problem \(\nabla\_x E(x) = 0\) corresponds to molecular geometry
optimization and the optimized nuclear coordinates determine the equilibrium geometry of the
molecule. The figure below illustrates these concepts for the
[trihydrogen cation](https://en.wikipedia.org/wiki/Trihydrogen_cation). Its equilibrium
geometry in the electronic ground state corresponds to the minimum energy of the potential
energy surface. At this minimum, the three hydrogen atoms are located at the vertices of an
equilateral triangle whose side length is the optimized bond length \(d.\)

In this tutorial, you will learn how to recast the problem of finding the equilibrium
geometry of a molecule in terms of a general variational quantum algorithm. The
central idea is to consider explicitly that the target electronic Hamiltonian \(H(x)\)
is a **parametrized** observable that depends on the nuclear coordinates \(x.\) This
implies that the objective function, defined by the expectation value of the Hamiltonian
computed in the trial state prepared by a quantum computer, depends on both the quantum
circuit and the Hamiltonian parameters.

## The quantum algorithm in a nutshell

The goal of the variational algorithm is to find the global minimum of
the cost function \(g(\theta, x) = \langle \Psi(\theta) \vert H(x) \vert \Psi(\theta) \rangle\)
with respect to the circuit parameters \(\theta\) and the
nuclear coordinates \(x\) entering the electronic Hamiltonian of the molecule. To that end,
we use a gradient-descent method and follow a **joint** optimization scheme where the gradients of
the cost function with respect to circuit and Hamiltonian parameters are simultaneously computed
at each step. This approach does not require nested optimization of the state
parameters for each set of nuclear coordinates, as occurs in classical algorithms for
molecular geometry optimization, where the energy minimum is searched for along the potential energy
surface of the electronic state [[1]](#jensenbook).

In this tutorial we demonstrate how to use PennyLane to implement
quantum optimization of molecular geometries. The algorithm consists of the following steps:

1. Build the parametrized electronic Hamiltonian \(H(x)\) of the molecule.
2. Design the variational quantum circuit to prepare the electronic trial state of the
   molecule, \(\vert \Psi(\theta) \rangle.\)
3. Define the cost function \(g(\theta, x) = \langle \Psi(\theta) \vert H(x) \vert
   \Psi(\theta) \rangle\).
4. Initialize the variational parameters \(\theta\) and \(x.\) Perform a joint
   optimization of the circuit and Hamiltonian parameters to minimize the cost function
   \(g(\theta, x).\) The gradient with respect to the circuit parameters can be obtained
   using a variety of established methods, which are natively supported in PennyLane. The
   gradients with respect to the nuclear coordinates can be computed using the formula

   \[\nabla\_x g(\theta, x) = \langle \Psi(\theta) \vert \nabla\_x H(x) \vert \Psi(\theta) \rangle.\]

Once the optimization is finalized, the circuit parameters determine the energy of the
electronic state, and the nuclear coordinates determine the equilibrium geometry of the
molecule in this state.

Let’s get started! ⚛️

## Building the parametrized electronic Hamiltonian

In this example, we want to optimize the geometry of the trihydrogen cation
\(\mathrm{H}\_3^+,\) described in a minimal basis set, where two electrons are shared
between three hydrogen atoms (see figure above). The molecule is specified by providing a list
with the symbols of the atomic species and a one-dimensional array with the initial
set of nuclear coordinates in [atomic units](https://en.wikipedia.org/wiki/Hartree_atomic_units) .

```python
import jax
from jax import numpy as jnp

jax.config.update("jax_enable_x64", True)

symbols = ["H", "H", "H"]
x = jnp.array([[0.028, 0.054, 0.0], [0.986, 1.610, 0.0], [1.855, 0.002, 0.0]])
```

Next, we need to build the parametrized electronic Hamiltonian \(H(x).\)
We use the Jordan-Wigner transformation [[2]](#seeley2012) to represent the fermionic
Hamiltonian as a linear combination of Pauli operators,

\[H(x) = \sum\_j h\_j(x) \prod\_i^{N} \sigma\_i^{(j)}.\]

The expansion coefficients \(h\_j(x)\) carry the dependence on the coordinates \(x,\)
the operators \(\sigma\_i\) represent the Pauli group \(\{I, X, Y, Z\},\) and
\(N\) is the number of qubits required to represent the electronic wave function.

We define the function `H(x)` to build the parametrized Hamiltonian
of the trihydrogen cation using the
[`molecular_hamiltonian()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.qchem.molecular_hamiltonian.html#pennylane.qchem.molecular_hamiltonian "(in PennyLane v0.45)") function.

```python
import pennylane as qp

def H(x):
    molecule = qp.qchem.Molecule(symbols, x, charge=1)
    return qp.qchem.molecular_hamiltonian(molecule)[0]
```

## The variational quantum circuit

Here, we describe the second step of the quantum algorithm: define the quantum circuit
to prepare the electronic ground-state \(\vert \Psi(\theta)\rangle\) of the
\(\mathrm{H}\_3^+\) molecule.

Six qubits are required to encode the occupation number of the molecular spin-orbitals.
To capture the effects of electronic correlations [[3]](#kohanoff2006), we need to prepare
the \(N\)-qubit system in a superposition of the Hartree-Fock state
\(\vert 110000 \rangle\) with other states that differ by a double- or single-excitation.
For example, the state \(\vert 000011 \rangle\) is obtained by exciting two particles
from qubits 0, 1 to 4, 5. Similarly, the state \(\vert 011000 \rangle\) corresponds to a
single excitation from qubit 0 to 2. This can be done using the single-excitation and
double-excitation gates \(G\) and \(G^{(2)}\) [[4]](#qchemcircuits) implemented
in the form of Givens rotations in PennyLane. For more details see the tutorial
[Givens rotations for quantum chemistry](https://pennylane.ai/demos/tutorial_givens_rotations.html "(in PennyLane vNone)").

In addition, we use an adaptive algorithm [[6]](#geo-opt-paper) to select the excitation
operations included in the variational quantum circuit. The algorithm proceeds as follows:

1. Generate the indices of the qubits involved in all single- and
   double-excitations.
   For example, the indices of the singly-excited state \(\vert 011000 \rangle\)
   are given by the list `[0, 2]`. Similarly, the indices of the doubly-excited
   state \(\vert 000011 \rangle\) are [``](#id6)[0, 1, 4, 5]`.`
2. Construct the circuit using all double-excitation gates. Compute the gradient
   of the cost function \(g(\theta, x)\) with respect to each double-excitation
   gate and retain only those with non-zero gradient.
3. Include the selected double-excitation gates and repeat the process for the
   single-excitation gates.
4. Build the final variational quantum circuit by including the selected gates.

For the \(\mathrm{H}\_3^+\) molecule in a minimal basis set we have a total of eight
excitations of the reference state. After applying the adaptive algorithm the final
quantum circuit contains only two double-excitation operations that act on the qubits
`[0, 1, 2, 3]` and `[0, 1, 4, 5]`. The circuit is illustrated in the figure below.

To implement this quantum circuit, we use the
[`hf_state()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.qchem.hf_state.html#pennylane.qchem.hf_state "(in PennyLane v0.45)") function to generate the
occupation-number vector representing the Hartree-Fock state

```python
hf = qp.qchem.hf_state(electrons=2, orbitals=6)
print(hf)
```

```python
[1 1 0 0 0 0]
```

The `hf` array is used by the [`BasisState`](https://docs.pennylane.ai/en/stable/code/api/pennylane.BasisState.html#pennylane.BasisState "(in PennyLane v0.45)") operation to initialize
the qubit register. Then, the [`DoubleExcitation`](https://docs.pennylane.ai/en/stable/code/api/pennylane.DoubleExcitation.html#pennylane.DoubleExcitation "(in PennyLane v0.45)") operations are applied
First, we define the quantum device used to compute the expectation value.
In this example, we use the `default.qubit` simulator:

```python
num_wires = 6
dev = qp.device("default.qubit", wires=num_wires)

@qp.qnode(dev, interface="jax")
def circuit(params, obs, wires):
    qp.BasisState(hf, wires=wires)
    qp.DoubleExcitation(params[0], wires=[0, 1, 2, 3])
    qp.DoubleExcitation(params[1], wires=[0, 1, 4, 5])

    return qp.expval(obs)
```

This circuit prepares the trial state

\[\vert\Psi(\theta\_1, \theta\_2)\rangle =
\mathrm{cos}(\theta\_1)\mathrm{cos}(\theta\_2)\vert110000\rangle -
\mathrm{cos}(\theta\_1)\mathrm{sin}(\theta\_2)\vert000011\rangle -
\mathrm{sin}(\theta\_1)\vert001100\rangle,\]

where \(\theta\_1\) and \(\theta\_2\) are the circuit parameters that need to be
optimized to find the ground-state energy of the molecule.

## The cost function and the nuclear gradients

The third step of the algorithm is to define the cost function
\(g(\theta, x) = \langle \Psi(\theta) \vert H(x) \vert\Psi(\theta) \rangle.\) It
evaluates the expectation value of the parametrized Hamiltonian \(H(x)\) in the
trial state \(\vert\Psi(\theta)\rangle.\)

Next, we define the `cost` function \(g(\theta, x)\) which depends on
both the circuit and the Hamiltonian parameters. Specifically we consider the
expectation values of the Hamiltonian.

```python
def cost(params, x):
    hamiltonian = H(x)
    return circuit(params, obs=hamiltonian, wires=range(num_wires))
```

We minimize the cost function \(g(\theta, x)\) using a gradient-based
method, and compute the gradients with respect to both the
circuit parameters \(\theta\) and the nuclear coordinates \(x.\)
The circuit gradients are computed analytically using the automatic differentiation
techniques available in PennyLane. The nuclear gradients are evaluated
by taking the expectation value of the gradient of the electronic Hamiltonian,

\[\nabla\_x g(\theta, x) = \langle \Psi(\theta) \vert \nabla\_x H(x) \vert \Psi(\theta) \rangle.\]

We use the `finite_diff()` function to compute the gradient of
the Hamiltonian using a central-difference approximation. Then, we evaluate the expectation
value of the gradient components \(\frac{\partial H(x)}{\partial x\_i}.\) This is implemented by
the function `grad_x`:

```python
def finite_diff(f, x, delta=0.01):
    """Compute the central-difference finite difference of a function"""
    gradient = []
    x = jnp.ravel(x)

    for i in range(len(x)):
        shift = jnp.zeros_like(x)
        shift = shift.at[i].set(0.5*delta)
        res = (f(x + shift) - f(x - shift)) * delta**-1
        gradient.append(res)

    return gradient

def grad_x(params, x):
    grad_h = finite_diff(H, x)
    grad = [circuit(params, obs=obs, wires=range(num_wires)) for obs in grad_h]
    return jnp.array(grad).reshape(x.shape)
```

## Optimization of the molecular geometry

Finally, we proceed to minimize our cost function to find the ground state equilibrium
geometry of the \(\mathrm{H}\_3^+\) molecule. As a reminder,
the circuit parameters and the nuclear coordinates will be jointly optimized at
each optimization step. This approach does not require nested VQE
optimization of the circuit parameters for each set of nuclear coordinates.

First, we initialize the circuit parameters \(\theta.\) The angles
\(\theta\_1\) and \(\theta\_2\) are set to zero so that the
initial state \(\vert\Psi(\theta\_1, \theta\_2)\rangle\)
is the Hartree-Fock state.

```python
theta = jnp.array([0.0, 0.0])
```

The initial set of nuclear coordinates \(x,\) defined at
the beginning of the tutorial, was computed classically within the Hartree-Fock
approximation using the GAMESS program [[5]](#ref-gamess). This is a natural choice
for the starting geometry that we are aiming to improve due to the electronic
correlation effects included in the trial state \(\vert\Psi(\theta)\rangle.\)

We carry out the optimization over a maximum of 36 steps.
The circuit parameters and the nuclear coordinates are optimized until the
maximum component of the nuclear gradient \(\nabla\_x g(\theta,x)\) is
less than or equal to \(10^{-5}\) Hartree/Bohr. Typically, this is the
convergence criterion used for optimizing molecular geometries in
quantum chemistry simulations.

```python
# store the values of the cost function
energies = []

# store the values of the bond length
bond_length = []

# Factor to convert from Bohrs to Angstroms
bohr_angs = 0.529177210903

for n in range(36):
    # gradient for params
    g_param = jax.grad(cost, argnums=[0])(theta, x)[0]
    theta = theta - 0.8 * g_param

    # gradient for coordinates
    value, _ = jax.value_and_grad(cost, argnums=1)(theta, x)
    grad = grad_x(theta, x)
    x = x - 0.8 * grad
    energies.append(value)
    bond_length.append(jnp.linalg.norm(x[0] - x[1]) * bohr_angs)

    if n % 4 == 0:
        print(f"Step = {n},  E = {energies[-1]:.8f} Ha,  bond length = {bond_length[-1]:.5f} A")

    # Check maximum component of the nuclear gradient
    if jnp.max(grad_x(theta, x)) <= 1e-04:
        break

print("\n" f"Final value of the ground-state energy = {energies[-1]:.8f} Ha")
print("\n" "Ground-state equilibrium geometry")
print("%s %4s %8s %8s" % ("symbol", "x", "y", "z"))
for i, atom in enumerate(symbols):
    print(f"  {atom}    {x[0][i]:.4f}   {x[1][i]:.4f}   {x[2][i]:.4f}")
```

```python
Step = 0,  E = -1.26999182 Ha,  bond length = 0.96963 A
Step = 4,  E = -1.27440927 Ha,  bond length = 0.98192 A
Step = 8,  E = -1.27443682 Ha,  bond length = 0.98496 A

Final value of the ground-state energy = -1.27443760 Ha

Ground-state equilibrium geometry
symbol    x        y        z
  H    0.0104   0.9867   1.8719
  H    0.0443   1.6301   -0.0084
  H    0.0000   0.0000   0.0000
```

Next, we plot the values of the ground state energy of the molecule
and the bond length as a function of the optimization step.

```python
import matplotlib.pyplot as plt

fig = plt.figure()
fig.set_figheight(5)
fig.set_figwidth(12)

# Add energy plot on column 1
E_fci = -1.27443765658
E_vqe = jnp.array(energies)
ax1 = fig.add_subplot(121)
ax1.plot(range(n + 1), E_vqe - E_fci, "go", ls="dashed")
ax1.plot(range(n + 1), jnp.full(n + 1, 0.001), color="red")
ax1.set_xlabel("Optimization step", fontsize=13)
ax1.set_ylabel("$E_{VQE} - E_{FCI}$ (Hartree)", fontsize=13)
ax1.text(5, 0.0013, r"Chemical accuracy", fontsize=13)
plt.yscale("log")
plt.xticks(fontsize=12)
plt.yticks(fontsize=12)

# Add bond length plot on column 2
d_fci = 0.986
ax2 = fig.add_subplot(122)
ax2.plot(range(n + 1), bond_length, "go", ls="dashed")
ax2.plot(range(n + 1), jnp.full(n + 1, d_fci), color="red")
ax2.set_ylim([0.965, 0.99])
ax2.set_xlabel("Optimization step", fontsize=13)
ax2.set_ylabel("bond length ($\AA$)", fontsize=13)
ax2.text(5, 0.9865, r"Equilibrium bond length", fontsize=13)
plt.xticks(fontsize=12)
plt.yticks(fontsize=12)

plt.subplots_adjust(wspace=0.3)
plt.show()
```

Notice that despite the fact that the ground-state energy is already converged
within chemical accuracy (\(0.0016\) Ha) after the first iteration, more
optimization steps are required to find the equilibrium bond length of the
molecule.

The figure below animates snapshots of the atomic structure of the
trihydrogen cation as the quantum algorithm was searching for the equilibrium
geometry. For visualization purposes, the initial nuclear coordinates were
generated by perturbing the HF geometry. The quantum algorithm
is able to find the correct equilibrium geometry of the \(\mathrm{H}\_3^+\)
molecule where the three H atoms are located at the vertices of an equilateral triangle.

To summarize, we have shown how the scope of variational quantum algorithms can be
extended to perform quantum simulations of molecules involving both the electronic and
the nuclear degrees of freedom. The joint optimization scheme described here
is a generalization of the usual VQE algorithm where only the electronic
state is parametrized. Extending the applicability of the variational quantum algorithms to
target parametrized Hamiltonians could be also relevant to simulate the optical properties of
molecules where the fermionic observables depend also on the electric field of the
incoming radiation [[7]](#pulay).

## References

[[1](#id1)]

F. Jensen. “Introduction to computational chemistry”.
(John Wiley & Sons, 2016).

[[2](#id2)]

Jacob T. Seeley, Martin J. Richard, Peter J. Love. “The Bravyi-Kitaev transformation for
quantum computation of electronic structure”. [Journal of Chemical Physics 137, 224109
(2012).](https://aip.scitation.org/doi/abs/10.1063/1.4768229)

[[3](#id3)]

Jorge Kohanoff. “Electronic structure calculations for solids and molecules: theory and
computational methods”. (Cambridge University Press, 2006).

[[4](#id4)]

J.M. Arrazola, O. Di Matteo, N. Quesada, S. Jahangiri, A. Delgado, N. Killoran.
“Universal quantum circuits for quantum chemistry”. arXiv:2106.13839, (2021)

[[5](#id8)]

M.W. Schmidt, K.K. Baldridge, J.A. Boatz, S.T. Elbert, M.S. Gordon, J.H. Jensen,
S. Koseki, N. Matsunaga, K.A. Nguyen, S.Su, *et al.* “General atomic and molecular
electronic structure system”. [Journal of Computational Chemistry 14, 1347 (1993)](https://onlinelibrary.wiley.com/doi/10.1002/jcc.540141112)

[[6](#id5)]

A. Delgado, J.M. Arrazola, S. Jahangiri, Z. Niu, J. Izaac, C. Roberts, N. Killoran.
“Variational quantum algorithm for molecular geometry optimization”.
arXiv:2106.13840, (2021)

[[7](#id9)]

P. Pulay.
“Analytical derivative methods in quantum chemistry”.
[Advances in Chemical Sciences (1987)](https://onlinelibrary.wiley.com/doi/10.1002/9780470142943.ch4)

## About the author

[Alain Delgado Gran](https://pennylane.ai/profile/adgran)

Quantum simulations of molecules and materials.

**Total running time of the script:** (5 minutes 22.100 seconds)

Share demo

[Ask a question on the forum](https://discuss.pennylane.ai/c/demos/25)

### Related Demos

[Building molecular Hamiltonians](https://pennylane.ai/qml/demos/tutorial_quantum_chemistry)

[A brief overview of VQE](https://pennylane.ai/qml/demos/tutorial_vqe)

[Givens rotations for quantum chemistry](https://pennylane.ai/qml/demos/tutorial_givens_rotations)

[VQE in different spin sectors](https://pennylane.ai/qml/demos/tutorial_vqe_spin_sectors)

[Differentiable Hartree-Fock](https://pennylane.ai/qml/demos/tutorial_differentiable_HF)

[Modelling chemical reactions on a quantum computer](https://pennylane.ai/qml/demos/tutorial_chemical_reactions)

[Adaptive circuits for quantum chemistry](https://pennylane.ai/qml/demos/tutorial_adaptive_circuits)

[How to implement VQD with PennyLane](https://pennylane.ai/qml/demos/tutorial_vqe_vqd)

[Qubit tapering](https://pennylane.ai/qml/demos/tutorial_qubit_tapering)

[Mapping fermionic Hamiltonians to qubit Hamiltonians](https://pennylane.ai/qml/demos/tutorial_mapping)
