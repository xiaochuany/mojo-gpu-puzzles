# Puzzle 5: Broadcast

## Overview
Implement a kernel that broadcast adds vector `a` and vector `b` and stores it in 2D matrix `out`.

**Note:** _You have more threads than positions._

![Broadcast visualization](./media/videos/720p30/puzzle_05_viz.gif)

## Key concepts

In this puzzle, you'll learn about:
- Broadcasting 1D vectors across different dimensions
- Using 2D thread indices for broadcast operations
- Handling boundary conditions in broadcast patterns

The key insight is understanding how to map elements from two 1D vectors to create a 2D output matrix through broadcasting, while handling thread bounds correctly.

- **Broadcasting**: Each element of `a` combines with each element of `b`
- **Thread mapping**: 2D thread grid \\((3 \times 3)\\) for \\(2 \times 2\\) output
- **Vector access**: Different access patterns for `a` and `b`
- **Bounds checking**: Guard against threads outside matrix dimensions

## Code to complete

```mojo
{{#include ../../../problems/p05/p05.mojo:broadcast_add}}
```
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p05/p05.mojo" class="filename">View full file: problems/p05/p05.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Get 2D indices: `local_i = thread_idx.x`, `local_j = thread_idx.y`
2. Add guard: `if local_i < size and local_j < size`
3. Inside guard: `out[local_j * size + local_i] = a[local_i] + b[local_j]`
</div>
</details>

## Running the code

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

<details class="solution-details">
<summary></summary>

```mojo
{{#include ../../../solutions/p05/p05.mojo:broadcast_add_solution}}
```

<div class="solution-explanation">

This solution:
- Gets 2D thread indices with `local_i = thread_idx.x`, `local_j = thread_idx.y`
- Guards against out-of-bounds with `if local_i < size and local_j < size`
- Broadcasts by adding `a[local_i]` and `b[local_j]` into the output matrix
</div>
</details>
