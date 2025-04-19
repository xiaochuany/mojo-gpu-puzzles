# Puzzle 11: 1D Convolution

Implement a kernel that computes a 1D convolution between `a` and `b` and stores it in `out`.
You need to handle the general case. You only need 2 global reads and 1 global write per thread.

In pseudocode, 1D convolution is:

```txt
for i in range(SIZE):
    for j in range(CONV):
        if i + j < SIZE:
            ret[i] += a_host[i + j] * b_host[j]
```

## Visual Representation

![1D Convolution visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_50_1.svg)

## Key Concepts

In this puzzle, you'll learn about:

- Implementing convolution operations on GPUs
- Managing boundary conditions in convolution
- Efficient shared memory usage for sliding window operations

The key insight is understanding how to load both the input array and the convolution kernel into shared memory, then compute the convolution result for each position while handling boundary conditions correctly.

For example, with:
- Input array size: 6 elements
- Convolution kernel size: 3 elements
- Threads per block: 8
- Number of blocks: 1
- Shared memory: 6 elements for input, 3 elements for kernel

- **1D Convolution**: Computing sliding dot products
- **Boundary Handling**: Managing edge cases at array boundaries
- **Shared Memory**: Using separate shared arrays for input and kernel
- **Thread Coordination**: Ensuring data is loaded before computation

## Part 1: Simple Case

### Code to Complete

```mojo
{{#include ../../../problems/p11/p11.mojo:conv_1d_simple}}
```
<a href="../../../problems/p11/p11.mojo" class="filename">View full file: problems/p11/p11.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Load input array `a` into `shared_a` and kernel `b` into `shared_b`
2. Call `barrier()` to synchronize after loading
3. For each position, compute the convolution sum:
   - Iterate over the kernel size
   - Multiply and accumulate results
4. Write final result to global memory only if index is valid
</div>
</details>

### Running the Code

To test your solution, run the following command in your terminal:

```bash
magic run p11 --simple
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([5.0, 8.0, 11.0, 14.0, 5.0, 0.0])
```

### Solution

<details>
<summary>Click to see the solution</summary>

```mojo
{{#include ../../../solutions/p11/p11.mojo:conv_1d_simple_solution}}
```

<div class="solution-explanation">

This solution:
- Loads input array and convolution kernel into shared memory
- Synchronizes threads using barrier()
- Computes convolution sum for each position
- Handles boundary conditions correctly
- Writes results back to global memory

</div>
</details>

## Part 2: Block Boundary Case

### Code to Complete

```mojo
{{#include ../../../problems/p11/p11.mojo:conv_1d_block_boundary}}
```
<a href="../../../problems/p11/p11.mojo" class="filename">View full file: problems/p11/p11.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Load input array `a` into `shared_a` and kernel `b` into `shared_b`
2. Call `barrier()` to synchronize after loading
3. For each position, compute the convolution sum:
   - Iterate over the kernel size
   - Handle boundary conditions across blocks
   - Multiply and accumulate results
4. Write final result to global memory only if index is valid
</div>
</details>

### Running the Code

To test your solution, run the following command in your terminal:

```bash
magic run p11 --block-boundary
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([5.0, 8.0, 11.0, 14.0, 5.0, 0.0])
```

### Solution

<details>
<summary>Click to see the solution</summary>

```mojo
{{#include ../../../solutions/p11/p11.mojo:conv_1d_block_boundary_solution}}
```

<div class="solution-explanation">

This solution:
- Loads input array and convolution kernel into shared memory
- Handles data loading across block boundaries
- Synchronizes threads using barrier()
- Computes convolution sum for each position
- Manages boundary conditions between blocks
- Writes results back to global memory

</div>
</details>
