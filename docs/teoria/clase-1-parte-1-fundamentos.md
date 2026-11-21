# ¡Bienvenidos a la Quantum Jam 2026!

Hola! Esta es la primera clase de fundamentos de la computación cuántica y Qiskit, dentro del marco de la *Quantum Jam 2026* y el *Qiskit Fall Fest 2026*. En este curso de cuatro clases aprenderán las bases necesarias para afrontar importantes desafíos de computación cuántica y pasar [de cero a héroe](https://www.youtube.com/watch?v=Ye-hSDw6OWA) en tan solo un mes.

Las clases se estructurarán de la siguiente manera:

- **Clase 1:** fundamentos de la computación cuántica
- **Clase 2:** circuitos cuánticos
- **Clase 3:** algoritmos cuánticos y comunicaciones (parte 1)
- **Clase 4:** algoritmos cuánticos y comunicaciones (parte 2)

A lo largo del contenido, se encontrarán con ejercicios de programación en Qiskit. Sugerimos que los hagan, buscando documentación y consultando las dudas que surjan. Estos ejercicios están diseñados para repasar conceptos teóricos y familiarizarse con las distintas clases y métodos de Qiskit.

Además, vamos a subir contenido adicional y bibliografía sugerida en nuestro canal de Discord, para los que quieran avanzar un poco más en su aprendizaje.

**Comunicación:** toda la comunicación se dará por el canal de Discord, en el que subiremos las clases, el material y recordatorios de eventos especiales. Allí, podrán hacer cualquier tipo de preguntas y hablar con otros participantes.

**Guardar esta clase:** para guardar las clase y el código que escriban en los ejercicios, les recomendamos hacer una copia de este doumento en su carpeta de Google Drive. Seleccionen ```Archivo```, arriba a la izquierda en Google Collab, y luego elijan la opción ```Guardar una copia en Drive```.

**Instalación:** para instalar todas las librerías y servicios necesarios para esta clase, corran la siguiente celda apretando el botón de play a la izquierda.

# Introducción conceptual

El objetivo de esta clase es familizarizarse con las herramientas matemáticas que se utilizan en la computación cuántica (y en la mecánica cuántica en general).  

Estas herramientas probablemente ya sean conocidas por muchos, ya que se tratan de temas fundamentales del álgebra lineal: vectores fila, vectores columna, matrices, productos internos, etc. También es necesario tener algún conocimiento de números complejos, y puede ser útil tener conocimientos de probabilidad. Para los que necesiten un repaso rápido de estos temas, pueden consultar la bibliografía complementaria al final de esta clase.

Antes de adentrarnos en los aspectos más técnicos, presentamos una breve introducción conceptual e histórica de la computación cuántica. Quienes deseen saltearse esta parte (o volver a ella después), pueden seguir con las siguientes secciones.

## ¿Qué es la computación cuántica?

La **computación cuántica** es una manera de procesar información utilizando las reglas de la **mecánica cuántica** - como la *superposición*, el *entrelazamiento* y la *interferencia* - para resolver problemas que son muy difíciles para una computadora clásica (se cree que algunos de estos problemas son imposibles de resolver en máquinas clásicas).

En la práctica, una computadora cuántica no puede resolver cualquier problema más rápido que una computadora clásica, sino que ofrece ventajas específicas para ciertas familias de problemas como la *simulación* de sistemas cuánticos y *química cuántica*, algunas formas de *optimización* y *muestreo*, y tareas específicas de *criptografía*.

## ¿Cómo empezó todo esto?



La historia de la mecánica cuántica se remonta a más de 100 años atrás, pero la historia moderna de la computación cuántica comienza en la década de 1980 con el físico **Richard Feynman** (ver imagen a la derecha), quien argumentó que la manera correcta de simular sistemas cuánticos era a través de máquinas cuánticas, ya que la Naturaleza "no es clásica".

En los años posteriores, muchas personas comenzaron a interesarse en el desarrollo de este nuevo campo de estudio. En la década de 1990, el matemático **Peter Shor** descubrió un algoritmo cuántico de factorización en tiempo polinomial (exponencialmente más rápido que el mejor algoritmo clásico). Poco tiempo después, el informático **Lov Grover** halló una mejora importante respecto a los algoritmos clásicos para búsquedas en una secuencia no estructurada de datos. Estos dos algoritmos demostraron las potenciales ventajas de las computadoras cuánticas.

En la misma época, el físico **David DiVicenzo** estableció los criterios necesarios para construir computadoras cuánticas, lo que guió las investigaciones para las implementaciones de hardware en diferentes tecnologías.

Estos hitos (y otros que dejamos de lado en esta breve narración) definieron los inicios de la computación cuántica y guiaron su desarrollo hacia el panorama actual.

## ¿Dónde estamos ahora?

Los dispositivos que tenemos hoy en día todavía son demasiado [ruidosos](https://es.wikipedia.org/wiki/Ruido_cu%C3%A1ntico) y de escala intermedia ([NISQ](https://es.wikipedia.org/wiki/Cu%C3%A1ntica_de_escala_intermedia_ruidosa)), pero son útiles para el aprendizaje y la implementación de algunos algoritmos en hardware real. Las dos motivaciones principales para mejorar el estado actual de las computadoras cuánticas son:

- Obtener mejores *simulaciones* de materiales y compuestos químicos y biológicos para el desarrollo científico e industrial, que reproduzcan el comportamiento cuántico de estos sistemas y superen las limitaciones de las simulaciones clásicas actuales.

- Crear sistemas de *seguridad* y *criptografía* más seguros. La obtención de una computadora de muchos qubits tolerante a fallos podrá implementar exitosamente el algoritmo de Shor, volviendo obsoleta la *criptografía de clave pública RSA*.

Con mejores compiladores y técnicas de mitigación de errores, podemos extraer buenos resultados para problemas más pequeños antes de que la corrección de errores pueda ser implementada. Por eso, las empresas de tecnología, los laboratorios y los gobiernos están invirtiendo ahora: para construir el hardware, el software y la reserva de talentos. Así, cuando los sistemas escalen tendremos los problemas relevantes y las personas capacitadas para resolverlos.

En este contexto, **Qiskit** es un SDK (kit de desarrollo de software) creado por IBM para implementar circuitos y algoritmos cuánticos. Ofrece la posibilidad de correr programas en las computadoras cuánticas reales de IBM a través de sus servicios en la nube y utilizando *Qiksit Runtime*. También permite simular programas localmente.

#Kets y qubits

## Vectores columna (kets)

Para expresar objetos en computación cuántica (y en mecánica cuántica en general), usamos la *notación de Dirac*, o *notación bra-ket*, la cual es más compacta para expresar elementos del álgebra lineal como vectores, matrices y productos internos. Fue creada en 1939 por el físico Paul Dirac (ver imagen a la derecha).

En la notación de Dirac, un **ket** $\left|v\right>$ representa un vector columna en un espacio vectorial complejo de $n$ dimensiones:

\begin{equation}
\left|v\right>=\begin{bmatrix} z_1 \\ \vdots \\ z_n \end{bmatrix}\in\mathbb{C}^n
\end{equation}

Los vectores columna - o kets - son lineales:

\begin{equation}
\left|\alpha v_1+\beta v_2\right>=\alpha\left|v_1\right>+\beta\left|v_2\right>
\end{equation}

## Qubits y superposición

En computación clásica, el **bit** es la unidad de información básica. Un bit puede tener uno de dos estados: $0$ ó $1$. Estos estados pueden representarse físicamente en una computadora con señales eléctricas; por ejemplo, con 0 y 5 volts respectivamente.

En computación cuántica, trabajamos con **qubits** (”bits cuánticos”). Al igual que un bit, un qubit tiene dos estados posibles: el estado $\left|0\right>$ y el estado $\left|1\right>$. Veremos que la manera en la que funcionan estos estados es bastante diferente a la manera en la que funcionan los estados clásicos.

$\left|0\right>$ y $\left|1\right>$ son estados especiales conocidos como estados de la **base computacional**, y forman una base ortonormal para este espacio vectorial. Podemos pensarlos a ambos como los siguientes vectores unitarios:

\begin{equation}
\left|0\right>=\begin{bmatrix} 1\\ 0\end{bmatrix}
\qquad\qquad
\left|1\right>=\begin{bmatrix} 0\\ 1\end{bmatrix}
\end{equation}

La diferencia entre un bit y un qubit es que un qubit puede encontrarse en otros estados que no son $\left|0\right>$ ó $\left|1\right>$, sino "*ambos a la vez*".
Este principio se llama **superposición**, y se representa mediante una *combinación lineal* de estados:

\begin{equation}
\left|\psi\right>=\alpha\left|0\right>+\beta\left|1\right>=\alpha\begin{bmatrix} 1\\ 0\end{bmatrix}+\beta\begin{bmatrix} 0\\ 1\end{bmatrix}=\begin{bmatrix}\alpha \\ \beta\end{bmatrix}
\end{equation}

donde $\alpha$ y $\beta$ son números complejos que suelen denominarse **amplitudes de probabilidad**.

Físicamente, podemos implementar un qubit con cualquier sistema cuántico que admita dos estados superpuestos: la polarización horizontal y vertical de un [fotón](https://es.wikipedia.org/wiki/Fot%C3%B3n), la orientación del [spin](https://es.wikipedia.org/wiki/Esp%C3%ADn) nuclear en un campo magnético uniforme, o dos estados diferentes de un [electrón orbitando un átomo](https://es.wikipedia.org/wiki/Modelo_at%C3%B3mico_de_Bohr#:~:text=El%20modelo%20at%C3%B3mico%20de%20Bohr,ocupar%20ciertos%20niveles%20de%20energ%C3%ADa.) (un estado base y un estado excitado).Sin embargo, por ahora los trataremos exclusivamente como objetos matemáticos. Esto nos permite construir una teoría de la información cuántica sin depender de su implementación física.

---

Cuando examinamos (observamos, medimos) un qubit, la superposición de estados *colapsa*. Por lo tanto, solo podemos medir uno de los dos estados clásicos representados por los estados de la base computacional:

- $0$, con una probabilidad $|\alpha|^2$;
- $1$, con una probabilidad $|\beta| ^2$.

Como la suma de probabilidades debe ser uno:

\begin{equation}
|\alpha|^2+|\beta|^2=1
\end{equation}



Este comportamiento puede resultar extraño y contraintuitivo, ya que no se corresonde con ningún efecto que estemos acostumbrados a presenciar en nuestro mundo clásico y macroscópico. El físico Erwin Schrödinger demostró lo paradójico que puede resultar este comportamiento en su [famoso experimento mental](https://es.wikipedia.org/wiki/Gato_de_Schr%C3%B6dinger), en donde un gato encerrado en una caja con veneno está en una superposición de los estados "vivo" y "muerto" antes de que lo observemos.

¿Por qué ocurre este colapso de la superposición? Nadie sabe: es uno de los postulados fundamentales de la mecánica cuántica.

Geométricamente, que la suma de probabilidades sea igual a uno es equivalente a que el estado de un qubit esté *normalizado* (tenga longitud 1): es un *vector unitario* en un *espacio vectorial* complejo bidimensional ($\mathbb{C}^2$). Este espacio vectorial en el que "vive" el qubit se llama *espacio de Hilbert*: para los espacios vectoriales complejos y finitos con los que trataremos nosotros, es equivalente a hablar de un espacio vectorial con producto interno (el cual definiremos más adelante). Todos los sistemas físicos aislados de la mecánica cuántica se representan con un vector columna o ket de estado normalizado en un espacio de Hilbert.

**Nota 1:** la letra griega $\psi$ (*psi*) se utiliza para representar sistemas u objetos cuánticos en la mecánica cuántica ondulatoria. Representa la *función de onda* de ese objeto. Otros nombres comunes para funciones de onda son $\phi$  /$\varphi$ (*phi*) y $\pi$ (*pi*).

**Nota 2:** la función de onda de un sistema $\psi(\mathbf{x}, t)$ no tiene una interpretación física inmediata y no se puede observar. Sin embargo, es útil para construir una función de densidad de probabilidad dada por $\left|\psi(\mathbf{x},t)\right|^2=\psi^*(\mathbf{x},t)\psi(\mathbf{x},t)$ (por ser un número complejo), la cual nos permite conocer la probabilidad de encontrar al objeto cuántico en la posición $\mathbf{x}$ para un determinado tiempo $t$.

## Representando qubits en Qiskit

Podemos representar qubits con la clase ``` Statevector ```. Esta clase es útil para representar qubits individuales y múltiples qubits en conjunto (lo veremos más adelante).

Existen múltiples maneras de crear objetos de la clase ```Statevector```.
Dos formas importantes son el método ```.from_label('string')```, en donde ingresaremos un string representativo del estado que queremos crear, y utilizando un arreglo ```Statevector([α,β])```. Más adelante veremos cómo extraer el vector de estado de un circuito cuántico.

También existen múltiples maneras de visualizar la información del vector de estados; por ejemplo, imprimiendo con ```print()``` o con los métodos ```.data```, ```.draw()``` y ```.probabilities_dict()```.

Los siguientes ejercicios sirven para aplicar los conceptos básicos de esta clase. Los animamos a que consulten [la documentación apropiada](https://quantum.cloud.ibm.com/docs/en/api/qiskit/qiskit.quantum_info.Statevector), sean curiosos, prueben distintos códigos para ver los resultados, investiguen lo que no entiendan y consulten a nuestros mentores por nuestro canal de Discord.

### algunos qubits famosos

Los siguientes estados son *muy* utilizados en computación cuántica:

\begin{equation}
\left|+\right>=\frac{\left|0\right>+\left|1\right>}{\sqrt{2}}
\qquad\qquad
\left|-\right>=\frac{\left|0\right>-\left|1\right>}{\sqrt{2}}
\qquad\qquad
\left|i\right>=\frac{\left|0\right>+i\left|1\right>}{\sqrt{2}}
\qquad\qquad
\left|-i\right>=\frac{\left|0\right>-i\left|1\right>}{\sqrt{2}}
\end{equation}

# Bras y bases

## Vectores fila (bras)

En notación de Dirac, un **bra** $\left< u\right|$
representa un vector fila en $\mathbb{C}^n$:

\begin{equation}
\left< u\right| =\begin{bmatrix}y_1 & \cdots & y_n\end{bmatrix}\in \mathbb{C}^n
\end{equation}

Supongamos que tenemos un ket expresado como la combinación lineal de otros kets: $\left|\psi\right>=\alpha\left|\psi_1\right>+\beta\left|\psi_2\right>$. Entonces, podemos obtener su *bra asociado* $\left< \psi\right|$ tomando su **conjugado hermítico**, representado por el símbolo $\dagger$. Aplicar el conjugado hermítico a un ket (vector columna) lo vuelve un bra (vector fila), y aplicarlo a una constante devuelve el conjugado complejo de esa constante ($z^\dagger=z^*$):
\begin{equation}
\left< \psi\right|=\left|\psi\right>^\dagger=(\alpha\left|\psi_1\right>+\beta\left|\psi_2\right>)^\dagger=\alpha^*\left< \psi_1\right|+\beta^*\left< \psi_2\right|
\end{equation}

Cuando tomamos una combinación lineal dentro de un bra, hay que tener en cuenta que las constantes "salen conjugadas":

\begin{equation}
\left< \alpha\psi_1+\beta\psi_2\right|=\alpha^*\left< \psi_1\right|+\beta^*\left< \psi_2\right|
\end{equation}

**Ejemplo:** para un qubit en el estado $|\psi\rangle=\alpha|0\rangle+\beta|1\rangle=(\alpha,\beta)$, su bra asociado está dado por $\langle\psi|=\alpha^*\langle0|+\beta^*\langle1|=\begin{bmatrix} \alpha^* & \beta^*\end{bmatrix}$

## Productos internos (brakets)

No podemos sumar peras con manzanas: podemos sumar kets entre sí, y bras entre sí, pero no kets con bras. Sin embargo, sí podemos multiplicarlos.

¿Qué sucede cuando multiplicamos un bra $\left< w\right|$ por un ket $\left| v \right>$? Obtenemos un **braket** $\left< w|v\right>$: un número complejo que representa el *producto interno* entre los vectores columna $\left| w\right>=\begin{pmatrix} w_1, \ldots , w_n \end{pmatrix}$ y $\left| v\right>=\begin{pmatrix} v_1, \ldots , v_n \end{pmatrix}$. Los vectores deben tener las mismas dimensiones para realizar esta operación.

\begin{equation}
\left< w|v\right>=\begin{bmatrix}w_1^* & \cdots & w_n^*\end{bmatrix}\begin{bmatrix}v_1 \\ \vdots \\ v_n\end{bmatrix}=w_1^*v_1+\cdots+w_n^*v_n\in\mathbb{C}
\end{equation}

El producto interno de un vector no nulo con sí mismo siempre es positivo: $\left< v|v\right>>0$; sólo puede ser $0$ si el vector es nulo, $\left| v\right>=\begin{pmatrix} 0, \ldots , 0\end{pmatrix}\equiv\vec{0}$.

En computación cuántica, el producto interno de un qubit con sí mismo siempre es igual a uno: $\left< \psi|\psi\right>=1$. Esta condición es equivalente a pedir que las probabilidades sumen uno: $|\alpha|^2+|\beta|^2=1$.

\begin{equation}
\left< \psi|\psi\right>=\begin{bmatrix}\alpha^* & \beta^*\end{bmatrix}\begin{bmatrix}\alpha \\ \beta\end{bmatrix}=\alpha^*\alpha+\beta^*\beta=|\alpha|^2+|\beta|^2=1
\end{equation}

## Bases ortonormales

Una *base ortonormal* es un conjunto de vectores ortogonales y de norma unitaria que generan un espacio vectorial.

Por ejemplo, supongamos que la base $\mathbb{B}=\left\{\left|u_1\right>, \left|u_2\right>, \ldots , \left|u_n\right> \right\}$ es una base ortonormal de $\mathbb{C}^n$. Entonces, el producto interno entre dos kets distintos de la base valdrá $0$, y será $1$ para cuando sea entre kets idénticos:

\begin{equation}
\left< u_i |u_j\right> =
\begin{cases}
1, & i = j \\
0, & i \neq j
\end{cases}
\end{equation}

En computación cuántica, es muy común escribir la superposición de estados de un qubit como la combinación lineal de alguna base ortonormal:

\begin{equation}
\left|\psi\right>=\sum_{i=1}^n c_i \left|u_i\right>
\end{equation}

Para el caso de un qubit, vimos que podemos escribir la superposición como la combinación lineal de los estados de la base computacional: $\left|\psi\right>=\alpha\left|0\right>+\beta\left|1\right>$. También podemos expresar una superposición respecto a otras bases ortonormales, como $\left\{\left|+\right>,\left|-\right>\right\}$ ó $\left\{\left|+i\right>,\left|-i\right>\right\}$ (ver el ejercicio 2).

También podemos expresar dos qubits en simultáneo como una combinación lineal de una base ortonormal. Lo veremos en detalle más adelante, pero es útil tener un entendimiento básico ahora.

Dos bits pueden estar en los estados $00$, $01$, $10$ y $11$. Análogamente, un qubit puede estar en los estados $\left|00\right>$, $\left|01\right>$, $\left|10\right>$, $\left|11\right>$, o en una combinación lineal (o superposición) de ellos:

\begin{equation}
\left|\psi\right>=\alpha_{00} \left|00\right>+\alpha_{01}\left|01\right>+\alpha_{10}\left|10\right>+\alpha_{11}\left|11\right>
\end{equation}

Al tener cuatro estados de la base computacional, podemos representarlos vectorialmente de la siguiente manera:

\begin{equation}
\left|00\right>=\begin{bmatrix} 1\\ 0 \\ 0 \\ 0\end{bmatrix}
\qquad\qquad
\left|01\right>=\begin{bmatrix} 0\\ 1 \\ 0 \\ 0\end{bmatrix}
\qquad\qquad
\left|10\right>=\begin{bmatrix} 0\\ 0 \\ 1 \\ 0\end{bmatrix}
\qquad\qquad
\left|11\right>=\begin{bmatrix} 0\\ 0\\ 0\\ 1\end{bmatrix}
\end{equation}

Este mismo razonamiento puede extenderse para cualquier número de qubits. Para $N$ qubits, podremos superponer $2^N$ estados. Para tan solo $500$ qubits, tendremos $2^{500}$ amplitudes de probabilidad: ¡más que el número estimado de átomos en el universo! En parte, el gran poder de procesamiento de las computadoras cuánticas proviene de este hecho.

### simetría conjugada

El producto interno entre dos vectores cumple que $\langle v|w\rangle=\langle w|v\rangle^*$. Muestra esta propiedad computando $\langle i|-\rangle$ y $\langle -|i\rangle$.

### norma de un ket

La **norma** de un vector es un número real dado por $|||v\rangle||=\sqrt{\langle v|v\rangle}$. Verifica que la norma del qubit del ejercicio 1 tenga norma unitaria utilizando un método apropiado. Crea el vector columna $|w\rangle=(\sqrt{2},1)=\sqrt{2}|0\rangle+|1\rangle$ y verifica, utilizando el mismo método, que su norma no es unitaria.

# Operadores y matrices

## Producto externo

Vimos qué pasa si mutiplicamos un bra por un ket: obtenemos un braket, o producto interno, que es un número complejo.

Ahora, ¿qué pasa si multiplicamos un ket por un bra? Al multiplicar un vector columna por un vector fila, ambos de $n$ dimensiones, obtendremos una matriz de $n\times n$ dimensiones.

Es importante notar que la multiplicación en vectores y matrices no es conmutativa. Multiplicar un vector fila por un vector columna nos da un número, mientras que multiplicar un vector columna por un vector fila nos devuelve una matriz.

Supongamos que tenemos los kets $\left|\psi\right>=\begin{pmatrix}z_1, \ldots, z_n\end{pmatrix}$ y $\left|\phi\right>=(y_1,\ldots,y_n)$. Entonces, definiremos el **producto externo** entre $\left|\psi\right>$ y $\left|\phi\right>$ como la siguiente operación:

\begin{equation}
\left|\psi\right>\left<\phi\right|=\begin{bmatrix}z_1\\ \vdots \\ z_n \end{bmatrix}\begin{bmatrix}y_1^* & \cdots & y_n^*\end{bmatrix}=\begin{bmatrix}z_1y_1^* & \cdots & z_1y_n^* \\ \vdots & \ddots & \vdots \\ z_ny_1^* & \cdots & z_ny_n^*\end{bmatrix}
\end{equation}

Pueden verificar que el resultado no es el mismo si hacemos $\left|\phi\right>\left<\psi\right|$.

Al aplicarle el producto externo a un ket, obtenemos otro ket. Supongamos que tenemos el producto externo $\left|\psi\right>\left<\phi\right|$ y se lo aplicamos al ket $\left|\pi\right>$. Teniendo en cuenta que el producto interno $\left<\phi|\pi\right>$ es igual a un número complejo $\gamma$, tenemos que:

\begin{equation}
\left(\left|\psi\right>\left<\phi\right|\right)\left|\pi\right>=\left|\psi\right>\left<\phi|\pi\right>=\gamma\left|\psi\right>
\end{equation}

Matricialmente, la operación se escribiría de la siguiente manera:

\begin{equation}
\left(\left|\psi\right>\left<\phi\right|\right)\left|\pi\right>=\begin{bmatrix} z_1y_1^* & \cdots & z_1y_n^* \\ \vdots & \ddots & \vdots \\ z_ny_1^* & \cdots & z_ny_n^*\end{bmatrix}\begin{bmatrix}\pi_1 \\ \vdots \\ \pi_n \end{bmatrix}=\begin{bmatrix}z_1\sum_{i=1}^n\pi_iy_i^*\\ \vdots \\ z_n\sum_{i=1}^n\pi_iy_i^*\end{bmatrix}=\sum_{i=1}^n\pi_iy_i^*\begin{bmatrix}z_1\\ \vdots \\ z_n\end{bmatrix}
\end{equation}

donde $\left|\pi\right>=\begin{pmatrix}\pi_1,\ldots ,\pi_n\end{pmatrix}$. Claramente, la notación de Dirac nos ayuda a escribir estas expresiones de una forma mucho más compacta e intuitiva.

En Python, podemos computar productos externos entre dos vectores utilizando el método ```.outer()``` de la librería ```Numpy```. Pueden ver la documentación [aquí](https://numpy.org/doc/2.3/reference/generated/numpy.outer.html).

## Operadores lineales

Un **operador lineal** es una función que transforma vectores columna en otros vectores columna. Estos operadores lineales pueden ser representados como productos externos (o suma de productos externos). Por ejemplo, si definimos el producto externo anterior como un operador lineal $\hat{A}=\left|\psi\right>\left<\phi\right|$, al aplicarlo a $\left|\pi\right>$ obtendremos $\hat{A}\left|\pi\right>=\gamma\left|\psi\right>$.

Solemos usar mayúsculas con el símbolo "$\widehat{}$" para representar operadores lineales: $\hat{P}$, $\hat{H}$, $\hat{E}$.

Para un operador lineal $\hat{A}$, podemos encontrar su **representación matricial** $A$ (sin "$\hat{}$") respecto a una base ortonormal.

Supongamos que tenemos una base ortonormal $\left\{\left|u_1\right>,\ldots,\left|u_n\right>\right\}$ y que podemos expresar al operador lineal $\hat{A}$ como productos externos entre los kets de esa base multiplicados por cierto coeficiente:

\begin{equation}
\hat{A}=\sum_{i,j}a_{ij}\left|u_i\right>\left< u_j \right|
\end{equation}

La representeación matricial del operador en esa base estará dada por:

\begin{equation}
A=\begin{bmatrix}a_{11} & \cdots & a_{1n} \\ \vdots & \ddots & \vdots \\ a_{n1} & \cdots & a_{nn}\end{bmatrix}
\end{equation}

En esta representación matricial, cada coeficiente de la matriz representa un producto externo entre kets de la base. Para adquirir una intuición mayor, podemos imaginar que las filas representan kets y las columnas, bras:

\begin{equation}
\begin{array}{c|cccc}
   & \left< u_1\right| & \left< u_2\right| & \cdots & \left< u_n\right| \\ \hline
\left|u_1\right>    & a_{11} & a_{12} & \cdots & a_{1n} \\
\left|u_2\right>    & a_{21} & a_{22} & \cdots & a_{2n} \\
\vdots & \vdots & \vdots & \ddots & \vdots \\
\left|u_n\right>    & a_{n1} & a_{n2} & \cdots & a_{nn}
\end{array}
\end{equation}

En notación de Dirac, podemos representar cada elemento de la matriz de la siguiente manera:

\begin{equation}
a_{ij}=\left< u_i\right|\hat{A}\left|u_j\right>
\end{equation}

Como hemos visto, esta expresión representa un producto interno y, por lo tanto, un número complejo. Podemos pensarlo como el producto interno entre el ket $\left|u_i\right>$ y $\hat{A}\left| u_j\right>$ que, como vimos, también es un ket.

En Qiskit, podemos instanciar operadores con la clase ```Operator```. Podemos crear un nuevo operador a partir de una matriz, o a partir de ciertos *strings* o etiquetas. También podemos obtener la representación matricial de un operador. Los invitamos a investigar la [documentación de la clase Operator](https://quantum.cloud.ibm.com/docs/en/api/qiskit/qiskit.quantum_info.Operator#operator).

## Conjugado hermítico

Matricialmente, podemos obtener el **conjugado hermítico** de un operador lineal - también conocido como **operador adjunto** - tomando el conjugado complejo de sus elementos y transponiendo la matriz (o viceversa):

\begin{equation}
A^\dagger=\left(A^*\right)^T=\left(A^T\right)^*
\end{equation}

A este punto, ya tenemos todas las herramientas principales de la notación de Dirac: kets, bras, productos internos, productos externos, operadores lineales y sus conjugados hermíticos. Podemos encontrarnos con expresiones compuestas por varios de estos elementos (siempre y cuando la operación matemática tenga sentido), y puede ser muy útil saber cómo obtener el conjugado de esas expresiones. Podemos obtener el conjugado hermítico de expresiones compuestas en notación de Dirac reemplazando las constantes por sus complejos conjugados, los operadores por sus adjuntos, los kets por bras y los bras por kets. Finalmente, invertiremos el orden de los elementos.

A continuación, se muestran algunos ejemplos básicos de expresiones comunes y cómo resolver sus conjugados:

\begin{equation}
\begin{array}{|c|c|}
\hline
\textbf{Expresion} & \textbf{Solucion} \\
\hline
z^\dagger & z^* \\
\hline
|\psi \rangle^\dagger & \langle \psi | \\
\hline
\langle\psi|^\dagger & |\psi\rangle \\
\hline
\langle \psi |\hat{A}| \phi \rangle^\dagger & \langle\phi|{\hat{A}}^\dagger |\psi\rangle \, \text{ó} \, \langle \psi | \hat{A} |\phi \rangle^* \\
\hline
{({\hat{A}}^\dagger)}^\dagger & \hat{A} \\
\hline
(\hat{A}\hat{B})^\dagger & \hat{B}^\dagger \hat{A}^\dagger \\
\hline
(|\psi\rangle \langle \phi|)^\dagger & |\phi\rangle \langle \psi| \\
\hline
(\hat{A} + \hat{B})^\dagger & {\hat{A}}^\dagger + {\hat{B}}^\dagger \\
\hline
\end{array}
\end{equation}

### las matrices de Pauli

A continuación, se muestran las representaciones matriciales (con respecto a la base computacional) de los **operadores de Pauli**, los cuales son muy importantes en la computación cuántica:

\begin{equation}
I=\begin{bmatrix}1 & 0\\ 0 & 1\end{bmatrix}
\qquad
X=\begin{bmatrix}0 & 1\\ 1 & 0\end{bmatrix}
\qquad
Y=\begin{bmatrix}0 & -i\\ i & 0\end{bmatrix}
\qquad
Z=\begin{bmatrix}1 & 0\\ 0 & -1\end{bmatrix}
\end{equation}

Crea los operadores con el método ```.from_label()``` de la clase ```Operator```. Luego, observa el efecto que tienen al aplicarlos a:

- Los estados de la base computacional: $|0\rangle$ y $|1\rangle$;

- Los estados de la **base de Hadamard**: $|+\rangle$ y $|-\rangle$;

- Los estados de la **base circular**: $|i\rangle$ y $|-i\rangle$;

### la compuerta de Hadamard

La **compuerta de Hadamard** es una compuerta cuántica muy importante. Se expresa a través de un operador lineal, cuya representación matricial en la base computacional es:

\begin{equation}
H=\frac{1}{\sqrt{2}}\begin{bmatrix}1 & 1\\ 1 & -1\end{bmatrix}
\end{equation}

Aplica este operador a los estados $|0\rangle$, $|1\rangle$, $|+\rangle$ y $|-\rangle$. Observa el resultado.
