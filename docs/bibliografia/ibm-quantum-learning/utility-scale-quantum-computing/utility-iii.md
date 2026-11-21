# Utility-scale experiment III

> Fuente: <https://quantum.cloud.ibm.com/learning/en/courses/utility-scale-quantum-computing/utility-iii>

> Solo las celdas de texto del notebook original; sin código.


<Admonition type="note">

Toshinari Itoko, Tamiya Onodera, Kifumi Numata (19 July 2024)

[Download the pdf](https://ibm.ent.box.com/public/static/fw1538dogvyv0qbfqg8tan1k2fs27mfv.zip) of the original lecture. Note that some code snippets might become deprecated since these are static images.

*Approximate QPU time to run this first experiment is 12 m 30 s. There is an additional experiment below that requires approximately 4 m.*

(Note: this notebook might not evaluate in the time allowed on the Open Plan. Be sure to use quantum computing resources wisely.)

</Admonition>

## 1. Introduction

Let us briefly review GHZ states, and what sort of distribution you might expect from ```Sampler``` applied to one. Then we will spell out the goal of this lesson explicitly.

###  1.1 GHZ state

The GHZ state (Greenberger-Horne-Zeilinger state) for $n$ qubits is defined as

$$
\frac{1}{\sqrt 2}(|0\rangle ^ {\otimes n}+ |1\rangle^ {\otimes n})
$$

Naturally, it can be created for 6 qubits with the following quantum circuit.

The depth is not too large, though you know from previous lessons that you can do better. Let's pick a backend and transpile this circuit.

Again the transpiled two-qubit depth is not too large. But to work with a GHZ state on more qubits, you will clearly need to think about optimizing the circuit. Let's run this using ```Sampler``` and see what a real quantum computer returns.

This is the result of the 6-qubit GHZ circuit. As you can see, the states of all $|0\rangle$'s and all $|1\rangle$'s do dominate, but the errors are substantial. Let's try to see how large a GHZ circuit you can make with an Eagle device, while still getting results where the correct states are at least more than 50% likely.

### 1.2 Your goal

Build a GHZ circuit for 20 qubits or more so that, upon measurement, **the fidelity of your GHZ state > 0.5.**
Note:
- You need to use an Eagle device (`min_num_qubits=127`) and set the shots number as 40,000.
- You should execute the GHZ circuit using the `execute_ghz_fidelity` function, and calculate the fidelity using the `check_ghz_fidelity_from_jobs` function.

This is intended as an independent exercise, in which you leverage what you have learned so far in this course.

In this notebook, we will apply three strategies to creating good GHZ states using 16 qubits and 30 qubits. These approaches build on strategies you already know from previous lessons.

## 2. Strategy 1. Noise-aware qubit selection

We first specify a backend. Because we will be working extensively with the properties of a specific backend, it is a good idea to specify one backend, as opposed to using the ```least_busy``` option.

We are going to build a circuit involving many two-qubit gates. It makes sense for us to use the qubits that have the lowest errors when implementing those two-qubit gates. Finding the best "qubit chain" based on the reported 2q-gate errors is a nontrivial problem. But we can define a few functions to help us determine the best qubits to use.

We will use the functions above to find all the simple paths of N qubits between all pairs of nodes in the graph (Reference: [all_pairs_all_simple_paths](https://www.rustworkx.org/apiref/rustworkx.all_pairs_all_simple_paths.html#rustworkx-all-pairs-all-simple-paths)).

Then, using the `path_fidelity` function created above, we will find the best qubit chain which has the largest path fidelity.

Let's plot the best qubit chain, shown in pink, in the coupling map diagram.

### 2.1 Build a GHZ circuit on the best qubit chain

We choose a qubit in the middle of the chain to first apply the H gate to. This should reduce the depth of the circuit by about half.

Be careful to execute the next cell after the above jobs statuses have become 'DONE', to show the result using the `check_ghz_fidelity_from_jobs` function.

This result does not meet the criteria. Let's move to the next idea.

## 3. Strategy 2. Balanced tree of qubits

The next idea is to find a balanced tree of qubits. Using the tree rather than the chain, the circuit depth should become lower. Before that, we remove nodes with "bad" readout errors and edges with "bad" gate errors from the coupling graph.

Let's draw the coupling map graph without the bad edges and bad qubits.

We try to create a 16-qubit GHZ state as before.

We call the `betweenness_centrality` function to find a qubit for the root node. The node with the highest value of betweenness centrality is at the center of the graph. Reference: https://www.rustworkx.org/tutorial/betweenness_centrality.html

Or you can select it manually.

Starting from the root node, generate a tree by breadth first search (BFS). Reference: https://qiskit.org/ecosystem/rustworkx/apiref/rustworkx.bfs_search.html#rustworkx-bfs-search

Let us plot the selected qubits, shown in pink, in the coupling map diagram.

Let us show the tree structure of qubits.

The depth of the circuit has now become much lower than that in the chain structure.

We have successfully passed the criteria with the balanced tree structure!

Now, let us try to create a larger GHZ state: a 30-qubit GHZ state.

### 3.1 N = 30

We will follow the [Qiskit patterns](https://quantum.cloud.ibm.com/docs/guides/intro-to-patterns) framework.

- Step 1: Map problem to quantum circuits and operators
- Step 2: Optimize for target hardware
- Step 3: Execute on target hardware
- Step 4: Post-process results

#### Step 1: Map problem to quantum circuits and operators and Step 2: Optimize for target hardware

Here we select the root node manually.

The depth of this tree is 5.

### 3.2 Select a different root node manually

The depth of this tree is 6.

Surprisingly, while the tree depth increased from 5 to 6, the two-qubit depth decreased from 9 to 8! So let us use the latter circuit.

#### Step 3: Execute on target hardware

#### Step 4: Post-process results

As you can see, this result has not met the criteria.

## 4. Strategy 3. Run with the error suppression options

You can set the error suppression options in Sampler. Refer to the [Sampler noise management](https://quantum.cloud.ibm.com/docs/ibm-quantum-compute/sampler-noise-management) guide and the [`ExecutionOptions`](https://quantum.cloud.ibm.com/docs/api/qiskit-ibm-runtime/options-models-execution-options) API reference for more information.

The result has improved but still has not met the criteria.

We have seen three ideas so far. You can combine and expand these ideas or you come up with your own ideas to create a better GHZ circuit. Now let's review the goal again.

## 5. Your goal (recap)

Build a GHZ circuit for 20 qubits or more so that the measurement result meets the criteria: The fidelity of your GHZ state > 0.5.

- You need to use an Eagle device (such as `ibm_brisbane`) and set the shots number as 40,000.
- You should execute the GHZ circuit using the `execute_ghz_fidelity` function, and calculate the fidelity using the `check_ghz_fidelity_from_jobs` function.
You need to find the biggest qubits - GHZ circuit which meet the criteria. Write your code below, show the result with the function `check_ghz_fidelity_from_jobs` .

Now we implement the same GHZ workflow as in the preceding material, but on a Heron device. This gives you some experience with the layout and features of the Heron processors. No new strategies are introduced.

*Approximate QPU time to run this next experiment is 4 m 40 s.*

Congratulations! You have completed your introduction to utility-scale quantum computing! You are now poised to make meaningful contributions in the quest for quantum advantage! Thank you for making IBM Quantum&reg; part of your personal quantum journey.

## Post-course survey

Congratulations on completing this course! Please take a moment to help us improve our course by filling out the following [quick survey](https://your.feedback.ibm.com/jfe/form/SV_5vvmdT5yFFetkgK). Your feedback will be used to enhance our content offering and user experience. Thank you!
