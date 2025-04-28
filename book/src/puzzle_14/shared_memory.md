# Shared Memory Matrix Multiplication

Implement a kernel that multiplies square matrices \\(A\\) and \\(\text{transpose}(A)\\) and stores the result in \\ \text{out}\\, using shared memory to improve memory access efficiency. This version loads matrix blocks into shared memory before computation.

## Key concepts

In this puzzle, you'll learn about:
- Block-local memory management
- Thread synchronization patterns
- Memory access optimization
- Collaborative data loading

The key insight is understanding how to use fast shared memory to reduce expensive global memory operations.

## Configuration

- Matrix size: \\(\\text{SIZE} \\times \\text{SIZE} = 2 \\times 2\\)
- Threads per block: \\(\\text{TPB} \\times \\text{TPB} = 3 \\times 3\\)
- Grid dimensions: \\(1 \\times 1\\)
- Shared memory: Two \\(\\text{TPB} \\times \\text{TPB}\\) arrays

Memory layout:
```txt
Matrix A (2×2):     Matrix B (2×2):     Shared Memory (3×3 each):
 [0 1]              [0 1]                a_shared: [0 1 *]  b_shared: [0 1 *]
 [2 3]              [2 3]                          [2 3 *]            [2 3 *]
                                                   [* * *]            [* * *]
```
Where \\(*\\) represents unused shared memory cells.

## Code to complete

```mojo
{{#include ../../../problems/p14/p14.mojo:single_block_matmul}}
```
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p14/p14.mojo" class="filename">View full file: problems/p14/p14.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Load matrices to shared memory using global and local indices
2. Call `barrier()` after loading
3. Compute dot product using shared memory indices
4. Check array bounds for all operations
</div>
</details>

## Running the code

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

<details class="solution-details">
<summary></summary>

```mojo
{{#include ../../../solutions/p14/p14.mojo:single_block_matmul_solution}}
```

<div class="solution-explanation">

The shared memory implementation improves performance by reducing global memory access. Here's a detailed analysis:

### Memory Organization

```txt
Global Memory:           Shared Memory (per block):
 Matrix A (2×2):         a_shared (3×3):
  [0 1]                   [0 1 *]
  [2 3]                   [2 3 *]
                          [* * *]

Matrix B (2×2):          b_shared (3×3):
  [0 1]                   [0 1 *]
  [2 3]                   [2 3 *]
                          [* * *]
```

### Implementation Phases:

1. **Shared Memory Setup**:
   ```mojo
   a_shared = stack_allocation[TPB * TPB * sizeof[dtype](), ...]
   b_shared = stack_allocation[TPB * TPB * sizeof[dtype](), ...]
   ```

2. **Data Loading**:
   ```mojo
   if global_i < size and global_j < size:
       a_shared[local_i * size + local_j] = a[global_i * size + global_j]
       b_shared[local_i * size + local_j] = b[global_i * size + global_j]
   barrier()
   ```

3. **Computation**:
   ```mojo
   for k in range(size):
       out[...] += a_shared[local_i * size + k] * b_shared[k + local_j * size]
   ```

### Performance Improvements:

1. **Memory Access Efficiency**:
   - Reduced global memory accesses
   - Fast shared memory for repeated access
   - Better data locality

2. **Thread Cooperation**:
   - Threads cooperate to load data
   - Shared data reuse within block
   - Synchronized access with barriers

3. **Limitations**:
   - Still limited by block size
   - Not optimal for large matrices
   - Room for further tiling optimization

This implementation significantly reduces memory bandwidth requirements compared to the naive version.
</div>
</details>
