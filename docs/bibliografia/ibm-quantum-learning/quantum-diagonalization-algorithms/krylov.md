# Krylov quantum diagonalization

> Fuente: <https://quantum.cloud.ibm.com/learning/en/courses/quantum-diagonalization-algorithms/krylov>

> Solo las celdas de texto del notebook original; sin código.


In this lesson on Krylov quantum diagonalization (KQD) we will answer the following:

* What is the Krylov method, generally?
* Why does the Krylov method work and under what conditions?
* How does quantum computing play a role?

The quantum part of the calculations are based largely on work in Ref [\[1\]](#references).

The video below gives an overview of Krylov methods in classical computing, motivates their use, and explains how quantum computing can play a role in that workstream. The subsequent text offers more detail and implements a Krylov method both classically, and using a quantum computer.

## 1. Introduction to Krylov methods

A __Krylov subspace method__ can refer to any of several methods built around what is called the __Krylov subspace__. A complete review of these is beyond the scope of this lesson, but Ref [\[2-4\]](#references) can all give substantially more background. Here, we will focus on what a Krylov subspace is, how and why it is useful in solving eigenvalue problems, and finally how it can be implemented on a quantum computer.

__Definition:__ Given a symmetric, positive semi-definite $N\times N$ matrix $A$, the Krylov space $\mathcal{K}^r$ of order $r$ is the space spanned by vectors obtained by multiplying higher powers of a matrix $A$, up to $r-1\leq N$, with a reference vector $\vert v \rangle$.

$$
\mathcal{K}^r = \text{span}\left\{ \vert v \rangle, A \vert v \rangle, A^2 \vert v \rangle, ..., A^{r-1} \vert v \rangle \right\}
$$

Although the vectors above span what we call a Krylov subspace, there is no reason to think that they will be orthogonal. One often uses an iterative orthonormalizing process similar to __Gram-Schmidt orthogonalization__. Here the process is slightly different since each new vector is made orthogonal to the others as it is generated. In this context this is called __Arnoldi iteration__. Starting with the initial vector $|v\rangle$, one generates the next vector $A|v\rangle$, and then ensures that this second vector is orthogonal to the first by subtracting off its projection on $|v\rangle$. That is

$$
\begin{aligned}
|v_0\rangle &=\frac{|v\rangle}{\left|\left| |v\rangle \right|\right|}\\

|v_1\rangle &=\frac{A|v\rangle-\langle v_0|A|v\rangle |v_0\rangle}{\left|\left|A|v\rangle-\langle v_0|A|v\rangle |v_0\rangle \right|\right|}
\end{aligned}
$$

It is now easy to see that $|v_0\rangle \perp |v_1\rangle$, since
$$
\langle v_0 | v_1\rangle=\frac{\langle v_0 | A|v\rangle-\langle v_0 |A|v\rangle\langle v_0|v_0\rangle}{\left|\left| A|v\rangle-\langle A|v\rangle|v_0\rangle |v_0\rangle \right|\right|}=0
$$

We do the same for the next vector, ensuring it is orthogonal to both the previous two:
$$
|v_2\rangle=\frac{A |v_1\rangle-\langle v_0|A |v_1\rangle |v_0\rangle-\langle v_1|A |v_1\rangle |v_1\rangle}{\left|\left| A |v_1\rangle-\langle v_0|A |v_1\rangle |v_0\rangle-\langle v_1|A |v_1\rangle |v_1\rangle\right|\right|}
$$
If we repeat this process for all $r$ vectors, we have a complete orthonormal basis for a Krylov space. Note that the orthogonalization process here will yield zero once $r>m$, since $m$ orthogonal vector necessarily span the full space. The process will also yield zero if any vector is an eigenvector of $A$ since all subsequent vectors will be multiples of that vector.

### 1.1 A simple example: Krylov by hand

Let us step through a generation of a Krylov subspace generation on a trivially small matrix, so that we can see the process. We start with an initial matrix $A$ of interest to us:
$$
A=\begin{pmatrix}4&-1&0\\-1&4&-1\\0&-1&4\end{pmatrix}
$$
For this small example, we can determine the eigenvectors and eigenvalues easily even by hand. We show the numerical solution here.

We record them here for later comparison:
$$
\begin{aligned}
a_0&=2.59,&|0\rangle&=&\begin{pmatrix}1/2\\-\sqrt{2}/2\\1/2\end{pmatrix}\\
\\
a_1&=4,&|1\rangle&=&\begin{pmatrix}\sqrt{2}/2\\0\\-\sqrt{2}/2\end{pmatrix}\\
\\
a_2&=5.41,&|2\rangle&=&\begin{pmatrix}1/2\\\sqrt{2}/2\\1/2\end{pmatrix}
\end{aligned}
$$

We would like to study how this process works (or fails) as we increase the dimension of our Krylov subspace, $r$. To this end, we will apply this process:

* Generate a subspace of the full vector space starting with a randomly-chosen vector $|v\rangle$ (call it $|v_0\rangle$ if it is already normalized, as above).
* Project the full matrix $A$ onto that subspace, and find the eigenvalues of that projected matrix $\tilde{A}$.
* Increase the size of the subspace by generating more vectors, ensuring that they are orthonormal, using a process similar to Gram-Schmidt orthogonalization.
* Project $A$ onto the larger subspace and find the eigenvalues of the resulting matrix, $\tilde{A}$.
* Repeat this until the eigenvalues converge (or in this toy case, until you have generated vectors spanning the full vector space of the original matrix $A$).

A normal implementation of the Krylov method would not need to solve the eigenvalue problem for the matrix projected on every Krylov subspace as it is built. You could construct the subspace of the desired dimension, project the matrix onto that subspace, and diagonalize the projected matrix. Projecting and diagonalizing at each subspace dimension is only done for checking convergence.

#### Dimension $r=1$:

We choose a random vector, say
$$
|v_0\rangle=\begin{pmatrix}1\\0\\0\end{pmatrix}
$$

If it is not already normalized, normalize it.

We now project our matrix $A$ onto the subspace of this one vector:
$$
\tilde{A}_0=\langle v_0| A|v_0\rangle=\begin{pmatrix}1&0&0\end{pmatrix}\begin{pmatrix}4&-1&0\\-1&4&-1\\0&-1&4\end{pmatrix}\begin{pmatrix}1\\0\\0\end{pmatrix}=(4)
$$
This is our projection of the matrix onto our Krylov subspace when it contains just a single vector, $|v_0\rangle$. The eigenvalue of this matrix is trivially 4. We can think of this as our zeroth-order estimate of the eigenvalues (in this case just one) of $A$. Although it is a poor estimate, it is the correct order of magnitude.

#### Dimension $r=2$:

We now generate the next vector in our subspace through operation with $A$ on the previous vector:

$$
A|v_0\rangle=\begin{pmatrix}4&-1&0\\-1&4&-1\\0&-1&4\end{pmatrix}\begin{pmatrix}1\\0\\0\end{pmatrix}=\begin{pmatrix}4\\-1\\0\end{pmatrix}
$$

Now we subtract off the projection of this vector onto our previous vector to ensure orthogonality.
$$
|v_1\rangle=A|v_0\rangle-\langle v_0 |A|v_0\rangle|v_0\rangle
$$
$$
|v_1\rangle=\begin{pmatrix}4\\-1\\0\end{pmatrix}-\begin{pmatrix}1& 0& 0\end{pmatrix}\begin{pmatrix}4\\-1\\0\end{pmatrix}\begin{pmatrix}1\\0\\0\end{pmatrix}=\begin{pmatrix}0\\-1\\0\end{pmatrix}
$$

If it is not already normalized, normalize it. In this case, the vector was already normalized, so

$$
|v_1\rangle=\begin{pmatrix}0\\-1\\0\end{pmatrix}
$$

We now project our matrix A onto the subspace of these two vectors:
$$
\tilde{A}_1= \begin{pmatrix} 1&0&0\\0&-1&0 \end{pmatrix} \begin{pmatrix}4&-1&0\\-1&4&-1\\0&-1&4\end{pmatrix}\begin{pmatrix}1&0\\0&-1\\0&0\end{pmatrix}=\begin{pmatrix}1&0&0\\0&-1&0\end{pmatrix}\begin{pmatrix}4&1\\-1&-4\\0&1\end{pmatrix}=\begin{pmatrix}4&1\\1&4\end{pmatrix}
$$

We are still left with the problem of determining the eigenvalues of this matrix. But this matrix is slightly smaller than the full matrix. In problems involving very large matrices, working with this smaller subspace may be highly advantageous.

$$
\det(\tilde{A_1}-\lambda I)=0
$$
$$
\begin{vmatrix} 4-\lambda&1\\1&4-\lambda\end{vmatrix} =(4-\lambda)^2-1=0
$$
$$
4-\lambda=±1→\lambda=3,5
$$
Although this is still not a good estimate, it is better than the zeroth order estimate. We will carry this out for one more iteration, to ensure the process is clear. However, this undercuts the point of the method, since we will end up diagonalizing a 3x3 matrix in the next iteration, meaning we have not saved time or computational power.

#### Dimension $r=3$:

We now generate the next vector in our subspace through operation with A on the previous vector:
$$
A|v_1\rangle=\begin{pmatrix}4&-1&0\\-1&4&-1\\0&-1&4\end{pmatrix}\begin{pmatrix}0\\-1\\0\end{pmatrix}=\begin{pmatrix}1\\-4\\1\end{pmatrix}
$$
Now we subtract off the projection of this vector onto both our previous vectors to ensure orthogonality.
$$
\begin{aligned}
|v_2\rangle&=A|v_1\rangle-\langle v_0 |A|v_1\rangle|v_0\rangle-\langle v_1 |A|v_1\rangle|v_1\rangle\\
|v_2\rangle&=\begin{pmatrix}1\\-4\\1\end{pmatrix}-\begin{pmatrix}1& 0& 0 \end{pmatrix}\begin{pmatrix}1\\-4\\1\end{pmatrix}\begin{pmatrix}1\\0\\0\end{pmatrix}-\begin{pmatrix}0&-1& 0\end{pmatrix}\begin{pmatrix}1\\-4\\1\end{pmatrix}\begin{pmatrix}0\\-1\\0\end{pmatrix}=\begin{pmatrix}0\\0\\1\end{pmatrix}
\end{aligned}
$$

If it is not already normalized, normalize it. In this case, the vector was already normalized, so
$$
|v_2 \rangle=\begin{pmatrix}0\\0\\1\end{pmatrix}
$$
We now project our matrix $A$ onto the subspace of these vectors:

$$
\tilde{A}_2=\begin{pmatrix}1&0&0\\0&-1&0\\0&0&1\end{pmatrix}\begin{pmatrix}4&-1&0\\-1&4&-1\\0&-1&4\end{pmatrix}\begin{pmatrix}1&0&0\\0&-1&0\\0&0&1\end{pmatrix}=\begin{pmatrix}4&-1&0\\1&-4&1\\0&-1&4\end{pmatrix}\begin{pmatrix}1&0&0\\0&-1&0\\0&0&1\end{pmatrix}=\begin{pmatrix}4&1&0\\1&4&1\\0&1&4\end{pmatrix}
$$

We now determine the eigenvalues:
$$
\det(\tilde{A}_2-\lambda I)=0
$$
$$
\begin{vmatrix}4-\lambda&1&0\\1&4-\lambda&1\\0&1&4-\lambda\end{vmatrix} = (4-\lambda)((4-\lambda)^2-1)-(4-\lambda)=0\\
$$
$$
4-\lambda=0,4-\lambda=±2^{1/2}→\lambda=4-2^{1/2},4,4+2^{1/2}≈2.59,4,5.41
$$
These eigenvalues are exactly the eigenvalues of the original matrix $A$. This must be the case, since we have expanded our Krylov subspace to span the entire vector space of the original matrix $A$.

In this example, the Krylov method may not appear particularly easier than direct diagonalization. Indeed, as we will see in later sections, the Krylov method is only advantageous above a certain matrix dimension; this is intended to help us solve eigenvalue/eigenvector problems of extremely large matrices.

This is the only example we will show worked “by hand”, but section 2 below shows computational examples.

#### Clarification of terms

A common misconception is that there is just a single Krylov subspace for a given problem. But of course, since there are many initial vectors to which our matrix could be applied, there are many possible Krylov subspaces. We will only use the phrase "__the__ Krylov subspace" to refer to a specific Krylov subspace already defined for a specific example. For general problem-solving approaches we will refer to "__a__ Krylov subspace".
A final clarification is that it is valid to refer to a "Krylov __space__". One often sees it called a "Krylov __subspace__" because of its use in the context of projecting matrices from an initial space into a subspace. In keeping with that context, we will mostly refer to it as a subspace here.

#### Check your understanding

Explain why it is not (a) useful, and (b) possible to extend the dimension of the Krylov subspace $r$ beyond the dimension $N$ of the matrix of interest.

<Accordion>
<AccordionItem title="Answer">

(a) Since we are orthonormalizing the vectors as we produce them, a set of $N$ such vectors will form a complete basis, meaning a linear combination of them can be used to create any vector in the space.

(b) The orthogonalization process consists of subtracting off the projection of a new vector onto all previous vectors. If all previous vectors span the full vector space, then subtracting off projections onto the full subspace will always leave us with a zero vector.

</AccordionItem>
</Accordion>

Suppose a fellow researcher is demonstrating the Krylov method applied to a small toy matrix. Is there something wrong with their choice of matrix $A$ and initial vector $|\psi\rangle$?

$$
A=\begin{pmatrix}2&1&3\\1&2&3\\3&3&5\end{pmatrix}
$$
and
$$
|\psi\rangle=\frac{1}{\sqrt{2}}\begin{pmatrix}1\\-1\\0\end{pmatrix}.
$$

<Accordion>
<AccordionItem title="Answer">

Your colleague has accidentally chosen an eigenvector for his/her initial vector. Acting with the matrix on the initial vector will simply return the same vector back, scaled by the eigenvalue. This will not generate a subspace of increasing dimension. Advise your colleague to select a different initial vector, making sure it is not an eigenvector.

</AccordionItem>
</Accordion>

Apply the Krylov method to the given matrix, selecting an appropriate new initial vector. Write down the estimates of the minimum eigenvalue at the 0th and 1st order of your Krylov subspace.

$$
A=\begin{pmatrix}1&1&0\\1&1&1\\0&1&1\end{pmatrix}
$$

<Accordion>
<AccordionItem title="Answer">

There are many possible answers depending on the choice of initial vector. We will choose:
$$
|v_0\rangle=\frac{1}{\sqrt{3}}\begin{pmatrix}1\\1\\1\end{pmatrix}.
$$
To get $|v_1\rangle$ we apply $A$ once to $|v_0\rangle$, and then make $|v_1\rangle$ orthogonal to $|v_0\rangle$.
$$
A|v_0\rangle=\begin{pmatrix}1&1&0\\1&1&1\\0&1&1\end{pmatrix}\frac{1}{\sqrt{3}}\begin{pmatrix}1\\1\\1\end{pmatrix} = \frac{1}{\sqrt{3}}\begin{pmatrix}2\\3\\2\end{pmatrix}
$$
$$
A|v_0\rangle - \langle v_0|A|v_0\rangle |v_0\rangle=\frac{1}{\sqrt{3}}\begin{pmatrix}2\\3\\2\end{pmatrix} - \frac{1}{\sqrt{3}}\begin{pmatrix}1&1&1\end{pmatrix}\frac{1}{\sqrt{3}}\begin{pmatrix}2\\3\\2\end{pmatrix}\frac{1}{\sqrt{3}}\begin{pmatrix}1\\1\\1\end{pmatrix} = \frac{1}{\sqrt{3}}\begin{pmatrix}2\\3\\2\end{pmatrix}-\frac{7}{3}\frac{1}{\sqrt{3}}\begin{pmatrix}1\\1\\1\end{pmatrix}=\sqrt{\frac{3}{2}}\begin{pmatrix}-1/3\\2/3\\-1/3\end{pmatrix}
$$
At 0th order, the projection onto our Krylov subspace is

$$
\langle v_0|A|v_0\rangle=\frac{1}{\sqrt{3}}\begin{pmatrix}1&1&1\end{pmatrix} \begin{pmatrix}1&1&0\\1&1&1\\0&1&1\end{pmatrix} \frac{1}{\sqrt{3}}\begin{pmatrix}1\\1\\1\end{pmatrix} = \frac{7}{3}
$$
At 1st order, the projection onto this Krylov subspace is

$$
\langle V^1|A|V^1\rangle=\begin{pmatrix}\frac{1}{\sqrt{3}}&\frac{1}{\sqrt{3}}&\frac{1}{\sqrt{3}}\\-\sqrt{\frac{1}{6}}&\sqrt{\frac{2}{3}}&-\sqrt{\frac{1}{6}}\end{pmatrix} \begin{pmatrix}1&1&0\\1&1&1\\0&1&1\end{pmatrix} \begin{pmatrix}\frac{1}{\sqrt{3}}&-\sqrt{\frac{1}{6}}\\\frac{1}{\sqrt{3}}& \sqrt{\frac{2}{3}} \\  \frac{1}{\sqrt{3}}&-\sqrt{\frac{1}{6}}\end{pmatrix}
$$
This can be done by hand, but is most easily done using numpy:

```python

vstar = np.array([[1/np.sqrt(3),1/np.sqrt(3),1/np.sqrt(3)],[-1/np.sqrt(6),np.sqrt(2/3),-1/np.sqrt(6)]]
)
A = np.array([[1, 1, 0],
              [1, 1, 1],
              [0, 1, 1]])
v = np.array([[1/np.sqrt(3),-1/np.sqrt(6)],[1/np.sqrt(3),np.sqrt(2/3)],[1/np.sqrt(3),-1/np.sqrt(6)]])
proj = vstar@A@v
print(proj)
eigenvalues, eigenvectors = np.linalg.eig(proj)
print("The eigenvalues are ", eigenvalues)
print("The eigenvectors are ", eigenvectors)
```
outputs:
```python
[[ 2.33333333  0.47140452]
 [ 0.47140452 -0.33333333]]
The eigenvalues are  [ 2.41421356 -0.41421356]
The eigenvectors are  [[ 0.98559856 -0.16910198]
 [ 0.16910198  0.98559856]]
```
The minimum eigenvalue estimate is -0.414.

</AccordionItem>
</Accordion>

### 1.2 Types of Krylov methods

"Krylov subspace methods" can refer to any of several iterative techniques used to solve large linear systems and eigenvalue problems. What they all have in common is that they construct an approximate solution from a Krylov subspace

$$\mathcal{K}^r(A,|v\rangle ) = \text{span}\{|v\rangle, A|v\rangle, A^2|v\rangle, ..., A^{r-1}|v\rangle\},$$

where $|v\rangle$ is the initial guess (see Ref [\[5\]](#references)). They differ in how they choose the best approximation from this subspace, balancing factors such as convergence rate, memory usage, and overall computational cost. The focus of this lesson is to leverage quantum computing in the context of Krylov subspace methods; an exhaustive discussion of these methods is beyond its scope. The brief definitions below are for context only and include some references for investigating these methods further.

__The conjugate gradient (CG) method__: This method is used for solving symmetric, positive definite linear systems[\[6\]](#references). It minimizes the A-norm of the error at each iteration, making it particularly effective for systems arising from discretized elliptic PDEs[\[7\]](#references). We will use this approach in the next section to motivate why a Krylov subspace would be an effective subspace in which to probe for improved solutions to linear systems.

__The generalized minimal residual (GMRES) method__: This is designed for solving general nonsymmetric linear systems. It minimizes the residual norm over a Krylov space at each iteration, making it robust but potentially memory-intensive for large systems[\[7\]](#references).

__The minimal residual (MINRES) method__: This method is used for solving symmetric indefinite linear systems. It's similar to GMRES but takes advantage of the matrix symmetry to reduce computational cost[\[8\]](#references).

Other approaches of note include the __full orthogonalization method (FOM)__, which is closely related to Arnoldi's method for eigenvalue problems, the __bi-conjugate gradient (BiCG) method__, and the __induced dimension reduction (IDR) method__.

### 1.3 Why the Krylov subspace method works

Here we will motivate that the Krylov subspace method should be an efficient way to approximate matrix eigenvalues via iterative refinement of eigenvector approximations, through the lens of steepest descent. We will argue that given an initial guess of a ground state, the space of successive corrections to that initial guess that yields the fastest convergence is a Krylov subspace. We stop short of a rigorous proof of convergence behavior.

Assume our matrix of interest $A$ is symmetric and positive definite. This makes our argument most relevant to the CG method above. We make no assumptions about sparsity here; nor are we claiming that $A$ must be a Hermitian (which it needs to be if it is a Hamiltonian).

We typically wish to solve a problem of the form
$$
A|x\rangle=|b\rangle.
$$
One might imagine that $|b\rangle=c|x\rangle$ where $c$ is some constant, as in an eigenvalue problem. But our problem statement remains more general for now.

We start with a vector $|x_0\rangle$ that is an approximate solution. Although there are parallels between this guess $|x_0\rangle$ and $|v_0\rangle$ in Section 1.1, we are not leveraging these here.  Our guess $|x_0\rangle$ has error, which we call $|e_0\rangle$:
$$
|e_0\rangle:=|x\rangle−|x_0\rangle.
$$
We also define the residual $R_0$:
$$
|R_0\rangle=|b\rangle−A|x_0\rangle.
$$
Here we use capital $R$ to distinguish the residual from the dimension of our Krylov subspace $r$.

We now want to make a correction step of the form
$$
|x_1\rangle=|x_0\rangle+|p_0\rangle,
$$
which we hope improves our approximation. Here $|p_0\rangle$ is some vector yet to be determined. Let $|e_1\rangle$ be the error after the correction is made. Then
$$
|e_1\rangle=|x\rangle−|x_1\rangle=|x\rangle−(|x_0\rangle+|p_0\rangle)=|e_0\rangle−|p_0\rangle.
$$

We are interested in how our error behaves when transformed by our matrix. So let us calculate the $A$-norm of the error. That is
$$
\begin{aligned}
∥|e_0\rangle−|p_0\rangle∥_A^2&=\left(\langle e_0|A−\langle p_0|A\right)\left(|e_0\rangle−|p_0\rangle\right)\\
 & = \langle e_0|A|e_0 \rangle − \langle e_0|A|p_0\rangle − \langle p_0|A|e_0\rangle+\langle p_0|A|p_0\rangle\\
 & = \langle e_0|A|e_0\rangle−2\langle e_0|A|p_0\rangle+\langle p_0|A|p_0\rangle\\
 & = d−2\langle R_0|p_0\rangle +\langle p_0|A|p_0\rangle,
 \end{aligned}
$$
where we have used the symmetry of $A$ and also that $A |e_0\rangle = |R_0\rangle$. Here $d$ is some constant independent of $|p_0\rangle$. As mentioned in Section 1.2, the $A$-norm of the error is not the only quantity we might choose to minimize, but it is a good one. We want to see how this quantity varies with our choice of correction vectors $|p_0\rangle$. So we define the function $f$ by setting
$$
f(|p_0\rangle)=\langle p_0|A|p_0\rangle−2\langle R_0|p_0\rangle+d.
$$
$f$ is just the error $|e_1\rangle$ as a function of the correction $|p_0\rangle$ measured in the $A$-norm. Hence, we want to choose $|p_0\rangle$ such that $f(|p_0\rangle)$ is as small as possible. For this purpose, we compute the gradient of $f$. Using the symmetry of $A$ we have
$$
\nabla f(|p_0\rangle) = 2(A|p_0\rangle−|R_0\rangle).
$$
The gradient points in the direction of steepest ascent, meaning its opposite gives us the direction in which the function decreases the most: the direction of __steepest descent__. At our initial guess $|x_0\rangle$, where $|p_0\rangle=0$, we have that
$\nabla f(0) = -2|R_0\rangle$.
Thus, the function $f$ decreases the most in the direction of the residual $|R_0\rangle$. So our initial choice would benefit most by the addition of the vector $|p_0\rangle=\alpha_0 |R_0\rangle$ for some scalar $\alpha_0$.

In the next step, we choose, again, a vector $|p_1\rangle$ and add its value to the current approximation. Using the same argument as before we choose $|p_1\rangle = \alpha_1 |R_1\rangle$ for some scalar $\alpha_1$. We continue in this manner, such that the $k^\text{th}$ iteration of our vector is
$$
|x_{k+1}\rangle=|x_0\rangle+\alpha_0 |R_0\rangle+\alpha_1 |R_1\rangle+⋯+\alpha_k |R_k\rangle.
$$
Equivalently, we want to build up the space from which we choose our improved estimates by adding $|R_0\rangle$, $|R_1\rangle$, and so on, in order. The $k^\text{th}$ estimated vector lies in
$$
|x_{k+1}\rangle\in |x_0\rangle+\text{span}\{|R_0\rangle,|R_1\rangle,…,|R_k\rangle \}.
$$
Now, using the relation that
$$
|R_{k+1}\rangle=|b\rangle−A |x_{k+1}\rangle=|b\rangle−A(|x_k\rangle+\alpha_k |R_k\rangle)=|R_k\rangle−\alpha_k A |R_k\rangle,
$$
we see that
$$
\text{span} \{|R_0\rangle,|R_1\rangle,…,|R_k\rangle \}=\text{span} \{|R_0\rangle,A|R_0\rangle,…,A^{k}|R_0\rangle \}.
$$
That is, the space we build up that most efficiently approximates the correct solution $|x\rangle$ is exactly the space built up by successive operation of the matrix $A$ on $|R_0\rangle$. A Krylov subspace _is_ the space spanned by the vectors of successive directions of steepest descent.

Finally we reiterate that we have made no numerical claims about the scaling of this approach, nor have we discussed the comparative benefit for sparse matrices. This is only meant to motivate the use of Krylov subspace methods, and add some intuitive sense for them. We will now explore the behavior of these methods numerically.

#### Check your understanding

In the workflow above, we proposed minimizing the $A$-norm of the error. What other quantities might one consider minimizing in seeking the ground state and its eigenvalue?

<Accordion>
<AccordionItem title="Answer">

One could imagine using the residual vector instead of the $A$-norm of the error. There might be cases in which considering the error vector itself is useful.

</AccordionItem>
</Accordion>

## 2. Krylov methods in classical computation

In this section we implement Arnoldi iterations computationally so that we may leverage a Krylov subspace in solving eigenvalue problems. We will apply this first to a small-scale example, then examine how computation time scales as the size of the matrix of interest increases. A key idea here will be that the generation of the vectors spanning the Krylov space will be a large contributor to total computing time required. The memory required will vary between specific Krylov methods. But memory constraints can limit the use of traditional Krylov methods.

### 2.1 Simple small-scale example

In the process of creating a Krylov subspace, we will need to orthonormalize the vectors in our subspace. Let us define a function that takes an established vector from our subspace `vknown` (not assumed to be normalized) and a candidate vector to add to our subspace `vnext` and make `vnext` orthogonal to `vknown` and normalized. Let us further define a function that steps through this process for all established vectors in our Krylov subspace to ensure a fully orthonormal set.

Now let us define a function that builds an iteratively larger and larger Krylov subspace, until the space of Krylov vectors spans the full space of the original matrix. This will enable us to see how well the eigenvalues obtained using our Krylov subspace method match the exact values, as a function of Krylov subspace dimension. Importantly, our function `krylov_full_build` returns the Krylov vectors, the projected Hamiltonians, the eigenvalues, and the time required.

We will test this on a matrix that is still quite small, but larger than we might want to do by hand.

We can check our functions by ensuring that in the last step (when the Krylov space is the full vector space of the original matrix) the eigenvalues from the Krylov method exactly match those of the exact numerical diagonalization:

That was successful. Of course, what really matters is how good our approximation is as a function of the dimension of our Krylov subspace dimension. Because we are often concerned with finding ground states and other minimum eigenvalues (and for other more algebraic reasons explained below), let's look at our estimate of the lowest eigenvalue as a function of Krylov subspace dimension. That is

We see that the minimum eigenvalue is reached fairly accurately once the Krylov subspace has grown to $\mathcal{K}^2$, and is perfect by $\mathcal{K}^3$.

### 2.2 Time scaling with matrix dimension

Let us convince ourselves that the Krylov method can be advantageous over exact numerical eigensolvers in the following way:
* Construct random matrices (not sparse, not the ideal application for KQD)
* Determine eigenvalues using two methods: directly using NumPy and using a Krylov subspace.
* We choose a cutoff for how precise our eigenvalues must be, before we accept the Krylov estimates.
* Compare the wall time required to solve in these two ways.

__Caveats:__ As we will discuss in detail below, Krylov quantum diagonalization is best applied to operators whose matrix representations are sparse and/or can be written using a small number of groups of commuting Pauli operators. The random matrices we are using here do not fit that description. These are only useful in probing the scale at which classical Krylov methods might be useful.
Secondly, in using the Krylov method we will calculate eigenvalues using many different-sized Krylov subspaces. We will report the time required for the minimum-dimension Krylov subspace that achieves our required accuracy for the ground state eigenvalue. Again, this is a bit different from solving a problem that is intractable for exact eigensolvers, since we are using the exact solution to assess the dimension needed.

We begin by generating our set of random matrices.

We now diagonalize each matrix directly, using numpy. We calculate the time required for diagonalization for later comparison.

Note that in the image above, the anomalously high time around a dimension of 125 may be due to the random nature of the matrices or due to implementation on the classical processor used, but it is not reproducible. Re-running the code will yield a different profile with different anomalous peaks.

Now for each matrix we will build up a Krylov subspace and calculate eigenvalues in steps. At each step, we will check to see if the lowest eigenvalue has been obtained to within our specified absolute error. The subspace that first gives us eigenvalues within our specified error is the subspace for which we will record computation times. Executing this cell may take several minutes, depending on processor speed. Feel free to skip evaluation or reduce the maximum dimension of matrices diagonalized. Looking at the pre-calculated results is sufficient.

Let us plot the times we have obtained for these two methods for comparison:

These are the actual times required, but for the purposes of discussion, let us smooth these curves by averaging over a few adjacent points / matrix dimensions. This is done below:

Note that the time required for the building of a Krylov subspace initially exceeds the time required for numpy's full diagonalization. But as the size of the matrix grows, the Krylov method becomes advantageous. This is true even if we lower our acceptable error, but the advantage sets in at a larger matrix size. This is worth picking apart.

The time complexity of numerical diagonalization is $O(n^3)$ (with some variation among algorithms). The time complexity of generating an orthonormal basis of $n$ vectors is also $O(n^3)$. So the advantage of the Krylov method is __not__ related to the use of $\it{some}$ orthonormal basis, but to the use of a particular orthonormal basis that effectively picks out the eigenvalues of interest. We have already seen this from the sketch of a proof in the first section of this lesson, and this is critical for the convergence guarantees in Krylov methods.

Let us review our progress so far:
* For very large matrices, the Krylov subspace method may yield approximate eigenvalues within required tolerances faster than traditional diagonalization algorithms.
* For such very large matrices, the generation of a Krylov subspace is the most time-consuming part of the Krylov subspace method.
* Thus an efficient way of generating a Krylov subspace would be highly valuable.
This is finally where quantum computer comes into the picture.

#### Check your understanding

Refer to the smoothed plot of diagonalization times versus matrix dimension above.

(a) At approximately what matrix dimension did the Krylov method become faster, according to this plot?

(b) What aspects of the calculation could change that dimension at which the Krylov method becomes faster?

<Accordion>
<AccordionItem title="Answer">

(a) Answers may vary if you re-run the calculation, but the Krylov method becomes faster at approximately dimension 80-85.

(b) There are many possible answers. Some important factors are the precision we require and the sparsity of the matrices being diagonalized.

</AccordionItem>
</Accordion>

## 3. Krylov via time evolution

Everything that we have described so far can be done classically. So how and when would we use a quantum computer? For very large matrices, the Krylov method can require long computing times and large amounts of memory. The time required for matrix operation of $H$ on $|v\rangle$ scales like $O(N^2)$ in the worst case. Even multiplying sparse matrices on a vector (the typical case for classical Krylov-type solvers) has a time complexity scaling like $O(N)$. This is done for every vector we want in our subspace. The subspace dimension $r$ is usually not a significant fraction of $N$, and often scales like $\log(N)$. So generating all vectors scales like $O(N^2 \log(N))$ in the worst case. Although there are other steps, like orthogonalization, this is the dominant scaling to keep in mind.

Quantum computing allows us to change what attributes of the problem determine the scaling of the time and resources required. Instead of dependence on matrix size $N$ across the board, we will see things like number of shots and number of non-commuting Pauli terms that make up the Hamiltonian. Let’s explore how this works.

### 3.1 Time evolution

Recall that the operator that time-evolves a quantum state is $e^{-iHt/\hbar}$ (and it is very common, especially in quantum computing to drop the $\hbar$ from the notation). One way of understanding and even realizing such an exponential function of an operator is to look at its Taylor series expansion. Note that this operation acting on some initial vector $|v\rangle$ yields a sum of terms with increasing powers of $H$ applied to the initial state. It looks like we can just make our Krylov subspace by time-evolving our initial guess state!

$$
\begin{aligned}
e^{-iHt/\hbar}→e^{-iHt}&≈1-iHt-\frac{(H^2 t^2)}{2}+⋯\\
e^{-iHt} |v\rangle &≈ |v\rangle-iHt|v\rangle-\frac{(H^2 t^2)}{2}|v\rangle+⋯
\end{aligned}
$$

The caveat is in realizing the time evolution on a real quantum computer. Many of the terms in the Hamiltonian will not commute with each other. So while some simple exponential operators like $e^{-iZ}$ correspond to simple circuits, general Hamiltonians do not. And since they contain non-commuting terms, we can’t simply decompose the exponential into a product of simple ones, the way we can with numbers.

$$
e^{-iHt}=e^{-i(H_1+H_2+⋯+H_n)t}\neq e^{-iH_1 t} e^{-iH_2 t}... e^{-iH_n t}
$$

So this is not trivial, but this is a well-studied process in quantum computing. We carry out time-evolution on quantum computers using a process called trotterization, which in itself is a rich subject[\[10\]](#references). But at a very high level, by breaking the time evolution into very small steps, say $m$ steps of size $dt$, we limit the effects of the non-commutativity of terms.

$$
e^{-iHt}=e^{-i(H_1+H_2+⋯+H_n )t} = (e^{-i(H_1+H_2+⋯+H_n )t/m} )^m
≈(e^{-iH_1 dt} e^{-iH_2 dt} …e^{-iH_n dt} )^m
$$
where $dt = t/m$.

Let us call a Krylov subspace of order r that we generated in the classical context using powers of H directly a “power Krylov subspace”.

$$
\mathcal{K}_P^r (H,|v\rangle)=\text{span}\{|v\rangle,H|v\rangle,H^2 |v\rangle… H^{r-1}  |v\rangle\}
$$

Now we generate a similar space using the unitary time-evolution operator $U \equiv e^{-iHt}$; we'll refer to this as the “unitary Krylov space” $\mathcal{K}_U^r$. The power Krylov subspace $\mathcal{K}_P^r$  that we use classically cannot be generated directly on a quantum computer as $H$ is not a unitary operator. Using the unitary Krylov subspace can be shown to give similar convergence guarantees as the power Krylov subspace, namely, the ground state error converges efficiently as long as the initial state $|v\rangle$ has overlap with the true ground state that is not exponentially vanishing, and as long as there is a sufficient gap between eigenvalues. See Ref [\[1\]](#references) for a more precise discussion of convergence.

Here, powers of $U$ become different time steps (the $k^\text{th}$ power of $U$ is stepping forward by a time $k \times dt$).  We can label the element of the subspace that is time-evolved for total time $k dt$ as $|\psi_k\rangle$.

$$
\begin{aligned}
U&=e^{-iHdt}\\
U^k&=e^{-iH(kdt)}\\
\mathcal{K}_U^r&=\text{span}\{|\psi\rangle,U|\psi\rangle,U^2 |\psi\rangle… U^{r-1}  |\psi\rangle\}
\end{aligned}
$$

We can project our Hamiltonian H on to the unitary Krylov subspace, $\mathcal{K}_U^r$. In other words, we calculate each matrix element of $H$ in the $\mathcal{K}_U^r$  basis. We'll refer to this projected matrix as $\tilde{H}$.

### 3.2 How to implement on a quantum computer

The matrix elements of $\tilde{H}$ are given by the expectation values $\langle \psi_m |H| \psi_n\rangle$, which can be estimated using the quantum computer. Keep in mind that $H$ can be written as a sum of Pauli operators on different qubits, and that not all the Pauli operators can be measured simultaneously. We can sort the Pauli terms into groups of commuting terms, and measure all those at once. But we may need many such groups to cover all the terms. So the number of distinct commuting groups into which the terms can be partitioned, $N_\text{GCP}$ becomes important.

$$
H=\sum_{\alpha=1}^{N_\text{GCP}} c_\alpha P_\alpha
$$
Here $P_\alpha$ is a Pauli string of the form $P_\alpha \sim IZIXII...YZXIX$ or a set of such Pauli strings that commute with one another. Given that we can write $H$ as such a sum of measureable operators, the following expressions for matrix elements of $\tilde{H}$ can be realized using the IBM Quantum&reg; primitive Estimator.

$$
\begin{aligned}
\tilde{H}_{mn}&=\langle \psi_m |H| \psi_n\rangle\\
&=\langle \psi e^{iHt_m} |H| \psi e^{-iHt_n}\rangle\\
&=\langle \psi e^{iHmdt} |H|\psi e^{-iHndt}\rangle
\end{aligned}
$$

Where $\vert \psi_n \rangle = e^{-i H t_n} \vert \psi \rangle$ are the vectors of the unitary Krylov space and $t_n = n dt$ are the multiples of the time step $dt$ chosen. On a quantum computer, the calculation of each matrix elements can be done with any algorithm which allows us to obtain overlap between quantum states. In this lesson we'll focus on the Hadamard test. Given that the $\mathcal{K}_U$ has dimension $r$, the Hamiltonian projected into the subspace will have dimensions $r \times r$. With $r$ small enough (generally $r<<100$ is sufficient to obtain convergence of estimates of eigenvalues) we can then easily diagonalize the projected Hamiltonian $\tilde{H}$, classically. However, we cannot directly diagonalize $\tilde{H}$ because of the non-orthogonality of the Krylov space vectors. We'll have to measure their overlaps and construct a matrix $\tilde{S}$

$$
\tilde{S}_{mn} = \langle \psi_m \vert \psi_n \rangle
$$

This allows us to solve the eigenvalue problem in a non-orthogonal space (also called generalized eigenvalue problem)

$$
\tilde{H} \ \vec{c} = E \ \tilde{S} \ \vec{c}
$$

One can then obtain estimates of the eigenvalues and eigenstates of $H$ by looking at the solutions of this generalized eigenvalue problem. For example, the estimate of the ground state energy is obtained by taking the smallest eigenvalue $E$ and the ground state from the corresponding eigenvector $\vec{c}$. The coefficients in $\vec{c}$ determines the contribution of the different vectors that span $\mathcal{K}_U$.

#### Generalized eigenvalue problem

Why can we not simply diagonalize $\tilde{H}$? Since $\tilde{S}$ contains the information about the geometry of the Krylov basis (which is nonorthogonal in all but very special cases), $\tilde{H}$ on its own does not describe a projection of the full Hamiltonian, so its eigenvalues have no particular relation to those of the full Hamiltonian -- they could be any random values. Solving the generalized eigenvalue problem is required to obtain the approximate eigenvalues and eigenvectors corresponding to the projection of the full Hamiltonian into the Krylov space..

The Figure shows a circuit representation of the modified Hadamard test, a method that is used to compute the overlap between different quantum states. For each matrix element $\tilde{H}_{i,j}$, a Hadamard test between the state $\vert \psi_i \rangle$, $\vert \psi_j \rangle$ is carried out. This is highlighted in the figure by the color scheme for the matrix elements and the corresponding $\text{Prep} \; \psi_i$, $\text{Prep} \; \psi_j$ operations. Thus, a set of Hadamard tests for all the possible combinations of Krylov space vectors is required to compute all the matrix elements of the projected Hamiltonian $\tilde{H}$. The top wire in the Hadamard test circuit is an ancilla qubit which is measured either in the X or Y basis, its expectation value determines the value of the overlap between the states. The bottom wire represents all the qubits of the system Hamiltonian. The $\text{Prep} \; \psi_i$ operation prepares the system qubit in the state $\vert \psi_i \rangle$ controlled by the state of the ancilla qubit (similarly for $\text{Prep} \; \psi_j$) and the operation $P$ represents Pauli decomposition of the system Hamiltonian $H = \sum_i P_i$. The implementation of this is on a quantum computer is shown in greater detail below.

## 4. Krylov quantum diagonalization on a quantum computer

We will now implement Krylov quantum diagonalization on a real quantum computer. Let's start by importing some useful packages.

We define the function below to solve the generalized eigenvalue problem we just explained above.

At least in initial benchmarking, it is useful to know an exact classical solution to check convergence behavior. The function below calculates the ground state energy of a Hamiltonian, using the Hamiltonian and the number of qubits as arguments.

### 4.1 Step 1: Map problem to quantum circuits and operators

Now we will define a Hamiltonian. This is distinct from the function above in that the function above takes a Hamiltonian as an argument and returns only the ground state, and it does so classically. This Hamiltonian we define here determines the energy levels of all energy eigenstates, and this Hamiltonian can be constructed using Pauli operators and implemented on a quantum computer.

We choose a Hamiltonian corresponding to a chain of spins which can have any orientation in space, called a "Heisenberg chain". We assume that the $i^\text{th}$ spin can be influenced by its nearest neighbors (the $(i-1)^\text{th}$ and $(i+1)^\text{th}$ spins) but not by more distant neighbors. We also allow for the possibility that the interaction between spins is different when the spins point along different axes. This asymmetry sometimes arises, for example, due to the structure of the crystal lattice into which spins are embedded.

The code below restricts the Hamiltonian to single particle states, and uses the spectral norm to set a good size for our time step $dt$. We heuristically choose a value for the time-step `dt` (based on upper bounds on the Hamiltonian norm). Ref [\[9\]](#references)  showed that a sufficiently small timestep is $\pi/\vert \vert H \vert \vert$, and that it is preferable up to a point to underestimate this value rather than overestimate, since overestimating can allow contributions from high-energy states to corrupt even the optimal state in the Krylov space. On the other hand, choosing $dt$ to be too small leads to worse conditioning of the Krylov subspace, since the Krylov basis vectors differ less from timestep to timestep.

We specify the number of Trotter steps to use in the time evolution. We also specify a maximum Krylov dimension of 4. This Krylov dimension is not large enough for realistic applications. But it is sufficient for this example. Furthermore, we will check for convergence at even smaller dimensions. We will explore methods in later lessons that allow us to scale and project our Hamiltonians onto larger subspaces.

#### State preparation

Pick a reference state $\vert \psi \rangle$ that has some overlap with the ground state. For this Hamiltonian, We use the a state with an excitation in the middle qubit $\vert 00..010...00 \rangle$ as our reference state.

#### Time evolution

We can realize the time-evolution operator generated by a given Hamiltonian: $U=e^{-iHt}$ via the [Lie-Trotter approximation](https://quantum.cloud.ibm.com/docs/api/qiskit/qiskit.synthesis.LieTrotter). For simplicity we use the built-in ```PauliEvolutionGate``` in the time-evolution circuit. The general syntax for this is this.

We will use a version of this below in the Hadamard test, but stepping forward for times $dt$.

#### Hadamard test

Recall that we wish to calculate the matrix elements of both $\tilde{H}$ and the Gram matrix $\tilde{S}$ using the Hadamard test. Let's review how this works in this context, focusing first on the construction of $\tilde{H}$. The overall process is depicted graphically below. The layers of colored state preparation blocks $\text{Prep}|\psi_i\rangle$ serve as a reminder that this process is carried out for all combinations of $|\psi_i\rangle$ and $|\psi_j\rangle$ in our subspace.

The states of the system at the steps indicated are:
$$
\begin{aligned}
    \text{Step 0:}\qquad|\Psi\rangle & = |0\rangle|0\rangle^N \\
    \text{Step 1:}\qquad|\Psi\rangle & = \frac{1}{\sqrt{2}}\Big(|0\rangle + |1\rangle \Big)|0\rangle^N \\
    \text{Step 2:}\qquad|\Psi\rangle & = \frac{1}{\sqrt{2}}\Big(|0\rangle|0\rangle^N+|1\rangle |\psi_i\rangle\Big)\\
    \text{Step 3:}\qquad|\Psi\rangle & = \frac{1}{\sqrt{2}}\Big(|0\rangle |0\rangle^N+|1\rangle P |\psi_i\rangle\Big) \\
    \text{Step 4:}\qquad|\Psi\rangle & = \frac{1}{\sqrt{2}}\Big(|0\rangle |\psi_j\rangle+|1\rangle P|\psi_i\rangle\Big)
\end{aligned}
$$

Here $P$ is a Pauli term in the decomposition of the Hamiltonian (note that it cannot be a linear combination of multiple commuting Pauli terms since that would not be unitary -- grouping is possible using a different construction we will show later) $\text{Prep} \; \psi_i$, $\text{Prep} \; \psi_j$ are controlled operations that prepare $|\psi_i\rangle$, $|\psi_j\rangle$ vectors of the unitary Krylov space, with $|\psi_k\rangle = e^{-i H k dt } \vert \psi \rangle = e^{-i H k dt } U_{\psi} \vert 0 \rangle^N$. Applying measurements of $X$ and $Y$ to this circuit calculates the real and imaginary parts, respectively, of the matrix elements we require.

Starting from Step 4 above, apply the Hadamard gate $H$ to the zeroth qubit.

$$
\begin{equation*}
   |\Psi\rangle \longrightarrow\quad\frac{1}{2}|0\rangle\Big( |\psi_j\rangle + P|\psi_i\rangle\Big) + \frac{1}{2}|1\rangle\Big(|\psi_j\rangle - P|\psi_i\rangle\Big)
\end{equation*}
$$

Then measure either $X$ or $Y$.

$$
\begin{equation*}
\begin{split}
    \Rightarrow\quad\langle X\rangle &= \frac{1}{4}\Bigg(\Big\|| \psi_j\rangle + P|\psi_i\rangle \Big\|^2-\Big\||\psi_j\rangle - P|\psi_i\rangle\Big\|^2\Bigg) \\
    &= \text{Re}\Big[\langle\psi_j| P|\psi_i\rangle\Big].
\end{split}
\end{equation*}
$$

From the identity $|a + b\|^2 = \langle a + b | a + b \rangle = \|a\|^2 + \|b\|^2 + 2\text{Re}\langle a | b \rangle$. Similarly, measuring $Y$ yields

$$
\begin{equation*}
    \langle Y\rangle = \text{Im}\Big[\langle\psi_j| P|\psi_i\rangle\Big].
\end{equation*}
$$

Adding these steps to the time-evolution we set up previously we write the following.

We warned already about the depth involved in Trotter circuits. Performing the Hadamard test in these conditions can yield an even deeper circuit, especially once we decompose to native gates. This will increase even more if we account for the topology of the device. So before using any time on the quantum computer, it is a good idea to check the 2-qubit depth of our circuit.

A circuit of this depth cannot return usable results on modern quantum computers. If we are to construct $\tilde{H}$ and $\tilde{S}$, we need a better way. This is the reason for the efficient Hadamard test introduced below.

### 4. 2 Step 2. Optimize circuits and operators for target hardware

#### Efficient Hadamard test

We can optimize the deep circuits for the Hadamard test that we have obtained by introducing some approximations and relying on some assumption about the model Hamiltonian. For example, consider the following circuit for the Hadamard test:

Assume we can classically calculate $E_0$, the eigenvalue of $|0\rangle^N$ under the Hamiltonian $H$.
This is satisfied when the Hamiltonian preserves the U(1) symmetry. Although this may seem like a strong assumption, there are many cases where it is safe to assume that there is a vacuum state (in this case it maps to the $|0\rangle^N$ state) which is unaffected by the action of the Hamiltonian. This is true for example for chemistry Hamiltonians that describe stable molecule (where the number of electrons is conserved).
Given that the gate $\text{Prep} \; \psi_0$, prepares the desired reference state $\ket{\psi_0} = \text{Prep} \; \psi_0 \ket{0} = e^{-i H 0 dt} U_{\psi_0} \ket{0}$, for example, to prepare the HF state for chemistry $\text{Prep} \; \psi_0$ would be a product of single-qubit NOTs, so controlled-$\text{Prep} \; \psi_0$ is just a product of CNOTs.
Then the circuit above implements the following state prior to measurement:

$$
\begin{aligned}
    \text{Step 0:}\qquad|\Psi\rangle & = \ket{0} \ket{0}^{N}\\
    \text{Step 1:}\qquad|\Psi\rangle & = \frac{1}{\sqrt{2}}\left(\ket{0}\ket{0}^N+ \ket{1} \ket{0}^N\right)\\
    \text{Step 2:}\qquad|\Psi\rangle & = \frac{1}{\sqrt{2}}\left(|0\rangle|0\rangle^N+|1\rangle|\psi_0\rangle\right)\\
    \text{Step 3:}\qquad|\Psi\rangle & = \frac{1}{\sqrt{2}}\left(e^{i\phi}\ket{0}\ket{0}^N+\ket{1} U\ket{\psi_0}\right)\\
    \text{Step 4:}\qquad|\Psi\rangle & = \frac{1}{\sqrt{2}}\left(e^{i\phi}\ket{0} \ket{\psi_0}+\ket{1} U\ket{\psi_0}\right)\\
    & = \frac{1}{2}\left(\ket{+}\left(e^{i\phi}\ket{\psi_0}+U\ket{\psi_0}\right)+\ket{-}\left(e^{i\phi}\ket{\psi_0}-U\ket{\psi_0}\right)\right)\\
    & = \frac{1}{2}\left(\ket{+i}\left(e^{i\phi}\ket{\psi_0}-iU\ket{\psi_0}\right)+\ket{-i}\left(e^{i\phi}\ket{\psi_0}+iU\ket{\psi_0}\right)\right)
\end{aligned}
$$

where we have used the classical simulable phase shift $ U\ket{0}^N = e^{i\phi}\ket{0}^N$ from step 2 to 3. Therefore the expectation values are

$$
\begin{aligned}
    \langle X\otimes P\rangle&=\frac{1}{4}
    \Big(
    \left(e^{-i\phi}\bra{\psi_0}+\bra{\psi_0}U^\dagger\right)P\left(e^{i\phi}\ket{\psi_0}+U\ket{\psi_0}\right)
    \\
    &\qquad-\left(e^{-i\phi}\bra{\psi_0}-\bra{\psi_0}U^\dagger\right)P\left(e^{i\phi}\ket{\psi_0}-U\ket{\psi_0}\right)
    \Big)\\
    &=\text{Re}\left[e^{-i\phi}\bra{\psi_0}PU\ket{\psi_0}\right],
\end{aligned}

$$

$$

\begin{aligned}
    \langle Y\otimes P\rangle&=\frac{1}{4}
    \Big(
    \left(e^{-i\phi}\bra{\psi_0}+i\bra{\psi_0}U^\dagger\right)P\left(e^{i\phi_0}\ket{\psi_0}-iU\ket{\psi_0}\right)
    \\
    &\qquad-\left(e^{-i\phi}\bra{\psi_0}-i\bra{\psi_0}U^\dagger\right)P\left(e^{i\phi}\ket{\psi_0}+iU\ket{\psi_0}\right)
    \Big)\\
    &=\text{Im}\left[e^{-i\phi}\bra{\psi_0}PU\ket{\psi_0}\right].
\end{aligned}

$$

Using these assumptions we were able to write the expectation values of operators of interest with fewer controlled operations. In fact, we only need to implement the controlled state preparation $\text{Prep} \; \psi_0$ and not controlled time evolutions. Reframing our calculation as above will allow us to greatly reduce the depth of the resulting circuits.

Note that as a bonus, since the Pauli operator now appears as a measurement at the end of the circuit rather than as a controlled gate in the middle, it can be measured alongside other commuting Pauli operators as in the decomposition $$H=\sum_{\alpha = 1}^{N_\text{GCP}}c_\alpha P_\alpha $$ given above.

### Decompose time-evolution operator with Trotter decomposition

Instead of implementing the time-evolution operator exactly we can use the Trotter decomposition to implement an approximation of it. Repeating several times a certain order Trotter decomposition gives us further reduction of the error introduced from the approximation. In the following, we directly build the Trotter implementation in the most efficient way for the interaction graph of the Hamiltonian we are considering (nearest neighbor interactions only). In practice we insert Pauli rotations $R_{xx}$, $R_{yy}$, $R_{zz}$ with coupling strengths $J_x$, $J_y$, and $J_z$ and a parametrized angle $t$, which correspond to the approximate implementation of $e^{-i (J_x XX + J_y YY + J_z ZZ) t}$. Given the difference in definition of the Pauli rotations and the time-evolution that we are trying to implement, we'll have to use the parameter $2*dt$ to achieve a time-evolution of $dt$. Furthermore, we reverse the order of the operations for odd number of repetitions of the Trotter steps, which is functionally equivalent but allows for synthesizing adjacent operations in a single $SU(2)$ unitary. This gives a much shallower circuit than what is obtained using the generic `PauliEvolutionGate()` functionality.

We prepare an initial state again for this efficient Hadamard test.

#### Template circuits for calculating matrix elements of $\tilde{S}$ and $\tilde{H}$ via Hadamard test

The only difference between the circuits used in the Hadamard test will be the phase in the time-evolution operator and the observables measured. Therefore we can prepare a template circuit which represent the generic circuit for the Hadamard test, with placeholders for the gates that depend on the time-evolution operator.

This depth is substantially reduced compared to the original Hadamard test. This depth is manageable on modern quantum computers, though it is still quite high. We will need to use state-of-the-art error mitigation to obtain useful results.

Select a backend on which to run our quantum Krylov calculation, so that we can transpile our circuit for running on that quantum computer.

We now transpile our circuits and operators.

After optimization, our transpiled two-qubit depth is further reduced.

### 4.3 Step 3. Execute using an IBM Quantum primitive

We now create PUBs for execution with Estimator.

Circuits for $t=0$ are classically calculable. We carry this out before moving on to the $t\neq 0$ case using a quantum computer.

Although we were able to reduce our gate depth by orders of magnitude using the efficient Hadamard test, the depth is still sufficient to require state-of-the-art error mitigation. Below, we specify attributes of the mitigation being used. All of the methods used are important, but it is worth called out [probabilistic error amplification (PEA)](https://quantum.cloud.ibm.com/docs/guides/error-mitigation-and-suppression-techniques#zne-with-probabilistic-error-amplification-pea) specifically. This powerful technique comes with a great deal of quantum overhead. The calculation done here can take 20 minutes or more to run on a real quantum computer. You may wish to play with the parameters below to increase or decrease precision and consequentially overhead. The default settings below yield high-fidelity results.

Finally, we execute the circuits for $\tilde{S}$ and $\tilde{H}$ with Estimator.

### 4.4 Step 4. Post-process and analyze results

What we have obtained from the quantum computer are the individual matrix elements of $\tilde{S}$ and the commuting Pauli groups that make up the matrix elements of $\tilde{H}$. These terms must be combined to recover our matrices, so that we can solve the generalized eigenvalue problem.

#### Calculate Effective Hamiltonian and Overlap matrices

First calculate the phase accumulated by the $\vert 0 \rangle$ state during the uncontrolled time evolution

Once we have the results of the circuit executions we can post-process the data to calculate the matrix elements of $S$

And the matrix elements of $\tilde{H}$

Finally, we can solve the generalized eigenvalue problem for $\tilde{H}$:

$$\tilde{H} \vec{c} = c S \vec{c}$$

and get an estimate of the ground state energy $c_{min}$

For a single-particle sector, we can efficiently calculate the ground state of this sector of the Hamiltonian classically

## 5. Discussion and extension

To recap, we start with a reference state, then evolve it for different periods of time to generate the unitary Krylov subspace. We project our Hamiltonian onto that subspace. We also estimate the overlaps of the subspace vectors. Finally we solve the lower-dimensional, generalized eigenvalue problem classically.

Let’s compare what determines computational costs of using the Krylov technique classically and quantum mechanically. There are not perfect analogs between classical and quantum approaches for all steps. This table collects some scaling of different steps for consideration.

Recall that Hamiltonians generally have terms that cannot be simultaneously measured (because they do not commute with on another). We sort terms in the Hamiltonian into groups of commuting Pauli operators that can all be measured simultaneously, and we may require many such groups to account for all the terms that do not commute with one another. To build up $\tilde{H}$ on a quantum computer requires separate measurements for each group of commuting Pauli strings in the Hamiltonian, and each of those requires many shots. We must do this for $r^2$ different matrix elements, corresponding to $r^2$ combinations of different time evolution factors. There are sometimes ways to reduce this, but in this rough treatment, the time required for this scales like $N_\text{shots}\times N_\text{GCP} \times r^2$. The elements of $S$ must be estimated, which scales like $O(N_\text{shots}\times r^2)$. Finally, solving the generalized eigenvalue problem in the projected space, classically, takes $O(r^3)$.

We see that quantum Krylov diagonalization may be useful in cases where the number of commuting Pauli groups in the Hamiltonian is relatively small. These scaling dependencies suggest some applications where the Krylov method can be useful, and others where it likely will not be.
Some Hamiltonians have high complexity when mapped to qubits, involving many non-commuting Pauli strings that cannot easily be partitioned into a few commuting groups. This is often true of quantum chemistry problems, for example. This complexity presents two primary challenges for near-term quantum computers:

* The estimation of each element of $\tilde{H}$ becomes computationally expensive due to the large number of terms.
* The required Trotter circuits become prohibitively deep.

Both of the above points will be less problematic when quantum computers reach fault-tolerance, but they must be considered in the near term. Even systems with “simpler” mappings than those in quantum chemistry may experience the same impediments, if the Hamiltonians have too many non-commuting terms.
The Krylov method is most useful where the Hamiltonian can be partitioned into relatively few commuting Pauli groups, and where $H$ is easy to implement in trotter circuits. Both of these conditions are satisfied, for example, for many lattice models of interest in physics. KQD is especially useful if very little is known about the ground state. This stems from its inherent convergence guarantees and its applicability in scenarios where alternative methods are untenable due to insufficient ground state knowledge.

While KQD is a powerful tool, the protocol's time-consuming aspects, particularly the estimation of each element of the projected Hamiltonian and the overlap of Krylov states, represent opportunities for improvement. An alternative approach involves leveraging Krylov methods in conjunction with sampling-based methods, which are the subject of the next lesson.

## 6. Appendices

### Appendix I: Krylov subspace from real time-evolutions

The unitary Krylov space is defined as

$$
\mathcal{K}_U(H, |\psi\rangle) = \text{span}\left\{ |\psi\rangle,  e^{-iH\,dt} |\psi\rangle, \dots, e^{-irH\,dt} |\psi\rangle \right\}
$$

for some timestep $dt$ that we will determine later. Temporarily assume $r$ is even: then define $d=r/2$. Notice that when we project the Hamiltonian into the Krylov space above, it is indistinguishable from the Krylov space

$$
\mathcal{K}_U(H, |\psi\rangle) = \text{span}\left\{ e^{i\,d\,H\,dt}|\psi\rangle,  e^{i(d-1)H\,dt} |\psi\rangle, \dots, e^{-i(d-1)H\,dt} |\psi\rangle, e^{-i\,d\,H\,dt} |\psi\rangle \right\},
$$

that is, where all the time-evolutions are shifted backward by $d$ timesteps.
The reason it is indistinguishable is because the matrix elements

$$
\tilde{H}_{j,k} = \langle\psi|e^{i\,j\,H\,dt}He^{-i\,k\,H\,dt}|\psi\rangle=\langle\psi|He^{i(j-k)H\,dt}|\psi\rangle
$$

are invariant under overall shifts of the evolution time, since the time-evolutions commute with the Hamiltonian. For odd $r$, we can use the analysis for $r-1$.

We want to show that somewhere in this Krylov space, there is guaranteed to be a low-energy state. We do so by way of the following result, which is derived from Theorem 3.1 in [\[3\]](#references):

**Claim 1:** there exists a function $f$ such that for energies $E$ in the spectral range of the Hamiltonian (that is, between the ground state energy and the maximum energy)...

1. $f(E_0)=1$
2. $|f(E)|\le2\left(1 + \delta\right)^{-d}$ for all values of $E$ that lie $\ge\delta$ away from $E_0$, that is, it is exponentially suppressed
3. $f(E)$ is a linear combination of $e^{ijE\,dt}$ for $j=-d,-d+1,...,d-1,d$

We give a proof below, but that can be safely skipped unless one wants to understand the full, rigorous argument. For now we focus on the implications of the above claim. By property 3 above, we can see that the shifted Krylov space above contains the state $f(H)|\psi\rangle$. This is our low-energy state. To see why, write $|\psi\rangle$ in the energy eigenbasis:

$$
|\psi\rangle = \sum_{k=0}^{N}\gamma_k|E_k\rangle,
$$

where $|E_k\rangle$ is the kth energy eigenstate and $\gamma_k$ is its amplitude in the initial state $|\psi\rangle$. Expressed in terms of this, $f(H)|\psi\rangle$ is given by

$$
f(H)|\psi\rangle = \sum_{k=0}^{N}\gamma_kf(E_k)|E_k\rangle,
$$

using the fact that we can replace $H$ by $E_k$ when it acts on the eigenstate $|E_k\rangle$. The energy error of this state is therefore

$$
\text{energy error} = \frac{\langle\psi|f(H)(H-E_0)f(H)|\psi\rangle}{\langle\psi|f(H)^2|\psi\rangle}
$$

$$
= \frac{\sum_{k=0}^{N}|\gamma_k|^2f(E_k)^2(E_k-E_0)}{\sum_{k=0}^{N}|\gamma_k|^2f(E_k)^2}.
$$

To turn this into an upper bound that is easier to understand, we first separate the sum in the numerator into terms with $E_k-E_0\le\delta$ and terms with $E_k-E_0>\delta$:

$$
\text{energy error} = \frac{\sum_{E_k\le E_0+\delta}|\gamma_k|^2f(E_k)^2(E_k-E_0)}{\sum_{k=0}^{N}|\gamma_k|^2f(E_k)^2} + \frac{\sum_{E_k> E_0+\delta}|\gamma_k|^2f(E_k)^2(E_k-E_0)}{\sum_{k=0}^{N}|\gamma_k|^2f(E_k)^2}.
$$

We can upper bound the first term by $\delta$,

$$
\frac{\sum_{E_k\le E_0+\delta}|\gamma_k|^2f(E_k)^2(E_k-E_0)}{\sum_{k=0}^{N}|\gamma_k|^2f(E_k)^2} < \frac{\delta\sum_{E_k\le E_0+\delta}|\gamma_k|^2f(E_k)^2}{\sum_{k=0}^{N}|\gamma_k|^2f(E_k)^2} \le \delta,
$$

where the first step follows because $E_k-E_0\le\delta$ for every $E_k$ in the sum, and the second step follows because the sum in the numerator is a subset of the sum in the denominator. For the second term, first we lower bound the denominator by $|\gamma_0|^2$, since $f(E_0)^2=1$: adding everything back together, this gives

$$
\text{energy error} \le \delta + \frac{1}{|\gamma_0|^2}\sum_{E_k>E_0+\delta}|\gamma_k|^2f(E_k)^2(E_k-E_0).
$$

To simplify what is left, notice that for all these $E_k$, by the definition of $f$ we know that $f(E_k)^2 \le 4\left(1 + \delta\right)^{-2d}$. Additionally upper bounding $E_k-E_0<2\|H\|$ and upper bounding $\sum_{E_k>E_0+\delta}|\gamma_k|^2<1$ gives

$$
\text{energy error} \le \delta + \frac{8}{|\gamma_0|^2}\|H\|\left(1 + \delta\right)^{-2d}.
$$

This holds for any $\delta>0$, so if we set $\delta$ equal to our goal error, then the error bound above converges towards that exponentially with the Krylov dimension $2d=r$. Also note that if $\delta<E_1-E_0$ then the $\delta$ term actually goes away entirely in the above bound.

To complete the argument, we first note that the above is just the energy error of the particular state $f(H)|\psi\rangle$, rather than the energy error of the lowest energy state in the Krylov space. However, by the (Rayleigh-Ritz) variational principle, the energy error of the lowest energy state in the Krylov space is upper bounded by the energy error of any state in the Krylov space, so the above is also an upper bound on the energy error of the lowest energy state, that is, the output of the Krylov quantum diagonalization algorithm.

A similar analysis as the above can be carried out that additionally accounts for noise and the thresholding procedure discussed in the notebook. See [\[2\]](#references) and [\[4\]](#references) for this analysis.

### Appendix II: proof of Claim 1

The following is mostly derived from [\[3\]](#references), Theorem 3.1: let $0 < a < b$ and let $\Pi^*_d$ be the space of residual polynomials (polynomials whose value at 0 is 1) of degree at most $d$. The solution to

$$
\beta(a, b, d) = \min_{p \in \Pi^*_d} \max_{x \in [a, b]} |p(x)| \quad
$$

is

$$
p^*(x) = \frac{T_d\left(\frac{b + a - 2x}{b - a}\right)}{T_d\left(\frac{b + a}{b - a}\right)}, \quad
$$

and the corresponding minimal value is

$$
\beta(a, b, d) = T_d^{-1}\left(\frac{b + a}{b - a}\right).
$$

We want to convert this into a function that can be expressed naturally in terms of complex exponentials, because those are the real time-evolutions that generate the quantum Krylov space.
To do so, it is convenient to introduce the following transformation of energies within the spectral range of the Hamiltonian to numbers in the range $[0,1]$: define

$$
g(E) = \frac{1-\cos\big((E-E_0)dt\big)}{2},
$$

where $dt$ is a timestep such that $-\pi < E_0dt < E_\text{max}dt < \pi$.
Notice that $g(E_0)=0$ and $g(E)$ grows as $E$ moves away from $E_0$.

Now using the polynomial $p^*(x)$ with the parameters a, b, d set to $a = g(E_0 + \delta)$, $b = 1$, and d = int(r/2), we define the function:

$$
f(E) = p^* \left( g(E) \right) = \frac{T_d\left(1 + 2\frac{\cos\big((E-E_0)dt\big) - \cos\big(\delta\,dt\big)}{1 +\cos\big(\delta\,dt\big)}\right)}{T_d\left(1 + 2\frac{1-\cos\big(\delta\,dt\big)}{1 + \cos\big(\delta\,dt\big)}\right)}
$$

where $E_0$ is the ground state energy. We can see by inserting $\cos(x)=\frac{e^{ix}+e^{-ix}}{2}$ that $f(E)$ is a trigonometric polynomial of degree $d$, that is, a linear combination of $e^{ijE\,dt}$ for $j=-d,-d+1,...,d-1,d$. Furthermore, from the definition of $p^*(x)$ above we have that $f(E_0)=p(0)=1$ and for any $E$ in the spectral range such that $\vert E-E_0 \vert > \delta$ we have

$$
|f(E)| \le \beta(a, b, d) = T_d^{-1}\left(1 + 2\frac{1-\cos\big(\delta\,dt\big)}{1 + \cos\big(\delta\,dt\big)}\right)
$$

$$
\leq 2\left(1 + \delta\right)^{-d} = 2\left(1 + \delta\right)^{-\lfloor k/2\rfloor}.
$$

## References:

[1] https://arxiv.org/abs/2407.14431

[2] https://arxiv.org/abs/1811.09025

[3] https://people.math.ethz.ch/~mhg/pub/biksm.pdf

[4] https://academic.oup.com/book/36426

[5] https://en.wikipedia.org/wiki/Krylov_subspace

[6] Krylov Subspace Methods: Principles and Analysis, Jörg Liesen, Zdenek Strakos https://academic.oup.com/book/36426

[7] Iterative Methods for Sparse Linear Systems" by Yousef Saad

[8] "MINRES-QLP: A Krylov Subspace Method for Indefinite or Singular Symmetric Systems" by Sou-Cheng Choi, Christopher Paige, and
Michael Saunders (https://epubs.siam.org/doi/10.1137/100787921)

[9] Ethan N. Epperly, Lin Lin, and Yuji Nakatsukasa. "A theory of quantum subspace diagonalization". SIAM Journal on Matrix Analysis and Applications 43, 1263–1290 (2022).

[10] https://link.aps.org/doi/10.1103/PRXQuantum.4.030319
