# Naive Matrix Multiplication

## Overview

Implement a kernel that multiplies square matrices \\(A\\) and \\(B\\) and stores the result in \\(\text{out}\\).
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

Layout configuration:
- Input A: `Layout.row_major(SIZE, SIZE)`
- Input B: `Layout.row_major(SIZE, SIZE)`
- Output: `Layout.row_major(SIZE, SIZE)`

Memory layout (LayoutTensor):
- Matrix A: `a[i, j]` directly indexes position (i,j)
- Matrix B: `b[i, j]` is the transpose of A
- Output C: `out[i, j]` stores result at position (i,j)

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
expected: HostBuffer([4.0, 6.0, 12.0, 22.0])
```

## Solution

<details class="solution-details">
<summary></summary>

```mojo
{{#include ../../../solutions/p14/p14.mojo:naive_matmul_solution}}
```

<div class="solution-explanation">

The naive matrix multiplication using LayoutTensor demonstrates the basic approach:

### Matrix Layout (2×2 example)
```txt
Matrix A:        Matrix B (transpose of A):    Output C:
 [a[0,0] a[0,1]]  [b[0,0] b[0,1]]             [c[0,0] c[0,1]]
 [a[1,0] a[1,1]]  [b[1,0] b[1,1]]             [c[1,0] c[1,1]]
```

### Implementation Details:

1. **Thread Mapping**:
   ```mojo
   global_i = block_dim.x * block_idx.x + thread_idx.x
   global_j = block_dim.y * block_idx.y + thread_idx.y
   ```

2. **Memory Access Pattern**:
   - Direct 2D indexing: `a[global_i, k]`
   - Transposed access: `b[k, global_j]`
   - Output writing: `out[global_i, global_j]`

3. **Computation Flow**:
   ```mojo
   # Use var for mutable accumulator with tensor's element type
   var acc: out.element_type = 0

   # @parameter for compile-time loop unrolling
   @parameter
   for k in range(size):
       acc += a[global_i, k] * b[k, global_j]
   ```

### Key Language Features:

1. **Variable Declaration**:
   - The use of `var` in `var acc: out.element_type = 0` allows for type inference with `out.element_type` ensures type compatibility with the output tensor
   - Initialized to zero before accumulation

2. **Loop Optimization**:
   - [`@parameter`](https://docs.modular.com/mojo/manual/decorators/parameter/#parametric-for-statement) decorator unrolls the loop at compile time
   - Improves performance for small, known matrix sizes
   - Enables better instruction scheduling

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
