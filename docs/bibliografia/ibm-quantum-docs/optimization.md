# Optimización

> Fuente: <https://quantum.cloud.ibm.com/docs/en/guides/optimization>

> Documentación de IBM Quantum Platform (repositorio <https://github.com/Qiskit/documentation>).

# Quantum optimization

Quantum optimization explores how quantum computing can be used to solve optimization problems, where the goal is to find the best, or a good, solution among many possible alternatives (often under a set of constraints). Applications of this field include logistics and scheduling, portfolio optimization, and protein folding.
Quantum optimization approaches include quantum approximate optimization algorithms (QAOA) and other hybrid quantum-classical methods that combine quantum processors with classical optimization techniques. Although quantum computing has the potential to augment our ability to solve optimization problems, identifying practical performance benefits over classical methods remains an active area of research.

Solving an optimization problem on a quantum computer generally involves two stages. First, formulate the problem, (for example, as a quadratic unconstrained binary optimization (QUBO) problem, a higher-order binary optimization (HUBO) problem, or a problem with explicit constraints), and map that formulation into quantum operators and circuits. Second, run the resulting circuit on quantum hardware and interpret the measurement results as a candidate solution. The tools on this page support these two stages: the mapping tool helps you move from a problem definition to a quantum-ready representation, and the application functions combine mapping, hardware execution, and classical post-processing into a single managed workflow.

## Mapping tools 

This capability specializes in mapping domain problems into quantum operators and circuits for execution on a quantum computer. Use it to formulate an optimization problem as a binary model, convert that model between representations, and validate it against classical solvers before running on quantum hardware.

<CardGroup>

</CardGroup>

<span id="application-functions"></span>
## Application functions for optimization

The following quantum functions package the full optimization workflow, from problem mapping through hardware execution and post-processing, behind a managed interface. Rather than building and tuning your own circuits, you provide a problem definition, such as an objective function, a graph, or an industry-specific input like asset price data, and the function returns an optimized solution. These functions address optimization problems across domains, including unconstrained and constrained binary optimization, portfolio rebalancing in finance, and resource allocation problems defined on graphs.

<Admonition type="note">
IBM Quantum&reg; Functions are a beta feature available only to IBM Quantum Premium Plan, Flex Plan, and On-Prem (through the IBM Quantum Platform API) Plan users. Refer to [Set up IBM Quantum Functions](https://quantum.cloud.ibm.com/functions) for instructions on getting access.
</Admonition>

<CardGroup>

</CardGroup>
