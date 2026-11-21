# Entrada y salida de primitivas (PUBs)

> Fuente: <https://quantum.cloud.ibm.com/docs/en/qiskit/primitive-input-output>

> Documentación de IBM Quantum Platform (repositorio <https://github.com/Qiskit/documentation>). Solo texto, sin las celdas de código.

# Primitive inputs and outputs

<Accordion>
<AccordionItem title="Package versions">

The code on this page was developed using the following requirements.
We recommend using these versions or newer.

```
qiskit[all]~=2.6.2
```
</AccordionItem>
</Accordion>

This page gives an overview of the inputs and outputs of the Qiskit SDK primitives. With these primitives you can use a data structure known as a **Primitive Unified Bloc (PUB)** to efficiently define vectorized workloads. These PUBs are the fundamental unit of work for workload execution. They are used as inputs to the `run()` method for the Sampler and Estimator primitives, which execute the defined workload as a job. Then, after the job has completed, the results are returned in a format that depends on the PUBs used and any specified options.

<span id="pubs"></span>
## Overview of PUBs

When invoking a primitive's `run()` method, the main argument that is required is a `list` of one or more tuples -- one for each circuit being executed by the primitive. Each of these tuples is considered a PUB, and the required elements of each tuple in the list depends on the primitive used. The data provided to these tuples can also be arranged in a variety of shapes to provide flexibility in a workload through broadcasting -- the rules of which are described in a [following section](#broadcasting-rules).

### Estimator PUB
For the Estimator primitive, the format of the PUB should contain at most four values:
- A single `QuantumCircuit`, which may contain one or more [`Parameter`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.Parameter) objects
- A list of one or more observables, which specify the expectation values to estimate, arranged into an array (for example, a single observable represented as a 0-d array, a list of observables as a 1-d array, and so on). The data can be in any one of the `ObservablesArrayLike` format such as `Pauli`, `SparsePauliOp`, `PauliList`, or `str`.
   <Admonition type="note">
   If you have two commuting observables in different PUBs but with the same circuit, they will not be estimated using the same measurement. Each PUB represents a different basis for measurement, and therefore, separate measurements are required for each PUB. To ensure that commuting observables are estimated using the same measurement, they must be grouped within the same PUB.
   </Admonition>
- A collection of parameter values to bind the circuit against. This can be specified as a single array-like object where the last index is over circuit `Parameter` objects, or omitted (or equivalently, set to `None`) if the circuit has no `Parameter` objects.
- (Optionally) a target precision for expectation values to estimate

### Sampler PUB
For the Sampler primitive, the format of the PUB tuple contains at most three values:
- A single `QuantumCircuit`, which may contain one or more [`Parameter`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.circuit.Parameter) objects
   *Note: These circuits must also include measurement instructions for each of the qubits to be sampled.*
- A collection of parameter values to bind the circuit against $\theta_k$ (only needed if any `Parameter` objects are used that must be bound at runtime)
- (Optionally) a number of shots to measure the circuit with

---

The following code demonstrates an example set of vectorized inputs to the `Estimator` primitive.

<span id="broadcasting"></span>
### Broadcasting rules

The PUBs aggregate elements from multiple arrays (observables and parameter values) by following the same broadcasting rules as NumPy. This section briefly summarizes those rules.  For a detailed explanation, see the [NumPy broadcasting rules documentation](https://numpy.org/doc/stable/user/basics.broadcasting.html).

Rules:

* Input arrays do not need to have the same number of dimensions.
  * The resulting array will have the same number of dimensions as the input array with the largest dimension.
  * The size of each dimension is the largest size of the corresponding dimension.
  * Missing dimensions are assumed to have size one.
* Shape comparisons start with the rightmost dimension and continue to the left.
* Two dimensions are compatible if their sizes are equal or if one of them is 1.

Examples of array pairs that broadcast:

```text
A1     (1d array):      1
A2     (2d array):  3 x 5
Result (2d array):  3 x 5

A1     (3d array):  11 x 2 x 7
A2     (3d array):  11 x 1 x 7
Result (3d array):  11 x 2 x 7
```

Examples of array pairs that do not broadcast:

```text
A1     (1d array):  5
A2     (1d array):  3

A1     (2d array):      2 x 1
# The following would work if the middle dimension were 2,
# instead of 5.
A2     (3d array):  6 x 5 x 4
```

`Estimator` returns one expectation value estimate for each element of the broadcasted shape.

Here are some examples of common patterns expressed in terms of array broadcasting.  Their accompanying visual representation is shown in the figure that follows:

Parameter value sets are represented by n x m arrays, and observable arrays are represented by one or more single-column arrays. For each example in the previous code, the parameter value sets are combined with their observable array to create the resulting expectation value estimates.

 - *Example 1*: (broadcast single observable) has a parameter value set that is a 5x1 array and a 1x1 observables array.  The one item in the observables array is combined with each item in the parameter value set to create a single 5x1 array where each item is a combination of the original item in the parameter value set with the item in the observables array.

 - *Example 2*: (zip) has a 5x1 parameter value set and a 5x1 observables array.  The output is a 5x1 array where each item is a combination of the nth item in the parameter value set with the nth item in the observables array.

  - *Example 3*: (outer/product) has a 1x6 parameter value set and a 4x1 observables array.  Their combination results in a 4x6 array that is created by combining each item in the parameter value set with *every* item in the observables array, and thus each parameter value becomes an entire column in the output.

  - *Example 4*: (Standard nd generalization) has a 3x6 parameter value set array and two 3x1 observables array.  These combine to create two 3x6 output arrays in a similar manner to the previous example.

<Admonition type="tip" title="SparsePauliOp">
Each `SparsePauliOp` counts as a single element in this context, regardless of the number of Paulis contained in the `SparsePauliOp`. Thus, for the purpose of these broadcasting rules, all of the following elements have the same shape:

```text
a = SparsePauliOp("Z") # shape ()
b = SparsePauliOp("IIIIZXYIZ") # shape ()
c = SparsePauliOp.from_list(["XX", "XY", "IZ"]) # shape ()
```

The following lists of operators, while equivalent in terms of information contained, have different shapes:

```text
list1 = SparsePauliOp.from_list(["XX", "XY", "IZ"])
    # list1 has shape ()
list2 = [SparsePauliOp("XX"), SparsePauliOp("XY"), SparsePauliOp("IZ")]
    # list2 has shape (3, )
```
</Admonition>

## Overview of primitive outputs

Once one or more PUBs are sent to a QPU for execution and a job successfully completes, the data is returned as a [`PrimitiveResult`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.primitives.PrimitiveResult) container object. The `PrimitiveResult` contains an iterable list of [`PubResult`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.primitives.PubResult) objects that contain the execution results for each PUB. For example, a job submitted with 20 PUBs will return a `PrimitiveResult` object that contains a list of 20 `PubResults`, one corresponding to each PUB.

Each of these `PubResult` objects possess both a `data` and an optional `metadata` attribute. The `data` attribute is a customized [`DataBin`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.primitives.DataBin) that contains the the expectation value estimates in case of the Estimator, or samples of the circuit output in the case of the Sampler.

The `data` attribute might also include other implementation-specific information such as standard deviations. The `metadata` attribute can contain additional implementation-specific information about the execution of the associated PUB.

The following is a visual outline of the `PrimitiveResult` data structure:

<Tabs>
    <TabItem value="estimator" label="Estimator output">
    ```
    └── PrimitiveResult
        ├── PubResult[0]
        │   ├── metadata
        │   └── data  ## In the form of a DataBin object,
        |       |     ## which includes data such as the following:
        │       ├── evs
        │       │   └── List of estimated expectation values in the shape
        |       |         specified by the first pub
        │       └── stds
        │           └── List of calculated standard deviations in the
        |                 same shape as above
        ├── PubResult[1]
        |   ├── metadata
        |   └── data  ## In the form of a DataBin object,
        |       |     ## which includes data such as the following:
        |       ├── evs
        |       │   └── List of estimated expectation values in the shape
        |       |        specified by the second pub
        |       └── stds
        |           └── List of calculated standard deviations in the
        |                same shape as above
        ├── ...
        ├── ...
        └── ...
    ```
    <Admonition type="note">
    The above is an example of data that might be returned.  The actual data returned depends on the implementation.
    </Admonition>
    </TabItem>
    <TabItem value="sampler" label="Sampler output">
    ```
    └── PrimitiveResult
        ├── PubResult[0]
        │   ├── metadata
        │   └── data  ## In the form of a DataBin object
        │       ├── NAME_OF_CLASSICAL_REGISTER
        │       │   └── BitArray of count data for first PUB (default is 'meas')
        |       |
        │       └── NAME_OF_ANOTHER_CLASSICAL_REGISTER
        │           └── BitArray of count data (exists only if more than one
        |                 ClassicalRegister was specified in the circuit)
        ├── PubResult[1]
        |   ├── metadata
        |   └── data  ## In the form of a DataBin object
        |       └── NAME_OF_CLASSICAL_REGISTER
        |           └── BitArray of count data for second PUB
        ├── ...
        ├── ...
        └── ...
    ```
    </TabItem>
</Tabs>

### Estimator output

As stated previously, the data returned in the `PubResult` for the Estimator primitive depends on the implementation. For example, it might contain an array of expectation values (`PubResult.data.evs`) and associated standard deviations (`PubResult.data.stds`).

The below code snippet describes the `PrimitiveResult` (and associated `PubResult`) format for the job created above.

### Sampler output

When a Sampler job is completed successfully, the returned [`PrimitiveResult`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.primitives.PrimitiveResult) object contains a list of [`SamplerPubResult`](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.primitives.SamplerPubResult)s, one per PUB. The data bins of these `SamplerPubResult` objects are dict-like objects that contain one `BitArray` per `ClassicalRegister` in the circuit.

The `BitArray` class is a container for ordered shot data. In more detail, it stores the sampled bitstrings as bytes inside a two-dimensional array. The left-most axis of this array runs over ordered shots, while the right-most axis runs over bytes.

As a first example, let us look at the following ten-qubit circuit:

It can sometimes be convenient to convert from the bytes format in the `BitArray` to bitstrings. The `get_count` method returns a dictionary mapping bitstrings to the number of times that they occurred.

When a circuit contains more than one classical register, the results are stored in different `BitArray` objects. The following example modifies the previous snippet by splitting the classical register into two distinct registers:

#### Leveraging `BitArray` objects for performant post-processing

Since arrays generally offer better performance compared to dictionaries, it is advisable to perform any post-processing directly on the `BitArray` objects rather than on dictionaries of counts. The `BitArray` class offers a range of methods to perform some common post-processing operations:

## Result metadata

In addition to the execution results, the `PrimitiveResult` and `PubResult` objects contain an optional metadata attribute about the job that was submitted. The metadata returned (if any) is implementation-specific.

## Next steps

<Admonition type="tip" title="Recommendations">

  -  Review the [Qiskit SDK primitives](https://quantum.cloud.ibm.com/docs/api/qiskit/primitives) API.
  -  Review the [Qiskit Aer primitives](https://qiskit.github.io/qiskit-aer/apidocs/aer_primitives.html) API.
  -  Learn more about the [IBM Quantum&reg; primitives](https://quantum.cloud.ibm.com/docs/ibm-quantum-compute/qiskit-runtime-primitives).
  -  Review the [`qiskit-ibm-runtime` Estimator](https://quantum.cloud.ibm.com/docs/api/qiskit-ibm-runtime/executor-estimator-estimator) API.
  -  Review the [`qiskit-ibm-runtime` Sampler](https://quantum.cloud.ibm.com/docs/api/qiskit-ibm-runtime/executor-sampler-sampler) API.
</Admonition>
