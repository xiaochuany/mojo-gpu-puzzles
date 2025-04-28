# Puzzle 13: Axis Sum

## Overview
Implement a kernel that computes a sum over each row of 2D matrix `a` and stores it in `out`.

![Axis Sum visualization](./media/videos/720p30/puzzle_13_viz.gif)

## Key concepts

In this puzzle, you'll learn about:
- Parallel reduction along matrix dimensions
- Using block coordinates for data partitioning
- Efficient shared memory reduction patterns

The key insight is understanding how to map thread blocks to matrix rows and perform efficient parallel reduction within each block.

## Configuration
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
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p13/p13.mojo" class="filename">View full file: problems/p13/p13.mojo</a>

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

<details class="solution-details">
<summary></summary>

```mojo
{{#include ../../../solutions/p13/p13.mojo:axis_sum_solution}}
```

<div class="solution-explanation">

The solution implements a parallel row-wise sum reduction for a 2D matrix. Here's a comprehensive breakdown:

### Matrix Layout and Block Mapping
```txt
Matrix (4×6):                     Block Assignment:
[0  1  2  3  4  5 ] → sum=15     Block(0,0) → Row 0
[6  7  8  9  10 11] → sum=51     Block(0,1) → Row 1
[12 13 14 15 16 17] → sum=87     Block(0,2) → Row 2
[18 19 20 21 22 23] → sum=123    Block(0,3) → Row 3
```

### Parallel Reduction Process

1. **Initial Data Loading**:
   ```txt
   Block(0,0): cache = [0 1 2 3 4 5 * *]  // * = unused
   Block(0,1): cache = [6 7 8 9 10 11 * *]
   Block(0,2): cache = [12 13 14 15 16 17 * *]
   Block(0,3): cache = [18 19 20 21 22 23 * *]
   ```

2. **Reduction Steps** (for Block 0,0):
   ```txt
   Initial:  [0  1  2  3  4  5  *  *]
   Stride 4: [4  5  6  7  4  5  *  *]
   Stride 2: [10 12 6  7  4  5  *  *]
   Stride 1: [15 12 6  7  4  5  *  *]
   ```

### Key Implementation Features:

1. **Block-Row Mapping**:
   ```mojo
   batch = block_idx.y    --> Each y-block handles one row
   offset = batch * size  --> Starting position in global memory
   ```

2. **Memory Access Pattern**:
   - Row-aligned loading: `cache[local_i] = a[batch * size + local_i]`
   - Coalesced global memory access
   - Shared memory for efficient reduction

3. **Parallel Reduction Logic**:
   ```mojo
   stride = TPB // 2
   while stride > 0:
       if local_i < size:
           cache[local_i] += cache[local_i + stride]
       barrier()
       stride //= 2
   ```

4. **Output Writing**:
   ```mojo
   if local_i == 0:
       out[batch] = cache[0]  --> One result per row
   ```

### Performance Optimizations:

1. **Memory Efficiency**:
   - Single global memory load per thread
   - Shared memory for fast reduction
   - Minimal global memory writes

2. **Thread Utilization**:
   - Perfect load balancing across rows
   - No thread divergence in main computation
   - Efficient parallel reduction pattern

3. **Synchronization**:
   - Minimal barriers (only during reduction)
   - Independent processing between rows
   - No inter-block communication needed

### Complexity Analysis:
- Time: \\(O(\log n)\\) per row, where n is row length
- Space: \\(O(TPB)\\) shared memory per block
- Total parallel time: \\(O(\log n)\\) with sufficient threads

</div>
</details>
