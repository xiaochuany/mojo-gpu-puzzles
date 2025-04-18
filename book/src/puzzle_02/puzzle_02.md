# Puzzle 2: Zip

Implement a kernel that adds together each position of `a` and `b` and stores it in `out`.
You have 1 thread per position.

## Visual Representation

![Zip operation visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_17_1.svg)

## Key Concepts

In this puzzle, you'll learn about:
- Processing multiple input arrays in parallel
- Element-wise operations with multiple inputs
- Maintaining thread-to-data mapping across arrays

The key insight is that each thread should read one element from each input array, add them together, and write the result to the output array.

- **Parallelism**: Each thread processes corresponding elements from both arrays
- **Thread Indexing**: Using `thread_idx.x` to access matching positions in both arrays
- **Memory Access**: Reading from multiple input arrays and writing to output array
- **Data Independence**: Each position can be processed without knowledge of others

The zip pattern is a fundamental GPU operation for combining multiple arrays element-wise.

## Code to Complete

```mojo
{{#include ../../../problems/p02/p02.mojo:add}}
```
<a href="../../../problems/p02/p02.mojo" class="filename">View full file: problems/p02/p02.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Each thread needs to access the same position in both input arrays
2. Use the same thread index (`local_i`) to read from both arrays

</div>
</details>

## Running the Code

To test your solution, run the following command in your terminal:

```bash
magic run p02
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([0.0, 2.0, 4.0, 6.0])
```

## Solution

<details>
<summary>Click to see the solution</summary>

```mojo
{{#include ../../../solutions/p02/p02.mojo:add_solution}}
```

<div class="solution-explanation">

This solution:

- Uses `local_i` (thread index) to access corresponding elements in both arrays
- Adds the values from arrays `a` and `b`
- Stores the result in the output array

</div>
</details>
