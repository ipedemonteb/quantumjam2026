# The Extended Stabilizer Simulator

> Fuente: <https://github.com/Qiskit/qiskit-aer/blob/main/docs/tutorials/6_extended_stabilizer_tutorial.ipynb>

## Introduction

The Extended Simulator is a new method for classically simulating quantum circuits available in the latest release of [Qiskit-Aer](https://github.com/qiskit/qiskit-aer). 

This method is an implementation of the ideas published in the paper _Simulation of quantum circuits by low-rank stabilizer decompositions_ by Bravyi, Browne, Calpin, Campbell, Gosset & Howard, 2018, [**arXiv:1808.00128**](https://arxiv.org/abs/1808.00128).

It uses a different representation of a quantum circuit, that gives it some unique capabilities. This notebook will give some examples of what the extended stabilizer method can do.

For example:

We've created a random circuit with just 60 gates, that acts on 40 qubits. But, because of the number of qubits, if we wanted to run this with say the statevector simulator then I hope you have access to terabytes of RAM!

The Extended Stabilizer method, in contrast, handles this circuit just fine. (Though it needs a couple of minutes!)

## How does this work?
If you're interested in how exactly we can handle such large circuits, then for a detailed explanation you can [read the paper!](https://arxiv.org/abs/1808.00128)

For running circuits, however, it's important to just understand the basics.

The Extended Stabilizer method is made up of two parts. The first is a method of decomposing quantum circuits into _stabilizer circuits_, a special class of circuit that can be efficiently simulated classically. The second is then a way of combining these circuits to perform measurements.

The number of terms you need scales with the number of what we call _non-Clifford Gates_. At the moment, the method knows how to handle the following methods:
```python
circ.t(qr[qubit])
circ.tdg(qr[qubit])
circ.ccx(qr[control_1], qr[control_2], qr[target])
circ.u1(rotation_angle, qr[qubit])
```

The simulator is also able to handle circuits of up to 63 qubits.

One thing that's important to note is these decompositions are approximate. This means that the results aren't exactly the same as with the State Vector simulator.

You can control this approximation error using the `extended_stabilizer_approximation_error` in Qiskit Aer. The default error is 0.05. The smaller the error, the more precise the results, but also the longer your simulation will take and the more memory it will require.

## Simulator Options

There are several other options you can tweak to control how the extended stabilizer method performs. What these options are and their explanation can all be found in the Qiskit Aer documentation. However, I want to highlight two important ones that can help to optimize your simulations.

To perform measurements, the extended stabilizer method uses a Markov chain method to sample outcomes at random. This Markov chain has to be run for some time we call the 'mixing time' before it will start sampling, and has to be re-mixed for every circuit shot.

If you expect your circuit output to be concentrated on just a few output states, then you can likely optimize your simulations by reducing the `extended_stabilizer_mixing_time` option.

Similarly, if your circuit has some non-zero probability on all amplitudes (e.g. if it's a random circuit), then you can avoid this expensive re-mixing step to take multiple shots from the output at once. This can be enabled by setting `extended_stabilizer_measure_sampling=True`.

For example, let's look again at the random circuit from the start of the tutorial, running for 100 shots:

## When shall I use it?

If you have smaller circuits with lots of non-Clifford gates, then the statevector method will likely perform better than the extended stabilizer. If however you want to look at circuits on many qubits, without needing access to high performance computation, then give this method a try!
