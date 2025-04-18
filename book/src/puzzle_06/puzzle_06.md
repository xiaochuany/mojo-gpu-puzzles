# Puzzle 6: Blocks

Implement a kernel that adds 10 to each position of vector `a` and stores it in `out`.
**You have fewer threads per block than the size of `a`.**

## Visual Representation

![Blocks visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_31_1.svg)

## Key Concepts

In this puzzle, you'll learn about:
- Working with multiple blocks of threads
- Computing global thread indices
- Understanding the block/thread hierarchy in GPU programming

The key insight is understanding how to compute the global thread index using the block index, and ensuring that this index doesn't exceed the data size.

- **Thread Blocks**: Groups of threads that execute together
- **Block Index**: Using `block_idx` to identify which block is executing
- **Global Thread ID**: Computing unique thread identifiers across all blocks
- **Thread Hierarchy**: Understanding how blocks and threads work together
- **Scaling**: Processing large datasets with limited threads per block

## Code to Complete

```mojo
{{#include ../../../problems/p06/p06.mojo:add_10_blocks}}
```
<a href="../../../problems/p06/p06.mojo" class="filename">View full file: problems/p06/p06.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. We have 9 elements to process. Each block as 4 threads and we have 3 blocks so total of 12 threads (more than the size of our array)
2. Check if the global index is within the valid range
3. Only threads with valid global indices should modify the output array

</div>
</details>

## Running the Code

To test your solution, run the following command in your terminal:

```bash
magic run p06
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0])
```

## Solution

<details>
<summary>Click to see the solution</summary>

```mojo
{{#include ../../../solutions/p06/p06.mojo:add_10_blocks_solution}}
```

<div class="solution-explanation">

This solution:
- Calculates the global thread index using block and thread indices
- Checks if the global index is within the array bounds
- Adds 10 to the value when the guard condition is met

</div>
</details>
