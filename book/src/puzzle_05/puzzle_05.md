# Puzzle 5: Broadcast

Implement a kernel that adds `a` and `b` and stores it in `out`.
Inputs `a` and `b` are vectors. You have more threads than positions.

## Visual Representation

![Broadcast visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_27_1.svg)

## Key Concepts

In this puzzle, you'll learn about:
- Broadcasting operations across dimensions
- Processing 1D data with 2D thread configurations
- Coordinate conversion between thread and data indices

The key insight is understanding how to map 2D thread coordinates to 1D memory indices for the operation, while also ensuring proper boundary checking.

- **Broadcasting**: Understanding how to apply operations across different dimensions
- **Dimension Mapping**: Converting between 2D thread space and 1D data space
- **Thread Organization**: Efficiently using 2D thread blocks for 1D operations
- **Boundary Handling**: Managing thread indices that exceed data dimensions

## Code to Complete

```mojo
{{#include ../../../problems/p05/p05.mojo:broadcast_add}}
```
<a href="../../../problems/p05/p05.mojo" class="filename">View full file: problems/p05/p05.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. For row-major matrix, convert 2D thread indices to a 1D index using: `index = local_j * size + local_i`
2. Check if the calculated index is within the valid range
3. Add corresponding elements from `a` and `b` only for valid indices

</div>
</details>

## Running the Code

To test your solution, run the following command in your terminal:

```bash
magic run p05
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([0.0, 1.0, 1.0, 2.0])
```

## Solution

<details>
<summary>Click to see the solution</summary>

```mojo
{{#include ../../../solutions/p05/p05.mojo:broadcast_add_solution}}
```

<div class="solution-explanation">

This solution:
- Converts 2D thread coordinates to a 1D memory index
- Checks if the index is within the valid range
- Performs element-wise addition of `a` and `b` for valid indices

</div>
</details>


Now solve the same puzzle with `LayoutTensor` as explained in the previous puzzle.

## Code to Complete

```mojo
{{#include ../../../problems/p05/p05_layout_tensor.mojo:broadcast_add_layout_tensor}}
```
<a href="../../../problems/p05/p05_layout_tensor.mojo" class="filename">View full file: problems/p05/p05_layout_tensor.mojo</a>

## Running the Code

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

<details>
<summary>Click to see the solution</summary>

```mojo
{{#include ../../../solutions/p05/p05.mojo:broadcast_add_solution}}
```
