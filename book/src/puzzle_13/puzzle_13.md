# Puzzle 13: Axis Sum

Implement a kernel that computes a sum over each column of `a` and stores it in `out`.

In pseudocode:

```txt
# For a matrix of size (BATCH × SIZE)
for batch in range(BATCH):  # each row
    sum = 0
    for i in range(SIZE):   # elements in row
        sum += a[batch * SIZE + i]  # row-major order
    out[batch] = sum
```

## Visual Representation

TODO: this image is wrong and is transposed

![Axis Sum visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_64_1.svg)

## Key Concepts

In this puzzle, you'll learn about:

- Computing reductions along specific dimensions (axes)
- Using multiple thread blocks to process different parts of data
- Mapping thread blocks to specific data columns/regions

The key insight is organizing your computation to have separate thread blocks handle different columns of the input array, then using shared memory within each block to compute the sum efficiently.

For example, with:

- Matrix size: 4×6 elements (BATCH × SIZE)
- Threads per block: 8×1
- Number of blocks: 1×4 (one block per row)
- Shared memory: 8 elements per block

- **Column-wise Reduction**: Computing sums along columns
- **Block Organization**: Using block.y to select columns
- **Shared Memory**: Using block-local storage for partial sums
- **Thread Coordination**: Ensuring efficient column-wise summation

## Code to Complete

```mojo
{{#include ../../../problems/p13/p13.mojo:axis_sum}}
```
<a href="../../../problems/p13/p13.mojo" class="filename">View full file: problems/p13/p13.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Use `block_idx.y` to determine which column you're processing
2. Calculate the starting index in the column:
   - `column_start = batch * size`
   - `global_index = column_start + global_i`
3. Load column elements into shared memory:
   - Only load if `global_i < size`
   - Use `local_i` for shared memory access
4. Synchronize threads using `barrier()`
5. Compute the column sum:
   - First thread accumulates all values in shared memory
   - Store result in `out[batch]`
</div>
</details>

## Running the Code

To test your solution, run the following command in your terminal:

```bash
magic run p13
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: DeviceBuffer([0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([15.0, 51.0, 87.0, 123.0])
```

## Solution

<details>
<summary>Click to see the solution</summary>

```mojo
{{#include ../../../solutions/p13/p13.mojo:axis_sum_solution}}
```

<div class="solution-explanation">

This solution:
- Uses `block_idx.y` (batch) to select which row of the matrix to process
- Loads elements from the row into shared memory using `cache[local_i] = a[batch * size + local_i]`
- Performs parallel reduction in shared memory:
  - Uses stride-halving approach (TPB/2, TPB/4, TPB/8, ...)
  - Each thread adds elements that are `stride` apart
  - Synchronizes between reduction steps with `barrier()`
- Thread 0 writes the final sum to `out[batch]`

The matrix layout is:
```txt
Block(0,0): handles Row 0: [0,1,2,3,4,5]
Block(0,1): handles Row 1: [6,7,8,9,10,11]
Block(0,2): handles Row 2: [12,13,14,15,16,17]
Block(0,3): handles Row 3: [18,19,20,21,22,23]
```

Note: While we call it "axis sum", we're actually summing rows of the matrix (when viewed in row-major order), not columns as previously described.
</div>
</details>
