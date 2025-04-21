# Naive Matrix Multiplication

Implement a kernel that multiplies square matrices `a` and `b` and stores the result in `out`.
This is the most straightforward implementation where each thread computes one element of the output matrix.

## Visual Representation

![Matrix Multiply visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_67_1.svg)

## Key Concepts

In this puzzle, you'll learn about:
- Basic matrix multiplication on GPU
- One-to-one thread to output mapping
- Row and column access patterns
- Global memory access patterns

The key insight is that each thread computes a single dot product between a row of matrix \\(A\\) and a column of matrix \\(B\\). For position \\((i,j)\\) in the output matrix:

\\[
C_{ij} = \sum_{k=0}^{n-1} A_{ik} \cdot B_{kj}
\\]

Where:
- \\(C_{ij}\\) is the output element at position \\((i,j)\\)
- \\(A_{ik}\\) is element at row \\(i\\), column \\(k\\) of matrix \\(A\\)
- \\(B_{kj}\\) is element at row \\(k\\), column \\(j\\) of matrix \\(B\\)
- \\(n\\) is the matrix dimension (SIZE)

In memory (row-major layout):
- \\(A_{ik} = a[i \cdot \text{size} + k]\\)
- \\(B_{kj} = b[k + j \cdot \text{size}]\\)
- \\(C_{ij} = \text{out}[i \cdot \text{size} + j]\\)

- **Thread Mapping**: Each thread \\(t_{ij}\\) computes one output element \\(c_{ij}\\)
- **Memory Access**: Direct access to global memory
- **Dot Product**: Computing row-column products and sums
- **Matrix Layout**: Understanding row-major storage

## Code to Complete

```mojo
{{#include ../../../problems/p14/p14.mojo:naive_matmul}}
```
<a href="../../../problems/p14/p14.mojo" class="filename">View full file: problems/p14/p14.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Calculate global thread indices for output position (i,j)
2. Check if thread indices are within matrix bounds
3. Compute dot product:
   - Initialize accumulator \\(c_{ij} = 0\\)
   - For \\(k = 0\\) to \\(\text{size}-1\\):
     - Access \\(a_{ik} = a[i \cdot \text{size} + k]\\)
     - Access \\(b_{kj} = b[k + j \cdot \text{size}]\\)
     - Accumulate \\(c_{ij} += a_{ik} \cdot b_{kj}\\)
4. Store result \\(\text{out}[i \cdot \text{size} + j] = c_{ij}\\)
</div>
</details>

## Running the Code

To test your solution, run the following command in your terminal:

```bash
magic run p14 --naive
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([1.0, 3.0, 3.0, 13.0])
```

## Solution

<details>
<summary>Click to see the solution</summary>

```mojo
{{#include ../../../solutions/p14/p14.mojo:naive_matmul_solution}}
```

<div class="solution-explanation">

This solution:
- Computes global thread indices for output position \\((i,j)\\)
- Checks if thread is within matrix bounds \\(i,j < \text{size}\\)
- Initializes accumulator \\(c_{ij} = 0\\)
- Iterates over \\(k \in [0, \text{size})\\) to compute dot product:
  - Accesses row elements: \\(a_{ik} = a[i \cdot \text{size} + k]\\)
  - Accesses column elements: \\(b_{kj} = b[k + j \cdot \text{size}]\\)
  - Accumulates \\(c_{ij} += a_{ik} \cdot b_{kj}\\)
- Stores final sum in output matrix
</div>
</details>
