# Puzzle 8: Shared

Implement a kernel that adds 10 to each position of `a` and stores it in `out`.
You have fewer threads per block than the size of `a`.

## Visual Representation

![Shared memory visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_39_1.svg)

## Key Concepts

In this puzzle, you'll learn about:
- Using shared memory within a thread block
- Synchronizing threads with barriers
- The importance of thread synchronization in shared memory operations

The key insight is understanding how to use shared memory for temporary storage within a block and ensuring proper synchronization between threads.

For example, with:
- Array size: 8 elements
- Threads per block: 4
- Number of blocks: 2
- Shared memory size: 4 elements per block

- **Shared Memory**: Fast, block-local storage shared between threads
- **Barriers**: Synchronization points where all threads must wait
- **Memory Loading**: Copying from global to shared memory
- **Thread Synchronization**: Ensuring memory operations complete before proceeding

> **Warning**: Each block can only have a *constant* amount of shared memory that threads in that block can read and write to. This needs to be a literal python constant, not a variable. After writing to shared memory you need to call [barrier](https://docs.modular.com/mojo/stdlib/gpu/sync/barrier/) to ensure that threads do not cross.

## Code to Complete

```mojo
{{#include ../../../problems/p08/p08.mojo:add_10_shared}}
```
<a href="../../../problems/p08/p08.mojo" class="filename">View full file: problems/p08/p08.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Data is already loaded into shared memory for you
2. After the barrier, use `shared[local_i]` to access the data
3. Write the result back to global memory using `global_i`
4. Remember to check if `global_i < size` before writing
</div>
</details>

## Running the Code

To test your solution, run the following command in your terminal:

```bash
magic run p08
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0])
```

## Solution

<details>
<summary>Click to see the solution</summary>

```mojo
{{#include ../../../solutions/p08/p08.mojo:add_10_shared_solution}}
```

<div class="solution-explanation">

This solution:
- Uses shared memory already loaded with input data
- Waits for all threads at the barrier
- Adds 10 to the value in shared memory
- Writes the result back to global memory when index is valid

</div>
</details>
