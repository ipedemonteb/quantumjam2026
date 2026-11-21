# quantum-circuit-optimization

> Fuente: <https://quantum.cloud.ibm.com/learning/en/courses/utility-scale-quantum-computing/quantum-circuit-optimization>

> Solo las celdas de texto del notebook original; sin código.

 # Quantum circuit optimization

<Admonition type="note">

Toshinari Itoko (21 June 2024)

[Download the pdf](https://ibm.ent.box.com/public/static/0hvvgr1gnwx64x2ukgk04sss6sxc4zko.zip) of the original lecture. Note that some code snippets might become deprecated since these are static images.

*Approximate QPU time to run this experiment is 15 s.*

(Note: Some cells of part 2 are copied from the notebook "Qiskit Deep dive", written by Matthew Treinish (Qiskit maintainer))

</Admonition>

## 1. Introduction

This lesson will address several aspects of circuit optimization in quantum computing. Specifically, we will see the value of circuit optimization by using optimization settings built into Qiskit. Then we will go a bit deeper and see what you can do as an expert in your particular application area to build circuits in a smart way. Finally, we will take a close look at what goes on during transpilation that helps us optimize our circuits.

## 2. Circuit optimization matters

We first compare the results of running 5-qubit GHZ state ($\frac{1}{\sqrt{2}} \left( |00000\rangle + |11111\rangle \right)$) preparation circuits with and without optimization.

We first use a GHZ circuit naively synthesized as follows.

### 2.1 Optimization level
`optimization_level` has four options, from 0 to 3. The higher the optimization level, the more computational effort is spent to optimize the circuit. Level 0 performs no optimization and just does the minimal amount of work to make the circuit runnable on the selected backend. Level 3 spends the most amount if effort (and typically runtime) to try to optimize the circuit. Level 1 is the default optimization level.

We transpile the circuit without optimization (`optimization_level=0`) and with optimization (`optimization_level=2`).
We see a big difference in the circuit length of transpiled circuits.

### 2.2 Exercise
Try `optimization_level=1` as well and compare the resulting circuit with the above two. Try it by modifying the code above.

__Solution:__

Run on a fake backend (noisy simulation). See Appendix 1 for how to run on a real backend.

## 3. Circuit synthesis matters

We next compare the results of running two differently synthesized 5-qubit GHZ state ($\frac{1}{\sqrt{2}} \left( |00000\rangle + |11111\rangle \right)$) preparation circuits.

The new synthesis produces a shallower circuit. Why?

This is because the new circuit can be laid out on linearly connected qubits, so on IBM&reg; Brisbane's heavy-hexagon coupling graph as well, while the original circuit requires star-shaped connectivity (a degree-4 node) and hence cannot be laid out on the heavy-hex coupling graph, which has nodes at most degree 3. As a result, the original circuit requires qubit routing that adds SWAP gates, increasing the gate count.

What we have done in the new circuit can be seen as a manual "coupling constraint-aware" circuit synthesis. In other words: manually solving circuit synthesis and circuit mapping at the same time.

In general, circuit synthesis depends on application and it's too difficult for a software to cover all possible applications. Qiskit transpiler happens to have no functions of synthesizing GHZ state preparation circuit. In such a case, manual circuit synthesis as shown above is worth considering.

In this section, we look into the details of how Qiskit transpiler works using the following toy example circuit.

### 3.1 Draw the entire Qiskit transpilation flow

We look into the transpiler passes (tasks) for `optimization_level=1`.

The flow consists of six stages:

### 3.2 Draw an individual stage

First, let's draw all the tasks (transpiler passes) done in the `init` stage.

We can run each individual stage. Let's run `init` stage for our circuit. By enabling logger, we can see the details of the run.

### 3.3 Exercise
Draw `layout` stage passes and run the stage for the output circuit of the `init` stage (`init_out`), by modifying cells used above.

__Solution:__

Do the same thing for `translation` stage.

__Solution:__

Note: Any individual stage cannot always be run independently (as some of them need to carry over information from one previous stage).

### 3.4 Optimization Stage

The last default stage in the pipeline is optimization. After we've embedded the circuit for the target the circuit has expanded quite a bit. Most of this is due to inefficiencies in the equivalence relationships from basis translation and swap insertion. The optimization stage is used to try and minimize the size and depth of the circuit. It runs a series of passes in a ```do while``` loop until it reaches a steady output.

## 4. In-depth examples
### 4.1 Two-qubit block optimization using two-qubit unitary synthesis

For level 2 and 3, we have more passes (`Collect2qBlocks`, `ConsolidateBlocks`, `UnitarySynthesis`) for more optimization, namely two-qubit block optimization. (Compare the optimization stage flow for level 2 with that above for level 1)

The two-qubit block optimization is composed of two steps: Collecting and consolidating 2-qubit blocks and synthesizing the 2-qubit unitary matrices.

We saw in Part 2 that the real quantum compiler flow is not that simple and is composed of many passes (tasks). This is mainly due to the software engineering required to ensure performance for a wide range of application circuits and maintainability of the software. Qiskit transpiler would work well in most cases but if you happen to see your circuit is not well optimized by Qiskit transpiler, it would be a good opportunity to research your own application-specific circuit optimization as shown in Part 1. Transpiler technology is evolving, your R&D contribution is welcome.

### 4.2 Circuit optimization matters

We first compare the results of running 5-qubit GHZ state ($\frac{1}{\sqrt{2}} \left( |00000\rangle + |11111\rangle \right)$) preparation circuits with and without optimization.

We first use a GHZ circuit naively synthesized as follows.

We transpile the circuit without optimization (`optimization_level=0`) and with optimization (`optimization_level=2`).
As you can see, there is a big difference in the circuit length of transpiled circuits.

### 4.3 Circuit synthesis matters

We next compare the results of running two differently synthesized 5-qubit GHZ state ($\frac{1}{\sqrt{2}} \left( |00000\rangle + |11111\rangle \right)$) preparation circuits.

### 4.4 General 1-qubit gate decomposition

### 4.5 One-qubit block optimization

### 4.6 Toffoli decomposition

### 4.7 CU gate decomposition

### 4.8 CX, ECR, CZ equal up to local Cliffords

Note that $H$(Hadamard), $S$($\pi/2$ Z-rotation), $S^\dagger$($-\pi/2$ Z-rotation), $X$(Pauli X) are all Clifford gates.

Using IBM backend 1q basis gates "rz", "sx" and "x".
