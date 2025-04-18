# Puzzle 4: Map 2D

Implement a kernel that adds 10 to each position of `a` and stores it in `out`.
Input `a` is 2D and square. **You have more threads than positions**.

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


## Introduction to LayoutTensor

[LayoutTensor](https://docs.modular.com/mojo/stdlib/layout/layout_tensor/LayoutTensor/) provides a powerful abstraction for multi-dimensional data with precise control over memory organization. It supports various memory layouts (row-major, column-major, tiled), hardware-specific optimizations, and efficient parallel access patterns.

Given a `LayoutTensor` instance `a`

```mojo
from layout import Layout, LayoutTensor

alias dtype = DType.float32
alias layout = Layout.row_major(2, 3)

a_tensor = LayoutTensor[mut=True, dtype, layout](a_ptr)
a_tensor[0, 1] += 10
```

we can get the `(i, j)` elements with the more familiar syntax `a_tensor[i, j]` which in the row-major case is the same as `a_ptr[j * 3 + i]`.

This abstraction makes multi-dimensional array access more intuitive and less error-prone, as it handles the complex linear memory mapping internally. Instead of manually calculating indices with formulas like `j * width + i`, we can use the natural `[i, j]` notation. We will explore more powerful features of `LayoutTensor` in upcoming puzzles, including different memory layouts, tiling, and optimized access patterns.

## Code to Complete

Now, solve the same puzzle but this time with `LayoutTensor` as input and output.

```mojo
{{#include ../../../problems/p04/p04_layout_tensor.mojo:add_10_2d_layout_tensor}}
```
<a href="../../../problems/p04/p04_layout_tensor.mojo" class="filename">View full file: problems/p04/p04_layout_tensor.mojo</a>

## Running the Code

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
- Uses `tensor[i, j]` syntax to get the elements at position `(i, j)`
- Checks if both coordinates are within the array bounds
- Adds 10 to the value when the guard conditions are met

</div>
</details>
