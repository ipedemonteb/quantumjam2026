# Quantum Jam 2026

Repo de trabajo para el desafío de la Quantum Jam 2026 (ITBA, Qiskit Fall Fest 2026). La entrega es un notebook de Google Colab; acá se guarda el contexto y el trabajo previo.

## El desafío

Calcular con **VQE** la curva de energía de una cadena recta de **H₄** (átomos separados por la misma distancia `d`, base **STO-3G**) mientras se separan sus átomos, y ganarle a CCSD donde ese método falla. Consigna completa: [docs/consigna.md](docs/consigna.md). Lo esencial:

- Al menos 10 distancias entre 0,6 y 3,0 Å, cada energía con barra de error ±σ, comparada con CCSD y FCI.
- Obtener la distancia de equilibrio `R_e` y la energía de disociación `D_e = E(3,0 Å) − E(R_e)`.
- Desde 1,8 Å: `|E_VQE − E_FCI| + σ < |E_CCSD − E_FCI|`. Meta máxima: `|E_VQE − E_FCI| < 1,6 mHa` (precisión química).
- Reglas: el algoritmo central es VQE (SQD solo como extra). Las energías salen de **medir circuitos con `EstimatorV2` o `SamplerV2` de `qiskit_aer`**, no de leer el estado del simulador. Los métodos clásicos solo sirven para comparar y elegir puntos de partida. En la zona estirada hay que argumentar por qué el resultado es confiable.
- Entrega: notebook de Colab que corra de punta a punta instalando sus dependencias. Incluye una tabla por punto (energía, error, shots, cantidad de compuertas `cz`) y una explicación de qué se decidió, por qué y qué no funcionó.

## Documentación

Todo está en [docs/](docs/README.md), en markdown:

- [docs/consigna.md](docs/consigna.md): transcripción de la consigna oficial.
- [docs/teoria/](docs/teoria/): teoría de los workshops (clases 1 a 4 y química cuántica), extraída de `quantumjam-workshops`, sin código.
- [docs/bibliografia/](docs/bibliografia/README.md): papers (Kandala 2017, Temme 2017), documentación de PySCF, Qiskit Aer, qiskit-addon-sqd, demos de PennyLane y cursos y guías de IBM Quantum Learning.

Antes de buscar algo en internet, buscá en `docs/`: las fuentes principales ya están ahí, y cada archivo empieza con un enlace a su origen.

## Skills

Las skills están en `.claude/skills/`:

- `select-error-mitigation`: elegir y configurar mitigación de errores (ZNE, PEC, TREX, twirling, dynamical decoupling). Útil para el desafío central.
- `simulate-fermionic-systems`: hamiltonianos fermiónicos, encodings a qubits y transpilación con `qiskit-fermions`. Útil para el desafío central.
- `select-sqd-eigensolver`: elegir el solver de diagonalización en SQD. Solo para el extra de SQD.
- `migrate-qiskit-ibm-runtime`: migrar código viejo de `qiskit-ibm-runtime`.
- `managed-workflows-quickstart`: correr workflows pesados en IBM Quantum Managed Workflows.

## Convenciones

- Idioma: español (rioplatense) para docs y comentarios, como en el resto del repo.
- Los textos de `docs/teoria/` y `docs/bibliografia/` son material de referencia convertido: no los edites a mano. Si algo está mal, corregilo en el origen o reconvertilo.
- Para el entorno de Colab, ver las versiones de Qiskit que usan los notebooks de los workshops (`qiskit`, `qiskit-aer`, `qiskit-ibm-runtime`, `pyscf`).
