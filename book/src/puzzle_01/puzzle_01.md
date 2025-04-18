# Puzzle 1: Map

GPU programming is all about parallelism. In this puzzle, each thread will process a single element of the input array independently.
Implement a "kernel" (GPU function) that adds 10 to each position of vector `a` and stores it in vector `out`. You have 1 thread per position.

## Visual Representation

![Map operation visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_14_1.svg)

## Key Concepts

In this puzzle, you'll learn about:

- Basic GPU kernel structure
- Mapping thread indices to data indices
- Parallel execution of independent operations

The key insight is that each thread (identified by `thread_idx.x`) should process one element of the input array.

- **Parallelism**: Each thread executes the same instruction on different data
- **Thread Indexing**: Using `thread_idx.x` to identify which data element to process
- **Memory Access**: Reading from and writing to GPU memory using pointers
- **Data Independence**: Each element can be processed without knowledge of others

The mapping pattern is one of the most fundamental GPU operations and forms the basis for many more complex algorithms.

## Code to Complete

```mojo
{{#include ../../../problems/p01/p01.mojo:add_10}}
```
<a href="../../../problems/p01/p01.mojo" class="filename">View full file: problems/p01/p01.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Each thread processes a single element independently, which is the fundamental concept of parallel processing on GPUs.
2. In Mojo, we can get the value of an initialized [UnsafePointer](https://docs.modular.com/mojo/stdlib/memory/unsafe_pointer/UnsafePointer/) at `index` via `a[index]`.

</div>
</details>

## Running the Code

To test your solution, run the following command in your terminal:

```bash
magic run p01
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([10.0, 11.0, 12.0, 13.0])
```

## Solution

<details>
<summary>Click to see the solution</summary>

```mojo
{{#include ../../../solutions/p01/p01.mojo:add_10_solution}}
```

<div class="solution-explanation">
This solution:

- Uses `local_i` (thread index) to access the correct element
- Adds 10 to the value
</div>

</details>

