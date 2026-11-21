# ¡Bienvenidos a la parte extra de la Quantum Jam 2026!

**Guardar esta clase:** para guardar las clase y el código que escriban en los ejercicios, les recomendamos hacer una copia de este doumento en su carpeta de Google Drive. Seleccionen ```Archivo```, arriba a la izquierda en Google Collab, y luego elijan la opción ```Guardar una copia en Drive```.

# El algoritmo de Grover

## Introducción

El algoritmo de Grover, inventado por el informático Lov Grover en 1996, permite encontrar un elemento específico en una secuencia no ordenada de $N$ datos. Veremos que este algoritmo permite resolver el problema en $O(\sqrt{N})$ evaluaciones, mientras que tendríamos que hacer $O(N)$ evaluaciones clásicamente. Aunque no es una ventaja exponencial como el algoritmo de Shor para factorización, sí es el algoritmo óptimo para este problema: el [teorema BBBV](https://www.scottaaronson.com/qclec/23.pdf) (Bennett, Bernstein, Brassard, Vazirani) demuestra que es asintóticamente óptimo.

Si bien la ventaja cuántica que ofrece el algoritmo de Grover no es tan impresionante como la que ofrece el de Shor, sí puede ser utilizado (junto con otras técnicas) para acelerar considerablemente problemas [NP-completos](https://es.wikipedia.org/wiki/NP-completo).

## Definición del problema

Supongamos que tenemos una secuencia de $N$ datos que son un conjunto de claves posibles para acceder a cierta información o lugar, y que solamente una es la correcta:

\begin{array}{|c|c|c|c|c|c|c|c|}
\hline
\mathbf{Clave} & 1234 & 1045 & 8793 & \cdots & 2424 & \cdots & 9952 \\
\hline
\mathbf{x} & 0 & 1 & 2 & \cdots & w & \cdots & N-1 \\
\hline
\end{array}


Podemos modelar esta situación con una función $f:\{0,1\}^2\longrightarrow\{0,1\}$, en la que el input $x$ es el número del elemento de nuestro conjunto de datos. Si la clave contenida en $x$ no es la correcta, entonces $f(x)=0$; sino, $f(x)=1$. Inicialmente, no conocemos qué clave es la correcta, por lo que no sabemos la forma de $f(x)$. Como no conocemos $f(x)$ pero podemos consultar claves para ver si devuelven $0$ ó $1$, modelamos a dicha función como una *caja negra* u *oráculo* (ver la *Clase 3*).

Si el elemento $w$ contiene la clave correcta, la forma de la función será:

\begin{array}{|c|c|c|c|c|c|c|c|}
\hline
\mathbf{f(x)} & 0 & 0 & 0 & \cdots & 1 & \cdots & 0 \\
\hline
\mathbf{x} & 0 & 1 & 2 & \cdots & w & \cdots & N-1 \\
\hline
\end{array}

Clásicamente, tendríamos que probar las claves una por una y ver cuál devuelve $f(x)=1$. En promedio, nos llevaría $\frac{N}{2}$ iteraciones dar con la clave correcta: decimos que lleva $O(N)$ iteraciones. Veremos que el algoritmo de Grover reduce la complejidad computacional a $O(\sqrt{N})$ iteraciones.

## Descripción del algoritmo

Antes de ver el circuito cuántico que implementa este algoritmo, veamos los pasos que lo componen.

En primer lugar, inicializamos el algoritmo con $n$ qubits en el estado $|0\rangle^{\otimes n}=|0^n\rangle$.

Luego, aplicamos una transformada de Hadamard para obtener la superposición equiprobable de todos los $N=2^n$ estados posibles:

\begin{equation}
|s\rangle=H^{\otimes n}|0\rangle^{\otimes n}=\frac{1}{\sqrt{2^n}}\sum_{x\in\{0,1\}^n}|x\rangle
\end{equation}

Las amplitudes de probabilidad para el estado $|s\rangle$ pueden graficarse de la siguiente manera:



Recordemos que el estado $|w\rangle$ es la solución que estamos buscando, y que se encontrará dentro de esta superposición equiprobable, con amplitud $\frac{1}{\sqrt{2^n}}$. Podemos definir un estado $|w^\perp\rangle$ ortogonal a $|w\rangle$ de la siguiente manera:

\begin{equation}
|w^\perp\rangle=\frac{1}{\sqrt{2^n-1}}\sum_{x\neq w}|x\rangle
\end{equation}

También podemos expresar $|s\rangle$ como al superposición entre $|w\rangle$ y $|w^\perp\rangle$:

\begin{equation}
|s\rangle=\sqrt{\frac{2^n-1}{2^n}}|w^\perp\rangle+\frac{1}{\sqrt{2^n}}|w\rangle
\end{equation}

Como $|w\rangle$ y $|w^\perp\rangle$ son ortogonales, podemos graficarlos como dos vectores perpendiculares (forman un ángulo de $90^\circ$). Luego, el vector $|s\rangle$ estará entre ambos vectores ortogonales, ya que tiene una componente en $|w\rangle$ y otra en $|w^\perp\rangle$. Como todos los vectores están normalizados, podemos ubicarlos en el círculo unitario. Definiremos el ángulo entre $|w^\perp\rangle$ y $|s\rangle$ como $\theta/2$:



Viendo el diagrama vectorial, podemos expresar a $|s\rangle$ como:

\begin{equation}
|s\rangle=cos\left(\frac{\theta}{2}\right)|w^\perp\rangle+sin\left(\frac{\theta}{2}\right)|w\rangle
\end{equation}

Utilizando la expresión anterior de $|s\rangle$, vemos que $sin(\theta/2)=1/\sqrt{2^n}$, por lo que:

\begin{equation}
\theta=2arcsin\left(\frac{1}{\sqrt{2^n}}\right)
\end{equation}

Podemos verificar que mientras más estados tengamos, aumentará $n$ y disminuirá $\theta$, con lo que el vector $|s\rangle$ estará más próximo a los estados que no son solución y más alejado del que es solución.

A continuación, aplicamos el oráculo $U_f$ al estado $|s\rangle$. Este oráculo invierte la fase del estado $|w\rangle$ (que contiene la clave que genera $f(x)=1$). Usualmente, se suele denotar a este oráculo como $U_w$ en vez de $U_f$:

\begin{align}
U_w|w\rangle&=-|w\rangle\\
U_w|x\rangle&=|x\rangle\qquad x\neq w
\end{align}

Podemos definir al oráculo como $U_w=I-2|w\rangle\langle w|$, donde $I$ es el operador identidad. Vemos que el efecto de aplicarlo a la superposición equiprobable de estados es dejar todas las amplitudes de probabilidad intactas, excepto por la de la solución, que invierte su signo. En el círculo unitario, podemos pensarlo como una reflexión de $|s\rangle$ sobre el eje representado por $|w^\perp\rangle$.



El último paso del algoritmo es aplicar el llamado **operador de difusión de Grover** $U_s$. El efecto de este operador es reflejar el estado que obtuvimos anteriormente respecto al eje representado por $|s\rangle$. Solemos decir que $U_s$ realiza una "inversión respecto a la media". Lo llamamos operador de difusión porque "difunde" parte de las amplitudes de probabilidad de los estados que conforman $|w^\perp\rangle$ *hacia* la amplitud de probabilidad del estado solución.

Podemos ver que una vez que realizamos estas dos operaciones, el estado resultante $U_sU_w|s\rangle$ se encuentra "más cerca" de $|w\rangle$ que antes en el círculo unitario. Realmente, lo que hicimos con estos dos operadores es rotar el vector $|s\rangle$ de manera antihoraria en el círculo unitario, por un ángulo $\theta$. Consecuentemente, la probabilidad de medir $|w\rangle$ al final del circuito será mayor.

En conjunto, las dos operaciones que realizamos se conocen como **operador de Grover**: $G=U_sU_w$.

---

Ahora, ¿cómo podemos aumentar todavía más la probabilidad de medir la solución? La respuesta es: repitiendo las operaciones que le realizamos al estado $|s\rangle$ un total de $r$ veces.  Debemos definir $r$ de manera tal que nuestro estado final quede lo más próximo posible a $|w\rangle$. Después de correr $r$ veces el operador de Grover, queremos que nuestro ángulo final sea $90^\circ=\frac{\pi}{2}$ radianes, por lo que:

\begin{equation}
r\cdot\theta+\frac{\theta}{2}=\frac{\pi}{2} \Longrightarrow r=\frac{\pi}{2\theta}-\frac{1}{2}
\end{equation}

Recordemos que $\theta=2arcsin(1/\sqrt{2^n})$. Usualmente, los $N=2^n$ estados serán un número muy grande. En ese caso, podemos utilizar la aproximación $sin(\varphi)\approx\varphi$ para un ángulo $\varphi$ muy pequeño (nótese que la aproximación también vale para el arcoseno). En este caso, obtenemos que $\theta\approx 2\cdot\frac{1}{\sqrt{2^n}}$. Si reemplazamos en la expresión de $r$, tenemos:

\begin{equation}
r\approx\frac{\pi}{2\cdot2\cdot\frac{1}{\sqrt{N}}}-\frac{1}{2}=\frac{\pi}{4}\sqrt{N}-\frac{1}{2}\approx\frac{\pi}{4}\sqrt{N}\approx O(\sqrt{N})
\end{equation}

Al implementar el algoritmo, debemos tener cuidado de no correr las operaciones más veces que $r\approx\frac{\pi}{4}\sqrt{N}$, ya que rotaremos el vector $|s\rangle$ más de la cuenta, con lo que la probabilidad de medir $|w\rangle$ puede empezará a disminuir.

Nótese que $r$ no será siempre un número natural, por lo que muchas veces existirá una probabilidad mínima de medir un estado que no sea la solución. En ese caso, debemos volver a correr el algoritmo y esperar que el próximo resultado sea correcto.

## Construcción del operador de Grover

Dijimos que el oráculo $U_w$ se comporta de la misma manera que los oráculos $U_f$ que estudiamos en la *Clase 3*. Pueden notar que existe una diferencia sustancial: $U_w$ no posee un qubit auxiliar en el estado $|-\rangle$, como sí tenían los oráculos del algoritmo de Deutsch-Jozsa o Bernstein-Vazirani. Esto es porque consideramos que el qubit en el estado $|-\rangle$ es parte de la compuerta $U_w$ internamente.

Ahora, ¿cómo construimos el operador $U_s$? Pueden verificar que el operador que realiza la inversión sobre la media es:

\begin{equation}
U_s=H^{\otimes n}(2|0^n\rangle\langle0^n|-I) H^{\otimes n}=2|s \rangle\langle s|-I
\end{equation}

En medio de las dos transformadas de Hadamard, tenemos una compuerta que aplica una fase de $-1$ a todos los estados distintos de $|0^n\rangle$. Podemos comprobar que la matriz correspondiente a esta compuerta es:

\begin{equation}
\begin{bmatrix}
1 & 0 & 0 & \cdots & 0 \\
0 & -1 & 0 & \cdots & 0 \\
0 & 0 & -1 & \cdots & 0 \\
\vdots & \vdots & \vdots & \ddots & \vdots \\
0 & 0 & 0 & \cdots & -1
\end{bmatrix}
\end{equation}

Resulta que construir este operador es más dificil que construir $-(2|0^n\rangle\langle0^n|-I)=I-2|0^n\rangle\langle0^n|$, el cual invierte la fase únicamente del estado $|0^n\rangle$. La diferencia entre los dos operadores es solo una fase global, que es físicamente despreciable, por lo que son compuertas equivalentes.

Para crear el operador $I-2|0^n\rangle\langle0^n|$, empezamos alpicando la compuerta $X$ a todos los qubits; de esta manera, tendremos que $X^{\otimes n}|0\rangle^{\otimes n}=|1\rangle^{\otimes n}$. Luego, aplicamos una compuerta $Z$ controlada, con $n-1$ qubits como control:

\begin{equation}
(C^{(n-1)}Z)(|1\rangle^{\otimes n-1}\otimes |1\rangle)=|1\rangle^{\otimes n-1}\otimes (-|1\rangle)=-|1\rangle^{\otimes n}
\end{equation}

Vemos que como $|1\rangle$ es un autovector de $Z$, ocurre el fenómeno de *phase kickback* del que hablamos en la *Parte Extra* de la *Clase 3*.

Finalmente, volvemos a aplicar la compuerta $X$ para todos los qubits. Así, solo cambiaremos la fase de $|0\rangle^{\otimes n}$: $X^{\otimes n}(-|1\rangle^{\otimes n})=-|0\rangle^{\otimes n}$.

Recuerden que se deben aplicar las compuertas de Hadamard a todos los qubits antes y después de estas operaciones.

## Múltiples soluciones

Hasta ahora analizamos el caso en el que tenemos un conjunto de strings de largo $n$ y solo una es la solución. Podemos generalizar el algoritmo de Grover para $M$ soluciones entre $N$ elementos utilizando el mismo circuito cuántico.

Sea $W$ el conjunto de $M$ soluciones (si $w\in W$, entonces $f(w)=1$) y $T$ el conjunto de no-soluciones (si $t\in T$, entonces $f(t)=0$). Podemos armar las superposiciones equiprobables de ambos conjuntos:

\begin{equation}
|W\rangle=\frac{1}{\sqrt{M}}\sum_{w\in W}|w\rangle \qquad\qquad
|T\rangle=\frac{1}{\sqrt{N-M}}\sum_{t\in T}|t\rangle
\end{equation}

El oráculo inicial se definirá de manera muy similar al caso con una solución:

\begin{equation}
U_W=I-2\sum_{w\in W}|w\rangle\langle w|
\end{equation}

mientras que $U_s$ se define de la misma manera que antes.

En el caso de múltiples soluciones, podemos representar a los estados $|W\rangle$ y $|T\rangle$ en un círculo unitario como representamos a los estados $|w\rangle$ y $|w^\perp\rangle$ para el caso de una solución. Después de aplicar el operador de Grover $G=U_sU_W$, el estado $|s\rangle$ inicialmente en una superposición uniforme rotará por un ángulo el doble del inicial entre él y $|T\rangle$.

Pueden demostrar que si $M\ll N$ (lo que suele suceder), la cantidad de veces que debemos aplicar el operador de Grover es:

\begin{equation}
r\approx\frac{\pi}{4}\sqrt{\frac{N}{M}}
\end{equation}

Cuando midamos al final del algoritmo, obtendremos una de las posibles soluciones del conjunto $W$. Para obtener más de una solución, debemos correr el circuito cuántico varias veces.
