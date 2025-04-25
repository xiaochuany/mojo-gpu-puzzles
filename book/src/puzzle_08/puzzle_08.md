# Puzzle 8: Shared Memory

Implement a kernel that adds 10 to each position of `a` and stores it in `out`.

**Note:** _You have fewer threads per block than the size of `a`._

![Shared memory visualization](./media/videos/720p30/puzzle_08_viz.gif)

## Key concepts

In this puzzle, you'll learn about:
- Using shared memory within thread blocks
- Synchronizing threads with barriers
- Managing block-local data storage

The key insight is understanding how shared memory provides fast, block-local storage that all threads in a block can access, requiring careful coordination between threads.

Configuration:

- Array size: `SIZE = 8` elements
- Threads per block: `TPB = 4`
- Number of blocks: 2
- Shared memory: `TPB` elements per block

Recall:

- **Shared memory**: Fast storage shared by threads in a block
- **Thread sync**: Coordination using `barrier()`
- **Memory scope**: Shared memory only visible within block
- **Access pattern**: Local vs global indexing

> **Warning**: Each block can only have a *constant* amount of shared memory that threads in that block can read and write to. This needs to be a literal python constant, not a variable. After writing to shared memory you need to call [barrier](https://docs.modular.com/mojo/stdlib/gpu/sync/barrier/) to ensure that threads do not cross.

## Code to complete

```mojo
{{#include ../../../problems/p08/p08.mojo:add_10_shared}}
```
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p08/p08.mojo" class="filename">View full file: problems/p08/p08.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Wait for shared memory load with `barrier()`
2. Use `local_i` to access shared memory: `shared[local_i]`
3. Use `global_i` for output: `out[global_i]`
4. Add guard: `if global_i < size`
</div>
</details>

## Running the code

To test your solution, run the following command in your terminal:

```bash
magic run p08
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0])
```

## Solution

<details>
<summary>Click to see the solution</summary>

```mojo
{{#include ../../../solutions/p08/p08.mojo:add_10_shared_solution}}
```

<div class="solution-explanation">

This solution:
- Waits for shared memory load with `barrier()`
- Guards against out-of-bounds with `if global_i < size`
- Reads from shared memory using `shared[local_i]`
- Writes result to global memory at `out[global_i]`
</div>
</details>
