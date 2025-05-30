# Puzzle 3: Guards

## Overview
Implement a kernel that adds 10 to each position of vector `a` and stores it in vector `out`.

**Note**: _You have more threads than positions. This means you need to protect against out-of-bounds memory access._

![Guard](./media/videos/720p30/puzzle_03_viz.gif)

## Key concepts

In this puzzle, you'll learn about:
- Handling thread/data size mismatches
- Preventing out-of-bounds memory access
- Using conditional execution in GPU kernels
- Safe memory access patterns

### Mathematical Description
For each thread \\(i\\):
\\[\Large \text{if}\\ i < \text{size}: out[i] = a[i] + 10\\]

### Memory Safety Pattern
```txt
Thread 0 (i=0):  if 0 < size:  out[0] = a[0] + 10  ✓ Valid
Thread 1 (i=1):  if 1 < size:  out[1] = a[1] + 10  ✓ Valid
Thread 2 (i=2):  if 2 < size:  out[2] = a[2] + 10  ✓ Valid
Thread 3 (i=3):  if 3 < size:  out[3] = a[3] + 10  ✓ Valid
Thread 4 (i=4):  if 4 < size:  ❌ Skip (out of bounds)
Thread 5 (i=5):  if 5 < size:  ❌ Skip (out of bounds)
```

💡 **Note**: Boundary checking becomes increasingly complex with:
- Multi-dimensional arrays
- Different array shapes
- Complex access patterns

## Code to complete

```mojo
{{#include ../../../problems/p03/p03.mojo:add_10_guard}}
```
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p03/p03.mojo" class="filename">View full file: problems/p03/p03.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Store `thread_idx.x` in `i`
2. Add guard: `if i < size`
3. Inside guard: `out[i] = a[i] + 10.0`
</div>
</details>

## Running the code

To test your solution, run the following command in your terminal:

<div class="code-tabs" data-tab-group="package-manager">
  <div class="tab-buttons">
    <button class="tab-button">uv</button>
    <button class="tab-button">pixi</button>
  </div>
  <div class="tab-content">

```bash
uv run poe p03
```

  </div>
  <div class="tab-content">

```bash
pixi run p03
```

  </div>
</div>

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([10.0, 11.0, 12.0, 13.0])
```

## Solution

<details class="solution-details">
<summary></summary>

```mojo
{{#include ../../../solutions/p03/p03.mojo:add_10_guard_solution}}
```

<div class="solution-explanation">

This solution:
- Gets thread index with `i = thread_idx.x`
- Guards against out-of-bounds access with `if i < size`
- Inside guard: adds 10 to input value
</div>
</details>

### Looking ahead

While simple boundary checks work here, consider these challenges:
- What about 2D/3D array boundaries?
- How to handle different shapes efficiently?
- What if we need padding or edge handling?

Example of growing complexity:
```mojo
# Current: 1D bounds check
if i < size: ...

# Coming soon: 2D bounds check
if i < height and j < width: ...

# Later: 3D with padding
if i < height and j < width and k < depth and
   i >= padding and j >= padding: ...
```

These boundary handling patterns will become more elegant when we [learn about LayoutTensor in Puzzle 4](../puzzle_04/), which provides built-in boundary checking and shape management.
