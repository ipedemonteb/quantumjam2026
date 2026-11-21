# Bibliografía

Material de referencia para la Quantum Jam 2026, convertido a markdown. Todo está pensado para el desafío de la [consigna](../consigna.md): curva de energía de H₄ con VQE, comparada con CCSD y FCI, con ruido y mitigación de errores, usando `qiskit_aer`.

Los notebooks y los ejemplos se convirtieron dejando solo las explicaciones; el código no se incluyó. Cada archivo empieza con un enlace a su fuente original.

## Papers

| Archivo | Referencia | Para qué sirve |
|---|---|---|
| [papers/kandala-2017-hardware-efficient-vqe.md](papers/kandala-2017-hardware-efficient-vqe.md) | Kandala et al., *Nature* 549, 242 (2017) — <https://www.nature.com/articles/nature23879> | Es el VQE con ansatz *hardware-efficient* en 6 qubits que cita la consigna (H₂, LiH, BeH₂). |
| [papers/temme-2017-error-mitigation-short-depth-circuits.md](papers/temme-2017-error-mitigation-short-depth-circuits.md) | Temme, Bravyi, Gambetta, *PRL* 119, 180509 (2017) — <https://journals.aps.org/prl/abstract/10.1103/PhysRevLett.119.180509> | Define *zero-noise extrapolation* y *probabilistic error cancellation*, las bases de la mitigación de errores. |

Ambos son los preprints de arXiv (1704.05018 y 1612.02058), porque las versiones de las revistas están detrás de paywall o solo muestran el abstract. Las ecuaciones están en LaTeX (`$...$`).

## Librerías y documentación

| Carpeta | Fuente | Contenido |
|---|---|---|
| [pyscf/](pyscf/) | <https://pyscf.org> | Documentación de usuario: moléculas y bases, HF, CI/FCI, CCSD, MP, CASSCF, density fitting. Es la referencia para HF, CCSD y FCI del desafío. |
| [qiskit-aer/](qiskit-aer/) | <https://github.com/Qiskit/qiskit-aer> | README, primeros pasos, tutoriales (simulador, modelos de ruido, MPS, stabilizer) y guías de paralelismo y GPU. |
| [qiskit-addon-sqd/](qiskit-addon-sqd/) | <https://github.com/Qiskit/qiskit-addon-sqd> | README y guías de SQD (*sample-based quantum diagonalization*). La consigna lo permite solo como extra. |
| [pennylane/](pennylane/) | <https://pennylane.ai/demonstrations> | Demos de VQE, mapeos fermión-qubit, ADAPT, optimizadores, ruido y mitigación, más un [índice del catálogo](pennylane/_indice-demos.md). |
| [ibm-quantum-learning/](ibm-quantum-learning/) | <https://quantum.cloud.ibm.com/learning/en> | Cursos: química cuántica con VQE, diseño de algoritmos variacionales, diagonalización cuántica, ruido y mitigación, entre otros. Ver [README](ibm-quantum-learning/README.md). |
| [ibm-quantum-docs/](ibm-quantum-docs/) | <https://quantum.cloud.ibm.com/docs/en> | Guías sobre primitivas, modelos de ruido, mitigación y supresión de errores, simuladores locales y addons. |

Algunas notas sobre el contenido:
- `qiskit-sqd` es el nombre que se usa en el enlace pedido; el repo real es `Qiskit/qiskit-addon-sqd`.
- Los cursos de IBM Learning vienen del repositorio abierto `Qiskit/documentation`, porque la web los renderiza con JavaScript. Se incluyeron los cursos relevantes para el desafío, no el catálogo completo.
- De PennyLane se incluyeron los demos de química, VQE, ruido y mitigación. El resto del catálogo está solo como enlaces.

## Skills del repo relacionadas

El repo ya trae skills en [`.claude/skills/`](../../.claude/skills/). Estas son las que se relacionan con esta bibliografía:

| Skill | Se relaciona con | Cuándo usarla |
|---|---|---|
| `select-error-mitigation` | [Temme et al.](papers/temme-2017-error-mitigation-short-depth-circuits.md), [guía de mitigación de IBM](ibm-quantum-docs/error-mitigation-and-suppression-techniques.md), [curso de ventaja cuántica](ibm-quantum-learning/tools-for-quantum-advantage/), [demos de ruido de PennyLane](pennylane/tutorial_error_mitigation.md) | Elegir y configurar la mitigación (ZNE, PEC, TREX, twirling, dynamical decoupling) para un workload con Estimator o Sampler. |
| `select-sqd-eigensolver` | [qiskit-addon-sqd](qiskit-addon-sqd/), [curso de diagonalización](ibm-quantum-learning/quantum-diagonalization-algorithms/) | Elegir el solver de la diagonalización en SQD (PySCF, Dice, SBD, Fulqrum). |
| `simulate-fermionic-systems` | [PySCF](pyscf/), [mapeos de PennyLane](pennylane/tutorial_mapping.md), [addon qiskit-fermions](ibm-quantum-docs/addons/qiskit-fermions/), [química con VQE](ibm-quantum-learning/quantum-chem-with-vqe/) | Construir el hamiltoniano fermiónico, elegir el encoding (Jordan-Wigner, ternary-tree, etc.) y transpilar. |
| `migrate-qiskit-ibm-runtime` | [guía de primitivas](ibm-quantum-docs/primitives.md), [migración a primitivas client-side](ibm-quantum-docs/migrate-to-client-side-primitives.md) | Pasar código viejo de `qiskit-ibm-runtime` (primitivas V1) a la versión actual. |
| `managed-workflows-quickstart` | [guías de IBM](ibm-quantum-docs/) | Si el código local se queda sin memoria o tarda horas y hay que correrlo en IBM Quantum Managed Workflows. |

La consigna exige medir con `EstimatorV2` o `SamplerV2` de `qiskit_aer`, no con IBM Runtime. Por eso, para el desafío central, `select-error-mitigation` y `simulate-fermionic-systems` son las más útiles. `select-sqd-eigensolver` solo vale para el extra de SQD.
