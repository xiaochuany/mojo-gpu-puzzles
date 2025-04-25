# Puzzle 6: Blocks

Implement a kernel that adds 10 to each position of vector `a` and stores it in `out`.

**Note:** _You have fewer threads per block than the size of a._

![Blocks visualization](./media/videos/720p30/puzzle_06_viz.gif)

## Key concepts

In this puzzle, you'll learn about:
- Processing data larger than thread block size
- Coordinating multiple blocks of threads
- Computing global thread positions

The key insight is understanding how blocks of threads work together to process data that's larger than a single block's capacity, while maintaining correct element-to-thread mapping.

## Code to complete

```mojo
{{#include ../../../problems/p06/p06.mojo:add_10_blocks}}
```
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p06/p06.mojo" class="filename">View full file: problems/p06/p06.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Calculate global index: `global_i = block_dim.x * block_idx.x + thread_idx.x`
2. Add guard: `if global_i < size`
3. Inside guard: `out[global_i] = a[global_i] + 10.0`
</div>
</details>

## Running the code

To test your solution, run the following command in your terminal:

```bash
magic run p06
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0])
```

## Solution

<details>
<summary>Click to see the solution</summary>

```mojo
{{#include ../../../solutions/p06/p06.mojo:add_10_blocks_solution}}
```

<div class="solution-explanation">

This solution:
- Computes global thread index from block and thread indices
- Guards against out-of-bounds with `if global_i < size`
- Inside guard: adds 10 to input value at global index
</div>
</details>
