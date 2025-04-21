# Puzzle 10: Dot product

Implement a kernel that computes the dot-product of vector `a` and vector `b` and stores it in `out`.
You have 1 thread per position. You only need 2 global reads and 1 global write per thread.

![Dot product visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_47_1.svg)

## Key concepts

In this puzzle, you'll learn about:
- Implementing parallel reduction operations
- Using shared memory for intermediate results
- Coordinating threads for collective operations

The key insight is understanding how to efficiently combine multiple values into a single result using parallel computation and shared memory.

Configuration:
- Vector size: \\(\\text{SIZE} = 8\\) elements
- Threads per block: \\(\\text{TPB} = 8\\)
- Number of blocks: \\(1\\)
- Output size: \\(1\\) element
- Shared memory: \\(\\text{TPB}\\) elements

- **Element access**: Each thread reads corresponding elements from `a` and `b`
- **Partial results**: Computing and storing intermediate values
- **Thread coordination**: Synchronizing before combining results
- **Final reduction**: Converting partial results to scalar output

*Note: For this problem, you don't need to worry about number of shared reads. We will
handle that challenge later.*

## Code to complete

```mojo
{{#include ../../../problems/p10/p10.mojo:dot_product}}
```
<a href="../../../problems/p10/p10.mojo" class="filename">View full file: problems/p10/p10.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Store `a[global_i] * b[global_i]` in `shared[local_i]`
2. Call `barrier()` to synchronize
3. Use thread 0 to sum all products in shared memory
4. Write final sum to `out[0]`
</div>
</details>

## Running the code

To test your solution, run the following command in your terminal:

```bash
magic run p10
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0])
expected: HostBuffer([140.0])
```

## Solution

<details>
<summary>Click to see the solution</summary>

```mojo
{{#include ../../../solutions/p10/p10.mojo:dot_product_solution}}
```

<div class="solution-explanation">

This solution:
- Computes element-wise products into shared memory
- Synchronizes all threads with `barrier()`
- Uses thread 0 to sum all products
- Writes final dot product result to `out[0]`
</div>
</details>
