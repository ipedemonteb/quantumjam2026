# ¡Bienvenidos a la parte extra de la tercera clase de la Quantum Jam 2026!

El objetivo de esta sección es entender el algoritmo cuántico más importante: el algoritmo de Shor. Esto puede ser un desafío importante para muchos, comparable a escalar una montaña, ya que puede resultar complejo y tenemos que ver otros temas antes (en particular, la QFT y el algoritmo QPE).  

Tengan en cuenta que esta sección es completamente opcional y pueden retornar a ella en otro momento, paulatinamente y con tranquilidad.

**Guardar esta clase:** para guardar las clase y el código que escriban en los ejercicios, les recomendamos hacer una copia de este doumento en su carpeta de Google Drive. Seleccionen ```Archivo```, arriba a la izquierda en Google Collab, y luego elijan la opción ```Guardar una copia en Drive```.

**Instalación:** para instalar todas las librerías y servicios necesarios para esta clase, corran la siguiente celda apretando el botón de play a la izquierda.

# El camino hasta el algoritmo de Shor

## Phase Kickback

Comencemos hablando de una propiedad simple que no hemos analizado hasta ahora: el "retroceso de fase" o **phase kickback**.

Supongamos que tenemos una compuerta $U$ controlada. Sean $|v\rangle$ un autovector de $U$ y $e^{i\theta}$ su autovalor asociado (todos los autovalores de un operador unitario pueden escribirse de esta manera): $U|v\rangle=e^{i\theta}|v\rangle$.

Supongamos también que tenemos un estado $|+\rangle|v\rangle=\frac{1}{\sqrt2}(|0\rangle|v\rangle+|1\rangle|v\rangle)$. Si aplicamos la compuerta $U$ controlada con $|+\rangle$ como el qubit de control y $|v\rangle$ como el target, sucederá lo siguiente:

\begin{equation}
\frac{1}{\sqrt2}(|0\rangle|v\rangle+|1\rangle e^{i\theta}|v\rangle)=\frac{1}{\sqrt2}(|0\rangle+ e^{i\theta}|1\rangle)|v\rangle
\end{equation}

Podemos ver que el target no cambió y que le agregamos una fase relativa al qubit de control. Este fenómeno se denomina "phase kickback" porque "pateamos" la fase del target al qubit de control. Nótese que podemos usar otro estado que esté en una superposición de $|0\rangle$ y $|1\rangle$, y no necesariamente el estado $|+\rangle$.

En conclusión, si tenemos un estado $|v\rangle$ que es un autovector de una compuerta $U$, aplicando una compuerta $U$-controlada con $|v\rangle$ como el target, podemos pasarle la fase al qubit de control.

## La transformada cuántica de Fourier (QFT)

Muchos pueden estar familiarizados con la [transformada de Fourier](https://es.wikipedia.org/wiki/Transformada_de_Fourier). En particular, pueden conocer la [transformada de Fourier discreta (DFT)](https://es.wikipedia.org/wiki/Transformada_de_Fourier_discreta) y la [transformada rápida de Fourier (FFT)](https://es.wikipedia.org/wiki/Transformada_r%C3%A1pida_de_Fourier), que es la manera más común de computar la DFT. La transformada cuántica de Fourier (QFT) no es más que la DFT sobre el vector de estado de un sistema cuántico. Si no conocen estos términos, no se preocupen: vamos a ver la QFT desde cero.

Sea un estado $|j\rangle=|j_0j_1j_2\cdots j_{n-1}\rangle$ de $n$ qubits. El resultado al aplicar la QFT está dado por:

\begin{equation}
QFT|j\rangle=\frac{1}{\sqrt{2^n}}\sum_{k=0}^{2^n-1}e^{\frac{2\pi ijk}{2^n}}|k\rangle
\end{equation}

Existen muchos circuitos cuánticos para implementar la QFT. El circuito que se muestra a continuación es uno de los más comunes:



Acá utilizamos la compuerta $R_k$, que actúa de la siguiente manera sobre la base computacional: $R_k|0\rangle=|0\rangle$, $R_k|1\rangle=e^{\frac{2\pi i}{2^k}}|1\rangle$. Su representación matricial en la base computacional es:

\begin{equation}
R_k=\begin{bmatrix}1 & 0 \\ 0 & e^{\frac{2\pi i}{2^k}}\end{bmatrix}
\end{equation}

Para entender mejor como actúa, veamos un ejemplo con 3 qubits:



El estado inicial es $|j\rangle=|j_1j_2j_3\rangle$. Veamos cómo evoluciona el primer qubit al aplicar la compuerta de Hadamard:

\begin{equation}
H|j_1\rangle=\frac{1}{\sqrt{2}}\left(|0\rangle+(-1)^{j_1}|1\rangle\right)=\frac{1}{\sqrt{2}}\left(|0\rangle+e^{\pi ij_1}|1\rangle\right)=\frac{1}{\sqrt{2}}\left(|0\rangle+e^{2\pi i\left(\frac{j_1}{2}\right)}|1\rangle\right)
\end{equation}

Luego, aplicamos la compuerta $R_2$ controlada. Como $|j_2\rangle$ es el qubit de control, podemos elevar la fase relativa que agrega la compuerta a la $j_2$; de esa manera, no se aplicará si $j_2=0$ y sí lo hará cuando $j_2=1$.

\begin{equation}
R_2H|j_1\rangle=\frac{1}{\sqrt{2}}\left(|0\rangle+e^{2\pi i\left(\frac{j_1}{2}\right)}e^{\left(\frac{2\pi i}{2^2}\right)^{j_2}}|1\rangle\right)=\frac{1}{\sqrt{2}}\left(|0\rangle+e^{2\pi i\left(\frac{j_1}{2}+\frac{j_2}{4}\right)}|1\rangle\right)
\end{equation}

De manera similar:

\begin{equation}
R_3R_2H|j_1\rangle=\frac{1}{\sqrt{2}}\left(|0\rangle+e^{2\pi i\left(\frac{j_1}{2}+\frac{j_2}{4}\right)}e^{\left(\frac{2\pi i}{2^3}\right)^{j_3}}|1\rangle\right)=\frac{1}{\sqrt{2}}\left(|0\rangle+e^{2\pi i\left(\frac{j_1}{2}+\frac{j_2}{4}+\frac{j_3}{8}\right)}|1\rangle\right)
\end{equation}

Con lo anterior, es fácil ver que los otros qubits evolucionan de la siguiente manera:

\begin{align}
&R_2H|j_2\rangle=\frac{1}{\sqrt{2}}\left(|0\rangle+e^{2\pi i\left(\frac{j_2}{2}+\frac{j_3}{4}\right)}|1\rangle\right)\\
&H|j_3\rangle=\frac{1}{\sqrt{2}}\left(|0\rangle+e^{2\pi i\left(\frac{j_3}{2}\right)}|1\rangle\right)
\end{align}

Al final del circuito, se realiza un *swap*: se intercambian de lugar las expresiones que obtuvimos. Por lo tanto, la transformada cuántica de Fourier para 3 qubits es:

\begin{equation}
QFT|j\rangle=\frac{1}{\sqrt{2}}\left(|0\rangle+e^{2\pi i\left(\frac{j_3}{2}\right)}|1\rangle\right)\otimes\frac{1}{\sqrt{2}}\left(|0\rangle+e^{2\pi i\left(\frac{j_2}{2}+\frac{j_3}{4}\right)}|1\rangle\right)\otimes\frac{1}{\sqrt{2}}\left(|0\rangle+e^{2\pi i\left(\frac{j_1}{2}+\frac{j_2}{4}+\frac{j_3}{8}\right)}|1\rangle\right)
\end{equation}

---

**Ejemplo:** obtengamos la QFT de $|5\rangle=|101\rangle$.

Viendo la expresión anterior tenemos que $j_1=1$, $j_2=0$ y $j_3=1$.

\begin{align}
QFT|5\rangle&=\frac{1}{\sqrt{2}}\left(|0\rangle+e^{2\pi i\left(\frac{1}{2}\right)}|1\rangle\right)\otimes\frac{1}{\sqrt{2}}\left(|0\rangle+e^{2\pi i\left(\frac{0}{2}+\frac{1}{4}\right)}|1\rangle\right)\otimes\frac{1}{\sqrt{2}}\left(|0\rangle+e^{2\pi i\left(\frac{1}{2}+\frac{0}{4}+\frac{1}{8}\right)}|1\rangle\right)\\
&=\frac{1}{\sqrt{2}}\left(|0\rangle+e^{i\pi}|1\rangle\right)\otimes\frac{1}{\sqrt{2}}\left(|0\rangle+e^{i\frac{\pi}{2}}|1\rangle\right)\otimes\frac{1}{\sqrt{2}}\left(|0\rangle+e^{i\frac{5\pi}{4}}|1\rangle\right)
\end{align}

---

Supongamos que tenemos el siguiente estado:

\begin{equation}
|\psi\rangle=\frac{1}{\sqrt{2}}\left(|0\rangle+e^{i\pi}|1\rangle\right)\otimes\frac{1}{\sqrt{2}}\left(|0\rangle+e^{i\frac{\pi}{2}}|1\rangle\right)\otimes\frac{1}{\sqrt{2}}\left(|0\rangle+e^{i\frac{5\pi}{4}}|1\rangle\right)
\end{equation}

Viendo el último ejemplo, es la transformada cuántica de Fourier de $|5\rangle$. Podemos obtener el estado original aplicando la **transformada cuántica inversa de Fourier**, que denotaremos como $IQFT$ o $QFT^\dagger$:

\begin{equation}
IQFT|\psi\rangle=|101\rangle
\end{equation}

## Quantum Phase Estimation (QPE)

Una parte central del algoritmo de Shor se basa en el **algoritmo cuántico de estimación de fase** (QPE, *Quantum Phase Estimation*).

Supongamos que tenemos una compuerta $U$ que posee un autovector $|u\rangle$ y un autovalor asociado $e^{i\theta}$ que no conocemos. El algoritmo QPE aproxima el valor $e^{i\theta}$ dado el autovector $|u\rangle$ y la matriz $U$.

El circuito que implementa este algoritmo es el siguiente:



El estado de entrada al circuito es $|\psi_0\rangle=|0\rangle^{\otimes m}\otimes|u\rangle$. El número $m$ de qubits será el que determine la exactitud de la estimación de la fase $e^{i\theta}$.

Lo primero que hacemos es aplicar una transformada de Hadamard a los primeros $m$ qubits. Para seguir mejor el algoritmo, no utilizaremos la expresión que ya hemos visto de la transformada de Hadamard.

\begin{equation}
|\psi_1\rangle=\left(\frac{1}{\sqrt2}(|0\rangle+|1\rangle)\otimes\frac{1}{\sqrt2}(|0\rangle+|1\rangle)\otimes\cdots\otimes\frac{1}{\sqrt2}(|0\rangle+|1\rangle)\otimes\frac{1}{\sqrt2}(|0\rangle+|1\rangle)\right)|u\rangle
\end{equation}

Luego, aplicamos la compuerta $U$-controlada al estado $|u\rangle$. Como el qubit de control es el estado $|+\rangle$, tenemos *phase kickback*, por lo que el resultado es:

\begin{equation}
|\psi_2\rangle=\left(\frac{1}{\sqrt2}(|0\rangle+|1\rangle)\otimes\frac{1}{\sqrt2}(|0\rangle+|1\rangle)\otimes\cdots\otimes\frac{1}{\sqrt2}(|0\rangle+|1\rangle)\otimes\frac{1}{\sqrt2}(|0\rangle+e^{i\theta}|1\rangle)\right)|u\rangle
\end{equation}

Después, aplicamos la compuerta $U^2$-controlada. Podemos ver que también ocurrirá *phase kickback*:

\begin{equation}
|\psi_3\rangle=\left(\frac{1}{\sqrt2}(|0\rangle+|1\rangle)\otimes\frac{1}{\sqrt2}(|0\rangle+|1\rangle)\otimes\cdots\otimes\frac{1}{\sqrt2}(|0\rangle+e^{2i\theta}|1\rangle)\otimes\frac{1}{\sqrt2}(|0\rangle+e^{i\theta}|1\rangle)\right)|u\rangle
\end{equation}

Aplicaremos las potencias pares de $U$ al estado $|u\rangle$ hasta llegar a la compuerta controlada $U^{2^m-1}$. Ahí, tendremos el estado:

\begin{align}
|\psi\rangle=\left(\frac{1}{\sqrt2}(|0\rangle+e^{2^{m-1}i\theta}|1\rangle)\otimes\frac{1}{\sqrt2}(|0\rangle+e^{2^{m-2}i\theta}|1\rangle)\otimes\frac{1}{\sqrt2}(|0\rangle+e^{2^{m-3}i\theta}|1\rangle)\otimes\cdots\\\otimes\frac{1}{\sqrt2}(|0\rangle+e^{2i\theta}|1\rangle)\otimes\frac{1}{\sqrt2}(|0\rangle+e^{i\theta}|1\rangle)\right)|u\rangle
\end{align}

---

Ahora, digamos que $\theta=2\pi j$, donde $j$ es un número entre $0$ y $1$. En notación binaria, podemos expresar números decimales de la siguiente manera: $j=0.j_0j_1j_2\cdots j_{m-1}$. En base decimal, podemos convertir dicha expresión binaria de la siguiente manera: $j=\frac{j_0}{2}+\frac{j_1}{4}+\frac{j_2}{8}+\cdots+\frac{j_{m-1}}{2^{m}}$. Entonces, el estado $|\psi\rangle$ puede expresarse como:

\begin{align}
|\psi\rangle=\left(\frac{1}{\sqrt2}(|0\rangle+e^{2\pi i 2^{m-1}\left(\frac{j_0}{2}+\frac{j_1}{4}+\cdots+\frac{j_{m-1}}{2^{m}}\right)}|1\rangle)\otimes\frac{1}{\sqrt2}(|0\rangle+e^{2\pi i2^{m-2}\left(\frac{j_0}{2}+\frac{j_1}{4}+\cdots+\frac{j_{m-1}}{2^{m}}\right)}|1\rangle)\otimes\cdots\\\otimes\frac{1}{\sqrt2}(|0\rangle+e^{2\pi i2\left(\frac{j_0}{2}+\frac{j_1}{4}+\cdots+\frac{j_{m-1}}{2^{m}}\right)}|1\rangle)\otimes\frac{1}{\sqrt2}(|0\rangle+e^{2\pi i\left(\frac{j_0}{2}+\frac{j_1}{4}+\cdots+\frac{j_{m-1}}{2^{m}}\right)\theta}|1\rangle)\right)|u\rangle
\end{align}

Noten que $e^{2\pi i \cdot k}=e^{2\pi i}$ cuando $k$ es un entero: esto es porque ambos números representan una vuelta completa de $2\pi$ radianes en un círculo unitario. Por lo tanto, podemos despreciar los enteros en los exponentes de las fases relativas, ya que en todos tenemos un $2\pi i$ multiplicando. Por ejemplo, en el primer qubit, tenemos que $e^{2\pi i 2^{m-1}\left(\frac{j_0}{2}+\frac{j_1}{4}+\cdots+\frac{j_{m-1}}{2^{m}}\right)}=e^{2\pi i\left(2^{m-2}j_0+\cdots+j_{m-2}+\frac{j_{m-1}}{2}\right)}=e^{2\pi i\left(\frac{j_{m-1}}{2}\right)}$. Como pueden ver, el término con $j_{m-1}$ es el único que sobrevivió, ya que al multiplicarlo por $2^{m-1}$ no obtuvimos un entero y por lo tanto no puede ser despreciado. Si operamos de la misma manera con el resto de las fases relativas, llegamos a la siguiente expresión:

\begin{align}
|\psi\rangle=\left(\frac{1}{\sqrt2}(|0\rangle+e^{2\pi i\left(\frac{j_{m-1}}{2}\right)}|1\rangle)\otimes\frac{1}{\sqrt2}(|0\rangle+e^{2\pi i\left(\frac{j_{m-2}}{2}+\frac{j_{m-1}}{4}\right)}|1\rangle)\otimes\cdots\\\otimes\frac{1}{\sqrt2}(|0\rangle+e^{2\pi i\left(\frac{j_1}{2}+\frac{j_2}{4}+\cdots+\frac{j_{m-1}}{2^{m-1}}\right)}|1\rangle)\otimes\frac{1}{\sqrt2}(|0\rangle+e^{2\pi i\left(\frac{j_0}{2}+\frac{j_1}{4}+\cdots+\frac{j_{m-1}}{2^{m}}\right)}|1\rangle)\right)|u\rangle
\end{align}

Se puede observar que la expresión que obtuvimos es la transformada cuántica de Fourier de $j$: $QFT|j\rangle=|\psi\rangle$. Por lo tanto, si aplicamos la $IQFT=QFT^\dagger$ a los primeros $m$ qubits, mediremos los bits que conforman la expresión $j=0.j_0j_1j_2\cdots j_{m-1}$ a la salida del circuito. Así, habremos aproximado el valor de $\theta=2\pi j$. A partir de ahí, podemos reconstruir el autovalor $e^{i\theta}$.

## El algoritmo de Shor

El algoritmo de Shor nos permite encontrar de manera eficiente los factores primos $p$ y $q$ de un número $N$ muy grande; se cumple que $N=pq$. Si este algoritmo logra implementarse a gran escala, nos permitiría romper el sistema RSA, un método de encriptación ampliamente utilizado. De todos modos, eso no sucederá por un tiempo, ya que requeriría una computadora cuántica tolerante a fallos con millones de qubits lógicos.

Antes de adentrarnos en el algoritmo en sí, veamos algunos prerrequisitos importantes.

### Exponenciación modular

Diremos que $a\equiv b\: mod(n)$ si el resto de $\frac{a}{n}$ es $b$. Por ejemplo, $3\equiv 1\: mod(2)$, ya que el resto de dividir $3$ por $2$ es $1$.

Una operación matemática clave en el algoritmo de Shor es la **exponenciación modular**: las potencias de un número realizadas sobre un **módulo** (*mod*).

Como ejemplo, veamos la exponenciación modular de 2 módulo 9 (pueden comprobar los resultados con una calculadora):

\begin{align}
2^0\equiv1\:mod(9) \qquad 2^6\equiv1\:mod(9) \qquad 2^{12}\equiv1\:mod(9)\\
2^1\equiv2\:mod(9) \qquad 2^7\equiv2\:mod(9) \qquad 2^{13}\equiv2\:mod(9)\\
2^2\equiv4\:mod(9) \qquad 2^8\equiv4\:mod(9) \qquad 2^{14}\equiv4\:mod(9)\\
2^3\equiv8\:mod(9) \qquad 2^9\equiv8\:mod(9) \qquad 2^{15}\equiv8\:mod(9)\\
2^4\equiv7\:mod(9) \qquad 2^{10}\equiv7\:mod(9) \qquad 2^{16}\equiv7\:mod(9)\\
2^5\equiv5\:mod(9) \qquad 2^{11}\equiv5\:mod(9) \qquad 2^{17}\equiv5\:mod(9)\\
\end{align}

Como pueden ver, al tomar las potencias de un número sobre un módulo, obtenemos un patrón que se repite. El largo de este patrón es el **período** $r$. En el ejemplo para las potencias de 2 mod 9, el patrón que se repite es $1$, $2$, $4$, $8$, $7$, $5$. Entonces, el período es $r=6$.

Encontrar el período de una exponenciación modular es un problema cuya complejidad aumenta exponencialmente con $n$, por lo que no se puede resolver de manera eficiente con una computadora clásica.

Pueden encontrar más información sobre la exponenciación modular [acá](https://es.wikipedia.org/wiki/Exponenciaci%C3%B3n_modular).

### Fracciones continuas

Otra herramienta matemática, que usaremos al final del algoritmo de Shor, son las **fracciones continuas**. Nosotros nos limitaremos a ver fracciones continuas de números racionales, que son las que necesitamos para el algoritmo. En ese contexto, una fracción continua es una expresión de la forma:

\begin{equation}
a_0+\frac{1}{a_1+\frac{1}{a_2+\frac{1}{\ddots+\frac{1}{a_n}}}}
\end{equation}

donde $a_0$ es un número natural o $0$, y $a_1, a_2, \ldots, a_n\in \mathbb{N}$.

Podemos obtener la fracción continua de un racional de la siguiente manera: separamos su parte entera de su parte decimal (en forma de fracción) mediante una suma; luego, damos vuelta la fracción en el denominador; repetimos el proceso hasta obtener un $1$ en el denominador.

Veamos un ejemplo:

\begin{align}
&0,312=0+\frac{312}{1000}=0+\frac{1}{\left(\frac{1000}{312}\right)}=0+\frac{1}{3+\frac{8}{39}}\\
&=0+\frac{1}{3+\frac{1}{\left(\frac{39}{8}\right)}}=0+\frac{1}{3+\frac{1}{4+\frac{7}{8}}}=0+\frac{1}{3+\frac{1}{4+\frac{1}{\left(\frac{8}{7}\right)}}}=0+\frac{1}{3+\frac{1}{4+\frac{1}{1+\frac{1}{7}}}}
\end{align}

Podemos realizar **aproximaciones** del número racional original truncando la fracción continua. En nuestro ejemplo, las primeras aproximaciones de $0,312$ usando fracciones continuas son:

\begin{align}
0,312\approx\frac{1}{3}\qquad 0,312\approx\frac{1}{3+\frac{1}{4}}=\frac{4}{13} \qquad 0,312\approx\frac{1}{3+\frac{1}{4+\frac{1}{1}}}=\frac{5}{16}
\end{align}

Pueden encontrar más información sobre fracciones continuas [acá](https://es.wikipedia.org/wiki/Fracci%C3%B3n_continua#).

### Paso 1

Más adelante, vamos a ver que podemos reducir el problema de la factorización de un número al problema de encontrar el período de una exponenciación modular. El algoritmo de Shor encuentra el período $r$ de la exponenciación modular de un número $a$ sobre el módulo $N$ (el número que queremos factorizar). Denotamos esta operación como $a^x\:mod(N)$. Con una buena aproximación de $r$ (que obtenemos con el circuito cuántico del algoritmo), tenemos una buena chance de que las expresiones $mcd(a^{\frac{r}{2}}-1, N)$ y $mcd(a^{\frac{r}{2}}+1, N)$ (las veremos más adelante) contengan a $p$ y/o $q$.

El algoritmo de Shor combina pasos clásicos y cuánticos. El primer paso es elegir el número entero $a$ entre $1$ y $N$ tal que el **máximo común divisor** entre $a$ y $N$ sea $1$:

\begin{equation}
mcd(a, N)=1
\end{equation}

El [máximo común divisor](https://es.wikipedia.org/wiki/M%C3%A1ximo_com%C3%BAn_divisor) puede calcularse con el [algoritmo de Euclides](https://es.wikipedia.org/wiki/Algoritmo_de_Euclides). Luego de elegir $a$, viene la parte cuántica del algoritmo.

### Paso 2

Para la parte cuántica, necesitamos definir la siguiente compuerta:

\begin{equation}
U_{a,N}|x\rangle=|xa\:mod(N)\rangle
\end{equation}

Si aplicamos dicha compuerta al estado $|1\rangle$, obtenemos las potencias de $a$ en módulo $N$. Si $r$ es el período de $a^x\:mod(N)$, tenemos que:

\begin{align}
U_{a,N}^0|1\rangle&=|1\:mod(N)\rangle \\
U_{a,N}^1|1\rangle&=|a\:mod(N)\rangle \\
U_{a,N}^2|1\rangle&=|a^2\:mod(N)\rangle \\
U_{a,N}^3|1\rangle&=|a^3\:mod(N)\rangle \\
U_{a,N}^4|1\rangle&=|a^4\:mod(N)\rangle \\
&\vdots\\
U_{a,N}^r|1\rangle&=|a^r\:mod(N)\rangle=|1\:mod(N)\rangle \\
\end{align}

---

Ahora, consideremos el siguiente estado conformado por la superposición equiprobable de las potencias de $a$ mod $N$:

\begin{align}
|u_s\rangle=\frac{1}{\sqrt{r}}\left(e^{-2\pi i s (0)/r}|a^0\:mod(N)\rangle+e^{-2\pi i s (1)/r}|a^1\:mod(N)\rangle+\cdots\\+e^{-2\pi i s (r-2)/r}|a^{r-2}\:mod(N)\rangle+e^{-2\pi i s (r-1)/r}|a^{r-1}\:mod(N)\rangle\right)
\end{align}

Si aplicamos la compuerta $U_{a,N}$, obtenemos:

\begin{align}
U_{a,N}|u_s\rangle=\frac{1}{\sqrt{r}}\left(e^{-2\pi i s (0)/r}|a^1\:mod(N)\rangle+e^{-2\pi i s (1)/r}|a^2\:mod(N)\rangle+\cdots\\+e^{-2\pi i s (r-2)/r}|a^{r-1}\:mod(N)\rangle+e^{-2\pi i s (r-1)/r}|a^{r}\:mod(N)\rangle\right)
\end{align}

Como $a^{r}\:mod(N)=a^{0}\:mod(N)=1\:mod(N)$, podemos reescribir el último estado de la superposición como $|a^0\:mod(N)\rangle$. Multiplicando y dividiendo la expresión anterior por $e^{2\pi i s/r}$, tenemos:

\begin{align}
U_{a,N}|u_s\rangle\cdot e^{2\pi i s/r}e^{-2\pi i s/r}=e^{2\pi i s/r}\frac{1}{\sqrt{r}}\left(e^{-2\pi i s (1)/r}|a^1\:mod(N)\rangle+e^{-2\pi i s (2)/r}|a^2\:mod(N)\rangle+\cdots\\+e^{-2\pi i s (r-1)/r}|a^{r-1}\:mod(N)\rangle+e^{-2\pi i s (r)/r}|a^{r}\:mod(N)\rangle\right)
\end{align}

Como $e^{-2\pi i s (r)/r}=e^{-2\pi i s (0)/r}=1$, tenemos que:

\begin{equation}
U_{a,N}|u_s\rangle=e^{2\pi i s/r}|u_s\rangle
\end{equation}

---

Se puede ver que $|u_s\rangle$ es un autovector de $U_{a,N}$ y $e^{2\pi i s/r}$ es su autovalor asociado. Por lo tanto, si construimos el estado $|u_s\rangle$, ¡podemos obtener $s/r$ utilizando el algoritmo QPE!

Por la expresión del estado $|u_s\rangle$, pueden imaginarse que construir esta superposición puede ser un proceso complejo. Por lo tanto, construimos la superposición equiprobable de todos los estados $|u_s\rangle$ (con $0\leq s\leq r-1$). Esta suma es mucho más fácil de construir, ¡ya que equivale al estado $|1\rangle$! No veremos la demostración en esta clase, pero pueden intentar demostrar que, efectivamente:

\begin{equation}
\frac{1}{\sqrt{r}}\sum_{s=0}^{r-1}|u_s\rangle=|1\:mod(N)\rangle=|1\rangle
\end{equation}

Por lo tanto, el circuito para el algoritmo de Shor es idéntico al del algoritmo QPE, usando $|u\rangle=|1\rangle$:



Como $|1\rangle$ es un autovector de $U_{a,N}$, este circuito estimará el autovalor $e^{2\pi i s/r}$, para un $s$ entre $0$ y $r-1$. Recordemos que:

\begin{equation}
|1\rangle=\frac{1}{\sqrt{r}}\sum_{s=0}^{r-1}|u_s\rangle=\frac{1}{\sqrt{r}}(|u_0\rangle+|u_1\rangle+\cdots+|u_{r-1}\rangle)
\end{equation}

Con este circuito, estamos calculando los autovalores de todos los estados de la superposición en simultáneo. Al medir, obtendremos solo un autovalor asociado a uno de los autovectores. Si medimos $0$, entonces $s=0$ y repetimos el circuito para obtener otra respuesta no trivial.

En resumen, el algoritmo QPE devuelve un número $j$ tal que el autovalor de $|u\rangle$ es $e^{2\pi i j}$, por lo que en el circuito del algoritmo de Shor mediremos un número $j\approx\frac{s}{r}$ para algún $|u_s\rangle$ de la superposición equiprobable. La exactitud de la aproximación de $\frac{s}{r}$ depende de la cantidad de qubits que se utilizan para la $IQFT$.

### Paso 3

Una vez que obtenemos un número $j\approx s/r$ con nuestro circuito cuántico, estimamos los valores de $s$ y $r$ realizando las aproximaciones de $j$ con fracciones continuas. Al realizar dichas aproximaciones, obtendremos un $s$ y un $r$, que se corresponderan al numerador y denominador de la aproximación, respectivamente. Como $r< N$, tenemos que elegir un par de valores en el que el denominador sea menor que $N$.

Como para la última operación del algoritmo tenemos que utilizar un $r$ par, si obtenemos un $r$ impar repetimos el algoritmo y obtenemos un nuevo valor para el período.

Finalmente, sabemos que $a^r\equiv1\:mod(N)$, por lo que $a^r-1\equiv 0\:mod(N)$. Esto significa que $a^r-1$ es un factor de $N$. Tomando diferencia de cuadrados, $a^r-1=(a^{r/2}-1)(a^{r/2}+1)$. De acá, podemos ver que los máximos divisores entre dichos valores y $N$ contienen un factor no trivial de $N$. Por lo tanto, tenemos una buena chance de encontrar dicho factor usando nuestra estimación de $r$ para computar $mcd(a^{r/2}-1,N)$ y $mcd(a^{r/2}+1,N)$.

### Un ejemplo simple

Para acentar los conceptos del algoritmo de Shor, implementémoslo para $N=15$. Este es un ejemplo sencillo, ya que sabemos fácilmente que $p=3$ y $q=5$. Sin embargo, es útil para demostrar su funcionamiento para números más grandes.

 - *Paso 1:* elegimos un número $a$ tal que $mcd(a,N)=1$. En este ejemplo, elegimos $a=7$.
 - *Paso 2:* utilizamos una computadora cuántica para estimar $s/r$. Recordemos que se cumple que $7^r\equiv 1\:mod(N)$.
 - *Paso 3:* utilizando fracciones continuas, encontramos que $r=4$. Por último, calculamos $mcd(7^{4/2}-1,15)=mcd(48,15)=3$ y  $mcd(7^{4/2}+1,15)=mcd(50,15)=5$.

# Bibliografía

[1] M. A. Nielsen, I. L. Chuang, *Quantum Computation and Quantum Information*. Cambridge, U.K.: Cambridge Univ. Press, 2000.

[2] E. G. Rieffel, W. H. Polak, *Quantum Computing: A Gentle Introduction*. Cambridge, MA, USA: MIT Press, 2011.

[3] R. S. Sutor, *Dancing with Qubits: How Quantum Computing Works and How It Can Change the World*. Birmingham, U.K.: Packt Publishing, 2019.

[3] *Fundamentals of Quantum Algorithms*, por John Watrous. Disponible en: https://quantum.cloud.ibm.com/learning/es/courses/basics-of-quantum-information

[3] *Quantum Computing Course – Math and Theory for Beginners*, por @quantum-soar. Disponible en: https://www.youtube.com/watch?v=tsbCSkvHhMo

[4] *El algoritmo de Simon*, por Ket.G. Disponible en: https://www.youtube.com/watch?v=swzlvZxk5Q4
