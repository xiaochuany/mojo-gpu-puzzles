## Simple version: Single block

![1D Convolution visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_50_1.svg)

## Key concepts

In this puzzle, you'll learn about:
- Implementing sliding window operations on GPUs
- Managing data dependencies across threads
- Using shared memory for overlapping regions

The key insight is understanding how to efficiently access overlapping elements while maintaining correct boundary conditions.

## Part 1: Simple case

Configuration:
- Input array size: \\(\\text{SIZE} = 6\\) elements
- Kernel size: \\(\\text{CONV} = 3\\) elements
- Threads per block: \\(\\text{TPB} = 8\\)
- Number of blocks: \\(1\\)
- Shared memory: Two arrays of size \\(\\text{SIZE}\\) and \\(\\text{CONV}\\)

- **Data loading**: Each thread loads one element from input and kernel
- **Memory pattern**: Shared arrays for input and convolution kernel
- **Thread sync**: Coordination before computation
- **Boundary check**: Handling array edges correctly

### Code to complete

```mojo
{{#include ../../../problems/p11/p11.mojo:conv_1d_simple}}
```
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p11/p11.mojo" class="filename">View full file: problems/p11/p11.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Load input to `shared_a[local_i]` and kernel to `shared_b[local_i]`
2. Call `barrier()` after loading
3. Sum products within bounds: `if local_i + j < SIZE`
4. Write result if `global_i < a_size`
</div>
</details>

### Running the code

To test your solution, run the following command in your terminal:

```bash
magic run p11 --simple
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([5.0, 8.0, 11.0, 14.0, 5.0, 0.0])
```
