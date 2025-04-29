# LayoutTensor Version

## Overview
Implement a kernel that broadcast adds _LayoutTensor_ vector `a` and _LayoutTensor_ vector `b` and stores it in _LayoutTensor_ `out`.

**Note:** _You have more threads than positions._

## Key concepts

In this puzzle, you'll learn about:
- Using `LayoutTensor` for broadcast operations
- Working with different tensor shapes
- Handling 2D indexing with `LayoutTensor`

The key insight is that `LayoutTensor` allows natural broadcasting through different tensor shapes: \\((n,1)\\) and \\((1,n)\\) to \\((n,n)\\), while still requiring bounds checking.

- **Tensor shapes**: Input vectors have shapes \\((n,1)\\) and \\((1,n)\\)
- **Broadcasting**: Output combines both dimensions to \\((n,n)\\)
- **Guard condition**: Still need bounds checking for output size
- **Thread bounds**: More threads \\((3 \times 3)\\) than tensor elements \\((2 \times 2)\\)

## Code to complete

```mojo
{{#include ../../../problems/p05/p05_layout_tensor.mojo:broadcast_add_layout_tensor}}
```
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p05/p05_layout_tensor.mojo" class="filename">View full file: problems/p05/p05_layout_tensor.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Get 2D indices: `local_i = thread_idx.x`, `local_j = thread_idx.y`
2. Add guard: `if local_i < size and local_j < size`
3. Inside guard: `out[local_i, local_j] = a[local_i, 0] + b[0, local_j]`
</div>
</details>

## Running the code

To test your solution, run the following command in your terminal:

```bash
magic run p05_layout_tensor
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([0.0, 1.0, 1.0, 2.0])
```

## Solution

<details class="solution-details">
<summary></summary>

```mojo
{{#include ../../../solutions/p05/p05_layout_tensor.mojo:broadcast_add_layout_tensor_solution}}
```

<div class="solution-explanation">

This solution:
- Gets 2D thread indices with `local_i = thread_idx.x`, `local_j = thread_idx.y`
- Guards against out-of-bounds with `if local_i < size and local_j < size`
- Uses `LayoutTensor` broadcasting: `a[local_i, 0] + b[0, local_j]`
</div>
</details>
