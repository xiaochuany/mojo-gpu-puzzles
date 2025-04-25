# Puzzle 3: Guards

Implement a kernel that adds 10 to each position of vector a and stores it in vector out.

**Note**: _You have more threads than positions. This means you need to protect against out-of-bounds memory access._

![Guard](./media/videos/720p30/puzzle_03_viz.gif)

## Key concepts

In this puzzle, you'll learn about:
- Handling thread/data size mismatches
- Preventing out-of-bounds memory access
- Using conditional execution in GPU kernels

The key insight is that each thread \\(i\\) must check:
\\[\Large \\text{if}\\ i < \\text{size}: out[i] = a[i] + 10\\]

- **Thread safety**: Only threads where \\(i < \\text{size}\\) should execute
- **Guard condition**: Check `local_i < size` before accessing out-of-bound memory when \\(i \geq \\text{size}\\)

## Code to complete

```mojo
{{#include ../../../problems/p03/p03.mojo:add_10_guard}}
```
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p03/p03.mojo" class="filename">View full file: problems/p03/p03.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Store `thread_idx.x` in `local_i`
2. Add guard: `if local_i < size`
3. Inside guard: `out[local_i] = a[local_i] + 10.0`
</div>
</details>

## Running the code

To test your solution, run the following command in your terminal:

```bash
magic run p03
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
{{#include ../../../solutions/p03/p03.mojo:add_10_guard_solution}}
```

<div class="solution-explanation">

This solution:
- Gets thread index with `local_i = thread_idx.x`
- Guards against out-of-bounds access with `if local_i < size`
- Inside guard: adds 10 to input value
</div>
</details>
