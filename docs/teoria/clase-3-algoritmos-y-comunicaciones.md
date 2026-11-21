# ¡Bienvenidos a la tercera clase de la Quantum Jam 2026!

Hola! En esta clase, vamos a ver unos cuantos algoritmos cuánticos, que demuestran la utilidad y eficiencia de las computadoras cuánticas para resolver cierto tipo de problemas. Expresaremos a los algoritmos en forma de circuitos cuánticos. Además, algunos de ellos requerirán etapas de post-procesamiento con los resultados del circuito.

En primer lugar, vamos a analizar algunos protocolos de comunicación que utilizan computadoras cuánticas. Luego, veremos una serie de algoritmos basados en el oráculo cuántico. En la úlitma sección (disponible en la Parte 2 de la clase) analizaremos la transformada cuántica de Fourier, el algoritmo QPE y el algoritmo de Shor (el más importante de la computación cuántica). Esta última sección es completamente opcional, y su dificultad es mayor comparada con el resto de los temas que hemos visto.

**Guardar esta clase:** para guardar las clase y el código que escriban en los ejercicios, les recomendamos hacer una copia de este doumento en su carpeta de Google Drive. Seleccionen ```Archivo```, arriba a la izquierda en Google Collab, y luego elijan la opción ```Guardar una copia en Drive```.

**Instalación:** para instalar todas las librerías y servicios necesarios para esta clase, corran la siguiente celda apretando el botón de play a la izquierda.

# Comunicaciones cuánticas

Empecemos hablando de comunicaciones. La transmisión de información es una pieza fundamental en nuestras vidas y en el mundo. Nos permite hablar con familiares y amigos a la distancia, recibir emails y acceder a contenido como películas y música por Internet. En su capa más baja, esto se logra transmitiendo muchos bits, que codifican la información en un sistema binario: $0$ ó $1$.

Gracias a la superposición, un qubit puede almacenar más información que un bit en sus amplitudes de probabilidad. Sin embargo, vimos que solo podemos acceder a un bit de información cuando lo medimos. Entonces, ¿cómo podemos aprovechar la "información oculta" de los qubits para comunicaciones? Vamos a ver dos ejemplos: el protocolo de teleportación cuántica y el de codificación superdensa.

Antes de ver los protocolos, veamos brevemente cómo modelar las comunicaciones.

## Introducción: un modelo de las comunicaciones

Existen tres elementos básicos para transmitir información:

- Un **emisor** o **fuente de información** que codifica y envía el mensaje. Solemos usar el nombre **Alice** para referirnos al emisor.

- Un **receptor** que recibe y decodifica el mensaje. Solemos llamarlo **Bob**.

- Un **canal** por el que se transmiten las señales. En esta clase, hablaremos de canales clásicos - por los que enviamos bits - y cuánticos, que transmiten qubits. Ejemplos típicos de canales clásicos son líneas de transmisión, fibra óptica, cables de par trenzado, ondas de radio, WiFi y 5G. El ejemplo más simple de un canal cuántico es la transmisión de fotones individuales a través de una fibra óptica.

Existen dos características indeseadas en los canales que debemos tener en cuenta para más adelante:

- **Ruido**: mientras la información viaja por el canal, pueden ocurrir perturbaciones o fluctuaciones que modifiquen el valor de los bits (o qubits). Existen muchos tipos de ruido, siendo el *ruido blanco* el más común. Pueden encontrar información adicional [en este link](https://es.wikipedia.org/wiki/Ruido_blanco#).

- La presencia de un **hacker** (que usualmente llamaremos **Eve**) que quiera interceptar nuestro mensaje con fines maliciosos. Para evitar que Eve adquiera información secreta o privada, utilizamos procesos de cifrado (*encriptación*). Más adelante, veremos un protocolo para encriptar información en un canal cuántico.

**Nota:** gran parte de la seguridad actual usa el sistema criptográfico RSA, cuya solidez se basa en que factorizar números enteros grandes no tiene algoritmos clásicos conocidos en tiempo polinomial. Una computadora cuántica a gran escala y tolerante a fallas podría ejecutar el algoritmo de Shor (factorización en tiempo polinomial) y comprometer el sistema RSA.

## Teleportación cuántica: mandando qubits por WhatsApp

La **teleportación cuántica** es una técnica para transportar estados cuánticos en ausencia de un canal de comunicación cuántico que conecte al emisor con el receptor: ¡enviamos qubits por un canal clásico!

Supongamos que **Alice** y **Bob** generaron un *par EPR* estando juntos y luego se separaron por una gran distancia, cada uno se llevándose un qubit del par EPR:

\begin{equation}
|\beta_{00}\rangle=\frac{1}{\sqrt{2}}\left[|\color{red}{0}\color{blue}{0}\rangle+|\color{red}{1}\color{blue}{1}\rangle\right]
\end{equation}

Para facilitar la lectura, marcamos de *rojo* los qubits de Alice y de *azul* los de Bob.

Alice desconoce dónde está Bob, pero quiere enviarle un qubit $|\psi\rangle=\alpha|0\rangle+\beta|1\rangle$ (no usaremos colores para los estados de este qubit) cuyo estado no conoce. Además, solo puede enviarle información clásica a Bob (bits).

Por las leyes de la mecánica cuántica, Alice no puede determinar el estado de $|\psi\rangle$ con una sola copia. Y aunque lo supiera, no podría enviárselo a Bob porque necesitaría una cantidad infinita de información clásica para describirlo precisamente, ya que $|\psi\rangle$ toma valores continuos.

El siguiente circuito implementa la teleportación del qubit:



Las dos líneas de arriba le pertenecen a Alice (el qubit que quiere mandar y su qubit del par EPR). La línea de abajo es el qubit del par EPR de Bob. El primer estado del sistema es entonces:

\begin{equation}
|\psi_0\rangle=|\psi\rangle|\beta_{00}\rangle=\frac{1}{\sqrt{2}}\left[\alpha|0\rangle\left(|\color{red}{0}\color{blue}{0}\rangle+|\color{red}{1}\color{blue}{1}\rangle\right)+\beta|1\rangle\left(|\color{red}{0}\color{blue}{0}\rangle+|\color{red}{1}\color{blue}{1}\rangle\right)\right]
\end{equation}

Luego, se aplica una CNOT con $|\psi\rangle$ como el qubit de control y el qubit de Alice del par EPR como target:

\begin{equation}
|\psi_1\rangle=\frac{1}{\sqrt{2}}\left[\alpha|0\rangle\left(|\color{red}{0}\color{blue}{0}\rangle+|\color{red}{1}\color{blue}{1}\rangle\right)+\beta|1\rangle\left(|\color{red}{1}\color{blue}{0}\rangle+|\color{red}{0}\color{blue}{1}\rangle\right)\right]
\end{equation}

Después, se le aplica una compuerta de Hadamard a $|\psi\rangle$. Tras un poco de álgebra, obtenemos:

\begin{split}
|\psi_2\rangle &= \frac{1}{\sqrt{2}}\left[\alpha|+\rangle\left(|\color{red}{0}\color{blue}{0}\rangle+|\color{red}{1}\color{blue}{1}\rangle\right)+\beta|-\rangle\left(|\color{red}{1}\color{blue}{0}\rangle+|\color{red}{0}\color{blue}{1}\rangle\right)\right]\\
&=\frac{1}{2}\left[\alpha\left(|0\rangle+|1\rangle\right)\left(|\color{red}{0}\color{blue}{0}\rangle+|\color{red}{1}\color{blue}{1}\rangle\right)+\beta\left(|0\rangle-|1\rangle\right)\left(|\color{red}{1}\color{blue}{0}\rangle+|\color{red}{0}\color{blue}{1}\rangle\right)\right]\\
&=\frac{1}{2}\left[\alpha|0\color{red}{0}\color{blue}{0}\rangle+\alpha|1\color{red}{0}\color{blue}{0}\rangle+\alpha|0\color{red}{1}\color{blue}{1}\rangle+\alpha|1\color{red}{1}\color{blue}{1}\rangle+\beta|0\color{red}{1}\color{blue}{0}\rangle-\beta|1\color{red}{1}\color{blue}{0}\rangle+\beta|0\color{red}{0}\color{blue}{1}\rangle-\beta|1\color{red}{0}\color{blue}{1}\rangle\right]\\
&=\frac{1}{2}\left[
|0\color{red}{0}\rangle\left(\alpha|\color{blue}{0}\rangle+\beta|\color{blue}{1}\rangle\right)
+|0\color{red}{1}\rangle\left(\alpha|\color{blue}{1}\rangle+\beta|\color{blue}{0}\rangle\right)
+|1\color{red}{0}\rangle\left(\alpha|\color{blue}{0}\rangle-\beta|\color{blue}{1}\rangle\right)
+|1\color{red}{1}\rangle\left(\alpha|\color{blue}{1}\rangle-\beta|\color{blue}{0}\rangle\right)
\right]
\end{split}

En la última línea de la expresión anterior se puede apreciar que cuando Alice mide sus dos qubits, obtendrá 4 combinaciones posibles de dos bits clásicos. Al medirlos, determinará el estado del qubit de Bob:

\begin{split}
M_1\color{red}{M_2}=
0\color{red}{0}&\longmapsto |\psi_3\rangle=\alpha|\color{blue}{0}\rangle+\beta|\color{blue}{1}\rangle\\
M_1\color{red}{M_2}=
0\color{red}{1}&\longmapsto |\psi_3\rangle=\alpha|\color{blue}{1}\rangle+\beta|\color{blue}{0}\rangle\\
M_1\color{red}{M_2}=
1\color{red}{0}&\longmapsto |\psi_3\rangle=\alpha|\color{blue}{0}\rangle-\beta|\color{blue}{1}\rangle\\
M_1\color{red}{M_2}=
1\color{red}{1}&\longmapsto |\psi_3\rangle=\alpha|\color{blue}{1}\rangle-\beta|\color{blue}{0}\rangle\\
\end{split}

Luego, Alice envía por un canal de comunicaciones clásico sus dos bits (puede comunicarlos por Instagram o WhatsApp). Dependiendo del estado de los bits, se le aplicarán al qubit de Bob las transformaciones necesarias para obtener $|\psi\rangle$. Se puede ver que:

- si recibe los bits $00$, no debe aplicar ninguna transformación, ya que su qubit es $|\psi\rangle$;
- si recibe los bits $01$, se deben intercambiar los estados del qubit de Bob, por lo que se debe aplicar una compuerta $X$;
- si recibe los bits $10$, se debe invertir el signo del estado $|1\rangle$ del qubit de Bob, por lo que se debe aplicar una compuerta $Z$;
- si recibe los bits $11$, se deben intercambiar los estados del qubit de Bob y luego invertir el signo del estado $|1\rangle$, por lo que se debe aplicar una compuerta $X$ y luego una compuerta $Z$.

Estas operaciones pueden resumirse en la combinación de compuertas $Z^{M_1}X^{M_2}$.

Así, es fácil ver que Bob obtendrá siempre el qubit que Alice deseaba enviarle:

\begin{split}
M_1\color{red}{M_2}=
0\color{red}{0}&\longmapsto |\psi_4\rangle=Z^0X^0|\psi_3\rangle=|\psi\rangle\\
M_1\color{red}{M_2}=
0\color{red}{1}&\longmapsto |\psi_4\rangle=Z^0X^1|\psi_3\rangle=|\psi\rangle\\
M_1\color{red}{M_2}=
1\color{red}{0}&\longmapsto |\psi_4\rangle=Z^1X^0|\psi_3\rangle=|\psi\rangle\\
M_1\color{red}{M_2}=
1\color{red}{1}&\longmapsto |\psi_4\rangle=Z^1X^1|\psi_3\rangle=|\psi\rangle\\
\end{split}

Cuestiones importantes:

1. **La teleportación cuántica no permite enviar información más rápido que la velocidad de la luz** (lo que está prohibido, ya que la teoría de la relatividad muestra que la comunicación a velocidades más altas que la de la luz permitiría enviar información a un tiempo pasado): Alice necesita enviarle sus dos bits por un canal de comunicación clásico a Bob para completar la teleportación. Sin estos dos bits, la teleportación no transmite información.
2. **La teleportación cuántica no crea una copia del qubit que es teleportado:** el qubit original termina en uno de los dos estados de la base computacional y la información representada por $|\psi\rangle$ termina en el qubit de Bob.

## Codificación superdensa: 2 bits por el precio de 1 qubit

El protocolo de codificación superdensa se utiliza para transmitir la información de dos bits clásicos enviando un solo qubit por un canal cuántico.

Para la codificación superdensa, Alice y Bob preparan un par EPR al igual que en el protocolo de teleportación cuántica:

\begin{equation}
|\beta_{00}\rangle=\frac{1}{\sqrt{2}}\left[|\color{red}{0}\color{blue}{0}\rangle+|\color{red}{1}\color{blue}{1}\rangle\right]
\end{equation}

Luego, Alice se lleva el primer qubit (el rojo) y Bob el segundo (el azul).

Alice quiere enviarle a Bob 2 bits, que pueden estar en los estados $00$, $01$, $10$ ó $11$. Dependiendo de qué estado desee enviar, le aplicará distintas compuertas a su qubit del par:

- Si quiere enviar $00$, no aplica ninguna compuerta: $|\psi\rangle=\frac{1}{\sqrt2}\left(|\color{red}{0}\color{blue}{0}\rangle+|\color{red}{1}\color{blue}{1}\rangle\right)$.

- Si quiere enviar $01$, aplica la compuerta $X$: $|\psi\rangle=\frac{1}{\sqrt2}\left(|\color{red}{1}\color{blue}{0}\rangle+|\color{red}{0}\color{blue}{1}\rangle\right)$.

- Si quiere enviar $10$, aplica la compuerta $Z$: $|\psi\rangle=\frac{1}{\sqrt2}\left(|\color{red}{0}\color{blue}{0}\rangle-|\color{red}{1}\color{blue}{1}\rangle\right)$.

- Si quiere enviar $11$, aplica la compuerta $Z$ y luego la $X$: $|\psi\rangle=\frac{1}{\sqrt2}\left(|\color{red}{1}\color{blue}{0}\rangle-|\color{red}{0}\color{blue}{1}\rangle\right)$.

De manera similar a la teleportación cuántica, podemos sintetizar estas operaciones en la compuerta $X^{M_2}Z^{M_1}$. Después de que Alice aplique esta compuerta, codificando los bits que quiere enviar, le envía su qubit del par EPR a Bob. Bob aplicará una CNOT usando el qubit de Alice como el de control, y luego le aplicará una compuerta de Hadamard, con lo que al medir obtendrá los dos bits que Alice quería enviarle.

Al aplicar la compuerta CNOT, los estados son:

\begin{equation}
   \left\{
\begin{array}{ll}
      \frac{1}{\sqrt2}\left(|\color{red}{0}\color{blue}{0}\rangle+|\color{red}{1}\color{blue}{0}\rangle\right)=|\color{red}{+}\rangle|\color{blue}{0}\rangle & M_1M_2=00 \\
      \frac{1}{\sqrt2}\left(|\color{red}{1}\color{blue}{1}\rangle+|\color{red}{0}\color{blue}{1}\rangle\right)=|\color{red}{+}\rangle|\color{blue}{1}\rangle & M_1M_2=01 \\
      \frac{1}{\sqrt2}\left(|\color{red}{0}\color{blue}{0}\rangle-|\color{red}{1}\color{blue}{0}\rangle\right)=|\color{red}{-}\rangle|\color{blue}{0}\rangle & M_1M_2=10 \\
      \frac{1}{\sqrt2}\left(|\color{red}{1}\color{blue}{1}\rangle-|\color{red}{0}\color{blue}{1}\rangle\right)=|\color{red}{-}\rangle|\color{blue}{1}\rangle & M_1M_2=11 \\
\end{array}
\right.
\end{equation}

Al aplicar la compuerta de Hadamard, pueden ver que los estados serán:

\begin{equation}
   \left\{
\begin{array}{ll}
      (H|+\rangle)|0\rangle=|00\rangle & M_1M_2=00 \\
      (H|+\rangle)|1\rangle=|01\rangle & M_1M_2=01 \\
      (H|-\rangle)|0\rangle=|10\rangle & M_1M_2=10 \\
      (H|-\rangle)|1\rangle=|11\rangle & M_1M_2=11 \\
\end{array}
\right.
\end{equation}

Pueden verificar que podemos modelar este protocolo con el siguiente circuito:

# Oráculos y profecías

En esta sección, analizaremos una serie de algoritmos que utilizan funciones que no conocemos por completo: podemos modelarlas como una "caja negra" en la que introducimos *inputs* y obtenemos ciertos resultados. Debemos inferir el comportamiento de la caja negra (o alguna característica de ella) a partir de dichos resultados.

## El oráculo cuántico

En la Antigua Grecia, las personas que llegaban al templo de Apolo le realizaban consultas al oráculo de Delfos, que respondía con profecías, de manera enigmática.

En computación, un oráculo es una función nos dará dos respuestas: sí ($1$) o no ($0$). No podemos realizar cualquier pregunta: debemos ingresar un número de bits, $n$, que sabemos con antelación. Distintas cadenas otorgan distintos resultados.

En definitiva, el oráculo puede modelarse como una función $f$ desconocida para nosotros, que recibe $n$ bits y devuelve un solo bit como respuesta:

\begin{equation}
f:\{0,1\}^n\longrightarrow\{0,1\}
\end{equation}

Recordemos que $\{0,1\}^n$ se lee como "todos los strings posibles de largo $n$ cuyos caracteres son $0$ ó $1$".

Como en computación cuántica las compuertas que apliquemos en nuestros circuitos cuánticos deben ser unitarias, debemos crear una compuerta unitaria para evaluar la función desconocida $f$. Lo logramos con la compuerta $U_f$, el **oráculo cuántico**, que actúa sobre $n+1$ qubits de entrada:

El oráculo actúa de la siguiente manera:

\begin{equation}
U_f|x,y\rangle=|x,y\oplus f(x)\rangle
\end{equation}

donde $y\oplus f(x)$ es la operación XOR entre $f(x)$ e $y$. Teniendo en cuenta que $x\oplus 0=x$ y $x\oplus 1 = \bar{x}$, será útil para los siguientes algoritmos ver que se cumplen las siguientes igualdades para cualquier entrada $|x\rangle$ de largo $n$:

\begin{align}
U_f|x,0\rangle &=|x,0\oplus f(x)\rangle=|x,f(x)\rangle\\
U_f|x,1\rangle &=|x,1\oplus f(x)\rangle=|x,\overline{f(x)}\rangle\\
U_f|x\rangle|-\rangle &= U_f|x\rangle\frac{|0\rangle-|1\rangle}{\sqrt2}=(-1)^{f(x)}|x\rangle|-\rangle\\
\end{align}

Como podemos ver, si $y=0$, evaluaremos la función para $f(x)$ para la entrada $x$; si $y=1$, evaluaremos la función $f(x)$ negada. Si $|y\rangle=|-\rangle$, obtenemos la última propiedad, la cual es muy utilizada en los algoritmos que veremos a continuación. Pueden intentar demostrarla evaluando el oráculo para cada estado de la superposición.

## El algoritmo de Deutsch

El algoritmo de Deutsch nos dice si una función $f:\{0,1\}\longrightarrow\{0,1\}$ (desconocida para nosotros) es **constante** o **balanceada**.

Una función constante devuelve siempre el mismo resultado. Como tenemos un solo bit de entrada para la función $f$, las dos funciones constantes posibles son las siguientes:

$
\begin{array}{c|c}
x & f(x) \\
\hline
0 & 0 \\
1 & 0 \\
\end{array}
$ $\qquad\qquad$
$
\begin{array}{c|c}
x & f(x) \\
\hline
0 & 1 \\
1 & 1 \\
\end{array}
$

Por otro lado, las funciones balanceadas devuelven $1$ para la mitad de los inputs y $0$ para la otra mitad. En el caso de este algoritmo, tenemos dos funciones balanceadas posibles:

$
\begin{array}{c|c}
x & f(x) \\
\hline
0 & 0 \\
1 & 1 \\
\end{array}$$\qquad\qquad$
$
\begin{array}{c|c}
x & f(x) \\
\hline
0 & 1 \\
1 & 0 \\
\end{array}
$

Una solución clásica debería hacerle dos consultas al oráculo para saber si la función es constante o balanceada. El algoritmo de Deutsch permite saberlo con una sola consulta al oráculo.

El circuito que implementa el algoritmo de Deutsch es el siguiente:



Vemos que el estado de entrada del circuito es $|\phi_0\rangle=|0\rangle|1\rangle$. Luego, aplicamos una compuerta de Hadamard a cada qubit, con lo que obtenemos:

\begin{equation}
|\phi_1\rangle=|+\rangle|-\rangle=\frac{|0\rangle+|1\rangle}{\sqrt2}|-\rangle= \frac{|0\rangle|-\rangle+|1\rangle|-\rangle}{\sqrt2}
\end{equation}

Al ingresar este estado al oráculo, utilizaremos la propiedad vista en la sección anterior:

\begin{equation}
|\phi_2\rangle=U_f|\phi_1\rangle=\frac{(-1)^{f(0)}|0\rangle|-\rangle+(-1)^{f(1)}|1\rangle|-\rangle}{\sqrt2}=\frac{(-1)^{f(0)}|0\rangle+(-1)^{f(1)}|1\rangle}{\sqrt2}|-\rangle
\end{equation}

Podemos ver que evaluamos los dos valores de la función ($f(0)$ y $f(1)$) con una sola consulta utilizando el principio de superposición. Esta capacidad de las computadoras cuánticas de realizar múltiples cálculos simultáneamente se denomina **paralelismo cuántico**.

Analicemos ahora los posibles casos. Si $f$ es constante, obtendremos alguno de los siguientes estados:

\begin{equation}
   |\phi_2\rangle=\left\{
\begin{array}{ll}
      \frac{|0\rangle+|1\rangle}{\sqrt2}|-\rangle=|+\rangle|-\rangle & f(0)=f(1)=0\\
      \frac{-|0\rangle-|1\rangle}{\sqrt2}|-\rangle=-|+\rangle|-\rangle & f(0)=f(1)=1\\
\end{array}
\right.
\end{equation}

Por lo tanto, al aplicar la última compuerta de Hadamard obtendremos el estado $|\phi_3\rangle=|0\rangle|-\rangle$ (ignorando la fase global) y mediremos siempre $0$.

Por otro lado, si $f$ es balanceada, $|\phi_2\rangle$ puede ser uno de estos dos estados:

\begin{equation}
   |\phi_2\rangle=\left\{
\begin{array}{ll}
      \frac{|0\rangle-|1\rangle}{\sqrt2}|-\rangle=|-\rangle|-\rangle & f(0)=0,\quad f(1)=1\\
      \frac{-|0\rangle+|1\rangle}{\sqrt2}|-\rangle=-|-\rangle|-\rangle & f(0)=1, \quad f(1)=0\\
\end{array}
\right.
\end{equation}

Luego, $|\phi_3\rangle=(H\otimes I)|\phi_2\rangle=|1\rangle|-\rangle$ (ignorando la fase global) y mediremos siempre $1$.

En conclusión, obtendremos $0$ si nuestra función misteriosa $f$ es constante y $1$ si es balanceada.

## El algoritmo de Deutsch-Jozsa

El algoritmo de Deutsch-Jozsa es una extensión del algoritmo de Deutsch para funciones del tipo $f:\{0,1\}^n\longrightarrow\{0,1\}$; es decir, con entradas de largo $n$. Análicemos el problema de manera clásica: en el peor caso, deberíamos hacer $2^{n-1}+1$ consultas al oráculo para saber si la función es constante o balanceada: si obtenemos el mismo resultado en $2^{n-1}=2^n/2$ consultas, debemos realizar una adicional. Una computadora cuántica puede resolver este problema con una sola consulta.

El circuito que la implementa es el siguiente:



El estado inicial es $|\psi_0\rangle=|0\rangle^{\otimes n}\otimes|1\rangle$. Al aplicar la transformada de Hadamard al estado de entrada, obtenemos:

\begin{equation}
|\psi_1\rangle=H^{\otimes n}|0\rangle^{\otimes n}\otimes H|1\rangle= \frac{1}{\sqrt{2^n}}\sum_
{x=0}^{2^n-1}|x\rangle|-\rangle
\end{equation}

Al aplicar el oráculo, evaluaremos la función $f(x)$ en todos las posibles entradas con solo una consulta, gracias a la superposición y el paralelismo cuántico:

\begin{equation}
|\psi_2\rangle= \frac{1}{\sqrt{2^n}}\sum_
{x=0}^{2^n-1}(-1)^{f(x)}|x\rangle|-\rangle
\end{equation}

Al aplicar la última transformada de Hadamard a cada estado de la superposición, obtenemos:

\begin{equation}
|\psi_3\rangle= \frac{1}{\sqrt{2^n}}\sum_
{x=0}^{2^n-1}(-1)^{f(x)}(H|x\rangle)|-\rangle=\frac{1}{2^n}\sum_
{x=0}^{2^n-1}(-1)^{f(x)}\sum_
{y=0}^{2^n-1}(-1)^{\vec{x}\cdot\vec{y}}|y\rangle|-\rangle=\frac{1}{2^n}\sum_
{y=0}^{2^n-1}\sum_
{x=0}^{2^n-1}(-1)^{f(x)+\vec{x}\cdot\vec{y}}|y\rangle|-\rangle
\end{equation}

---

Analicemos la amplitud del estado $|0\rangle^{\otimes n}|-\rangle$ en $|\psi_3\rangle$:

\begin{equation}
\frac{1}{2^n}\sum_
{y=0}^{2^n-1}\sum_
{x=0}^{2^n-1}(-1)^{f(x)+(00\cdots 0)\cdot\vec{y}}=\frac{1}{2^n}\sum_
{y=0}^{2^n-1}\sum_
{x=0}^{2^n-1}(-1)^{f(x)}
\end{equation}

Si $f$ es constante, $(-1)^{f(x)}$ valdrá $1$ para $f(x)=0$ y $-1$ para $f(x)=1$. En ese caso, la amplitud del estado $|0\rangle^{\otimes n}|-\rangle$ será:

\begin{equation}
\frac{1}{2^n}\sum_
{y=0}^{2^n-1}\sum_
{x=0}^{2^n-1}\pm 1=\pm\frac{1}{2^n}2^n=\pm1
\end{equation}

Por lo tanto, la probabilidad de medir todos $0$s al final del circuito es del $100\%$ ($|\pm1|^2=1$).

Si $f$ es balanceada, $(-1)^{f(x)}$ será $1$ para la mitad de las entradas y $-1$ para la otra mitad, por lo que - viendo la expresión de la amplitud del estado $|0\rangle^{\otimes n}|-\rangle$ - todas se cancelarán al sumarse.

Tengan en cuenta que para un string $x$ de largo $n$, tenemos $2^n$ estados posibles, por lo que los estados de la superposición siempre serán una cantidad par y siempre se cancelarán si $f$ es balanceada. Entonces, la probabilidad de medir todos $0$s al final del circuito es del $0\%$.

En conclusión, el algoritmo de Deutsch-Jozsa devuelve una cadena de $0$s si la función es constante, y cualquier otra cadena si es balanceada.

## El algoritmo de Bernstein-Vazirani

El algoritmo de Bernstein-Vazirani utiliza exactamente el mismo circuito que el algoritmo de Deutsch-Jozsa para resolver otro problema.

Supongamos que tenemos una función $f:\{0,1\}^n\longrightarrow\{0,1\}$ que sabemos que actúa de la siguiente manera:

\begin{equation}
f(x)=x\cdot s=x_0s_0+x_1s_1+\cdots+x_{n-3}s_{n-3}+x_{n-2}s_{n-2}+x_{n-1}s_{n-1}
\end{equation}

El objetivo del algoritmo es encontrar el string secreto $s=s_0s_1\cdots s_{n-3}s_{n-2}s_{n-1}$.

Una solución clásica requiere $n$ consultas al oráculo: ingresamos las $n$ entradas en las que todos los caracteres son $0$ excepto uno. De esa manera, obtenemos todos los caracteres de $s$:

\begin{align}
f(00\cdots 001) &=0\cdot s_0+0\cdot s_1+\cdots+0\cdot s_{n-3}+0\cdot s_{n-2}+1\cdot s_{n-1}=s_{n-1}\\
f(00\cdots 010) &=0\cdot s_0+0\cdot s_1+\cdots+0\cdot s_{n-3}+1\cdot s_{n-2}+0\cdot s_{n-1}=s_{n-2}\\
f(00\cdots 100) &=0\cdot s_0+0\cdot s_1+\cdots+1\cdot s_{n-3}+0\cdot s_{n-2}+0\cdot s_{n-1}=s_{n-3}\\
\vdots\\
f(00\cdots 001) &=0\cdot s_0+1\cdot s_1+\cdots+0\cdot s_{n-3}+0\cdot s_{n-2}+0\cdot s_{n-1}=s_{1}\\
f(00\cdots 001) &=1\cdot s_0+0\cdot s_1+\cdots+0\cdot s_{n-3}+0\cdot s_{n-2}+0\cdot s_{n-1}=s_{0}\\
\end{align}

El algoritmo de Bernstein-Vazirani resuelve este problema con una sola consulta.

Como el circuito es idéntico al de Deutsch-Jozsa, podemos analizar directamente qué obtendremos a la salida del oráculo, ya que los pasos anteriores serán iguales:

\begin{equation}
|\psi_2\rangle= \frac{1}{\sqrt{2^n}}\sum_
{x=0}^{2^n-1}(-1)^{f(x)}|x\rangle|-\rangle=\frac{1}{\sqrt{2^n}}\sum_
{x=0}^{2^n-1}(-1)^{x\cdot s}|x\rangle|-\rangle
\end{equation}

Al aplicar la última transformada de Hadamard, obtenemos:

\begin{equation}
|\psi_2\rangle=\frac{1}{\sqrt{2^n}}\sum_
{x=0}^{2^n-1}(-1)^{x\cdot s}\frac{1}{\sqrt2}\sum_{y=0}^{2^n-1}(-1)^{x\cdot y}|y\rangle|-\rangle=\frac{1}{{2^n}}\sum_
{x=0}^{2^n-1}\sum_{y=0}^{2^n-1}(-1)^{x\cdot (s+y)}|y\rangle|-\rangle
\end{equation}

Como estamos trabajando con las representaciones binarias de los números, $s+y=s\oplus y$ es la operación XOR bitwise.

A la salida del algoritmo, obtendremos todos los caracteres ordenados del string $s$, ya que la amplitud del estado $|s\rangle|-\rangle$ es $1$:

\begin{equation}
\frac{1}{{2^n}}\sum_
{x=0}^{2^n-1}(-1)^{x\cdot (s+s)}=\frac{1}{{2^n}}\sum_
{x=0}^{2^n-1}(-1)^{x\cdot \vec{0}}=\frac{1}{{2^n}}\sum_
{x=0}^{2^n-1}1=\frac{1}{{2^n}}2^n=1
\end{equation}

En conclusión, podremos saber todos los caracteres del string secreto con una sola consulta al oráculo con una probabilidad del $100\%$.

## El algoritmo de Simon

El último algoritmo que analizaremos es el algoritmo de Simon (desarrollado por Daniel R. Simon), el cual tiene relevancia histórica por haber inspirado a Peter Shor (ver su imagen a la derecha) para desarrollar [su famoso algoritmo](https://es.wikipedia.org/wiki/Algoritmo_de_Shor). Si bien puede parecer que no resuelve un problema particularmente relevante, fue el primer algoritmo de la computación cuántica que consiguió una mejora exponencial sobre el mejor de los algoritmos clásicos.

Antes de ver el algoritmo, repasemos algunos prerrequisitos.

Una **función uno a uno** (o inyectiva) es una función $f:\{0,1\}^n\longrightarrow\{0,1\}^m $ en la que cada input da lugar a un output distinto; diferentes inputs no nos van a devolver lo mismo. A continuación se muestra un ejemplo de una función uno a uno con $n=m=3$:

\begin{align}
f(000)&=111 \qquad f(100)=000 \\
f(001)&=010 \qquad f(101)=101 \\
f(010)&=110 \qquad f(110)=100 \\
f(011)&=011 \qquad f(111)=001 \\
\end{align}

Una **función dos a uno** es una función $f:\{0,1\}^n\longrightarrow\{0,1\}^m $ en la que dos inputs distintos comparten un mismo output. Un ejemplo de una función dos a uno es:

\begin{align}
f(000)&=000 \qquad f(100)=111 \\
f(001)&=101 \qquad f(101)=100 \\
f(010)&=111 \qquad f(110)=000 \\
f(011)&=100 \qquad f(111)=101 \\
\end{align}

El algoritmo de Simon tratará con funciones dos a uno que cumplen una condición especial: si dos inputs $x$ e $y$ comparten el mismo output $f(x)=f(y)$, entonces se cumple que $x\oplus y=b$, donde $b$ es un número fijo (es el mismo para todos los pares de inputs). Como etamos trabajando con números binarios (módulo 2), también vale que $y=x\oplus b$. En el ejemplo anterior, $b=110$. Podemos ver que todos los inputs cumplen con esta condición:

\begin{align}
000\oplus110&=110 \qquad 001\oplus111=110 \\
010\oplus100&=110 \qquad 011\oplus101=110
\end{align}

Si la función es uno a uno, podemos pensarla como una función dos a uno en la que se cumple esta condición y $b=0$ (ya que se cumplirá que $x\oplus x =0$). En resumen, si $b=0$ entonces la función es uno a uno y si $b\neq0$ entonces la función es dos a uno.

El problema que queremos resolver es encontrar el string secreto $b$. No sabemos la forma de la función $f$, por lo que la modelamos como una caja negra u oráculo. Un algoritmo clásico necesita $\frac{n}{2}+1$ iteraciones en el peor caso. El algoritmo de Simon reduce exponencialmente el número de iteraciones.

El circuito cuántico que utilizaremos es el siguiente:



Como pueden ver, nuestro estado inicial es $|0\rangle^{\otimes n}\otimes|0\rangle^{\otimes m}$. Luego, aplicamos la transformada de Hadamard sobre los primeros $n$ qubits, por lo que el estado antes de aplicar el oráculo es:

\begin{equation}
\left(\frac{1}{\sqrt{2^n}}\sum_{x=0}^{2^n-1}|x\rangle\right)\otimes|0\rangle^{\otimes m}
\end{equation}

Al aplicar el oráculo, como $0\oplus f(x)=f(x)$, el estado será:

\begin{equation}
\frac{1}{\sqrt{2^n}}\sum_{x=0}^{2^n-1}|x\rangle|f(x)\rangle
\end{equation}

En este punto, realizamos una medición de los últimos $m$ qubits, con lo que obtendremos un output específico $f(x)$ con una probabilidad $|{1}/{\sqrt{2^n}}|^2=1/2^n$. Por lo tanto, el estado del sistema después de esta medición colapsará a:

\begin{equation}
\frac{|x\rangle+|y\rangle}{\sqrt2}|f(x)\rangle
\end{equation}

donde $x$ e $y$ son los inputs que comparten el mismo output ($f(x)=f(y)$) y que cumplen $y = x\oplus b$. Finalmente, aplicamos una transformada de Hadamard a los primeros $n$ qubits:

\begin{align}
&\frac{H^{\otimes n}|x\rangle+H^{\otimes n}|y\rangle}{\sqrt2}|f(x)\rangle\\&=\frac{1}{\sqrt2}\left(\frac{1}{\sqrt{2^n}}\sum_{z=0}^{2^n-1}(-1)^{\vec{x}\cdot\vec{z}}|z\rangle+\frac{1}{\sqrt{2^n}}\sum_{z=0}^{2^n-1}(-1)^{\vec{y}\cdot\vec{z}}|z\rangle\right)|f(x)\rangle\\
&=\frac{1}{\sqrt{2^{n+1}}}\sum_{z=0}^{2^n-1}\left[(-1)^{\vec{x}\cdot\vec{z}}+(-1)^{\vec{y}\cdot\vec{z}}\right]|z\rangle|f(x)\rangle
\end{align}

Cuando midamos los primeros $n$ qubits, obtendremos alguno de los $2^n$ estados $|z\rangle$ con probabilidad $(1/2^{n+1})\cdot|(-1)^{x\cdot z}+(-1)^{y\cdot z}|^2$. En ese caso, tendremos que $(-1)^{x\cdot z}=(-1)^{y\cdot z}$; sino, estos numeros se cancelarían entre ellos y la amplitud de probabilidad sería $0$. Por lo tanto, tenemos que $x\cdot z=y\cdot z$. Como $y=x\oplus b$, entonces $x\cdot z=(x+b)\cdot z=x\cdot z+b\cdot z$. Si cancelamos los términos $x\cdot z$, obtenemos que el estado $|z\rangle$ que medimos cumple con la ecuación $b\cdot z=b_0z_0+b_1z_2+\cdots+b_{n-1}z_{n-1}=0$.

Debemos correr este circuito cuántico la suficiente cantidad de veces para obtener $n$ números $z$ diferentes, que cumplan con $b\cdot z = 0$. Luego, podremos obtener $b$ resolviendo el sistema de ecuaciones lineales:

\begin{equation}
\begin{cases}
b_0 z_0^{(1)} + b_1 z_1^{(1)} + \dots + b_{n-1} z_{n-1}^{(1)} = 0, \\[4pt]
b_0 z_0^{(2)} + b_1 z_1^{(2)} + \dots + b_{n-1} z_{n-1}^{(2)} = 0, \\[4pt]
\vdots \\[4pt]
b_0 z_0^{(n)} + b_1 z_1^{(n)} + \dots + b_{n-1} z_{n-1}^{(n)} = 0.
\end{cases}
\end{equation}

Pueden observar que $b=0$ siempre será solución de este sistema. Si no obtenemos otra solución, la función será uno a uno. Si obtenemos otra solución más allá de la trivial, la función será dos a uno.
