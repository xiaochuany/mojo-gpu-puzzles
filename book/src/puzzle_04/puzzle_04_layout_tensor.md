# LayoutTensor version

Implement a kernel that adds \\(10\\) to each position of 2D `LayoutTensor` \\(a\\) and stores it in 2D `LayoutTensor` \\(out\\). You have more threads than positions.

## Key concepts

In this puzzle, you'll learn about:
- Using `LayoutTensor` for 2D array access
- Direct 2D indexing with `tensor[i, j]`
- Handling bounds checking with `LayoutTensor`

The key insight is that `LayoutTensor` provides a natural 2D indexing interface, abstracting away the underlying memory layout while still requiring bounds checking.

- **2D access**: Natural \\((i,j)\\) indexing with `LayoutTensor`
- **Memory abstraction**: No manual row-major calculation needed
- **Guard condition**: Still need bounds checking in both dimensions
- **Thread bounds**: More threads \\((3 \times 3)\\) than tensor elements \\((2 \times 2)\\)

## Code to complete

```mojo
{{#include ../../../problems/p04/p04_layout_tensor.mojo:add_10_2d_layout_tensor}}
```
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p04/p04_layout_tensor.mojo" class="filename">View full file: problems/p04/p04_layout_tensor.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Get 2D indices: `local_i = thread_idx.x`, `local_j = thread_idx.y`
2. Add guard: `if local_i < size and local_j < size`
3. Inside guard: `out[local_i, local_j] = a[local_i, local_j] + 10.0`
</div>
</details>

## Running the code

To test your solution, run the following command in your terminal:

```bash
magic run p04_layout_tensor
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
{{#include ../../../solutions/p04/p04_layout_tensor.mojo:add_10_2d_layout_tensor_solution}}
```

<div class="solution-explanation">

This solution:
- Gets 2D thread indices with `local_i = thread_idx.x`, `local_j = thread_idx.y`
- Guards against out-of-bounds with `if local_i < size and local_j < size`
- Uses `LayoutTensor`'s 2D indexing: `out[local_i, local_j] = a[local_i, local_j] + 10.0`
</div>
</details>
