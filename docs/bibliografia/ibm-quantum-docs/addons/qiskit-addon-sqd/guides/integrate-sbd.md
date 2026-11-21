# Scale SQD chemistry workflows with the SBD eigensolver

> Fuente: <https://github.com/Qiskit/documentation/tree/main/docs/addons/qiskit-addon-sqd/guides/integrate-sbd>

This guide shows how to use the [SBD eigensolver](https://github.com/Qiskit/sbd-eigensolver-python) as an alternative selected configuration interaction (SCI) solver to diagonalize larger fermionic problems beyond what the default PySCF solver can support. SBD (Selected Basis Diagonalization) runs in-process, is parallelized with MPI, and offers both CPU and CUDA backends. For information on how to install and use it, see the [SBD documentation](https://github.com/Qiskit/sbd-eigensolver-python).

SBD compiles a C++ extension against the MPI and BLAS libraries available on the machine, so you must install both before you install the `sbd` extra:

```bash
pip install qiskit-addon-sqd[sbd]
```

Because `solve_sci_batch` already matches the solver interface that `diagonalize_fermionic_hamiltonian` expects, you can pass it directly to `sci_solver` after you bind its configuration options with `functools.partial`. To run on a CUDA-capable GPU instead of the CPU, pass `device_config=DeviceConfig.gpu()` from `sbd.device_config`.

For more details on the SQD code used in this example, see the [chemistry Hamiltonian tutorial](https://quantum.cloud.ibm.com/docs/tutorials/sample-based-quantum-diagonalization).
