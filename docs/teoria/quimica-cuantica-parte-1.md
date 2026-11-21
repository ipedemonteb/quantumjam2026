# ¡Bienvenidos a la química cuántica!

¡Hola! Este es un material extra de la *Quantum Jam 2026*, pensado para los que quieran seguir aprendiendo después de las cuatro clases del curso. Vamos a meternos en una de las aplicaciones más prometedoras de la computación cuántica, la **química cuántica**.

El material tiene dos partes. En esta primera parte vamos a ver qué es una molécula, cómo se calcula su energía y cómo se traduce todo eso al idioma de los qubits. En la segunda parte vamos a usar lo que armemos acá para correr algoritmos cuánticos que calculan energías de moléculas.

No hace falta saber química para seguir este material. Lo que sí vamos a usar son las ideas de las clases 1 y 2, como los qubits, los operadores de Pauli, los valores esperados y los circuitos. Si algo no se entiende, pregunten en el canal de Discord.

Como en las clases, van a encontrar ejercicios a lo largo del contenido. Las soluciones están en una notebook aparte, pero les recomendamos intentar resolverlos antes de mirarlas.

**Instalación.** Para instalar todas las librerías necesarias, corran la siguiente celda apretando el botón de play a la izquierda. Además de Qiskit, vamos a usar [PySCF](https://pyscf.org/), una librería gratuita de química que puede tardar un par de minutos en instalarse.

# ¿Por qué química?

En la primera clase vimos que Richard Feynman propuso usar máquinas cuánticas para simular la naturaleza, porque la naturaleza "no es clásica".

Todo lo que pasa en química, desde que dos átomos se unan hasta que un remedio funcione, depende de cómo se acomodan los **electrones** dentro de las moléculas. Y los electrones se comportan de forma cuántica. Por eso, entender la química en serio significa resolver problemas de mecánica cuántica.

El problema es que estos cálculos son muy difíciles para una computadora clásica. En la clase 1 vimos que para describir $N$ qubits necesitamos $2^N$ amplitudes de probabilidad. Con los electrones pasa algo muy parecido, ya que la cantidad de números que necesitamos para describirlos crece de forma exponencial con el tamaño de la molécula. Hoy podemos calcular con exactitud la energía de moléculas pequeñas, pero no la de moléculas grandes como las que aparecen en un medicamento, una batería o un fertilizante.

La pregunta que vamos a responder en este material es la más básica de todas, **¿cuánta energía tiene una molécula?** A partir de la energía se puede saber si una molécula es estable, qué forma tiene, cuánto cuesta romper uno de sus enlaces o si una reacción química va a ocurrir o no.

# Átomos, electrones y orbitales

## Un repaso rápido del átomo

Un átomo tiene un **núcleo** muy pequeño en el centro, con carga positiva, y **electrones** alrededor, con carga negativa. Por ejemplo, el átomo de hidrógeno, el más simple de todos, tiene un núcleo formado por un solo protón y un único electrón.

Muchas veces se dibuja a los electrones girando alrededor del núcleo como si fueran planetas, pero eso no es lo que pasa en realidad. Un electrón no tiene una posición definida, sino que se describe con una función de onda $\psi$, como vimos en la clase 1. Las zonas donde es más probable encontrar al electrón se llaman **orbitales**. Cada orbital tiene una energía asociada, y los electrones tienden a ocupar los orbitales de menor energía.

## La ecuación de Schrödinger

En 1926, Erwin Schrödinger escribió la ecuación que permite calcular los orbitales y sus energías.

\begin{equation}
\hat{H}\left|\psi\right> = E\left|\psi\right>
\end{equation}

Es un problema de autovalores, como los que vimos en la clase 1. $\hat{H}$ es un operador llamado **Hamiltoniano**, que contiene toda la información sobre la energía del sistema (la energía de movimiento de los electrones, la atracción entre los electrones y los núcleos, y la repulsión entre los electrones). La ecuación dice que los estados posibles $\left|\psi\right>$ son los **autovectores** de $\hat{H}$, y que las energías posibles $E$ son sus **autovalores**.

De todos los autovalores, el que más nos interesa es el más chico. Se llama **energía del estado fundamental**, y su autovector es el **estado fundamental**, que es el estado en el que vamos a encontrar a la molécula en condiciones normales. Calcular el autovalor más chico del Hamiltoniano va a ser nuestro objetivo durante todo este material.

## El spin y el principio de exclusión de Pauli

Los electrones tienen una propiedad cuántica llamada **spin**, que puede tomar dos valores. Los llamamos spin "arriba" ($\uparrow$, o $\alpha$) y spin "abajo" ($\downarrow$, o $\beta$).

En 1925, el físico Wolfgang Pauli descubrió una regla muy importante, conocida como **principio de exclusión de Pauli**. Dice que dos electrones no pueden estar en el mismo estado cuántico. En la práctica, esto significa que en cada orbital entran como máximo dos electrones, uno con spin $\uparrow$ y otro con spin $\downarrow$.

Un orbital con un spin determinado (por ejemplo, el orbital de menor energía con spin $\uparrow$) se llama **spin-orbital**. Por el principio de Pauli, cada spin-orbital puede estar en una de dos situaciones, vacío u ocupado por un electrón. Dos opciones, como un bit. Esta idea es la clave de todo lo que viene.

# Nuestra primera molécula

La molécula más simple que existe es la de hidrógeno, $H_2$. Está formada por dos átomos de hidrógeno, es decir, por dos protones y dos electrones. Cuando los dos átomos se acercan, los electrones empiezan a compartirse entre los dos núcleos, y se forma un **enlace químico** que mantiene a los átomos unidos.

## Núcleos quietos y electrones en movimiento

Los protones son unas 1836 veces más pesados que los electrones, así que se mueven mucho más despacio. Por eso, una aproximación muy común es suponer que los núcleos están quietos en posiciones fijas y calcular solamente cómo se comportan los electrones a su alrededor. Esta idea se conoce como **aproximación de Born-Oppenheimer**, por Max Born y Robert Oppenheimer, que la propusieron en 1927.

Con los núcleos fijos, la energía de la molécula depende de dónde los pongamos. En el caso de $H_2$, lo único que importa es la distancia $R$ entre los dos núcleos. Si calculamos la energía para muchas distancias distintas, obtenemos una curva como la siguiente.



Si los núcleos están muy cerca, se repelen y la energía sube muchísimo. Si están muy lejos, tenemos dos átomos de hidrógeno sueltos que casi no se ven entre sí. En el medio hay un mínimo, y la distancia donde está ese mínimo es la **distancia de enlace**, que es la distancia a la que vamos a encontrar a la molécula en la naturaleza. Para $H_2$ es de unos 0,74 ångström. La profundidad del pozo es la **energía de disociación**, que es la energía que hace falta para romper el enlace.

## Unidades

Las distancias dentro de una molécula son muy chicas, así que se miden en **ångström** (Å). Un ångström es $10^{-10}$ metros, es decir, una diez mil millonésima parte de un metro.

Las energías se miden en **Hartree** (Ha), la unidad natural de energía a escala atómica. Un Hartree equivale a unos 27,2 electronvoltios, que es bastante energía para la química. Las diferencias de energía que importan suelen ser mucho más chicas, así que muchas veces vamos a hablar de **miliHartree** (mHa), la milésima parte de un Hartree.

Un número que vamos a usar mucho es el de **precisión química**, que vale 1,6 mHa (equivale a 1 kcal/mol). Si un cálculo tiene un error menor a 1,6 mHa, es lo suficientemente bueno como para predecir cómo se va a comportar una molécula en un experimento.

# Calculando energías con PySCF

Para calcular energías de moléculas vamos a usar [PySCF](https://pyscf.org/), una librería de Python para química cuántica que corre en computadoras clásicas.

Para describir una molécula en PySCF tenemos que indicar los átomos y sus posiciones en ångström, y la **base** de orbitales, que vamos a explicar en un momento. También se puede indicar la carga y el spin de la molécula. Si no decimos nada, PySCF supone que la molécula es neutra y que todos sus electrones están apareados, que es lo que vamos a usar siempre.

Los átomos se escriben como un texto, con el símbolo de cada átomo seguido de sus coordenadas $x$, $y$ y $z$. Para $H_2$, ponemos un hidrógeno en el origen y el otro sobre el eje $z$.

## La base de orbitales

Para que una computadora pueda trabajar con orbitales, hay que escribirlos como una combinación de funciones más simples, de la misma forma en que en la clase 1 escribíamos un vector como una combinación de los vectores de una base. A ese conjunto de funciones se lo llama **base** (*basis set*, en inglés).

La base más chica que se usa en la práctica se llama **STO-3G**. Usa una sola función por cada orbital de cada átomo, así que para $H_2$ nos deja con solo dos orbitales. Hay bases más grandes, como **6-31G** o **cc-pVDZ**, que dan resultados más precisos pero tienen muchos más orbitales. Más adelante vamos a ver que cada orbital nos va a costar dos qubits, así que elegir la base siempre es un balance entre precisión y costo. En este material vamos a usar casi siempre STO-3G.

## El método de Hartree-Fock

El método más básico para calcular la energía de una molécula se llama **Hartree-Fock**, por Douglas Hartree y Vladimir Fock, que lo desarrollaron alrededor de 1930.

Calcular cómo interactúa cada electrón con cada uno de los demás es muy difícil, así que Hartree-Fock hace una simplificación. Supone que cada electrón siente solamente el efecto *promedio* de todos los otros, como si los demás electrones formaran una nube fija. Con esa simplificación, el problema se vuelve mucho más fácil de resolver.

El resultado de Hartree-Fock son los orbitales de la molécula, ordenados por energía, y una primera estimación de la energía total. Los electrones se acomodan llenando los orbitales de menor energía, de a dos por orbital.

La energía total incluye también la repulsión entre los dos núcleos. Como los núcleos están quietos, esa repulsión es simplemente un número que se suma al final.

Repite el cálculo de Hartree-Fock para $H_2$ a 0,735 Å con las bases ```sto-3g```, ```6-31g``` y ```cc-pvdz```. Para cada una, muestra la cantidad de orbitales y la energía de Hartree-Fock.

¿Qué pasa con la energía a medida que la base crece? Si cada orbital cuesta dos qubits, ¿cuántos qubits necesitaríamos con cada base?

# La respuesta exacta y la energía de correlación

Hartree-Fock es una aproximación, así que su energía tiene un error. ¿Cómo podemos saber de cuánto es ese error?

Para moléculas pequeñas existe un método que da la respuesta exacta (dentro de la base elegida), llamado **interacción de configuraciones completa**, o **FCI** por sus siglas en inglés (*full configuration interaction*). FCI considera todas las formas posibles de acomodar a los electrones en los orbitales y busca la mejor combinación de todas. El problema es que la cantidad de formas crece muy rápido con el tamaño de la molécula, así que FCI solo se puede usar para moléculas chicas. Más adelante vamos a contar exactamente cuántas formas hay.

La diferencia entre la energía exacta y la de Hartree-Fock se llama **energía de correlación**.

\begin{equation}
E_{\text{correlación}} = E_{\text{FCI}} - E_{\text{HF}}
\end{equation}

La energía de correlación es pequeña comparada con la energía total, pero es muy importante para la química, y calcularla bien es uno de los problemas centrales de la química cuántica.

Si hicieron el ejercicio anterior, habrán notado que el error de Hartree-Fock nunca baja de la precisión química, y que se vuelve enorme cuando estiramos la molécula.

La razón es que Hartree-Fock pone a los dos electrones juntos en el mismo orbital, compartido entre los dos núcleos. Cerca de la distancia de enlace eso tiene bastante sentido, pero cuando los átomos se separan, lo que pasa en realidad es que cada electrón se queda con su propio núcleo. Hartree-Fock no puede describir esa situación, y en su lugar le da mucha probabilidad a estados donde los dos electrones quedan en el mismo átomo, que tienen bastante más energía.

Cuando el estado de una molécula no se puede describir bien con una sola forma de acomodar a los electrones, los químicos dicen que tiene **correlación fuerte**. Aparece cuando se estiran o se rompen enlaces, y también en muchas moléculas importantes para la industria. Es el tipo de problema donde las computadoras cuánticas podrían ayudar.

# Electrones como bitstrings

## Configuraciones

Volvamos a la idea de los spin-orbitales. En $H_2$ con la base STO-3G hay dos orbitales. El de menor energía se llama **orbital enlazante**, porque concentra a los electrones entre los dos núcleos y los mantiene unidos. El de mayor energía se llama **orbital antienlazante**. Cada orbital tiene dos spin-orbitales (uno $\uparrow$ y otro $\downarrow$), así que en total hay cuatro, y cada uno puede estar vacío (0) u ocupado (1).

Una forma concreta de acomodar a los electrones en los spin-orbitales se llama **configuración** (los químicos también le dicen *determinante de Slater*). Cualquier configuración se puede escribir como un bitstring. Por ejemplo, en la configuración de Hartree-Fock de $H_2$ los dos electrones están en el orbital enlazante.

Vamos a usar siempre la misma convención, que es la que usan las librerías de química de IBM. Los primeros bits, empezando por la derecha, corresponden a los spin-orbitales $\alpha$, y los siguientes a los spin-orbitales $\beta$. Dentro de cada grupo, los orbitales van de menor a mayor energía, también empezando por la derecha. Es el mismo ordenamiento *little-endian* de Qiskit que vimos en la clase 2. Con esta convención, la configuración de Hartree-Fock de $H_2$ se escribe ```0101```.

## El estado exacto es una superposición

El estado fundamental exacto de una molécula, en general, no es una sola configuración, sino una **superposición** de muchas configuraciones.

\begin{equation}
\left|\psi\right> = c_1\left|0101\right> + c_2\left|1010\right> + c_3\left|0110\right> + \cdots
\end{equation}

Los números $c_i$ funcionan igual que las amplitudes de probabilidad de la clase 1, y $|c_i|^2$ es el **peso** de cada configuración. Es un estado de qubits! Hartree-Fock se queda con una sola configuración, mientras que FCI encuentra la superposición completa.

La siguiente función calcula el estado exacto con FCI y devuelve las configuraciones con más peso

## ¿Cuántas configuraciones hay?

Supongamos que una molécula tiene $n$ orbitales, $n_\alpha$ electrones con spin $\uparrow$ y $n_\beta$ electrones con spin $\downarrow$. La cantidad de formas de elegir qué orbitales ocupan los electrones $\uparrow$ es el número combinatorio $\binom{n}{n_\alpha}$, que se lee "$n$ tomados de a $n_\alpha$". Lo mismo pasa con los electrones $\downarrow$, y como las dos elecciones son independientes, la cantidad total de configuraciones es

\begin{equation}
\binom{n}{n_\alpha}\binom{n}{n_\beta}
\end{equation}

En Python, el número combinatorio $\binom{n}{k}$ se calcula con ```comb(n, k)```.

Por otro lado, con $2n$ spin-orbitales hay $2^{2n}$ bitstrings posibles. Pero la mayoría no tiene la cantidad correcta de electrones, así que no representan a nuestra molécula. Por ejemplo, ```1111``` tiene cuatro electrones y ```0001``` tiene uno solo, pero $H_2$ tiene dos.

# De electrones a qubits

## El Hamiltoniano de una molécula

Para usar una computadora cuántica necesitamos escribir el Hamiltoniano de la molécula en el idioma de los qubits, es decir, como una suma de operadores de Pauli, como los que creábamos con ```SparsePauliOp``` en la clase 2.

Los químicos escriben el Hamiltoniano usando dos operadores especiales para cada spin-orbital $p$. El **operador de creación** $a_p^\dagger$ agrega un electrón en el spin-orbital $p$ (lo pasa de 0 a 1), y el **operador de destrucción** $a_p$ saca el electrón del spin-orbital $p$ (lo pasa de 1 a 0). Con estos operadores, el Hamiltoniano de cualquier molécula tiene la siguiente forma.

\begin{equation}
\hat{H} = E_{\text{nuc}} + \sum_{p,q} h_{pq}\, a_p^\dagger a_q + \frac{1}{2}\sum_{p,q,r,s} g_{pqrs}\, a_p^\dagger a_r^\dagger a_s a_q
\end{equation}

El primer término es la repulsión entre los núcleos, que es un número fijo. El segundo término describe a un electrón que salta del spin-orbital $q$ al spin-orbital $p$ (sale de $q$ con $a_q$ y entra en $p$ con $a_p^\dagger$), y el número $h_{pq}$ dice cuánta energía tiene asociada ese salto. El tercer término describe a dos electrones que saltan al mismo tiempo porque se repelen entre sí, y el número $g_{pqrs}$ cumple el mismo papel.

Los números $h_{pq}$ y $g_{pqrs}$ son **integrales**, y son lo que calcula PySCF a partir de las posiciones de los átomos y de la base. Una vez que los tenemos, el Hamiltoniano queda completamente definido.

## El mapeo de Jordan-Wigner

Los operadores $a_p^\dagger$ y $a_p$ no son operadores de Pauli, así que hay que traducirlos. La traducción más directa se llama **mapeo de Jordan-Wigner**, y fue propuesta en 1928 por los físicos Pascual Jordan y Eugene Wigner. La idea es asignarle un qubit a cada spin-orbital, de forma que el qubit esté en $\left|1\right>$ si el spin-orbital está ocupado y en $\left|0\right>$ si está vacío.



Veamos cómo queda el operador de destrucción para un solo spin-orbital. Necesitamos un operador que lleve $\left|1\right>$ a $\left|0\right>$ (sacar el electrón) y que anule al estado $\left|0\right>$ (no se puede sacar un electrón de un lugar vacío). Ese operador es el producto externo $\left|0\right>\left<1\right|$, y lo podemos escribir con matrices de Pauli.

\begin{equation}
a = \left|0\right>\left<1\right| = \begin{bmatrix} 0 & 1 \\ 0 & 0 \end{bmatrix} = \frac{X + iY}{2}
\end{equation}

Cuando hay varios spin-orbitales, Jordan-Wigner agrega operadores $Z$ en todos los qubits anteriores.

\begin{equation}
a_p = Z_0 Z_1 \cdots Z_{p-1}\,\frac{X_p + iY_p}{2}
\end{equation}

Esas $Z$ están por una propiedad de los electrones. Los electrones son **fermiones**, y cuando se intercambian dos fermiones, el estado cambia de signo. Las $Z$ se encargan de llevar la cuenta de ese signo. Con esta receta, cualquier término del Hamiltoniano se convierte en una suma de operadores de Pauli.

## Del Hamiltoniano molecular al Hamiltoniano de qubits

La siguiente celda define tres funciones.

- ```molecula``` usa PySCF para calcular Hartree-Fock, la energía exacta y las integrales $h_{pq}$ y $g_{pqrs}$. Devuelve todo en un diccionario.
- ```destruccion_jordan_wigner``` arma el operador de destrucción $a_p$ con la receta de Jordan-Wigner.
- ```hamiltoniano_qubits``` arma el Hamiltoniano con los operadores de creación y destrucción y lo devuelve como un ```SparsePauliOp```.

# Menos qubits, mismo resultado

Las computadoras cuánticas actuales tienen una cantidad limitada de qubits, y cada qubit que agregamos suma ruido. Si en cambio simulamos en una computadora clásica, cada qubit extra duplica la memoria necesaria. Por eso, antes de correr cualquier algoritmo, vale la pena preguntarse si se puede resolver el mismo problema con menos qubits. Veamos dos trucos.

## Primer truco, congelar orbitales

Los átomos más pesados que el hidrógeno tienen electrones muy cerca del núcleo, en orbitales de muy baja energía. Por ejemplo, el oxígeno tiene dos electrones en su orbital más interno, llamado 1s. Esos electrones están tan atrapados por el núcleo que casi no participan de los enlaces químicos.

La idea es dejarlos fijos en su lugar. Decimos que esos orbitales están **congelados**, y solo trabajamos con el resto, que se llaman **orbitales activos**. Cada orbital congelado nos ahorra dos qubits, a cambio de un error muy chico. La función ```molecula``` tiene el parámetro ```n_congelados```, que indica cuántos orbitales de menor energía queremos congelar.

## Segundo truco, usar las simetrías

El segundo truco usa información que ya conocemos de antemano. Sabemos cuántos electrones tiene la molécula, y cuántos de ellos tienen spin $\uparrow$ y cuántos spin $\downarrow$. Esa información está "escondida" en los qubits de Jordan-Wigner, pero no la aprovechamos.

Existe otro mapeo, llamado **mapeo de paridad**, que guarda la información de otra forma. En lugar de guardar en el qubit $k$ si el spin-orbital $k$ está ocupado, guarda la **paridad** de los spin-orbitales $0, 1, \ldots, k$. Es decir, el qubit $k$ vale 0 si la cantidad de electrones en esos spin-orbitales es par, y vale 1 si es impar.

Con nuestro ordenamiento, eso tiene una consecuencia muy útil. El último qubit $\alpha$ guarda la paridad de todos los electrones $\alpha$, y el último qubit de todos guarda la paridad de todos los electrones de la molécula. Pero esas dos cosas ya las conocemos. En $H_2$, por ejemplo, hay un electrón $\alpha$ (impar) y dos electrones en total (par). Esos dos qubits van a tener siempre el mismo valor, así que no necesitamos simularlos.

En el mapeo de paridad, esos dos qubits solo aparecen en el Hamiltoniano con $I$ o con $Z$. Lo que hacemos es reemplazar cada $Z$ de esos qubits por su valor, que es $+1$ si la paridad es par y $-1$ si es impar (recuerden que $Z\left|0\right> = \left|0\right>$ y $Z\left|1\right> = -\left|1\right>$). Así, el Hamiltoniano pierde dos qubits y sigue teniendo exactamente las mismas energías. A esta técnica se la suele llamar **reducción de dos qubits**.

Por si tienen curiosidad, el operador de destrucción en el mapeo de paridad es el siguiente, donde $N$ es la cantidad de qubits.

\begin{equation}
a_p = \frac{Z_{p-1}X_p + iY_p}{2}\, X_{p+1} \cdots X_{N-1}
\end{equation}

Las moléculas que tienen simetrías geométricas (por ejemplo, las que se ven iguales al rotarlas o al reflejarlas en un espejo) permiten eliminar todavía más qubits con la misma idea. Si les interesa, busquen *qubit tapering*.

# ¿Cuánto cuesta medir la energía?

En una computadora cuántica no podemos ver la matriz del Hamiltoniano. Lo único que podemos hacer es medir. En la clase 2 vimos que el ```Estimator``` calcula valores esperados de operadores de Pauli, y que para eso ejecuta el circuito muchas veces (los *shots*) y promedia los resultados. Como el Hamiltoniano es una suma de operadores de Pauli, su valor esperado es la suma de los valores esperados de cada término.

\begin{equation}
\left<\hat{H}\right> = \sum_k c_k \left<P_k\right>
\end{equation}

El problema es que cada término necesita sus propias mediciones, y las moléculas tienen muchos términos. Por suerte, muchos de ellos se pueden medir al mismo tiempo.

Para medir un qubit en la base de $X$ o de $Y$, antes de medir se aplica una rotación (por ejemplo, una compuerta de Hadamard para medir en la base de $X$). Si dos términos piden la misma base en cada qubit, o si uno de ellos tiene la identidad $I$ en ese qubit, alcanza con un solo circuito para medir los dos. Por ejemplo, $ZZII$ y $ZIZI$ se pueden medir juntos, pero $ZZII$ y $XXII$ no. Decimos que esos términos **conmutan qubit a qubit**.

Qiskit agrupa los términos automáticamente con el método ```.group_commuting(qubit_wise=True)```, que devuelve una lista de grupos. Cada grupo se puede medir con un solo circuito.

Existen formas más avanzadas de agrupar términos, que juntan también términos que conmutan pero no qubit a qubit (como $ZZ$ y $XX$). A cambio, necesitan un circuito un poco más complicado antes de medir.

Para $H_2$, la cadena $H_4$ y el agua con un orbital congelado, muestra la cantidad de qubits, la cantidad de términos del Hamiltoniano y la cantidad de grupos que conmutan qubit a qubit. ¿Cuántos circuitos nos ahorramos en cada caso? ¿Cómo crece la cantidad de términos con la cantidad de qubits?

# Resumen

En esta primera parte armamos todo lo necesario para atacar problemas de química con una computadora cuántica. Vimos que la energía de una molécula es el autovalor más chico de su Hamiltoniano, y aprendimos a calcularla con métodos clásicos como Hartree-Fock y FCI. Vimos que las configuraciones de los electrones se escriben como bitstrings y que el estado exacto es una superposición de configuraciones. Por último, convertimos el Hamiltoniano en una suma de operadores de Pauli, aprendimos a usar menos qubits y a medir la energía con menos circuitos.

En la segunda parte vamos a buscar ese autovalor más chico con algoritmos cuánticos.

# Bibliografía complementaria

- La [documentación de PySCF](https://pyscf.org/user.html), con muchos ejemplos.
- A. Szabo y N. S. Ostlund, *Modern Quantum Chemistry*, Dover (1996). Es el libro clásico para aprender en detalle la química cuántica de esta clase, como Hartree-Fock y la interacción de configuraciones.
- S. McArdle y otros, [*Quantum computational chemistry*](https://arxiv.org/abs/1808.10402), Reviews of Modern Physics (2020). Es una revisión muy completa de la química en computadoras cuánticas, con los mapeos, las reducciones de qubits y los algoritmos.
- La [documentación de SparsePauliOp](https://quantum.cloud.ibm.com/docs/en/api/qiskit/qiskit.quantum_info.SparsePauliOp) en Qiskit.
