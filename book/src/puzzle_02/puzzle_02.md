# Puzzle 2: Zip

Implement a kernel that adds together each position of vector `a` and vector `b` and stores it in `out`.

**Note:** _You have 1 thread per position._

![Zip](./media/videos/720p30/puzzle_02_viz.gif)

## Key concepts

In this puzzle, you'll learn about:
- Processing multiple input arrays in parallel
- Element-wise operations with multiple inputs
- Thread-to-data mapping across arrays

The key insight is that each thread \\(i\\) computes:
\\[\Large out[i] = a[i] + b[i]\\]

- **Parallelism**: Each thread adds elements from both arrays at position \\(i\\)
- **Memory access**: Read from \\(a[i]\\) and \\(b[i]\\), write to \\(out[i]\\)
- **Data independence**: Each output depends only on corresponding inputs

## Code to complete

```mojo
{{#include ../../../problems/p02/p02.mojo:add}}
```
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p02/p02.mojo" class="filename">View full file: problems/p02/p02.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Store `thread_idx.x` in `local_i`
2. Add `a[local_i]` and `b[local_i]`
3. Store result in `out[local_i]`
</div>
</details>

## Running the code

To test your solution, run the following command in your terminal:

```bash
magic run p02
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([0.0, 2.0, 4.0, 6.0])
```

## Solution

<details class="solution-details">
<summary></summary>

```mojo
{{#include ../../../solutions/p02/p02.mojo:add_solution}}
```

<div class="solution-explanation">

This solution:
- Gets thread index with `local_i = thread_idx.x`
- Adds values from both arrays: `out[local_i] = a[local_i] + b[local_i]`
</div>
</details>
