# Quantum Jam 2026 — Consigna

> Transcripción de las capturas de la consigna oficial.

## 01 Motivación

Más o menos la mitad de la comida del mundo depende de fertilizantes hechos con amoníaco, y el amoníaco se fabrica con el proceso Haber-Bosch: se rompen moléculas de nitrógeno a unos 450 °C y a cientos de atmósferas de presión. Solo ese proceso se lleva cerca del 1-2 % de toda la energía que consume la humanidad. Mientras tanto, unas bacterias que viven en las raíces de la soja hacen lo mismo a temperatura ambiente, gracias a una enzima (la nitrogenasa). Si entendiéramos exactamente cómo lo logran, podríamos diseñar catalizadores que hagan fertilizante gastando una fracción de esa energía.

¿Por qué no lo sabemos todavía? Porque para eso hay que calcular con mucha precisión la energía de los electrones mientras se rompe un enlace, y justamente ahí es donde las computadoras clásicas no dan abasto. El mismo problema aparece al diseñar baterías para celulares y autos eléctricos o al predecir cómo un medicamento se une a una proteína. Es uno de los casos de uso más prometedores de las computadoras cuánticas.

Obviamente, en esta Jam no vamos a resolver la nitrogenasa. Pero la pregunta de fondo es la misma, y la podemos atacar con una molécula de juguete: cuatro hidrógenos en fila.

### La energía de una molécula

Casi toda la química se reduce a una pregunta: ¿cuál es la energía más baja que puede tener una molécula para una cierta disposición de sus núcleos? Si acercamos demasiado los núcleos, sus cargas positivas se repelen y la energía sube. Si los alejamos demasiado, la molécula deja de existir. En el medio hay una distancia en la que la energía es mínima: la **distancia de equilibrio** $R_e$. La diferencia entre la energía de los átomos separados y ese mínimo es la **energía de disociación** $D_e$, es decir, lo que cuesta romper la molécula.

Para cada distancia, esa energía mínima es el autovalor más chico $E_0$ del hamiltoniano electrónico $\hat H$ de la molécula. El problema es que la dimensión de $\hat H$ crece exponencialmente con el tamaño del sistema, y por eso los métodos clásicos exactos (como FCI) dejan de ser viables muy rápido. Los métodos clásicos aproximados (como CCSD) funcionan muy bien cerca del equilibrio, pero acumulan cada vez más error a medida que se estiran los enlaces.

### De la molécula a los qubits

El camino tiene dos partes:

1. **Obtener el hamiltoniano:** como $\hat H$ es distinto para cada distancia internuclear, hay que construirlo una vez por punto de la curva. Con Hartree-Fock se definen los orbitales moleculares (espín-orbitales) y se escribe $\hat H$ con operadores de creación y aniquilación fermiónicos:

   $$\hat H = \sum_{pq} h_{pq}\, a_p^\dagger a_q + \frac{1}{2}\sum_{pqrs} h_{pqrs}\, a_p^\dagger a_q^\dagger a_r a_s.$$

   Luego una transformación como la de Jordan-Wigner reescribe esos operadores con matrices de Pauli, y el hamiltoniano queda como una suma de cadenas de Pauli que se pueden medir en un circuito cuántico:

   $$\hat H = \sum_k c_k P_k, \qquad P_k \in \{I, X, Y, Z\}^{\otimes n}.$$

2. **Encontrar su estado fundamental:** el *Variational Quantum Eigensolver* (VQE) propone un estado de prueba $|\psi(\boldsymbol\theta)\rangle$ preparado por un circuito parametrizado (el *ansatz*), mide su energía en la computadora cuántica y usa un optimizador clásico para ajustar los parámetros $\boldsymbol\theta$. El principio variacional garantiza que

   $$E(\boldsymbol\theta) = \langle \psi(\boldsymbol\theta) | \hat H | \psi(\boldsymbol\theta) \rangle \ge E_0,$$

   así que minimizar $E(\boldsymbol\theta)$ nos acerca a $E_0$ desde arriba.

### El ruido

En 2017, IBM calculó con VQE las curvas de energía de H₂, LiH y BeH₂ en un procesador de 6 qubits (Kandala et al., *Nature* 549, 242). El gran obstáculo era, y sigue siendo, el ruido. Cada compuerta tiene una probabilidad de fallar, y un circuito con muchas compuertas termina devolviendo basura. Por eso, en este desafío no alcanza con llegar al número correcto: importa **cómo** se llega, con cuántas compuertas y con cuántas mediciones.

---

## 02 El desafío

Calcular con VQE la curva de energía de una cadena de cuatro hidrógenos (H₄) mientras se separan sus átomos, y ganarle a CCSD en la zona donde ese método clásico falla. La cadena es recta, con los átomos separados por la misma distancia $d$, en la base STO-3G.

1. **Curva de energía:** calculen $E(d)$ con al menos 10 distancias entre 0,6 Å y 3,0 Å, cada energía con su barra de error $\pm\sigma$ (la incertidumbre estadística de la estimación), y compárenla con CCSD y con la energía exacta (FCI).

2. **Equilibrio y disociación:** obtengan la distancia de equilibrio $R_e$ y la energía de disociación, definida como

   $$D_e = E(3{,}0\ \text{Å}) - E(R_e),$$

   ya que a 3,0 Å los átomos se consideran separados.

3. **Ganarle a CCSD:** desde 1,8 Å en adelante, logren un error menor que el suyo contando la barra de error:

   $$|E_\text{VQE} - E_\text{FCI}| + \sigma < |E_\text{CCSD} - E_\text{FCI}| \quad \text{para } d \ge 1{,}8\ \text{Å}.$$

4. **Meta máxima:** lleguen a precisión química en esa zona:

   $$|E_\text{VQE} - E_\text{FCI}| < 1{,}6\ \text{mHa}.$$

---

## 03 Reglas

- El algoritmo del desafío central es **VQE**. SQD no vale para el desafío central, porque con tan pocos qubits hasta muestras al azar dan la respuesta exacta (pueden usarlo como extra, ver más abajo).
- Las energías reportadas tienen que salir de medir circuitos con EstimatorV2 o SamplerV2 de qiskit_aer, no de leer el estado del simulador.
- Pueden buscar los parámetros como quieran, incluso sin ruido.
- Los métodos clásicos no sirven como resultados: solo para comparar y para elegir puntos de partida.
- En la zona estirada, argumenten por qué su resultado es confiable antes de compararlo con FCI.

---

## 04 Entrega

Un notebook de Google Colab, guardado en una carpeta de Google Drive compartida con el jurado, que corra de punta a punta en Colab (instalando sus propias dependencias) y reproduzca la curva, $R_e$ y $D_e$. Tiene que incluir:

- una tabla con, para cada punto: la energía, su error, los *shots* usados y la cantidad de compuertas cz;
- una explicación de qué decidieron, por qué, y qué no funcionó.

---

## 05 Cosas extra

Nada de esto es obligatorio. Son ideas para quienes tengan tiempo o quieran agregar algo que diferencie su trabajo, y solo se tienen en cuenta si el desafío central está completo.

- **Simulador con ruido:** repetir la curva (o parte de ella) con el modelo de ruido de `ruido.py`, igual para todos: compuertas cz, sx, x y rz, qubits conectados en línea, y una probabilidad de error de 0,1 % por cz y 0,005 % por compuerta de un qubit.
- **Ruido de hardware real:** repetir un punto estirado con el ruido completo de FakeFez.
- **Mitigación de errores:** aplicar técnicas que funcionarían en una computadora real, como *Zero Noise Extrapolation* (ZNE) o corrección de errores de *readout*.
- **Menos qubits:** reducir a 6 qubits o menos usando simetrías y medir cuánto mejora.
- **Precisión química:** lograrla en toda la zona estirada ($d \ge 1{,}8$ Å).
- **Comparar ansätze:** probar distintos *ansätze* y comparar precisión, profundidad y costo.
- **VQE vs. SQD:** correr SQD en la zona estirada y compararlo con VQE, o mostrar si las muestras cuánticas le ganan al azar cuando se pone un tope al tamaño del subespacio.
- **Otra geometría:** correr otra forma de H₄ cambiando solo la geometría.

---

## 06 Evaluación

El jurado va a mirar, entre otras cosas:

- **Precisión y complejidad técnica:** error en la zona estirada comparado con CCSD, precisión en $R_e$ y $D_e$, y qué tan elaborada es la solución.
- **Validación:** barras de error bien calculadas y qué tan convincente es el argumento de confiabilidad.
- **Manejo del presupuesto y de los recursos:** cantidad de compuertas y reparto de *shots* (y, si lo hacen, manejo del ruido y mitigación).
- **Análisis de limitaciones:** hasta dónde funciona el método, dónde falla y por qué.
- **Claridad del notebook:** explicaciones, estructura y reproducibilidad.
- **Creatividad:** las decisiones que tomaron, qué probaron y las cosas extra que sumaron.

> **Importante:** la evaluación es integral y queda a criterio del jurado. Estos puntos orientan sobre qué se va a mirar, pero no son una rúbrica con puntajes ni una lista de requisitos para llegar a una nota.

---

## 07 Recursos

- A. Kandala et al., «Hardware-efficient variational quantum eigensolver for small molecules and quantum magnets», *Nature* 549, 242 (2017).
- K. Temme, S. Bravyi y J. Gambetta, «Error mitigation for short-depth quantum circuits», *Phys. Rev. Lett.* 119, 180509 (2017).
- PySCF, Qiskit Aer y qiskit-addon-sqd.
- Demos de PennyLane: muy buenas explicaciones de VQE y química cuántica (usan PennyLane en lugar de Qiskit, pero los algoritmos son los mismos).
- IBM Quantum Learning: cursos y tutoriales sobre VQE, química cuántica y mitigación de errores.

> Pendiente: el archivo `ruido.py` mencionado en "Cosas extra" no vino en las capturas; ponerlo en `docs/` si lo tienen.
