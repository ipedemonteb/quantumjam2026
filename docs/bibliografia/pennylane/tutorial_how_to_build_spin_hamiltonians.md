# How to build spin Hamiltonians

> Fuente: <https://pennylane.ai/qml/demos/tutorial_how_to_build_spin_hamiltonians>

[Diksha Dhawan](https://pennylane.ai/profile/ddhawan)[Soran Jahangiri](https://pennylane.ai/profile/soran)

Published: December 04, 2024. Last updated: May 25, 2026.

Systems of interacting spins provide simple but powerful models for studying problems in physics,
chemistry, and quantum computing. PennyLane offers a comprehensive set of tools that enables users
to intuitively construct a broad range of spin Hamiltonians. Here we show you how to use these tools
to easily construct spin Hamiltonians for the [Fermi–Hubbard model](https://en.wikipedia.org/wiki/Hubbard_model),
the [Heisenberg model](https://en.wikipedia.org/wiki/Quantum_Heisenberg_model),
the [transverse-field Ising model](https://en.wikipedia.org/wiki/Transverse-field_Ising_model),
[Kitaev’s honeycomb model](https://arxiv.org/abs/cond-mat/0506438),
the [Haldane model](https://journals.aps.org/prl/abstract/10.1103/PhysRevLett.61.2015),
the [Emery model](https://journals.aps.org/prl/abstract/10.1103/PhysRevLett.58.2794),
and more. And you can also already explore some of these models in detail using [PennyLane Spin Systems Datasets](https://pennylane.ai/datasets/collection/qspin)!

## Hamiltonian templates

PennyLane provides a set of built-in
[functions](https://docs.pennylane.ai/en/latest/code/qp_spin.html#hamiltonian-functions)
in the [qp.spin](https://docs.pennylane.ai/en/stable/code/qp_spin.html "(in PennyLane v0.45)") module for
constructing spin Hamiltonians with minimal input needed from the user: we only need to specify
the lattice that describes spin sites and the parameters that describe the interactions in our
system. Let’s look at some examples for the models that are currently supported in PennyLane.

### Fermi–Hubbard model

The [Fermi–Hubbard model Hamiltonian](https://docs.pennylane.ai/en/latest/code/api/pennylane.spin.fermi_hubbard.html)
has a kinetic energy component, which is parameterized by a hopping parameter \(t\), and a
potential energy component which is parameterized by the on-site interaction strength, \(U\):

\[H = -t\sum\_{\left< i,j \right>, \sigma} c\_{i\sigma}^{\dagger}c\_{j\sigma} + U\sum\_{i}n\_{i \uparrow} n\_{i\downarrow}.\]

The terms \(c^{\dagger}, c\) are the creation and annihilation operators,
\(\left< i,j \right>\) represents the indices of neighbouring spins, \(\sigma\) is the
spin degree of freedom, and \(n\_{i \uparrow}, n\_{i \downarrow}\) are the number operators for
the spin-up and spin-down fermions at site \(i\), denoted by \(0\) and \(1\)
respectively. This model is often used as a simplified model to investigate superconductivity.

The Fermi–Hubbard Hamiltonian can be
constructed in PennyLane by passing the hopping and interaction parameters to the
[`fermi_hubbard()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.spin.fermi_hubbard.html#pennylane.spin.fermi_hubbard "(in PennyLane v0.45)") function. We also need to specify the shape of the lattice
that describes the positions of the spin sites. We will show an example here, and the full list of
supported lattice shapes is
provided in the [`generate_lattice()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.spin.generate_lattice.html#pennylane.spin.generate_lattice "(in PennyLane v0.45)") documentation.

We can also define the
number of lattice cells we would like to include in our Hamiltonian as a list of integers for
\(x, y, z\) directions, depending on the lattice shape. Here we generate the Fermi–Hubbard
Hamiltonian on a `square` lattice of shape \(2 \times 2\). The `square` lattice is
constructed from unit cells that contain only one site such that we will have
\(2 \times 2 = 4\) sites in total. We will provide more details on constructing lattices in
the following sections.

```python
import pennylane as qp

n_cells = [2, 2]
hopping = 0.2
onsite = 0.3

hamiltonian = qp.spin.fermi_hubbard('square', n_cells, hopping, onsite)
print('Hamiltonian:\n')
hamiltonian
```

```python
Hamiltonian:

(
    -0.1 * (Y(0) @ Z(1) @ Y(2))
  + -0.1 * (X(0) @ Z(1) @ X(2))
  + 0.3 * I([0, 1, 2, 3, 4, 5, 6, 7])
  + -0.1 * (Y(1) @ Z(2) @ Y(3))
  + -0.1 * (X(1) @ Z(2) @ X(3))
  + -0.1 * (Y(0) @ Z(1) @ Z(2) @ Z(3) @ Y(4))
  + -0.1 * (X(0) @ Z(1) @ Z(2) @ Z(3) @ X(4))
  + -0.1 * (Y(1) @ Z(2) @ Z(3) @ Z(4) @ Y(5))
  + -0.1 * (X(1) @ Z(2) @ Z(3) @ Z(4) @ X(5))
  + -0.1 * (Y(2) @ Z(3) @ Z(4) @ Z(5) @ Y(6))
  + -0.1 * (X(2) @ Z(3) @ Z(4) @ Z(5) @ X(6))
  + -0.1 * (Y(3) @ Z(4) @ Z(5) @ Z(6) @ Y(7))
  + -0.1 * (X(3) @ Z(4) @ Z(5) @ Z(6) @ X(7))
  + -0.1 * (Y(4) @ Z(5) @ Y(6))
  + -0.1 * (X(4) @ Z(5) @ X(6))
  + -0.1 * (Y(5) @ Z(6) @ Y(7))
  + -0.1 * (X(5) @ Z(6) @ X(7))
  + -0.075 * Z(1)
  + -0.075 * Z(0)
  + 0.075 * (Z(0) @ Z(1))
  + -0.075 * Z(3)
  + -0.075 * Z(2)
  + 0.075 * (Z(2) @ Z(3))
  + -0.075 * Z(5)
  + -0.075 * Z(4)
  + 0.075 * (Z(4) @ Z(5))
  + -0.075 * Z(7)
  + -0.075 * Z(6)
  + 0.075 * (Z(6) @ Z(7))
)
```

Let’s also visualize the square lattice we created. To do that, we need to
create a simple plotting function, as well as the helper function
[`generate_lattice()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.spin.generate_lattice.html#pennylane.spin.generate_lattice "(in PennyLane v0.45)"), which you will learn more about in the next sections.

```python
import matplotlib.pyplot as plt

def plot(lattice, figsize=None, showlabel=True):

    # initialize the plot
    if not figsize:
        figsize = lattice.n_cells[::-1]

    plt.figure(figsize=figsize)

    # get lattice nodes and edges and plot them
    nodes = lattice.lattice_points

    for edge in lattice.edges:
        start_index, end_index, color = edge
        start_pos, end_pos = nodes[start_index], nodes[end_index]

        x_axis = [start_pos[0], end_pos[0]]
        y_axis = [start_pos[1], end_pos[1]]
        plt.plot(x_axis, y_axis, color='gold')

        plt.scatter(nodes[:,0], nodes[:,1], color='dodgerblue', s=100)

        if showlabel:
            for index, pos in enumerate(nodes):
                plt.text(pos[0]-0.2, pos[1]+0.1, str(index), color='gray')

    plt.axis("off")
    plt.show()

lattice = qp.spin.generate_lattice('square', n_cells)
plot(lattice)
```

We currently support the following in-built lattice shapes: `chain`, `square`,
`rectangle`, `triangle`, `honeycomb`, `kagome`, `lieb`, `cubic`, `bcc`, `fcc`
and `diamond`. More details are provided
[here](https://docs.pennylane.ai/en/latest/code/api/pennylane.spin.generate_lattice.html).

### Heisenberg model

The [Heisenberg model Hamiltonian](https://docs.pennylane.ai/en/latest/code/api/pennylane.spin.heisenberg.html)
is defined as

\[H = J\sum\_{ < i, j >}(\sigma\_i ^ x\sigma\_j ^ x + \sigma\_i ^ y\sigma\_j ^ y + \sigma\_i ^ z\sigma\_j ^ z),\]

where \(J\) is the coupling constant and \(\sigma\) is a Pauli operator. The Hamiltonian
can be constructed on a `triangle` lattice as follows.

```python
coupling = [0.5, 0.5, 0.5]
hamiltonian = qp.spin.heisenberg('triangle', n_cells, coupling)

lattice = qp.spin.generate_lattice('triangle', n_cells)
plot(lattice)
```

### Transverse-field Ising model

The [transverse-field Ising model (TFIM) Hamiltonian](https://docs.pennylane.ai/en/latest/code/api/pennylane.spin.transverse_ising.html)
is defined as

\[H = -J \sum\_{<i,j>} \sigma\_i^{z} \sigma\_j^{z} - h\sum\_{i} \sigma\_{i}^{x},\]

where \(J\) is the coupling constant, \(h\) is the strength of the transverse magnetic
field and \(\sigma\) is a Pauli operator. The Hamiltonian can be constructed on the
`honeycomb` lattice as follows.

```python
coupling, h = 0.5, 1.0
hamiltonian = qp.spin.transverse_ising('honeycomb', n_cells, coupling, h)

lattice = qp.spin.generate_lattice('honeycomb', n_cells)
plot(lattice)
```

### Kitaev’s honeycomb model

The [Kitaev honeycomb model Hamiltonian](https://docs.pennylane.ai/en/latest/code/api/pennylane.spin.kitaev.html)
is defined on the honeycomb lattice, as

\[H = K\_X \sum\_{\langle i,j \rangle \in X}\sigma\_i^x\sigma\_j^x +
\:\: K\_Y \sum\_{\langle i,j \rangle \in Y}\sigma\_i^y\sigma\_j^y +
\:\: K\_Z \sum\_{\langle i,j \rangle \in Z}\sigma\_i^z\sigma\_j^z,\]

where \(\sigma\) is a Pauli operator and the parameters \(K\_X\), \(K\_Y\), \(K\_Z\)
are the coupling constants in each direction. The Hamiltonian can be constructed as follows.

```python
coupling = [0.5, 0.6, 0.7]
hamiltonian = qp.spin.kitaev(n_cells, coupling)
```

### Haldane model

The [Haldane model Hamiltonian](https://docs.pennylane.ai/en/latest/code/api/pennylane.spin.haldane.html)
is defined as

\[H = - t^{1} \sum\_{\langle i,j \rangle, \sigma}
c\_{i\sigma}^\dagger c\_{j\sigma}
- t^{2} \sum\_{\langle\langle i,j \rangle\rangle, \sigma}
\left( e^{i\phi} c\_{i\sigma}^\dagger c\_{j\sigma} + e^{-i\phi} c\_{j\sigma}^\dagger c\_{i\sigma} \right),\]

where \(t^{1}\) is the hopping amplitude between neighbouring sites
\(\langle i,j \rangle\), \(t^{2}\) is the hopping amplitude between next-nearest neighbour
sites \(\langle \langle i,j \rangle \rangle\), \(\phi\) is the phase factor that breaks
time-reversal symmetry in the system, and \(\sigma\) is the spin degree of freedom. This
function assumes two fermions with opposite spins on each lattice site. The Hamiltonian can be
constructed on the `kagome` lattice using the following code.

```python
hopping = 0.5
hopping_next = 1.0
phi = 0.1
hamiltonian = qp.spin.haldane('kagome', n_cells, hopping, hopping_next, phi)

lattice = qp.spin.generate_lattice('kagome', n_cells)
plot(lattice)
```

### Emery model

The [Emery model Hamiltonian](https://docs.pennylane.ai/en/latest/code/api/pennylane.spin.emery.html)
is defined as

\[H = - t \sum\_{\langle i,j \rangle, \sigma} c\_{i\sigma}^{\dagger}c\_{j\sigma}
+ U \sum\_{i} n\_{i \uparrow} n\_{i\downarrow} + V \sum\_{<i,j>} (n\_{i \uparrow} +
n\_{i \downarrow})(n\_{j \uparrow} + n\_{j \downarrow})\ ,\]

where \(t\) is the hopping term representing the kinetic energy of electrons,
\(U\) is the on-site Coulomb interaction representing the repulsion between electrons,
\(V\) is the intersite coupling,
\(\sigma\) is the spin degree of freedom, and \(n\_{k \uparrow}\), \(n\_{k \downarrow}\)
are number operators for spin-up and spin-down fermions at site \(k\). This function assumes
two fermions with opposite spins on each lattice site. The Hamiltonian can be
constructed on the `lieb` lattice as follows.

```python
hopping = 0.5
coulomb = 1.0
intersite_coupling = 0.2
hamiltonian = qp.spin.emery('lieb', n_cells, hopping, coulomb, intersite_coupling)

lattice = qp.spin.generate_lattice('lieb', n_cells)
plot(lattice)
```

## Building Hamiltonians manually

The Hamiltonian template functions are great and simple tools for someone who just wants to build
a Hamiltonian quickly. PennyLane also offers tools for building customized Hamiltonians. Let’s learn
how to use these tools by constructing the Hamiltonian for the
[transverse-field Ising model](https://docs.pennylane.ai/en/latest/code/api/pennylane.spin.transverse_ising.html)
on a two-dimensional lattice.

The Hamiltonian is represented as:

\[H = -J \sum\_{\left< i,j \right>} \sigma\_i^{z} \sigma\_j^{z} - h\sum\_{i} \sigma\_{i}^{x},\]

where \(J\) is the coupling defined for the Hamiltonian, \(h\) is the strength of
transverse magnetic field, and \(\left< i,j \right>\) represents the indices of neighbouring
spins.

Our approach for doing this is to construct a lattice that represents the spin sites and their
connectivity. This is done by using the [`Lattice`](https://docs.pennylane.ai/en/stable/code/api/pennylane.spin.Lattice.html#pennylane.spin.Lattice "(in PennyLane v0.45)") class, which can be
constructed either by calling the helper function [`generate_lattice()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.spin.generate_lattice.html#pennylane.spin.generate_lattice "(in PennyLane v0.45)") or by
manually constructing the object. Let’s see examples of both methods. First we use
[`generate_lattice()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.spin.generate_lattice.html#pennylane.spin.generate_lattice "(in PennyLane v0.45)") to construct a square lattice containing
\(3 \times 3 = 9\) cells. Because each cell of the `square` lattice contains only one
site, we get \(9\) sites in total, which are all connected to their nearest neighbor.

```python
lattice = qp.spin.generate_lattice('square', [3, 3])
```

To visualize this lattice, we use the plotting function we created before.

```python
plot(lattice)
```

Now, we construct a lattice manually by explicitly defining the positions of the sites in a
unit cell, the primitive translation vectors defining the lattice and the number of cells in each
direction [[1]](#ashcroft). Recall that a unit cell is the smallest repeating unit of a lattice.

Let’s create a square-octagon [[2]](#jovanovic) lattice manually. Our lattice
can be constructed in a two-dimensional Cartesian coordinate system with two primitive
translation vectors defined as unit vectors along the \(x\) and \(y\) directions, and four
lattice point located inside the unit cell. We also assume that the lattice has three unit cells
along each direction.

```python
from pennylane.spin import Lattice

positions = [[0.2, 0.5], [0.5, 0.2],
             [0.5, 0.8], [0.8, 0.5]] # coordinates of sites
vectors = [[1, 0], [0, 1]] # primitive translation vectors
n_cells = [3, 3] # number of unit cells in each direction

lattice = Lattice(n_cells, vectors, positions, neighbour_order=2)

plot(lattice, figsize = (5, 5), showlabel=False)
```

Constructing the lattice manually is more flexible, while [`generate_lattice()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.spin.generate_lattice.html#pennylane.spin.generate_lattice "(in PennyLane v0.45)")
only works for some
[predefined lattice shapes](https://docs.pennylane.ai/en/latest/code/api/pennylane.spin.generate_lattice.html#lattice-details).

Now that we have the lattice, we can use its attributes, e.g., edges and vertices, to construct
our transverse-field Ising model Hamiltonian. For instance, we can access the number of sites
with `lattice.n_sites` and the indices that define each edge with `lattice.edges_indices`. For
the full list of attributes, please see the documentation of the [`Lattice`](https://docs.pennylane.ai/en/stable/code/api/pennylane.spin.Lattice.html#pennylane.spin.Lattice "(in PennyLane v0.45)")
class. We also need to define the coupling, \(J\), and onsite parameters of the
Hamiltonian, \(h\).

```python
from pennylane import X, Y, Z

coupling, onsite = 0.25, 0.75

hamiltonian = 0.0
# add the one-site terms
for vertex in range(lattice.n_sites):
    hamiltonian += -onsite * X(vertex)

# add the coupling terms
for edge in lattice.edges_indices:
    i, j = edge[0], edge[1]
    hamiltonian += - coupling * (Z(i) @ Z(j))

hamiltonian
```

```python
(
    -0.75 * X(0)
  + -0.75 * X(1)
  + -0.75 * X(2)
  + -0.75 * X(3)
  + -0.75 * X(4)
  + -0.75 * X(5)
  + -0.75 * X(6)
  + -0.75 * X(7)
  + -0.75 * X(8)
  + -0.75 * X(9)
  + -0.75 * X(10)
  + -0.75 * X(11)
  + -0.75 * X(12)
  + -0.75 * X(13)
  + -0.75 * X(14)
  + -0.75 * X(15)
  + -0.75 * X(16)
  + -0.75 * X(17)
  + -0.75 * X(18)
  + -0.75 * X(19)
  + -0.75 * X(20)
  + -0.75 * X(21)
  + -0.75 * X(22)
  + -0.75 * X(23)
  + -0.75 * X(24)
  + -0.75 * X(25)
  + -0.75 * X(26)
  + -0.75 * X(27)
  + -0.75 * X(28)
  + -0.75 * X(29)
  + -0.75 * X(30)
  + -0.75 * X(31)
  + -0.75 * X(32)
  + -0.75 * X(33)
  + -0.75 * X(34)
  + -0.75 * X(35)
  + -0.25 * (Z(2) @ Z(5))
  + -0.25 * (Z(3) @ Z(12))
  + -0.25 * (Z(6) @ Z(9))
  + -0.25 * (Z(7) @ Z(16))
  + -0.25 * (Z(11) @ Z(20))
  + -0.25 * (Z(14) @ Z(17))
  + -0.25 * (Z(15) @ Z(24))
  + -0.25 * (Z(18) @ Z(21))
  + -0.25 * (Z(19) @ Z(28))
  + -0.25 * (Z(23) @ Z(32))
  + -0.25 * (Z(26) @ Z(29))
  + -0.25 * (Z(30) @ Z(33))
  + -0.25 * (Z(0) @ Z(1))
  + -0.25 * (Z(0) @ Z(2))
  + -0.25 * (Z(1) @ Z(3))
  + -0.25 * (Z(2) @ Z(3))
  + -0.25 * (Z(4) @ Z(5))
  + -0.25 * (Z(4) @ Z(6))
  + -0.25 * (Z(5) @ Z(7))
  + -0.25 * (Z(6) @ Z(7))
  + -0.25 * (Z(8) @ Z(9))
  + -0.25 * (Z(8) @ Z(10))
  + -0.25 * (Z(9) @ Z(11))
  + -0.25 * (Z(10) @ Z(11))
  + -0.25 * (Z(12) @ Z(13))
  + -0.25 * (Z(12) @ Z(14))
  + -0.25 * (Z(13) @ Z(15))
  + -0.25 * (Z(14) @ Z(15))
  + -0.25 * (Z(16) @ Z(17))
  + -0.25 * (Z(16) @ Z(18))
  + -0.25 * (Z(17) @ Z(19))
  + -0.25 * (Z(18) @ Z(19))
  + -0.25 * (Z(20) @ Z(21))
  + -0.25 * (Z(20) @ Z(22))
  + -0.25 * (Z(21) @ Z(23))
  + -0.25 * (Z(22) @ Z(23))
  + -0.25 * (Z(24) @ Z(25))
  + -0.25 * (Z(24) @ Z(26))
  + -0.25 * (Z(25) @ Z(27))
  + -0.25 * (Z(26) @ Z(27))
  + -0.25 * (Z(28) @ Z(29))
  + -0.25 * (Z(28) @ Z(30))
  + -0.25 * (Z(29) @ Z(31))
  + -0.25 * (Z(30) @ Z(31))
  + -0.25 * (Z(32) @ Z(33))
  + -0.25 * (Z(32) @ Z(34))
  + -0.25 * (Z(33) @ Z(35))
  + -0.25 * (Z(34) @ Z(35))
)
```

In this example, we just used the built-in attributes of our custom lattice without further
customising them. The lattice can be constructed in a more flexible way that allows us to build
fully general spin Hamiltonians. Let’s look at an example.

## Building anisotropic Hamiltonians

Now we work on a more complicated Hamiltonian. We construct the anisotropic square-trigonal
[[2]](#jovanovic) model, where the coupling parameters
depend on the orientation of the bonds. We can construct the Hamiltonian by building the
lattice manually and adding custom edges between the nodes. For instance, to define a custom
`XX` edge with the coupling constant \(0.5\) between nodes 0 and 1, we use the following.

```python
custom_edge = [(0, 1), ('XX', 0.5)]
```

Let’s now build our Hamiltonian. We first define the unit cell by specifying the positions of the
nodes and the translation vectors and then define the number of unit cells in each
direction [[2]](#jovanovic).

```python
positions = [[0.1830, 0.3169],
             [0.3169, 0.8169],
             [0.6830, 0.1830],
             [0.8169, 0.6830]]

vectors = [[1, 0], [0, 1]]

n_cells = [3, 3]
```

Let’s plot the lattice to see what it looks like.

```python
plot(Lattice(n_cells, vectors, positions), figsize=(5, 5))
```

Now we add custom edges to the lattice. In our example, we define four types of custom
edges: the first type is the one that connects node 0 to 1, the second type is defined to connect
node 0 to 2, and the third and fourth types connect node 1 to 3 and 2 to 3, respectively. Note that
this is an arbitrary selection. You can define any type of custom edge you would like.

```python
custom_edges = [[(0, 1), ('XX', 0.5)],
                [(0, 2), ('YY', 0.6)],
                [(1, 3), ('ZZ', 0.7)],
                [(2, 3), ('ZZ', 0.7)]]

lattice = Lattice(n_cells, vectors, positions, custom_edges=custom_edges)
```

Let’s print the lattice edges and check that our custom edge types are set correctly.

```python
print(lattice.edges)
```

```python
[(0, 1, ('XX', 0.5)), (4, 5, ('XX', 0.5)), (8, 9, ('XX', 0.5)), (12, 13, ('XX', 0.5)), (16, 17, ('XX', 0.5)), (20, 21, ('XX', 0.5)), (24, 25, ('XX', 0.5)), (28, 29, ('XX', 0.5)), (32, 33, ('XX', 0.5)), (0, 2, ('YY', 0.6)), (4, 6, ('YY', 0.6)), (8, 10, ('YY', 0.6)), (12, 14, ('YY', 0.6)), (16, 18, ('YY', 0.6)), (20, 22, ('YY', 0.6)), (24, 26, ('YY', 0.6)), (28, 30, ('YY', 0.6)), (32, 34, ('YY', 0.6)), (1, 3, ('ZZ', 0.7)), (5, 7, ('ZZ', 0.7)), (9, 11, ('ZZ', 0.7)), (13, 15, ('ZZ', 0.7)), (17, 19, ('ZZ', 0.7)), (21, 23, ('ZZ', 0.7)), (25, 27, ('ZZ', 0.7)), (29, 31, ('ZZ', 0.7)), (33, 35, ('ZZ', 0.7)), (2, 3, ('ZZ', 0.7)), (6, 7, ('ZZ', 0.7)), (10, 11, ('ZZ', 0.7)), (14, 15, ('ZZ', 0.7)), (18, 19, ('ZZ', 0.7)), (22, 23, ('ZZ', 0.7)), (26, 27, ('ZZ', 0.7)), (30, 31, ('ZZ', 0.7)), (34, 35, ('ZZ', 0.7))]
```

You can compare these edges with the lattice plotted above and verify the correct translation of
the edges over the entire lattice sites.

Now we pass the lattice object to the [`spin_hamiltonian()`](https://docs.pennylane.ai/en/stable/code/api/pennylane.spin.spin_hamiltonian.html#pennylane.spin.spin_hamiltonian "(in PennyLane v0.45)") function, which is
a helper function that constructs a Hamiltonian from a lattice object.

```python
hamiltonian = qp.spin.spin_hamiltonian(lattice=lattice)
```

Alternatively, you can build the Hamiltonian manually by looping over the custom edges
to build the Hamiltonian.

```python
opmap = {'X': X, 'Y': Y, 'Z': Z}

hamiltonian = 0.0
for edge in lattice.edges:
    i, j = edge[0], edge[1]
    k, l = edge[2][0][0], edge[2][0][1]
    hamiltonian += opmap[k](i) @ opmap[l](j) * edge[2][1]

hamiltonian
```

```python
(
    0.5 * (X(0) @ X(1))
  + 0.5 * (X(4) @ X(5))
  + 0.5 * (X(8) @ X(9))
  + 0.5 * (X(12) @ X(13))
  + 0.5 * (X(16) @ X(17))
  + 0.5 * (X(20) @ X(21))
  + 0.5 * (X(24) @ X(25))
  + 0.5 * (X(28) @ X(29))
  + 0.5 * (X(32) @ X(33))
  + 0.6 * (Y(0) @ Y(2))
  + 0.6 * (Y(4) @ Y(6))
  + 0.6 * (Y(8) @ Y(10))
  + 0.6 * (Y(12) @ Y(14))
  + 0.6 * (Y(16) @ Y(18))
  + 0.6 * (Y(20) @ Y(22))
  + 0.6 * (Y(24) @ Y(26))
  + 0.6 * (Y(28) @ Y(30))
  + 0.6 * (Y(32) @ Y(34))
  + 0.7 * (Z(1) @ Z(3))
  + 0.7 * (Z(5) @ Z(7))
  + 0.7 * (Z(9) @ Z(11))
  + 0.7 * (Z(13) @ Z(15))
  + 0.7 * (Z(17) @ Z(19))
  + 0.7 * (Z(21) @ Z(23))
  + 0.7 * (Z(25) @ Z(27))
  + 0.7 * (Z(29) @ Z(31))
  + 0.7 * (Z(33) @ Z(35))
  + 0.7 * (Z(2) @ Z(3))
  + 0.7 * (Z(6) @ Z(7))
  + 0.7 * (Z(10) @ Z(11))
  + 0.7 * (Z(14) @ Z(15))
  + 0.7 * (Z(18) @ Z(19))
  + 0.7 * (Z(22) @ Z(23))
  + 0.7 * (Z(26) @ Z(27))
  + 0.7 * (Z(30) @ Z(31))
  + 0.7 * (Z(34) @ Z(35))
)
```

You can see that it is easy and intuitive to construct this anisotropic Hamiltonian with the tools
available in the [qp.spin](https://docs.pennylane.ai/en/stable/code/qp_spin.html "(in PennyLane v0.45)") module. You can
use these tools to construct custom Hamiltonians for other interesting systems.

## Conclusion

The [qp.spin module](https://docs.pennylane.ai/en/stable/code/qp_spin.html "(in PennyLane v0.45)") in PennyLane provides
a set of powerful tools for constructing spin Hamiltonians.
Here we learned how to use these tools to construct predefined Hamiltonian templates such as the
Fermi–Hubbard Hamiltonian. This can be done with our built-in functions that currently support
several commonly used spin models and a variety of lattice shapes. More importantly, PennyLane
provides easy-to-use function to manually build spin Hamiltonians on customized lattice structures
with anisotropic interactions between the sites. This can be done intuitively using the
[`Lattice`](https://docs.pennylane.ai/en/stable/code/api/pennylane.spin.Lattice.html#pennylane.spin.Lattice "(in PennyLane v0.45)") object and provided helper functions. The versatility of the new
spin functionality allows you to construct any new spin Hamiltonian quickly and intuitively.

## References

[[1](#id1)]

N. W. Ashcroft, D. N. Mermin,
“Solid State Physics”, Chapter 4, New York: Saunders College Publishing, 1976.

[2]
([1](#id2),[2](#id3),[3](#id4))

D. Jovanovic, R. Gajic, K. Hingerl,
“Refraction and band isotropy in 2D square-like Archimedean photonic crystal lattices”,
Opt. Express 16, 4048, 2008.

## About the authors

[Diksha Dhawan](https://pennylane.ai/profile/ddhawan)

Developing Tools to Simulate Chemistry Using Quantum Computers

[Soran Jahangiri](https://pennylane.ai/profile/soran)

I am a quantum scientist and software developer working at Xanadu. My work is focused on developing and implementing quantum algorithms in PennyLane.

**Total running time of the script:** (0 minutes 2.345 seconds)

Share demo

[Ask a question on the forum](https://discuss.pennylane.ai/c/demos/25)

### Related Demos

[Building molecular Hamiltonians](https://pennylane.ai/qml/demos/tutorial_quantum_chemistry)

[Fermionic operators](https://pennylane.ai/qml/demos/tutorial_fermionic_operators)

[3-qubit Ising model in PyTorch](https://pennylane.ai/qml/demos/tutorial_isingmodel_PyTorch)

[Density matrix embedding theory](https://pennylane.ai/qml/demos/tutorial_dmet_embedding)

[Resource estimation for quantum chemistry](https://pennylane.ai/qml/demos/tutorial_resource_estimation)

[Quantum defect embedding theory](https://pennylane.ai/qml/demos/tutorial_qdet_embedding)

[Intro to QAOA](https://pennylane.ai/qml/demos/tutorial_qaoa_intro)

[Seeing quantum phase transitions with quantum computers](https://pennylane.ai/qml/demos/tutorial_quantum_phase_transitions)

[How to use noise models in PennyLane](https://pennylane.ai/qml/demos/tutorial_how_to_use_noise_models)

[Error mitigation with Mitiq and PennyLane](https://pennylane.ai/qml/demos/tutorial_error_mitigation)
