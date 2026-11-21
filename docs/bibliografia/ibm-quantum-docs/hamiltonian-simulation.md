# Simulación hamiltoniana

> Fuente: <https://quantum.cloud.ibm.com/docs/en/guides/hamiltonian-simulation>

> Documentación de IBM Quantum Platform (repositorio <https://github.com/Qiskit/documentation>).

# Hamiltonian simulation

Hamiltonian simulation is a quantum computing technique used to model and characterize quantum systems based on their energy and interactions. It has potential applications in drug discovery and chemistry, battery development, catalyst design, advanced materials, solar energy, and the study of complex physical phenomena such as superconductivity. 

By simulating molecular interactions and the behavior of electrons and atoms, Hamiltonian simulation can help researchers predict material properties, understand chemical reactions, and identify promising candidates for new technologies. Common approaches include Trotterization, which approximates continuous time evolution using sequences of quantum gates, and sample based quantum diagonalization, which estimates the energy spectrum for a given quantum system.

A typical workflow starts by mapping a physical system, such as a set of interacting fermions or bosons, onto qubits and circuits. From there, you can reduce the resulting circuit's depth and gate count with compilation and error-mitigation techniques, run the circuit on quantum hardware, and reconstruct the system's properties, such as its ground-state energy, from the measured samples. The tools on this page cover each of these stages, and the application functions listed here provides a single managed workflow for Hamiltonian simulation.

## Mapping tools
These capabilities specialize in mapping domain problems into quantum operators and circuits for execution on a quantum computer. Use them to represent fermionic, bosonic, or spin systems, and to compile the resulting circuits so that they run with less depth and fewer entangling gates on quantum hardware.
<CardGroup>

</CardGroup>

## Quantum subspace diagonalization tools
These tools provide capabilities for building workflows to estimate the eigenvalues of quantum Hamiltonians, like the ground state energy of a molecule, using approaches such as sample-based quantum diagonalization that can scale beyond exact classical diagonalization methods. These workflows use a quantum circuit to sample candidate configurations, then iteratively refine the configurations and diagonalize the system’s Hamiltonian in the reduced subspace spanned by those configurations.
<CardGroup>

</CardGroup>

## Workflow verification tools
These tools are used for verifying workflows through classical simulation. They can simulate certain classes of circuits more efficiently than a general-purpose quantum circuit simulator. You can use them to check a workflow, such as an excitation-preserving ansatz or fermionic circuit, against a classical reference result before running it on quantum hardware.
<CardGroup>

</CardGroup>

<span id="application-functions"></span>
## Application functions for Hamiltonian simulation

The following quantum function combines mapping, hardware execution, and classical post-processing into a single managed workflow for Hamiltonian simulation applications. Instead of assembling the mapping, diagonalization, and simulation tools yourself, you specify the model and run configurations, and the function executes an entire workflow for simulation.

<Admonition type="note" title="Notes">
IBM Quantum&reg; Functions are a beta feature available only to IBM Quantum Premium Plan, Flex Plan, and On-Prem (through the IBM Quantum Platform API) Plan users. Refer to [Set up IBM Quantum Functions](https://quantum.cloud.ibm.com/functions) for instructions on getting access.
</Admonition>

<CardGroup>

</CardGroup>
