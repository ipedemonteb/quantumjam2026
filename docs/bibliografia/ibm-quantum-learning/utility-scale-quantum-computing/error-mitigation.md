# error-mitigation

> Fuente: <https://quantum.cloud.ibm.com/learning/en/courses/utility-scale-quantum-computing/error-mitigation>

> Solo las celdas de texto del notebook original; sin código.

  # Quantum noise and error mitigation

<Admonition type="note">

Toshinari Itoko (28 June 2024)

[Download the pdf](https://ibm.ent.box.com/public/static/a0zgies7bh91hm2lwev9o0bfeybxc6n6.zip) of the original lecture. Note that some code snippets might become deprecated since these are static images.

*Approximate QPU time to run this experiment is 1 m 40 s.*

</Admonition>

## 1. Introduction

Throughout this lesson, we will examine noise and how it can be mitigated on quantum computers. We will begin by looking at the effects of noise using a simulator that can simulate noise in a few ways, including using noise profiles from real quantum computers. Then we will move on to real quantum computers, in which noise is inherent. We will look at the effects of error mitigation, including combinations of things like zero-noise extrapolation (ZNE) and gate-twirling.

We will start by loading some packages.

## 2. Noisy simulation without error mitigation

Qiskit Aer is a classical simulator for quantum computing. It can simulate not only ideal execution but also noisy execution of quantum circuits. This notebook demonstrates how to run noisy simulation using Qiskit Aer:

1. Build a noise model
2. Build a noisy sampler (simulator) with the noise model
3. Run a quantum circuit on the noisy sampler

```
noise_model = NoiseModel()
...
noisy_sampler = Sampler(options={"backend_options": {"noise_model": noise_model}})
job = noisy_sampler.run([circuit])
```

### 2.1 Build a test circuit

We consider toy 1-qubit circuits which just repeat X gates `d` times (`d`=0 ... 100) and measure the `Z` observable.

### 2.2 Build a noise model

To do noisy simulation, we need to specify `NoiseModel`. We show how to build `NoiseModel` in this section.

We first need to define quantum (or readout) errors to add to a noise model.

### 2.3 Build a noisy sampler with the noise model

### 2.4 Run quantum circuits on the noisy sampler

### 2.5 Plot results

### 2.6 Ideal simulation

###  2.7 Exercise

By tweaking the code below,
- [ ] Try 25x number of shots (= 10_000 shots) and ensure that a smoother plot is obtained
- [ ] Change noise parameters (OVER_ROTATION_ANGLE, AMPLITUDE_DAMPING_PARAM, PREP0_MEAS1, or PREP1_MEAS0) and see how the plot changes

### 2.8 More realistic noisy simulation

## 3. Real quantum computation with error mitigation

In this part, we demonstrate how to obtain error mitigated results (expectation values) using Qiskit Estimator.
We consider 6-qubit Trotterized circuits for simulating the time evolution of one dimensional Ising model and see how the error scales with respect to the number of time steps.

### 3.1 Build circuits

To know the ideal output in advance, we use compute-uncompute circuits that consist of a first stage where the original circuit $U$ is applied, and a second stage where it is reversed $U^\dagger$.
Note that the ideal outcome of such circuits will trivially be the input state $|000000\rangle$, which has the trivial expectation values for any Pauli observables, for example, $\langle IIIIIZ \rangle = 1$.

Note: As shown above, the circuit with $k$ time steps will have $4k$ two-qubit gate layers.

### 3.2 Transpile the circuits

We transpile the circuits for the backend with optimization (`optimization_level=1`).

### 3.3 Execute using Estimator (with different resilience levels)

Setting the resilienece level (`estimator.options.resilience_level`) is the easiest way to apply error mitigation when using Qiskit Estimator. Estimator supports the following resilience levels (as of 2024/06/28). See more details in the [Configure error mitigation](https://quantum.cloud.ibm.com/docs/guides/error-mitigation-and-suppression-techniques) guide.

### 3.4 Plot results

## 4. (Optional) Customize error mitigation options

We can customize the application of error mitigation techniques via options as shown below.

See the following guides and API reference for the details of error mitigation options.
- [Configure error mitigation](https://quantum.cloud.ibm.com/docs/guides/error-mitigation-and-suppression-techniques)
- [Introduction to options](https://quantum.cloud.ibm.com/docs/ibm-quantum-compute/runtime-options-overview)
- [EstimatorOptions](https://quantum.cloud.ibm.com/docs/api/qiskit-ibm-runtime/options-models-estimator-options)
- [SamplerOptions](https://quantum.cloud.ibm.com/docs/api/qiskit-ibm-runtime/options-models-sampler-options)
