# Glosario rápido (para tener a mano durante preguntas)

No hace falta memorizarlo — es para tener la definición corta a mano si alguien pregunta un término
puntual durante la presentación.

- **Qubit:** la unidad de información de una computadora cuántica. Acá no representa "un bit mejor",
  representa si un electrón ocupa o no un cierto orbital de la molécula.
- **Hartree-Fock (HF):** el método clásico más simple para estimar la energía de una molécula;
  ignora cómo los electrones se esquivan entre sí en tiempo real.
- **CCSD:** método clásico más preciso que HF, bueno cerca del equilibrio, que se degrada cuando los
  átomos se separan mucho.
- **FCI (Full Configuration Interaction):** la respuesta exacta. Solo calculable para sistemas chicos;
  es la vara de medir de todo el proyecto.
- **Correlación fuerte / zona estirada:** la situación (átomos muy separados) donde los métodos
  clásicos baratos como CCSD empiezan a fallar, porque la aproximación que usan deja de ser válida.
- **Ansatz:** el circuito cuántico parametrizado que usamos como "forma" del estado que buscamos.
  Nuestro ansatz es **UCCSD**: arranca de Hartree-Fock y aplica excitaciones (mover electrones de a
  uno o de a dos) con sentido químico.
- **VQE (Variational Quantum Eigensolver):** el algoritmo que, combinando una computadora cuántica
  (mide la energía de un circuito) con una clásica (ajusta los parámetros del circuito), busca la
  energía más baja posible.
- **Principio variacional:** garantía matemática de que VQE nunca devuelve una energía *menor* que la
  real — siempre igual o más alta. Por eso "más bajo = más cerca de la verdad" es un argumento válido.
- **Jordan-Wigner:** la receta puntual que usamos para convertir "electrones en orbitales" a "qubits".
- **Shots:** la cantidad de mediciones repetidas que se le piden a un circuito cuántico (real o
  simulado) para estimar un valor con una precisión dada — más shots, menos error estadístico.
- **Compuertas CZ:** un tipo de operación de dos qubits. Contarlas (nuestro circuito usa 382) es una
  forma de medir qué tan "caro"/profundo es el circuito.
- **R_e (distancia de equilibrio):** la distancia entre átomos donde la molécula tiene la energía más
  baja — la configuración más estable.
- **D_e (energía de disociación):** cuánta energía hace falta para separar la molécula del todo,
  partiendo del equilibrio.
- **mHa (milihartree):** la unidad en la que medimos los errores de energía. 1 mHa = 0,001 Hartree.
  La "precisión química" (una meta exigente, no obligatoria en este desafío) es estar por debajo de
  1,6 mHa de la respuesta exacta.
