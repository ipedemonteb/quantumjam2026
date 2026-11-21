¡Bienvenidos a la segunda parte de la Clase 2 de la *Quantum Jam 2026*! Para ejecutar el código de los ejercicios, corran la siguiente celda:

# Circuitos cuánticos en Qiskit

En esta sección, discutiremos brevemente sobre las clases y métodos de Qiskit para crear y correr circuitos cuánticos. Sin embargo, es importante realizar la ejercitación integradora para aprender los conceptos tratados acá. Para muchos participantes, puede ser útil ir directamente a los ejercicios y consultar esta sección (además de la documentación) a medida que avancen.

## Algunos elementos básicos para crear circuitos

**Crear y visualizar circuitos cuánticos:** en Qiskit, creamos circuitos cuánticos con la clase ```QuantumCircuit``` (pueden ver la documentación [acá](https://quantum.cloud.ibm.com/docs/en/api/qiskit/qiskit.circuit.QuantumCircuit)). Al instanciar un circuito cuántico, podemos especificar como parámetros la cantidad de qubits y el número de bits clásicos sobre los que aparecerán los resultados de las medidas proyectivas que realicemos. Podremos aplicar cualquier compuerta a los qubits del circuito utilizando el método apropiado que especifique dicha compuerta y los qubits a los que se le aplicará. Además, podemos obtener un objeto de la clase ```Statevector``` que represente el estado del sistema a partir del circuito, utilizando el método ```.from_instruction()```. Para visualizar el circuito, podemos utilizar el método ```.draw()```, en el que podemos especificar el formato de visualización (por ejemplo, ```'text'```, ```'mpl'``` o ```'latex'```). También podemos dar vuelta el orden de los qubits en el dibujo con ```reverse_bits```.

**Circuitos dinámicos:** Qiskit admite circuitos dinámicos donde las operaciones pueden condicionarse a los resultados clásicos de las mediciones (por ejemplo: si el resultado de la medición de un qubit fue $0$, aplico una compuerta determinada; si fue $1$, aplico otra compuerta). Podemos crear bloques condicionales donde las operaciones ejecutadas se basen en valores de bits clásicos utilizando el gestor de contexto (*context manager*) `if_test()`.

**Ordenamiento de qubits:** en Qiskit, los qubits se ordenan de arriba hacia abajo: el qubit que aparece en el cable de más arriba es $|q_0\rangle$, el que está inmediatamente debajo es $|q_1\rangle$, le sigue $|q_2\rangle$, y así sucesivamente. A la hora de escribir el estado general de múltiples qubits, Qiskit los ordena de derecha a izquierda: $|\psi\rangle=|q_n\rangle\cdots|q_2\rangle|q_1\rangle|q_0\rangle$. Esta convención suele ser una de las características más molestas de Qiskit para los usuarios, ya que toda la bibliografía de computación cuántica ordena los qubits al revés ($|\psi\rangle=|q_0\rangle|q_1\rangle|q_2\rangle\cdots|q_n\rangle$). Por este motivo, las representaciones matriciales de más de $2\times 2$ de compuertas y operadores presentarán diferencias con las presentadas en estas clases y en los libros.  

**Parámetros:** Qiskit admite circuitos con parámetros simbólicos usando la clase `Parameter`. Estos parámetros actúan como marcadores de posición (*placeholders*) que pueden vincularse a valores numéricos específicos más adelante mediante el método `assign_parameters()`. Esto es fundamental para algoritmos variacionales como VQE y QAOA.

## Qiskit Patterns

**Qiskit Patterns** es un marco de trabajo en cuatro pasos para llevar un problema desde su formulación clásica hasta un resultado cuántico interpretable. Los pasos son:

1. **Map the problem to circuits:** mapear el problema que queremos resolver a un algoritmo implementado con circuitos y operadores.
2. **Optimize for hardware:** optimizar el circuito abstracto para que pueda ejecutarse en la topología del hardware real (adapta un circuito cuántico a las limitaciones de un dispositivo cuántico específico, incluidas sus compuertas base y la conectividad entre qubits). Este proceso se denomina transpilación, y produce un circuito que sí puede ser ejecutado por nuestro backend, ya sea simulado o una computadora cuántica real a la que accedemos a través de la nube. Dicho circuito se denomina circuito ISA (Instruction Set Architecture). La función `generate_preset_pass_manager()` crea un administrador de pases de transpilación con configuraciones preestablecidas. Tiene varias configuraciones de `optimization_level` (0-3), donde los niveles más altos aplican técnicas de optimización más avanzadas para reducir la profundidad del circuito y el número de compuertas, a costa de un mayor tiempo de compilación. La profundidad del circuito es una medida de cuántas "capas" de compuertas ejecutadas en paralelo necesitan atravesarse para ejecutar el circuito completo.
3. **Execute on hardware:** ejecutar el circuito ISA con primitivas como *Sampler* (devuelve un espacio muestral de resultados del circuito) y *Estimator* (devuelve los valores esperados del circuito), ya sea local o en la nube.
4. **Post-process results:** procesar y presentar los resultados con técnicas clásicas de análisis y procesamiento de datos.



A medida que realicen los ejercicios, quedará más claro cómo transpilar, optimizar y ejecutar circuitos, además de cómo utilizar Sampler y Estimator. Puede ser útil recurrir al siguiente template, proporcionado en el tutorial [Hello World](https://quantum.cloud.ibm.com/docs/en/tutorials/hello-world) de Qiskit, para realizar todos los pasos del Qiskit Pattern cuando el ejercicio lo requiera:

# Ejercitación integradora

## operadores de Pauli (operadores de un solo qubit)

Los operadores de Pauli (X, Y, Z e I) son matrices de 2x2 que representan operaciones elementales de un solo qubit. En Qiskit, se pueden crear usando la clase `Pauli` (ejemplo: `Pauli('X')` para el operador X). También se pueden construir Paulis de múltiples qubits especificando caracteres para cada qubit (ejemplo: `'IX'` para la identidad en el qubit 0 y X en el qubit 1, siguiendo el ordenamiento de bits "little-endian" de Qiskit).

Escribe un código que realice lo siguiente:
1. Crea un operador de Pauli de 3 qubits representando `Z` en el qubit 2, `Y` en el qubit 1 e `I` (identidad) en el qubit 0.
2. Imprime el operador.
3. Imprime la representación matricial correspondiente.

## compuertas y fases de un solo qubit

Las compuertas de un solo qubit, como X, Y, Z, H, S y T, son operaciones básicas que actúan sobre un qubit. Las compuertas S y T son compuertas de fase. La compuerta S introduce una fase de π/2 en el componente ∣1⟩ de cualquier estado cuántico, mientras que la compuerta T introduce un desfase de π/4 en el componente ∣1⟩, manteniendo inalterado el componente ∣0⟩ en ambos casos. Estos cambios de fase son cruciales en muchos algoritmos cuánticos.

Escribe un código que realice lo siguiente:
1. Crea un circuito cuántico de un qubit.
2. Pone al qubit en el estado $|1\rangle$.
3. Añade una sola compuerta al circuito que aplica una fase de π/4 al qubit.
4. Muestra la representación en notación de Dirac del vector de estado del circuito.

## superposición y rotaciones en la esfera de Bloch

Las compuertas como `RX`, `RY` y `RZ` realizan rotaciones alrededor de los ejes de la esfera de Bloch, creando una superposición de estados. Una rotación por un ángulo θ alrededor del eje Y (`RY(θ)`) en un estado inicial |0⟩ produce la superposición cos(θ/2)|0⟩ + sin(θ/2)|1⟩. Las probabilidades de medir 0 ó 1 son el cuadrado de estas amplitudes.

Escribe un código que realice lo siguiente:

1. Crea un circuito cuántico de un qubit.
2. Aplica una única compuerta al qubit 0 (inicialmente en el estado |0⟩) para crear una superposición donde la probabilidad de medir |0⟩ sea aproximadamente 14.6% y la probabilidad de medir |1⟩ sea 85.4%.
3. Imprime las probabilidades.
4. Muestra la representación en la esfera de Bloch del vector de estado.

## entrelazamiento y operaciones de múltiples qubits

Algunas compuertas de múltiples qubits como la CNOT (qc.cx(control, target)) crean entrelazamiento cuando se las aplica a estados superpuestos. Un estado entrelazado común es el estado de Bell |Φ+⟩ = 1/√2(|00⟩ + |11⟩)

Multi-qubit gates like the CNOT (`qc.cx(control, target)`) create entanglement when applied to superposition states. A common entangled state is the Bell state |Φ+⟩ = 1/√2(|00⟩ + |11⟩), que se crea aplicando una compuerta de Hadamard a un qubit y luego una compuerta CNOT. Recuerden el ordenamiento de bits de Qiskit: el qubit 0 es el de más a la derecha (el menos significativo).

Escribe un código que realice lo siguiente:

1. Crea un circuito cuántico de dos qubits.
2. Crea el estado de Bell |Φ+⟩, donde el primero qubit (q0) es el qubit de control.
3. Dibuja el circuito cuántico usando matplotlib.
4. Imprime el vector de estado del circuito.

## construyendo y dibujando circuitos cuánticos

La clase `QuantumCircuit` se usa para construir circuitos cuánticos. El método `draw()` proporciona visualizaciones en formatos como `'text'`, `'mpl'` y `'latex'`. Pueden personalizar el dibujo con parámetros como `reverse_bits` para dar vuelta el ordenamiento de qubits.

Escribe un código que realice lo siguiente:
1. Crea un estado GHZ de 3 qubits.
2. Dibuja el circuito con el ordenamiento de qubits revertido en el diagrama (q2 arriba, q0 abajo).

## circuitos dinámicos y flujo de control clásico

Qiskit admite circuitos dinámicos donde las operaciones pueden condicionarse a los resultados de las mediciones. El gestor de contexto (*context manager*) `if_test()` puede utilizarse para crear bloques condicionales donde las operaciones ejecutadas se basan en valores de bits clásicos. Esto nos permite una potente prealimentación (*feed-forward*) clásica en nuestros programas cuánticos.

Escribe un código que realice lo siguiente:

1. Crea un circuito cuántico con dos qubits y al menos un bit clásico.
2. Añade una compuerta de Hadamard al qubit menos significativo.
3. Aplica una compuerta X al qubit 1 *si y sólo si* una medición del qubit 0 produce el resultado `1`. Utiliza el gestor de contexto `if_test()` con la tupla de condición adecuada.
4. Dibuja el circuito usando matplotlib.

## visualizando resultados y estados cuánticos

Qiskit ofrece varias funciones para visualizar resultados. `plot_histogram(counts)` se usa para mostrar resultados de mediciones de una simulación o una ejecución en un dispositivo real. Pueden ordenar los resultados para un análisis más fácil; por ejemplo, en base a la frecuencia de los resultados.

Escribe un código que realice lo siguiente:
1. Crea un circuito cuántico que contenga el estado de Bell |Φ+⟩.
2. Mide el resultado sobre cables clásicos.
3. Corre el circuito usando el simulador `AerSimulator`.
4. Obtiene el recuento de las mediciones.
5. Grafica un histograma con las barras ordenadas desde el resultado más común hasta el menos común.

## circuitos cuánticos parametrizados

Qiskit admite circuitos con parámetros simbólicos usando la clase `Parameter`. Estos parámetros actúan como marcadores de posición (*placeholders*) que pueden vincularse a valores numéricos específicos más adelante mediante el método `assign_parameters()`. Esto es fundamental para algoritmos variacionales como VQE y QAOA.

Escribe un código que realice lo siguiente:
1. Instancia un `Parameter` para representar un parámetro llamado `theta`.
2. Crea el circuito cuántico `qc` de un qubit.
3. Añade la compuerta RX con el parámetro `theta` al cable del qubit.
4. Dibuja el circuito `qc`.
5. Crea un nuevo circuito `bound_qc` vinculando el parámetro `theta` al valor `π/2`.
6. Dibuja el circuito `bound_qc`.

## transpilación y optimización de circuitos

La transpilación adapta un circuito cuántico a las limitaciones de un dispositivo cuántico específico, incluidas sus compuertas base y la conectividad entre qubits. La función `generate_preset_pass_manager()` crea un administrador de pases de transpilación con configuraciones preestablecidas. Tiene varias configuraciones de `optimization_level` (0-3), donde los niveles más altos aplican técnicas de optimización más avanzadas para reducir la profundidad del circuito y el número de compuertas, a costa de un mayor tiempo de compilación.

Escribe un código que realice lo siguiente:
1. Crea un circuito GHZ de 3 qubits.
2. Transpila el circuito para el backend `FakeVigoV2`, usando el nivel más alto de optimización (nivel 3).
3. Imprime la profundidad del circuito original.
4. Imprime la profundidad del circuito transpilado.
5. Dibuja el circuito transpilado.

## modos de ejecución de Qiskit Runtime

Qiskit Runtime ofrece tres modos de ejecución: **job**, **session** y **batch**. Los modos de ejecución determinan cómo se programan nuestros trabajos en el cronograma de la computadora cuántica, y elegir el modo correcto permite que la carga de trabajo se ejecute eficientemente, sin exceder un presupuesto determinado.

Esta es una pregunta conceptual. En la celda a continuación, explique qué modo de ejecución (job, session o lote) utilizaría para un algoritmo VQE (Variational Quantum Eigensolver) y explique brevemente por qué.

## las primitivas Sampler y Estimator

Las primitivas son interfaces de alto nivel para tareas cuánticas comunes. **Sampler** y **Estimator** son dos primitivas claves que cumplen distintas funciones cuando se trabaja con circuitos cuánticos. Sirven para abstraer los detalles de la ejecución y la mitigación de errores, lo que facilita la extracción de información importante de la computación cuántica.

Esta es una pregunta conceptual. En la celda a continuación, describa en una oración la diferencia fundamental entre las primitivas Sampler y Estimator.

## usando la primitiva Sampler

En Qiskit, pueden usar la primitiva `Sampler` de `qiskit_ibm_runtime` con simuladores locales como `AerSimulator`. Acá, inicializarán `Sampler` en el modo backend, transpilarán su circuito utilizando `generate_preset_pass_manager` y luego usarán el método `.run([circuits], shots=...)`. El objeto resultante contendrá datos de mediciones accesibles mediante los nombres de registros clásicos.

Escribe un código que realice lo siguiente:
1. Crea un circuito cuántico que contenga el estado de Bell |Φ+⟩.
2. Usa el método `measure_all` para medir los resultados.
3. Transpila el circuito usando el backend `AerSimulator`.
4. Inicializa la primitiva `Sampler` con el backend `AerSimulator`.
5. Corre el Sampler.
6. Obtiene la cantidad de mediciones de cada resultado.
7. Imprime la cantidad de mediciones de cada resultado.

## usando la primitiva Estimator

En Qiskit, pueden usar la primitiva `Estimator` de `qiskit_ibm_runtime` con simuladores locales como `AerSimulator`. `Estimator` ejecuta los valores esperados ⟨ψ|O|ψ⟩. Acá, inicializarán `Estimator` en el modo backend, transpilarán su circuito usando `generate_preset_pass_manager`, aplicarán el observable al layout del circuito y luego usarán el método `.run([(circuit, observable)])`. El objeto resultante contendrá los valores esperados, accesibles via `data.evs`.

Escribe un código que realice lo siguiente:
1. Crea un circuito cuántico que contenga el estado de Bell |Φ+⟩.
2. Define el observable ZZ usando `SparsePauliOp`.
3. Transpila el circuito usando el backend `AerSimulator`.
4. Aplica el observable al layout del circuito.
5. Inicializa la primitiva `Estimator` con el backend `AerSimulator`.
6. Corre el Estimator.
7. Obtiene el resultado PUB (Primitive Unified Block).
8. Recupera e imprime el valor esperado.

## técnicas de mitigación de errores

Qiskit proporciona técnicas para reducir el impacto del ruido en el hardware cuántico. El **readout error mitigation** (mitigación de errores de lectura) corrige errores en el paso final de la medición. El **Dynamical Decoupling (DD)** (desacoplamiento dinámico) inserta secuencias de pulsos durante los tiempos de inactividad para proteger los qubits de la decoherencia. La **Zero-Noise Extrapolation (ZNE)** (extrapolación de ruido cero) corre circuitos con diferentes niveles de ruido y extrapola el resultado hasta el límite de ruido cero.

Esta es una pregunta conceptual. Estás ejecutando un circuito en un backend ruidoso y sospechas que los qubits pierden su estado cuántico (decoherencia) durante los periodos de inactividad del circuito. ¿Qué técnica de *supresión* de errores sería la más adecuada?

## OpenQASM 3

OpenQASM 3 es la última versión del lenguaje ensamblador cuántico. Tiene una sintaxis más expresiva que su predecesor. Por ejemplo, declaramos un registro de 3 qubits con `qubit[3] my_qubits;` y un registro de bits clásicos con `bit[2] c;`.

Completa el string de OpenQASM 3 para crear un estado de Bell entre `q[0]` y `q[1]`.

## OpenQASM 3 vs. OpenQASM 2

OpenQASM 3 introdujo mejoras significativas con respecto a OpenQASM 2, destacando su expansión más allá de los circuitos simples basados ​​en compuertas. Una mejora importante involucra herramientas de programación que le permiten a los programas cuánticos tomar decisiones y repetir operaciones basándose en datos clásicos y resultados de mediciones, lo que permite la implementación de algoritmos cuánticos más dinámicos y adaptativos.

Esta es una pregunta conceptual. ¿Cuál es una característica importante relacionada con lógica clásica que está presente en OpenQASM 3 pero completamente ausente en OpenQASM 2?

## OpenQASM con Qiskit

Qiskit provee las herramientas para convertir objetos de la clase `QuantumCircuit` a strings de OpenQASM 3 y viceversa. Para importar un string de OpenQASM 3 a un circuito de Qiskit, pueden usar la función `qiskit.qasm3.loads()`.

Usando el string de OpenQASM del ejercicio 15, escribe un código de Pyhton que:
1. lo convierta a un `QuantumCircuit` llamado `qc_from_qasm`;
2. dibuje el circuito.

## API de Qiskit IBM Runtime

Las aplicaciones cuánticas modernas normalmente requieren integrar la computación cuántica en flujos de trabajo de software más amplios. IBM Quantum ofrece servicios en la nube a los que se puede acceder desde diversos entornos de programación, además de Python. Se requieren credenciales de autenticación adecuadas para acceder a estos servicios.

Esta es una pregunta conceptual. Estás desarrollando el backend de una aplicación web con Node.js, Go u otro lenguaje distinto de Python, y necesitas enviar trabajos cuánticos a las computadoras cuánticas de IBM. ¿Qué enfoque utilizarías para acceder a los servicios de computación cuántica de IBM y cuál es la información más importante que necesitarías para autenticar tus solicitudes?

## ejecutando código en el hardware real de IBM (opcional)

**Importante:** se requiere que hayas configurado correctamente una cuenta de IBM Cloud para acceder a una computadora cuántica a través de la nube.

En un ejercicio anterior, utilizaron la primitiva `Sampler` de `qiskit_ibm_runtime` con el simulador local `AerSimulator`. Acá, ejecutarán la primitiva `Sampler` en una computadora cuántica real de IBM.

Edita el código de abajo de la siguiente forma:
1. Comenta la siguiente línea:
```
backend = AerSimulator()
```
2. Agrega las siguientes líneas inmediatamente después:
```
service = QiskitRuntimeService(name="fallfest-2026")
backend = service.least_busy(operational=True, simulator=False)
```

# Bibliografía

La bibliografía mencionada es completamente optativa y sirve como orientación para quienes decidan profundizar en los temas vistos en esta clase.

Libros sobre computación cuántica:

[1] M. A. Nielsen, I. L. Chuang, *Quantum Computation and Quantum Information*. Cambridge, U.K.: Cambridge Univ. Press, 2000.

[2] E. G. Rieffel, W. H. Polak, *Quantum Computing: A Gentle Introduction*. Cambridge, MA, USA: MIT Press, 2011.

[3] R. S. Sutor, *Dancing with Qubits: How Quantum Computing Works and How It Can Change the World*. Birmingham, U.K.: Packt Publishing, 2019.

Libros sobre mecánica cuántica:

[4] C. Cohen-Tannoudji, B. Diu, F. Laloë, *Quantum Mechanics, vol. 1*. New York, NY, USA: John Wiley & Sons, 1977.

[5] R. A. Serway, C. J. Moses, C. A. Moyer, *Modern Physics*, 3rd ed. Boston, MA, USA: Cengage Learning, 2020.

Libros sobre electrónica digital y arquitectura de computadoras:

[6] J. F. Wakerly, *Digital Design, Principles and Practices*, 5th ed. New York, NY, USA: Pearson Education, 2018.

[7] T. L. Floyd, *Digital Fundamentals*, 11th ed. New York, NY, USA: Pearson Education, 2015.

[8] A. S. Tannenbaum,  T. Austin, *Structured Computer Organization*, 6th ed. New York, NY, USA: Pearson Education, 2013.

[9] J. Hennessy, D. Patterson, *Computer Architecture: A Quantitative Approach*, 6th ed. Cambridge, MA, USA: Morgan Kaufmann / Elsevier, 2017.

[10] W. Stallings, *Computer Organization and Architecture*, 10th ed. New York, NY, USA: Pearson Education, 2016.
