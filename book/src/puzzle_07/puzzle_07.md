# Puzzle 7: Blocks 2D

Implement a kernel that adds 10 to each position of matrix `a` and stores it in `out`.
You have fewer threads per block than the size of `a` in both directions.

## Visual Representation

![Blocks 2D visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_34_1.svg)

## Key Concepts

In this puzzle, you'll learn about:
- Working with 2D block configurations
- Computing global thread indices in multiple dimensions
- Mapping 2D thread/block indices to memory locations

The key insight is understanding how to compute global thread indices in a 2D grid, convert them to a linear memory index, and ensure that these indices don't exceed the data size in either dimension.

For example, with:
- Matrix size: 5×5 elements
- Threads per block: 3×3
- Number of blocks: 2×2
- Total threads: 36 (more than needed 25)

- **2D Block Grid**: Understanding how blocks are arranged in 2D
- **Global Indices**: Computing global (x,y) positions from block and thread indices
- **Linear Memory**: Converting 2D indices to linear memory addresses
- **Boundary Checks**: Handling edge cases in both dimensions

## Code to Complete

```mojo
{{#include ../../../problems/p07/p07.mojo:add_10_blocks_2d}}
```
<a href="../../../problems/p07/p07.mojo" class="filename">View full file: problems/p07/p07.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Check if both global indices are within the matrix bounds
2. Convert 2D indices to linear memory index for row-major matrix: `index = global_j * size + global_i`
3. Only threads with valid indices should modify the output array
</div>
</details>

## Running the Code

To test your solution, run the following command in your terminal:

```bash
magic run p07
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0, 0.0, 0.0, ... , 0.0])
expected: HostBuffer([11.0, 11.0, 11.0, ... , 11.0])
```

## Solution

<details>
<summary>Click to see the solution</summary>

```mojo
{{#include ../../../solutions/p07/p07.mojo:add_10_blocks_2d_solution}}
```

<div class="solution-explanation">

This solution:
- Calculates global thread indices for both dimensions using block and thread indices
- Checks if both global indices are within the matrix bounds
- Converts 2D indices to linear memory index for accessing the arrays
- Adds 10 to the value when all guard conditions are met

</div>
</details>


Now solve the same the puzzle with `LayoutTensor` as input and output.

## Code to Complete

```mojo
{{#include ../../../problems/p07/p07_layout_tensor.mojo:add_10_blocks_2d_layout_tensor}}
```
<a href="../../../problems/p07/p07.mojo" class="filename">View full file: problems/p07/p07.mojo</a>


## Running the Code

To test your solution, run the following command in your terminal:

```bash
magic run p07_layout_tensor
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0, 0.0, 0.0, ... , 0.0])
expected: HostBuffer([11.0, 11.0, 11.0, ... , 11.0])
```

## Solution

<details>
<summary>Click to see the solution</summary>

```mojo
{{#include ../../../solutions/p07/p07_layout_tensor.mojo:add_10_blocks_2d_layout_tensor_solution}}
```
