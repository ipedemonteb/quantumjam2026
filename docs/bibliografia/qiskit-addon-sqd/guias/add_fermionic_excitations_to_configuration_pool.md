# Add fermionic transitions to the pool of configurations

> Fuente: <https://github.com/Qiskit/qiskit-addon-sqd/blob/main/docs/guides/add_fermionic_excitations_to_configuration_pool.ipynb>

Here we demonstrate the functionalities to augment the pool of electronic
configurations obtained by the action of transition operators on each electronic 
configuration.

We demonstrate how to add single-electron hops of the type:
$$
c^\dagger_{p\sigma} c_{q\sigma} |\textbf{x} \rangle
$$
for $p, q = 1, ..., N_\textrm{orb}$ and $\sigma \in \{ \uparrow, \downarrow\}$,
and for all $|\textbf{x} \rangle$ in the batch of electronic configurations.

We start by generating a batch of random electronic configurations:

The excitation operators are specified inside a numpy array whose length is
equal to the number of fermionic nodes (or qubits). Each element of the array
must be a string that can take values:

- ``'I'``: Identity
- ``'+'``: Creation operator
- ``'-'``: Annihilation operator

We generate all possible single-electron transitions (amongst same spin 
species).

Now we apply the transition operators to the configurations in ``bitstring_matrix``:
