# ¡Bienvenidos a la tercera clase de la Quantum Jam 2026!

Hola! En esta última clase, vamos a ver los últimos algoritmos y protocolos cuánticos necesarios para afrontar los desafíos de la Hackathon.

Primero, vamos a retomar las comunicaciones cuánticas y adentrarnos un poco en criptografía. Veremos un método muy importante para distribuir claves criptográficas.

Finalmente, vamos a ver el algoritmo de Grover para búsquedas en una secuencia no ordenada de datos. Junto con el algoritmo de Shor, es el más importante de la computación cuántica. La explicación se encuentra en la segunda parte de esta clase y es completamente optativa debido a su dificultad ligeramente superior al resto de los temas.

**Guardar esta clase:** para guardar las clase y el código que escriban en los ejercicios, les recomendamos hacer una copia de este doumento en su carpeta de Google Drive. Seleccionen ```Archivo```, arriba a la izquierda en Google Collab, y luego elijan la opción ```Guardar una copia en Drive```.

# Distribución cuántica de claves (QKD)

En la clase anterior, vimos como modelar las comunicaciones (emisor, canal, receptor) y explicamos dos características indeseadas que nos podemos encontrar: el ruido y la presencia de un hacker o espía. Si no recuerdan estos conceptos, pueden repasarlos antes de encarar esta sección.

Además, vimos dos protocolos que aprovechan la computación cuántica para comunicaciones: la teleportación cuántica (enviar un qubit por un canal clásico) y la codificación superdensa (enviar dos bits usando solo un qubit).

En esta sección, vamos a introducir brevemente los conceptos esenciales de la criptografía y analizar un protocolo para distribuir claves criptográficas por un canal cuántico.

## Introducción: un poco sobre criptografía

En la actualidad, protegemos nuestros mensajes de texto, mails y otras actividades que realizamos por Internet con sistemas criptográficos. De esa manera, evitamos que un tercero no deseado entienda nuestros mensajes si son intervenidos mientras se envían.

Existen dos sistemas principales de criptografía:

- **Criptografía simétrica** o de **clave privada**: el emisor y el receptor tienen una misma clave secreta con la que codifican y decodifican el mensaje, utilizando diversas operaciones matemáticas. Como es secreta, existen muchos protocolos para distribuir dicha clave a ambas partes. Distribuir y custodiar la clave privada de forma segura suele ser difícil.

- **Criptografía asimétrica** o de **clave pública**: permite cifrar o verificar con una clave pública (disponible a un hacker que interfiera en la comunicación) y descifrar o firmar con una clave privada. Este sistema facilita intercambio de claves y firmas digitales, aunque suele ser más costosa computacionalmente.

Uno de los sistemas criptográficos más utilizados es el **sistema RSA** (Rivest, Shamir, Adleman). La seguridad de RSA se debe a la dificultad de factorizar números muy grandes (un problema cuya complejidad aumenta exponencialmente). Una computadora cuántica de millones de qubits lógicos podría implementar el algoritmo de Shor para factorizar estos números en un tiempo polinomial, lo que pondría en riesgo gran parte de los sistemas de seguridad del mundo.

Por eso, muchos científicos han pensado en alternativas para proteger la información cuando esto suceda. Entre todos los esfuerzos realizados, se han diseñado muchos protocolos de **distribución cuántica de claves** (*Quantum Key Distribution*, QKD): son maneras de compartir claves privadas utilizando un canal cuántico entre el emisor y el receptor. En este contexto, el primer protocolo de QKD que se inventó es el **protocolo BB84** (creado por Charles Bennett y Gilles Brassard en 1984).

## Protocolo BB84

En el protocolo BB84, el emisor (*Alice*) y el receptor (*Bob*) se comunican a través de dos canales:

- Un **canal clásico público autenticado**; es decir, podemos verificar la identidad de quien envía el mensaje y que este no haya sido manipulado.

- Un **canal cuántico** por el que se envían qubits.

Originalmente, Bennett y Brassard se refirieron específicamente a sintetizar qubits físicamente mediante la polarización de **fotones individuales**. En este caso, cada fotón representa un qubit y su polarización, el estado. Las compuertas para cambiar el estado de los qubits pueden sintetizarse físicamente con **polarizadores** orientados de distintas maneras. Los qubits pueden enviarse por una fibra óptica o por el aire libre.

Para el protocolo, nos interesan específicamente los estados $|0\rangle$, $|1\rangle$, $|+\rangle$ y $|-\rangle$, que se representan como las polarizaciónes horizontal ($|\rightarrow\rangle$), vertical ($|\uparrow\rangle$), diagonal ($|\nearrow\rangle$) y anti-diagonal ($|\nwarrow\rangle$) respectivamente.

Por último, tenemos que tener en cuenta que un hacker, *Eve*, puede interceptar tanto el canal clásico como el canal cuántico. Analizaremos la situación en la que Eve intercepta los qubits por el canal cuántico, los mide respecto a una base determinada (haciendo colapsar la superposición) y reenvía el estado que midió. También podrá escuchar la comunicación entre Alice y Bob por el canal clásico.

Existen muchas otras consideraciones respecto al protocolo BB84, como otros métodos de interceptar la línea de Eve, la presencia de ruido, y la corrección y mitigación de errores luego de obtener las claves. No las analizaremos en esta clase, pero les sugerimos fuertemente que las investiguen.

Veamos los pasos del protocolo:

### Paso 1

Alice crea una cadena de largo $n$ de $0$s y $1$s de manera aleatoria. Esta cadena se usa para crear la clave; al final del protocolo, la clave final que obtengamos tendrá un largo de aproximadamente $n/2$.

A lo largo de todos los pasos, analizaremos un ejemplo concreto para visualizar mejor el protocolo. Usando $n=10$, obtenemos este string clásico como ejemplo:


\begin{array}{|c|c|c|c|c|c|c|c|c|}
\hline
\text{String de Alice} & 1 & 0 & 1 & 1 & 0 & 0 & 1 & 0 & 1 & 0 \\
\hline
\end{array}

### Paso 2

Alice codifica la cadena que creó en el *Paso 1* para enviarla por el canal cuántico de la siguiente manera:

- Si el bit es un $0$, puede enviar un $|0\rangle$ o un $|+\rangle$.

- Si el bit es un $1$, puede enviar un $|1\rangle$ o un $|-\rangle$.

Alice elige de manera aleatoria para cada bit la base con la que lo codifica: $B_Z=\{|0\rangle, |1\rangle\}$ ó $B_X=\{|+\rangle, |-\rangle\}$. En este punto, no le comunica a Bob qué base eligió para cada bit.

\begin{array}{|c|c|c|c|c|c|c|c|c|c|c|}
\hline
\text{String de Alice} & 1 & 0 & 1 & 1 & 0 & 0 & 1 & 0 & 1 & 0 \\
\hline
\text{Base de Alice} & Z & X & Z & X & X & Z & Z & X & Z & X \\
\hline
\text{String codificado} & |1\rangle & |+\rangle & |1\rangle & |-\rangle & |+\rangle & |0\rangle & |1\rangle & |+\rangle & |1\rangle & |+\rangle\\
\hline
\end{array}

### Paso 3

Bob mide los qubits que recibe de Alice, eligiendo de manera aleatoria la base de medición entre $B_Z$ y $B_X$. Elegirá la misma base que Alice aproximadamente la mitad de las veces, por lo que para la otra mitad tendrá un $50\%$ de probabilidad de terminar con un bit incorrecto de la clave (puede obtener $1$ con probabilidad $1/2$, o $0$ con probabilidad $1/2).

\begin{array}{|c|c|c|c|c|c|c|c|c|c|c|}
\hline
\text{String de Alice} & 1 & 0 & 1 & 1 & 0 & 0 & 1 & 0 & 1 & 0 \\
\hline
\text{Base de Alice} & Z & X & Z & X & X & Z & Z & X & Z & X \\
\hline
\text{String codificado} & |1\rangle & |+\rangle & |1\rangle & |-\rangle & |+\rangle & |0\rangle & |1\rangle & |+\rangle & |1\rangle & |+\rangle\\
\hline
\text{Base de Bob} & X & Z & Z & X & Z & X & Z & X & Z & Z \\
\hline
\text{Posibles resultados de Bob} & 0/1 & 0/1 & 1 & 1 & 0/1 & 0/1 & 1 & 0 & 1 & 0/1 \\
\hline
\end{array}

### Paso 4

Este paso se conoce como **sifting**. Bob le comunicará a Alice por el canal clásico qué bases usó para medir cada qubit y Alice le contestará cuáles son correctas (ambos utilizaron la misma base) y cuáles incorrectas (usaron bases distintas).

\begin{array}{|c|c|c|c|c|c|c|c|c|c|c|}
\hline
\text{Base de Bob} & X & Z & Z & X & Z & X & Z & X & Z & Z \\
\hline
\text{Respuesta de Alice} & \color{red}{\text{NO}} & \color{red}{\text{NO}} & \color{green}{\text{SI}} & \color{green}{\text{SI}} & \color{red}{\text{NO}} & \color{red}{\text{NO}} & \color{green}{\text{SI}} & \color{green}{\text{SI}} & \color{green}{\text{SI}} & \color{red}{\text{NO}} \\
\hline
\end{array}

### Paso 5

Alice y Bob eliminan los bits medidos con distintas bases. El resultado es una clave privada de (en promedio) la mitad del largo de la clave original que generó Alice. Si el canal no tenía imperfecciones, ruido o espías, estas claves coincidirán un $100\%$

\begin{array}{|c|c|c|c|c|c|c|c|c|c|c|}
\hline
\text{Clave final} &  &  & 1 & 1 &  &  & 1 & 0 & 1 &  \\
\hline
\end{array}

Aunque hasta acá lleguen los pasos del protocolo BB84, el procedimiento para dar con la clave final que efectivamente se usará continúa:

- El canal cuántico puede tener *ruido*, por lo que, en la práctica, las claves de Alice y Bob no coincidirán en un $100\%$. Ambos deben establecer un límite de bits diferentes en sus claves finales para determinar que dichas imperfecciones se deben a ruido y no a espías. Para esto, compartirán $m$ bits de la clave que obtuvieron con el *Paso 5*. Si dichos $m$ bits coinciden en un porcentaje mayor al límite, entonces determinan que no intervinieron espías en el canal.

- Si los $m$ bits no coinciden por encima del límite, entonces se determina que Eve intervino los canales. En ese caso, se pueden implementar las técnicas de conciliación de datos y amplificación de la privacidad para eliminar discrepancias entre las claves y reducir la información parcial de Eve.

### Ataque interceptar y reenviar

¿Qué pasa si un hacker - Eve - se encuentra en los canales (el clásico y el cuántico)? ¿Cómo nos ayuda el protocolo BB84 a detectar su presencia?

Eve puede escuchar lo que Alice y Bob dicen por el canal clásico, por lo que se enterará de los bits que descartaron luego del *sifting*. Además, puede intervenir el canal cuántico. Una de las maneras de intervenir la fibra óptica es medir cada fotón enviado (eligiendo aleatoriamiente la base, $B_Z$ ó $B_X$) y luego reenviarle a Bob lo que midió con su base.

Si Alice y Bob codifican y decodifican los qubits con la misma base, deberían obtener el mismo bit. Si Eve midió el qubit enviado por Alice con una base distinta y obtuvo el bit incorrecto, enviará un dato equivocado. Luego del sifting, Alice y Bob podrán verificar que dicho bit no coincide en ambas claves. Si este comportamiento sucede con muchos bits, detectarán la presencia de Eve (uno solo no alcanza para determinar que la discrepancia es por Eve y no por ruido).

Supongamos que Alice envía el bit $b$ codificado con la base $B$ y que Eve lo intercepra, midiendo con la base $B'$ y obteniendo $b'$.

Si Eve realiza el ataque *interceptar y reenviar*, la probabilidad de que el bit que envía Alice codificado sea decodificado correctamente por el espía es:

\begin{align}
P(b'=b)&=P(b'=b|B'=B)P(B'=B)+P(b'=b|B'\neq B)P(B'\neq B)
=1\cdot0,5+0,5\cdot0,5=0,75
\end{align}

En esta expresión, utilizamos el [teorema de la probabilida total](https://es.wikipedia.org/wiki/Teorema_de_la_probabilidad_total) para calcular dicha probabilidad. Además, consideramos que las probabilidades de que Eve elija una base u otra son iguales ($0,5$).

Análogamente, vemos que la probabilidad de que los bits de Alice y Bob coincidan si Eve intervino el canal es del $75\%$ (la cuenta es exactamente igual a la anterior).

Al compartir $m$ bits para identificar la presencia de Eve, la probabilidad de detectar espías en el canal es:

\begin{equation}
P_d=P(\text{Eve detectado})=1-\left[P(b_\text{Eve}=b_\text{Alice})\right]^m=1-(0,75)^m=1-\left(\frac{3}{4}\right)^m
\end{equation}

Por lo tanto, para detectar a Eve con una probabilidad del $P_d=0,999999999$, Alice y Bob deben compartir $m=\text{log}_{0,75}(1-P_d)\approx72$ bits.

**Nota:** existen muchos otros métodos de ataque además del que acabamos de ver (llamado **interceptar y reenviar**). Algunos ejemplos son:

- **Ataque de intermediario** (también conocido como *Man-in-the-middle*, *MitM* o *Janus*): al igual que en criptografía clásica, si el canal no está autenticado, es vulnerable a este tipo de ataque (pueden leer más [acá](https://es.wikipedia.org/wiki/Ataque_de_intermediario)).

- **División del número de fotones** (*photon number splitting*, PNS): en muchas implementaciones reales, el protocolo utiliza pulsos de láser atenuados en vez de fotones individuales. En esos casos, se envía una cantidad de fotones por pulso que siguen una [distribución de Poisson](https://es.wikipedia.org/wiki/Distribuci%C3%B3n_de_Poisson). En ese caso, algunos pulsos contendrán $0$ fotones, otros $1$ fotón (es lo más deseable) y otros $2$ fotones (o más). Si se envía un pulso con $2$ fotones, Eve puede interceptar uno y dejar intacto el otro; de esa manera, es mucho más dificil detectar su presencia. Sin embargo, se puede generar una clave segura de todos modos. Además, existen otros protocolos de QKD que detectan más fácilmente la presencia de Eve si realiza este tipo de ataque. Pueden investigar más [acá](https://en.wikipedia.org/wiki/Quantum_key_distribution#Photon_number_splitting_attack).

- **Ataque de denegación de servicio** (*Denial of Service*, *DoS*): Eve puede cortar o bloquear la fibra óptica. Una solución a este ataque es crear una red de distribución cuántica de claves.
