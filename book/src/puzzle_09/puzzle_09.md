# Puzzle 9: Pooling

Implement a kernel that sums together the last 3 positions of vector `a` and stores it in vector `out`.
You have 1 thread per position. You only need 1 global read and 1 global write per thread.

In psuedocode

```txt
for i in range(a.shape[0]):
    out[i] = a[max(i - 2, 0) : i + 1].sum()
```

## Visual Representation

![Pooling visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_43_1.svg)

## Key Concepts

In this puzzle, you'll learn about:
- Implementing pooling operations using shared memory
- Accessing adjacent elements in shared memory
- Managing thread synchronization for dependent operations

The key insight is understanding how to efficiently implement a sliding window operation using shared memory, where each thread's output depends on multiple input values.

For example, with:
- Array size: 8 elements
- Threads per block: 8
- Number of blocks: 1
- Shared memory size: 8 elements
- Window size: 3 elements

- **Pooling Operation**: Summing multiple adjacent elements
- **Shared Memory Access**: Reading neighboring elements efficiently
- **Thread Synchronization**: Ensuring data is loaded before pooling
- **Sliding Window**: Managing boundary conditions for window operations

## Code to Complete

```mojo
{{#include ../../../problems/p09/p09.mojo:pooling}}
```
<a href="../../../problems/p09/p09.mojo" class="filename">View full file: problems/p09/p09.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Load data into shared memory and call barrier()
2. For position i, sum elements [i-2, i-1, i] if they exist
3. Be careful with boundary conditions (first two elements)
4. Write the result back to global memory only if index is valid

</div>
</details>

## Running the Code

To test your solution, run the following command in your terminal:

```bash
magic run p09
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([0.0, 1.0, 3.0, 6.0, 9.0, 12.0, 15.0, 18.0])
```

## Solution

<details>
<summary>Click to see the solution</summary>

```mojo
{{#include ../../../solutions/p09/p09.mojo:pooling_solution}}
```

<div class="solution-explanation">

This solution:
- Loads each element into shared memory
- Synchronizes threads using barrier()
- Computes the sum of last 3 elements for each position
- Handles edge cases for first two elements
- Writes result back to global memory

</div>
</details>
