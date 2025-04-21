# Puzzle 7: Blocks 2D

Implement a kernel that adds \\(10\\) to each position of matrix \\(a\\) and stores it in \\(out\\).
You have fewer threads per block than the size of \\(a\\) in both directions.

![Blocks 2D visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_34_1.svg)

## Key concepts

In this puzzle, you'll learn about:
- Working with 2D block and thread arrangements
- Handling matrix data larger than block size
- Converting between 2D and linear memory access

The key insight is understanding how to coordinate multiple blocks of threads to process a 2D matrix that's larger than a single block's dimensions.

Configuration:
- Matrix size: \\(5 \times 5\\) elements
- Threads per block: \\(3 \times 3\\)
- Number of blocks: \\(2 \times 2\\)
- Total threads: \\(36\\) for \\(25\\) elements

- **2D blocks**: Each block processes a \\(3 \times 3\\) region
- **Grid layout**: Blocks arranged in \\(2 \times 2\\) grid
- **Memory pattern**: Row-major storage for 2D data
- **Coverage**: Ensuring all matrix elements are processed

## Code to complete

```mojo
{{#include ../../../problems/p07/p07.mojo:add_10_blocks_2d}}
```
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p07/p07.mojo" class="filename">View full file: problems/p07/p07.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Calculate global indices: `global_i = block_dim.x * block_idx.x + thread_idx.x`
2. Add guard: `if global_i < size and global_j < size`
3. Inside guard: `out[global_j * size + global_i] = a[global_j * size + global_i] + 10.0`
</div>
</details>

## Running the code

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
- Computes global indices with `block_dim * block_idx + thread_idx`
- Guards against out-of-bounds with `if global_i < size and global_j < size`
- Uses row-major indexing to access and update matrix elements
</div>
</details>
