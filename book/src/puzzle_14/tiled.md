# Tiled matrix multiplication

Implement a kernel that multiplies square matrices `a` and `b` and stores the result in `out`, using tiled matrix multiplication with shared memory. This version handles matrices larger than a single thread block by processing tiles.

<div class="solution-tips">

Update your [shared memory code](./shared_memory.md) to compute a partial dot-product and iteratively move the part you
copied into shared memory. You should be able to do the hard case in 6 global reads.
</div>

![Matrix Multiply Tiled](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_70_1.svg)

## Key concepts

In this puzzle, you'll learn about:
- Processing large matrices in smaller chunks
- Coordinating multiple thread blocks
- Managing shared memory efficiently
- Handling matrix boundaries

The key insight is understanding how to break down large matrix operations into smaller, manageable pieces that fit in shared memory.

Configuration:
- Matrix size: \\(\\text{SIZE} = 8\\) elements
- Threads per block: \\(\\text{TPB} \\times \\text{TPB} = 3 \\times 3\\)
- Grid dimensions: \\(3 \\times 3\\) blocks
- Shared memory: Two \\(\\text{TPB} \\times \\text{TPB}\\) arrays per block

Block layout:
```txt
Grid (3×3 blocks):        Each block (3×3 threads):
[B00][B01][B02]          [T00 T01 T02]
[B10][B11][B12]          [T10 T11 T12]
[B20][B21][B22]          [T20 T21 T22]
```

## Code to complete

```mojo
{{#include ../../../problems/p14/p14.mojo:matmul_tiled}}
```
<a href="../../../problems/p14/p14.mojo" class="filename">View full file: problems/p14/p14.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Calculate elements per block: `size / BLOCKS_PER_GRID`
2. Clear shared memory before loading tiles
3. Load tiles with proper bounds checking
4. Accumulate partial results across tiles
</div>
</details>

## Running the code

To test your solution, run the following command in your terminal:

```bash
magic run p14 --tiled
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([1.0, 3.0, 3.0, 13.0])
```

## Solution

<details>
<summary>Click to see the solution</summary>

```mojo
{{#include ../../../solutions/p14/p14.mojo:matmul_tiled_solution}}
```

<div class="solution-explanation">

This solution implements tiled matrix multiplication in four phases:

1. Tile coordination:
   ```mojo
   elt_per_tiled_block_x = (size + BLOCKS_PER_GRID[0] - 1) // BLOCKS_PER_GRID[0]
   tile_i = elt_per_tiled_block_x * block_idx.x + thread_idx.x
   ```

2. Shared memory management:
   - Allocate two TPB×TPB buffers
   - Clear buffers before each tile: `a_shared[local_i * TPB + local_j] = 0`
   - Synchronize with `barrier()`

3. Tile processing loop:
   ```mojo
   for tile in range((size + TPB - 1) // TPB):
   ```
   - Load tile data with bounds checking
   - Compute partial results
   - Synchronize between operations

4. Result accumulation:
   - Track running sum in `tile_sum`
   - Handle boundary conditions
   - Write final result to global memory

Key features:
- Handles arbitrary matrix sizes
- Processes matrix in TPB×TPB tiles
- Maintains proper synchronization
- Checks bounds at matrix edges
</div>
</details>

## Block and Tile Layout Example

```txt
Matrix Layout (8×8 with 3×3 blocks):
[B00][B01][B02]  Each Bij is a block
[B10][B11][B12]  Each block processes
[B20][B21][B22]  multiple tiles

Block Thread Layout (3×3):
[T00 T01 T02]    Each thread handles
[T10 T11 T12]    multiple elements
[T20 T21 T22]    across tiles

Tile Processing:
1. Load tile from A and B into shared memory
2. Compute partial products
3. Move to next tile
4. Accumulate results
```

Note: This version can handle matrices of any size and provides better performance through efficient use of shared memory and tiling.
