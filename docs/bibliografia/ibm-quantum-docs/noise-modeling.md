# Modelado de ruido

> Fuente: <https://quantum.cloud.ibm.com/docs/en/guides/noise-modeling>

> Documentación de IBM Quantum Platform (repositorio <https://github.com/Qiskit/documentation>).

# Noise Modeling

A noise model describes how errors affect the results from executing a quantum circuit. Noise models support several stages of a typical workflow including: simulating a circuit classically to estimate expected performance before submitting a job  or to inform an error-mitigation technique such as probabilistic error cancellation. For general strategies to reduce the impact of noise during execution, see [Overview of noise management techniques](https://quantum.cloud.ibm.com/docs/guides/error-mitigation-and-suppression-techniques).

This page collects the packages and capabilities that support each part of that workflow, grouped into learning noise from a device, building a noise model for classical simulation, and refining a noise model for a specific error-mitigation technique.

## Building and running noise learning algorithms

Use noise learning packages to characterize a device's noise directly from experimental data. These packages run randomized circuits to estimate error rates and build a noise model that reflects actual hardware behavior.

<CardGroup>

</CardGroup>

## Building noise models for noisy circuit simulation

Use this package to construct a noise model for simulating circuits classically. With a noise model, you can estimate how a circuit behaves on noisy hardware before you run it on a QPU.

<CardGroup>

</CardGroup>

## Refining noise models

Use these packages to adjust a noise model for a specific error-mitigation technique. Each package targets a different tradeoff between sampling cost, bias, and the reliability of postselected samples.

<CardGroup>

</CardGroup>
