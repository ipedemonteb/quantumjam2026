# Bitácora de avance

Resumen corto de cada pasada de trabajo sobre `notebooks/vqe_h4.ipynb`, para que cualquiera (persona
o agente) pueda retomar sin tener que releer todo el historial de git. Entradas más nuevas arriba.

## 2026-11-21 — Velocidad del loop de VQE + evaluación de `qiskit-fermions`

**Qué se hizo:**

- Diagnosticamos por qué una corrida completa tardaba mucho más de lo esperado (hasta ~536 s por
  arranque de `optimize_vqe`): puliamos con L-BFGS-B *cada* arranque antes de comparar, y cuando
  COBYLA no converge desde un punto malo, L-BFGS-B tiene que terminar ese trabajo con gradiente
  numérico (~27 evals/iteración). Medido: 85% del tiempo de un punto (292 de 341 s) se gastaba
  puliendo candidatos que iban a perder igual.
- Arreglo aplicado y validado: `optimize_vqe` corre COBYLA en todos los arranques y pule con
  L-BFGS-B **solo** al que ganó. Resultado medido: **341 s → 70-100 s por punto (3-5x)**, misma
  energía final (verificado mHa a mHa en los puntos comparados).
- Semilla de CCSD (amplitudes t1/t2 de `classical_references`, antes se tiraban) para el primer
  punto de la curva en vez de arrancar al azar — valida mejor: 0,01 mHa de FCI con 400 iteraciones
  vs 6-7 mHa de un arranque aleatorio de 800 ([arXiv:2301.05666](https://arxiv.org/abs/2301.05666)).
  Confirmado que esta semilla **no sirve en la zona estirada** (d=2,4 Å da peor que Hartree-Fock,
  las amplitudes de CCSD dejan de ser chicas ahí) — por eso se usa solo en el primer punto.
- Bajamos de 2 a 1 arranque aleatorio de respaldo para el resto de los puntos; el warm start ya
  alcanza (0,02 mHa de FCI medido en d=0,84 Å), un segundo arranque nunca ganó en las pruebas.
- Evaluamos migrar Hamiltoniano/ansatz de `qiskit-nature` a `qiskit-fermions`, como pide
  `.claude/skills/simulate-fermionic-systems/SKILL.md`. El Hamiltoniano migra limpio (valida contra
  FCI a 1e-14). El ansatz UCCSD vía el wrapper `UCC` de `qiskit-fermions`, siguiendo la receta
  documentada del addon, **no mejora el circuito**: más CZ y más profundidad que el actual (382→516
  CZ en optimization_level 1, 265→499 en optimization_level 2-3), y además rompe el truco de
  transpilar una sola vez, porque `ffsim.UCCSDOpRestrictedReal` no acepta parámetros simbólicos de
  Qiskit (exige valores numéricos concretos, forzando un rebuild completo por evaluación de costo).
  **Decisión: no migrar.** Seguimos con `qiskit-nature` para Hamiltoniano/ansatz. El código del
  experimento no se subió al repo (vivió en el scratchpad de la sesión que lo hizo).

**Qué falta:**

- Correr la curva completa de punta a punta con esta versión más rápida para tener los 11 puntos
  reales (hasta ahora solo hay smoke tests y puntos sueltos).
- El margen VQE vs CCSD en d≈1,8 Å sigue siendo el más ajustado de toda la curva — con el tiempo que
  ahora se libera por punto, vale la pena darle más `maxiter`/arranques específicamente ahí si hace
  falta.
- Entrega a Drive: pendiente, no priorizada todavía.
