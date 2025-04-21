# Puzzle 13: Axis sum

Implement a kernel that computes a sum over each row of `a` and stores it in `out`.

In pseudocode:
```python
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

## Key concepts

In this puzzle, you'll learn about:
- Parallel reduction along matrix dimensions
- Using block coordinates for data partitioning
- Efficient shared memory reduction patterns

The key insight is understanding how to map thread blocks to matrix rows and perform efficient parallel reduction within each block.

Configuration:
- Matrix dimensions: \\(\\text{BATCH} \\times \\text{SIZE} = 4 \\times 6\\)
- Threads per block: \\(\\text{TPB} = 8\\)
- Grid dimensions: \\(1 \\times \\text{BATCH}\\)
- Shared memory: \\(\\text{TPB}\\) elements per block

Matrix layout in row-major order:

```txt
Row 0: [0, 1, 2, 3, 4, 5]       → Block(0,0)
Row 1: [6, 7, 8, 9, 10, 11]     → Block(0,1)
Row 2: [12, 13, 14, 15, 16, 17] → Block(0,2)
Row 3: [18, 19, 20, 21, 22, 23] → Block(0,3)
```

## Code to Complete

```mojo
{{#include ../../../problems/p13/p13.mojo:axis_sum}}
```
<a href="../../../problems/p13/p13.mojo" class="filename">View full file: problems/p13/p13.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Use `batch = block_idx.y` to select row
2. Load elements: `cache[local_i] = a[batch * size + local_i]`
3. Perform parallel reduction with halving stride
4. Thread 0 writes final sum to `out[batch]`
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

This solution implements a parallel row sum using:

1. Block mapping:
   - Each block handles one row: `batch = block_idx.y`
   - Threads within block share row elements

2. Data loading:
   ```txt
   Block(0,0): [T0,T1,T2,T3,T4,T5,T6,T7] → Row 0: [0,1,2,3,4,5]
   Block(0,1): [T0,T1,T2,T3,T4,T5,T6,T7] → Row 1: [6,7,8,9,10,11]
   Block(0,2): [T0,T1,T2,T3,T4,T5,T6,T7] → Row 2: [12,13,14,15,16,17]
   Block(0,3): [T0,T1,T2,T3,T4,T5,T6,T7] → Row 3: [18,19,20,21,22,23]
   ```

3. Parallel reduction:
   - Uses stride-halving approach
   - Synchronizes with `barrier()`
   - Handles size bounds correctly

4. Final output:
   - Thread 0 writes row sum to `out[batch]`
</div>
</details>
