# Puzzle 4: Map 2D

Implement a kernel that adds 10 to each position of 2D square matrix `a` and stores it in 2D square matrix `out`.
**You have more threads than positions**.

## Visual Representation

![Map 2D visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_24_1.svg)

## Key Concepts

In this puzzle, you'll learn about:
- Working with 2D thread configurations
- Mapping 2D thread indices to 1D memory
- Implementing boundary checks in multiple dimensions

The key insight is understanding how to convert 2D coordinates to a 1D memory index using row-major ordering, and ensuring that your thread indices are within the bounds of the 2D data.

- **2D Threading**: Using x and y thread indices for 2D data
- **Memory Layout**: Converting 2D coordinates to 1D memory addresses
- **Boundary Checks**: Ensuring threads stay within valid 2D array bounds
- **Row-Major Order**: Understanding how 2D data is stored in linear memory

## Code to Complete

```mojo
{{#include ../../../problems/p04/p04.mojo:add_10_2d}}
```
<a href="../../../problems/p04/p04.mojo" class="filename">View full file: problems/p04/p04.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. For a row-major matrix, calculate the 1D index from 2D coordinates using: `index = local_j * size + local_i`
2. Check if both `local_i` and `local_j` are less than `size`
3. Only threads within the 2D bounds should modify the output array

</div>
</details>

## Running the Code

To test your solution, run the following command in your terminal:

```bash
magic run p04
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
{{#include ../../../solutions/p04/p04.mojo:add_10_2d_solution}}
```

<div class="solution-explanation">

This solution:
- Calculates the 1D memory index from 2D thread coordinates using: `index = local_j * size + local_i`
- Checks if both coordinates are within the array bounds
- Adds 10 to the value when the guard conditions are met

</div>
</details>

