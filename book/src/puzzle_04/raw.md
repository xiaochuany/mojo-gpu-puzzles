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

> ## Thread indexing convention
> When working with 2D matrices in GPU programming, we follow a natural mapping between thread indices and matrix coordinates:
> - `thread_idx.y` corresponds to the row index
> - `thread_idx.x` corresponds to the column index
> ![2D thread indexing](./media/videos/720p30/thread_indexing_viz.gif)
>
> This convention aligns with:
> 1. The standard mathematical notation where matrix positions are specified as (row, column)
> 2. The visual representation of matrices where rows go top-to-bottom (y-axis) and columns go left-to-right (x-axis)
> 3. Common GPU programming patterns where thread blocks are organized in a 2D grid matching the matrix structure
>
> ### Historical origins
> While graphics and image processing typically use \\((x,y)\\) coordinates, matrix operations in computing have historically used (row, column) indexing. This comes from how early computers stored and processed 2D data: line by line, top to bottom, with each line read left to right. This row-major memory layout proved efficient for both CPUs and GPUs, as it matches how they access memory sequentially. When GPU programming adopted thread blocks for parallel processing, it was natural to map `thread_idx.y` to rows and `thread_idx.x` to columns, maintaining consistency with established matrix indexing conventions.

## Code to complete

```mojo
{{#include ../../../problems/p04/p04.mojo:add_10_2d}}
```
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p04/p04.mojo" class="filename">View full file: problems/p04/p04.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Get 2D indices: `row = thread_idx.y`, `col = thread_idx.x`
2. Add guard: `if row < size and col < size`
3. Inside guard add 10 in row-major way!
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
1. Get 2D indices:  `row = thread_idx.y`, `col = thread_idx.x`
2. Add guard: `if row < size and col < size`
3. Inside guard: `out[row * size + col] = a[row * size + col] + 10.0`
</div>
</details>
