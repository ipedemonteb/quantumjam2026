# Determining a molecular geometry

> Fuente: <https://quantum.cloud.ibm.com/learning/en/courses/quantum-chem-with-vqe/geometry>

> Solo las celdas de texto del notebook original; sin código.


In the previous section, we implemented VQE to determine the ground state energy of a molecule. That is a valid use of quantum computing, but even more useful would be to determine the structure of a molecule.

## Step 1: Map classical inputs to a quantum problem

Remaining with our basic example of diatomic hydrogen, the only geometric parameter to vary is the bond length. To accomplish this, we proceed as before, but using a variable in our initial molecule construction (a bond length, *x*, in the argument). This is a fairly simple change, but it does require that the variable be included in functions throughout the process, since it starts in the fermionic Hamiltonian construction and propagates through the mapping and finally to the cost function.

First, we load some of the packages we used before and define the Cholesky function.

Now to define our Hamiltonian, we will use PySCF exactly as in the previous example, but now we will include a variable, `x`, to play the role of our interatomic distance. This will return the core energy, single-electron energy, and two-electron energies as before.

Recall that the construction above is making a fermionic Hamiltonian based on the atomic species, geometry, and electronic orbitals. Below, we map this fermionic Hamiltonian onto Pauli operators. This `build_hamiltonian` function will also include a geometric variable as an argument.

We will load the remaining packages for running VQE itself, such as the efficient_su2 ansatz, and SciPy minimizers:

We will again define the cost function, but this always took a fully-built and mapped Hamiltonian as an argument, so nothing changes about this function.

## Step 2: Optimize problem for quantum execution

Because the Hamiltonian will change with each new geometry, the transpiling of the operator will change at each step. We can nevertheless define a general pass manager to be applied at each step, specific to the hardware we want to use.

Here we will use the least busy backend available. We will use that backend as a model for our AerSimulator, allowing our simulator to mimic, for example, the noise behavior of the real backend. These noise models are not perfect, but they may help you know what to expect from real hardware.

We import the pass manager and related packages to help us optimize our circuit. This step, and the one above it, are independent of the Hamiltonian, and so are unchanged from the previous lesson.

## Step 3: Execute using IBM Quantum primitives.

In the code block below, we set up an array to store our outputs from each step in our interatomic distance $x$. We have chosen the range of $x$ based on our knowledge of the experimental value for the equilibrium bond length: 0.74 Angstrom. We will run this first on a simulator, and will thus be importing our Estimator (BackendEstimator) from `qiskit.primitives`. For each geometry step, we build the Hamiltonian and allow a certain number of optimization steps (here 500) using the optimizer "cobyla". At each geometry step, we store both the total energy and the electronic energy. Because of the high number of optimizer steps, this may take an hour or more. You may wish to modify the inputs below to reduce the required time.

The results of this output are discussed below in the post-processing section; for now, simply note that the simulation was successful. Now you are ready to run on real hardware. We will set the resilience to `1`, indicating that TREX error mitigation will be used. Now that we are working with real hardware, we will use IBM Quantum Compute Service and IBM Quantum primitives. Note that both the for loop related to geometry and also the multiple variational trials are inside the session.

Because there are costs and time limits associated with real hardware runs, we have reduced the number of geometry steps and optimizer steps below. Be sure to tailor these steps according to your precision goals and time limits.

## Step 4: Post-processing

For both the simulator and real hardware, we can plot the ground state energies calculated for each inter-atomic distance and see where the lowest energy is achieved. That should be the inter-atomic distance found in nature, and indeed it is close. A smoother curve might be obtained by trying other ansaetze, optimizers, and running the calculation multiple times at each geometry step and averaging over several random initial conditions.

Note that simply increasing the number of optimization steps is not likely to improve the results from the simulator, since all optimizations actually converged to the required tolerance in fewer than the maximum number of iterations.

The results from the real hardware are comparable, aside from a slightly different range of values sampled.

In addition to expecting an H2 bond length of 0.74 Angstrom, the total energy should be -1.17 Hartrees. We see that the real hardware results came closer to these values than the simulator. This is likely because noise was present (or simulated) in both cases, but only in the case of real hardware was error mitigation employed.

### Closing

This concludes our course on VQE for quantum chemistry. If you are interested in understanding some of the underlying information theory used in quantum computing, check out John Watrous's course on the [Basics of Quantum Information](https://quantum.cloud.ibm.com/learning/courses/basics-of-quantum-information). For an additional short-form example of a VQE workflow, see our [Ground-state energy estimation of the Heisenberg chain with VQE tutorial](https://quantum.cloud.ibm.com/docs/tutorials/spin-chain-vqe). Or browse the [tutorials](https://quantum.cloud.ibm.com/docs/tutorials) and [courses](https://quantum.cloud.ibm.com/learning) to find more educational materials about the latest technology in quantum computing.

Don't forget to take this course's exam. A score of 80% or higher will earn you a Credly badge, which will automatically be emailed to you. Thank you for being a part of the IBM Quantum&reg; Network!
