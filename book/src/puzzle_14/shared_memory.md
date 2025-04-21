# Shared Memory Matrix Multiplication

Implement a kernel that multiplies square matrices `a` and `b` and stores the result in `out`, using shared memory to improve memory access efficiency. This version loads matrix blocks into shared memory before computation.

## Visual Representation

![Matrix Multiply with Shared Memory](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_67_1.svg)

## Key Concepts

In this puzzle, you'll learn about:

- Using shared memory for matrix multiplication
- Efficient memory access patterns
- Thread block collaboration
- Memory coalescing benefits

The key insight is loading portions of both matrices into shared memory first, which reduces global memory accesses and improves performance.

For example, with:
- Matrix size: 2×2 elements
- Threads per block: 3×3
- Number of blocks: 1×1
- Shared memory: Two TPB×TPB buffers (one for each matrix)

- **Shared Memory**: Fast, block-local storage for matrix chunks
- **Memory Loading**: Coordinated loading of matrix elements
- **Thread Synchronization**: Ensuring data is ready before computation
- **Memory Access Pattern**: Improved locality through shared memory

## Code to Complete

```mojo
{{#include ../../../problems/p14/p14.mojo:single_block_matmul}}
```
<a href="../../../problems/p14/p14.mojo" class="filename">View full file: problems/p14/p14.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Load data into shared memory:
   - Calculate global and local indices
   - Load `a[global_i, global_j]` into `a_shared[local_i, local_j]`
   - Load `b[global_i, global_j]` into `b_shared[local_i, local_j]`
   - Call `barrier()` to synchronize

2. Compute matrix multiplication:
   - Initialize accumulator
   - For `k = 0` to `size-1`:
     - Use `a_shared[local_i * size + k]`
     - Use `b_shared[k + local_j * size]`
     - Accumulate products

3. Remember:
   - Check bounds before loading/storing
   - Use `barrier()` after shared memory writes
   - Use local indices for shared memory access
</div>
</details>

## Running the Code

To test your solution, run the following command in your terminal:

```bash
magic run p14 --single-block
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
{{#include ../../../solutions/p14/p14.mojo:single_block_matmul_solution}}
```

<div class="solution-explanation">

This solution:
- Allocates shared memory for both input matrices
- Loads matrix elements into shared memory:
  - Uses global indices for loading from global memory
  - Uses local indices for storing in shared memory
- Synchronizes threads after loading with barrier()
- Computes matrix multiplication using shared memory:
  - Accesses a_shared[local_i * size + k]
  - Accesses b_shared[k + local_j * size]
  - Accumulates products for final result
- Only processes elements within matrix bounds
</div>
</details>

## Memory Layout Example

For a 2×2 matrix multiplication using 3×3 thread block:
```txt
Shared Memory Layout:
a_shared[TPB][TPB]:    b_shared[TPB][TPB]:
[0 1 *]                [0 1 *]
[2 3 *]                [2 3 *]
[* * *]                [* * *]

Where:
- Numbers show matrix elements
- * represents unused shared memory
- Each thread loads one element
- Threads collaborate for computation
```

Note: This version improves performance by reducing global memory accesses, but is limited to matrices that fit in a single thread block.
