# Puzzle 4: 2D Map

## Overview
Implement a kernel that adds 10 to each position of 2D square matrix `a` and stores it in 2D square matrix `out`.

**Note:** _You have more threads than positions_.

![2D Matrix Mapping](./media/videos/720p30/puzzle_04_viz.gif)

## Key concepts

In this puzzle, you'll learn about:
- Working with 2D thread indices (`thread_idx.x`, `thread_idx.y`)
- Converting 2D coordinates to 1D memory indices
- Handling boundary checks in two dimensions

The key insight is understanding how to map from 2D thread coordinates \\((i,j)\\) to elements in a row-major matrix of size \\(n \times n\\), while ensuring thread indices are within bounds.

- **2D indexing**: Each thread has a unique \\((i,j)\\) position
- **Memory layout**: Row-major ordering maps 2D to 1D memory
- **Guard condition**: Need bounds checking in both dimensions
- **Thread bounds**: More threads \\((3 \times 3)\\) than matrix elements \\((2 \times 2)\\)

## Code to complete

```mojo
{{#include ../../../problems/p04/p04.mojo:add_10_2d}}
```
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p04/p04.mojo" class="filename">View full file: problems/p04/p04.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Get 2D indices: `local_i = thread_idx.x`, `local_j = thread_idx.y`
2. Add guard: `if local_i < size and local_j < size`
3. Inside guard: `out[local_j * size + local_i] = a[local_j * size + local_i] + 10.0`
</div>
</details>

## Running the code

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

<details class="solution-details">
<summary></summary>

```mojo
{{#include ../../../solutions/p04/p04.mojo:add_10_2d_solution}}
```

<div class="solution-explanation">

This solution:
- Gets 2D thread indices with `local_i = thread_idx.x`, `local_j = thread_idx.y`
- Guards against out-of-bounds with `if local_i < size and local_j < size`
- Inside guard: adds 10 to input value using row-major indexing
</div>
</details>
