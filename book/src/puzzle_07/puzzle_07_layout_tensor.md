# LayoutTensor version

Implement a kernel that adds \\(10\\) to each position of 2D `LayoutTensor` \\(a\\) and stores it in 2D `LayoutTensor` \\(out\\). You have fewer threads per block than the size of \\(a\\) in both directions.

## Key concepts

In this puzzle, you'll learn about:
- Using `LayoutTensor` with multiple blocks
- Handling large matrices with 2D block organization
- Combining block indexing with `LayoutTensor` access

The key insight is that `LayoutTensor` simplifies 2D indexing while still requiring proper block coordination for large matrices.

Configuration:
- Matrix size: \\(5 \times 5\\) elements
- Threads per block: \\(3 \times 3\\)
- Number of blocks: \\(2 \times 2\\)
- Total threads: \\(36\\) for \\(25\\) elements

- **Layout handling**: `LayoutTensor` manages row-major organization
- **Block coordination**: Multiple blocks cover the full matrix
- **2D indexing**: Natural \\((i,j)\\) access with bounds checking
- **Thread mapping**: Each thread processes one matrix element

## Code to complete

```mojo
{{#include ../../../problems/p07/p07_layout_tensor.mojo:add_10_blocks_2d_layout_tensor}}
```
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p07/p07_layout_tensor.mojo" class="filename">View full file: problems/p07/p07_layout_tensor.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Calculate global indices: `global_i = block_dim.x * block_idx.x + thread_idx.x`
2. Add guard: `if global_i < size and global_j < size`
3. Inside guard: `out[global_i, global_j] = a[global_i, global_j] + 10.0`
</div>
</details>

## Running the code

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

<div class="solution-explanation">

This solution:
- Computes global indices with `block_dim * block_idx + thread_idx`
- Guards against out-of-bounds with `if global_i < size and global_j < size`
- Uses `LayoutTensor`'s 2D indexing: `out[global_i, global_j] = a[global_i, global_j] + 10.0`
</div>
</details>
