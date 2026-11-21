# Benchmark Pauli operator projection

> Fuente: <https://github.com/Qiskit/documentation/tree/main/docs/addons/qiskit-addon-sqd/guides/benchmark-pauli-projection>

### Pauli string action on a computational basis state

The action of a Pauli string on a computational basis state is rather trivial, and is a single computational basis state itself. This is a direct consequence of the structure of Pauli matrices, which only have a single nonzero element on each of their rows. Consequently, their action on a qubit is:

-------------------------------------------

$$
\sigma_x |0 \rangle = |1 \rangle
$$

$$
\sigma_x |1 \rangle = |0 \rangle
$$

-------------------------------------------

$$
\sigma_y |0 \rangle = i|1 \rangle
$$

$$
\sigma_y |1 \rangle = -i|0 \rangle
$$

-------------------------------------------

$$
\sigma_z |0 \rangle = |0 \rangle
$$

$$
\sigma_z |1 \rangle = -|1 \rangle
$$

-------------------------------------------

$$
I |0 \rangle = |0 \rangle
$$

$$
I |1 \rangle = |1 \rangle
$$

-------------------------------------------

Each bit on the bitstring labeling the computational basis will be labeled by $x \in \{0, 1 \}$. In order to keep the implementation at light as possible, we will
represent the bitstrings with `bool` variables: $0\rightarrow \textrm{False}$ and
$1\rightarrow \textrm{True}$.

To represent the action of each Pauli operator in a computational basis state,
we will assign three variables to it: `diag`, `sign`, `imag`.

- `diag` labels whether the operator is diagonal:

    - $\textrm{diag}(I) = \textrm{True}$
    - $\textrm{diag}(\sigma_x) = \textrm{False}$
    - $\textrm{diag}(\sigma_y) = \textrm{False}$
    - $\textrm{diag}(\sigma_z) = \textrm{True}$

- `sign` Identifies if there is a sign change in the matrix element connected
to either 0 or 1:

    - $\textrm{sign}(I) = \textrm{False}$
    - $\textrm{sign}(\sigma_x) = \textrm{False}$
    - $\textrm{sign}(\sigma_y) = \textrm{True}$
    - $\textrm{sign}(\sigma_z) = \textrm{True}$

- `imag` Identifies if there is a complex component to the matrix element:

    - $\textrm{imag}(I) = \textrm{False}$
    - $\textrm{imag}(\sigma_x) = \textrm{False}$
    - $\textrm{imag}(\sigma_y) = \textrm{True}$
    - $\textrm{imag}(\sigma_z) = \textrm{False}$

We label an arbitrary Pauli operator as $\sigma \in \{ I, \sigma_x, \sigma_y
\sigma_z\}$. The action of the Pauli operator on a computational basis state
can then be represented by the logic operation:
$$
\sigma |x \rangle = |x == \textrm{diag}(\sigma) \rangle (-1)^{x\textrm{ and sign}(\sigma)}
(i)^{\textrm{imag}(\sigma)}.
$$
The same is straightforwardly generalized to arbitrary number of qubits.

Let's check that this works:

We generate some large number of bitstrings (50 M) for a 40-qubit system:

### Benchmark SQD Pauli projection functions

The Pauli string under consideration is $\sigma_z \otimes ... \otimes \sigma_z$.

Different subspace dimensions are considered by slicing the matrix of bitstrings. We time the subspace projection for the different subspace sizes.

We now do the same for 60 qubits:
