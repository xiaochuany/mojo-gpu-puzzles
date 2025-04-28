# Naive Matrix Multiplication

## Overview

Implement a kernel that multiplies square matrices \\(A\\) and \\(\text{transpose}(A)\\) and stores the result in \\ \text{out}\\.
This is the most straightforward implementation where each thread computes one element of the output matrix.

## Key concepts

In this puzzle, you'll learn about:
- 2D thread organization for matrix operations
- Global memory access patterns
- Matrix indexing in row-major layout
- Thread-to-output element mapping

The key insight is understanding how to map 2D thread indices to matrix elements and compute dot products in parallel.

## Configuration

- Matrix size: \\(\\text{SIZE} \\times \\text{SIZE} = 2 \\times 2\\)
- Threads per block: \\(\\text{TPB} \\times \\text{TPB} = 3 \\times 3\\)
- Grid dimensions: \\(1 \\times 1\\)

For position \\((i,j)\\) in the output matrix:
\\[\Large C_{ij} = \sum_{k=0}^{\\text{SIZE}-1} A_{ik} \\cdot B_{kj} \\]

Memory layout (row-major):
- Matrix \\(A\\): \\(A_{ik} = a[i \\cdot \\text{SIZE} + k]\\)
- Matrix \\(B\\): \\(B_{kj} = b[k + j \\cdot \\text{SIZE}]\\)
- Output \\(C\\): \\(C_{ij} = \\text{out}[i \\cdot \\text{SIZE} + j]\\)

## Code to complete

```mojo
{{#include ../../../problems/p14/p14.mojo:naive_matmul}}
```
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p14/p14.mojo" class="filename">View full file: problems/p14/p14.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Calculate `global_i` and `global_j` from thread indices
2. Check if indices are within `size`
3. Accumulate products in a local variable
4. Write final sum to correct output position
</div>
</details>

## Running the code

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

<details class="solution-details">
<summary></summary>

```mojo
{{#include ../../../solutions/p14/p14.mojo:naive_matmul_solution}}
```

<div class="solution-explanation">

The naive matrix multiplication implementation demonstrates the basic approach. Here's a detailed breakdown:

### Matrix Layout (2×2 example)
```txt
Matrix A:        Matrix B:        Output C:
 [0 1]           [0 1]            [c00 c01]
 [2 3]           [2 3]            [c10 c11]
```

Where:
```txt
c00 = a00*b00 + a01*b10 = 0*0 + 1*2 = 2
c01 = a00*b01 + a01*b11 = 0*1 + 1*3 = 3
c10 = a10*b00 + a11*b10 = 2*0 + 3*2 = 6
c11 = a10*b01 + a11*b11 = 2*1 + 3*3 = 11
```

### Implementation Details:

1. **Thread Mapping**:
   ```mojo
   global_i = block_dim.x * block_idx.x + thread_idx.x
   global_j = block_dim.y * block_idx.y + thread_idx.y
   ```
   Each thread computes one element of the output matrix.

2. **Memory Access Pattern**:
   - Row access: `a[global_i * size + k]`
   - Column access: `b[k + global_j * size]`
   - Output: `out[global_i * size + global_j]`

3. **Computation Flow**:
   ```mojo
   total = 0
   for k in range(size):
       total += a[global_i * size + k] * b[k + global_j * size]
   ```

### Performance Characteristics:

1. **Memory Access**:
   - Each thread makes `2 x SIZE` global memory reads
   - One global memory write per thread
   - No data reuse between threads

2. **Computational Efficiency**:
   - Simple implementation but suboptimal performance
   - Many redundant global memory accesses
   - No use of fast shared memory

3. **Limitations**:
   - High global memory bandwidth usage
   - Poor data locality
   - Limited scalability for large matrices

This naive implementation serves as a baseline for understanding matrix multiplication on GPUs, highlighting the need for optimization in memory access patterns.
</div>
</details>
