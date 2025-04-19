# Puzzle 10: Dot Product

Implement a kernel that computes the dot-product of vector `a` and vector `b` and stores it in `out`.
You have 1 thread per position. You only need 2 global reads and 1 global write per thread.

## Visual Representation

![Dot product visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_47_1.svg)

## Key Concepts

In this puzzle, you'll learn about:
- Implementing **reduction** operations (like dot product)
- Using shared memory for thread collaboration
- Understanding parallel reduction patterns

The key insight is understanding how to compute partial results in parallel, then combine them efficiently using shared memory and synchronization to produce a final result.

For example, with:
- Array size: 8 elements
- Threads per block: 8
- Number of blocks: 1
- Shared memory size: 8 elements

- **Dot Product**: Computing element-wise multiplication and sum
- **Shared Memory**: Using block-local storage for partial results
- **Thread Synchronization**: Coordinating threads for reduction
- **Global Result**: Combining partial results into final output

*Note: For this problem, you don't need to worry about number of shared reads. We will
handle that challenge later.*

## Code to Complete

```mojo
{{#include ../../../problems/p10/p10.mojo:dot_product}}
```
<a href="../../../problems/p10/p10.mojo" class="filename">View full file: problems/p10/p10.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Load values from `a` and `b` and multiply them
2. Store the product in shared memory
3. Call `barrier()` to synchronize threads
4. Only thread 0 should compute the final sum
5. Write the final result to global memory only once

</div>
</details>

## Running the Code

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
- Loads corresponding elements from vectors `a` and `b`
- Computes element-wise products into shared memory
- Synchronizes threads using `barrier()`
- Uses thread 0 to sum all products
- Writes final dot product to global memory

</div>
</details>
