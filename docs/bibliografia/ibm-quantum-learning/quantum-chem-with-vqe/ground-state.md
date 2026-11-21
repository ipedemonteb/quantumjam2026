# Bringing it all together with IBM Quantum Compute Service

> Fuente: <https://quantum.cloud.ibm.com/learning/en/courses/quantum-chem-with-vqe/ground-state>

> Solo las celdas de texto del notebook original; sin código.


## Summary

Victoria Lipinska gives a final recap of what we have learned so far.

### References
The following articles are referenced in the above video.
* [Quantum Chemistry in the Age of Quantum Computing, Cao, et al](https://arxiv.org/pdf/1812.09976.pdf).
* [Quantum computational chemistry, McArdle, et al](https://arxiv.org/pdf/1808.10402.pdf).

## VQE with Qiskit patterns

We have all the necessary components for a VQE calculation:

* Hamiltonian
* Ansatz
* Classical optimizer

Now we just have to bring them together in the Qiskit patterns framework.

## Step 1: Map classical inputs to a quantum problem

As stated previously, we will assume here that a suitably formatted Hamiltonian of interest has already been generated. If you have questions about that, see the [lesson on Hamiltonians](https://quantum.cloud.ibm.com/learning/courses/quantum-chem-with-vqe/hamiltonian-construction) for guidance. The code block below sets up the components explained in previous lessons. Here we have chosen to model H2 because its Hamiltonian is compact enough to write out.

We select an efficient_su2 circuit, and the optimizer COBYLA, to start.

Now we construct our cost function. This is obviously related to the Hamiltonian, but differs in that the Hamiltonian is an operator, and we want a function that returns the expectation value of that operator, using Estimator. Of course, it accomplishes this by using the ansatz and the variational parameters, so all these show up as arguments. Below, we define slightly different versions for use on real hardware or simulators.

## Step 2: Optimize problem for quantum execution.

We want our code to run as efficiently as possible on the hardware we use. So we must select a backend to begin the optimization step. The code below selects the least busy backend available to you.

Optimizing the circuit for running on a real backend is a rich and critical topic. But it is not specific to VQE. For now, we will simply remind you of two important terms:

* **[optimization\_level](https://quantum.cloud.ibm.com/docs/api/qiskit/transpiler#preset-pass-managers)**: This describes how well the circuit is tailored to the layout of the backend selected. The lowest optimization level just does the bare minimum needed to get the circuit running on the device; it maps the circuit qubits to the device qubits and adds swap gates to allow all two-qubit operations. The highest optimization level is much smarter and uses lots of tricks to reduce the overall gate count. Since multi-qubit gates have high error rates and qubits decohere over time, the shorter circuits should give better results.
* **[Dynamical Decoupling](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.transpiler.passes.PadDynamicalDecoupling)**: We can apply a sequence of gates to idling qubits. This cancels out some unwanted interactions with the environment.
  Consult the linked documentation for more information on optimizing circuits. The code below generates a mass manager using preset pass managers from `qiskit.transpiler`.

We must similarly apply device layout characteristics to the Hamiltonian.

## Step 3: Execute using IBM Quantum primitives.

Before we execute on the selected hardware, it is a good idea to use a simulator for cursory debugging, and sometimes for estimates of error. For those reasons, we briefly show how to run VQE on a simulator. But it is critical to note that **no classical computer, simulator, or GPU** can accurately simulate the full functionality of a highly-entangled 127-qubit quantum computer. In the present era of quantum utility, simulators will have limited use.

Recall that for each choice of parameters in the variational circuit, an expectation value must be calculated (since that is the value to be minimized). As you may have already guessed, the most efficient way to do that is using the Qiskit SDK primitive, Estimator. We'll start by using a local simulator, which will require that we use the local version of Estimator called BackendEstimator.

Keeping the real backend we used for optimization, we can import a model of the noise behavior of that device to then use with the local simulator of our choice. Here, we will use the aer_simulator_statevector.

It is finally time to implement VQE, minimizing the cost function using the selected Hamiltonian, ansatz, classical optimizer, and our BackendEstimator, based on the real backend we selected for subsequent use. Note that here we have chosen a relatively small number for the maximum iterations. This is because we are merely using the simulator to debug. VQE optimization steps often require hundreds of iterations to converge.

This code evaluated correctly, though it did not converge, which we expected. We will proceed running the calculation on real hardware, and then discuss the outputs. For real backends, we will use the IBM Quantum Estimator. We will want to execute this inside a batch and we will generally want to specify options for that batch.

Among other things, using a batch means our job will only wait in the queue once, to begin. Subsequent iterations of the classical optimizer will not be queued. In the batch, we can set resilience and optimization levels. These tools are important enough that we include a brief review of each and their importance in VQE, with links to learn more:

* Batch: VQE is inherently iterative, with the classical optimizer selecting new variational parameters, and thus new gates being used, in each subsequent trial. Without using a batch, this could result in additional queue time between each trial circuit. Encapsulating the VQE calculation inside a batch results in only one initial queue prior to the job's start, but no additional queue time between variational steps. This strategy was already used in the previous lesson's example, but may play an even more important role when varying geometry. For more about batches and other execution modes, review the  [execution modes documentation](https://quantum.cloud.ibm.com/docs/ibm-quantum-compute/execution-modes).
* Estimator's built-in optimization: In Estimator there are built-in options for optimizing a calculation. In many contexts (Estimator included), settings are limited to 0 and 1, with 0 indicating no optimization, and 1 (the default) indicating some optimization of your circuit to hardware selected. Some other contexts allow settings of  0, 1, 2, or 3. For more on the specific methods used in different settings, see the [documentation](https://quantum.cloud.ibm.com/docs/api/qiskit-ibm-runtime/options-models-estimator-options). Here, we will actually set optimization to 0, and use 'skip\_transpilation = true', because we have already transpiled our circuit using the pass manager above, in the optimization section.
* Estimator's built-in resilience: As with optimization, Estimator has built-in settings for resilience against errors, corresponding to different approaches to error mitigation. To learn about resilience level settings, refer to the  [documentation](https://quantum.cloud.ibm.com/docs/guides/error-mitigation-and-suppression-techniques).

It is worth noting that error mitigation plays a nuanced role in the convergence of a VQE calculation. The classical optimizer is searching parameter space for those parameters that minimize the energy. When you are very far from the optimal parameters, a steep gradient may be apparent to the classical optimizer even in the presence of errors. But as the calculation converges and you approach the optimal values, the gradient becomes smaller, and more easily washed out by errors. How much error mitigation do you want to use? At what points in the convergence? These are choices you must make for your particular use case.

For this first hardware run, we have set resilience to 0 to facilitate a relatively fast run. For any serious application, you will want to use error mitigation. Note that in the cell below there are two sets of options: (1) options for the estimator, which we have named "estimator\_options", and (2) options for the classical optimizer, simply called "options" here.

You can view the progress of your job on the IBM Quantum&reg; Platform under [Workloads](https://quantum.cloud.ibm.com/workloads).

## Step 4: Post-process, return result in classical format.

Let's take a moment to ensure we understand these outputs. The "**fun**" output is the **minimum** value we obtained for the cost function (not necessarily the last value calculated). This is the total energy, including the positive nuclear repulsion, which is why we also defined electron\_energy.

In the case above, we have a message that the maximum number of function evaluations was exceeded, and that the number of function evaluations (**nfev**) was 10. This simply means that other criteria for convergence of the optimization were not met; in other words, there is no reason to think we found the ground state energy. This is also the meaning of **success** being "False".

Finally, we have **x**. This is the vector of variational parameters. These are the parameters used in the calculation that yielded the minimum cost function (energy expectation value). These eight values correspond to the eight rotation angles in those gates in the ansatz that take variable rotation angles.

Congratulations! You have run a VQE calculation on an IBM Quantum QPU!

In the next lesson, we will see how to adjust this workstream to include variables in your Hamiltonian. In the context of quantum chemistry problems, this might mean varying geometry to determine shapes of molecules or binding sites.
