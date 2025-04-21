# Tiled matrix multiplication

Implement a kernel that multiplies square matrices `a` and `b` and stores the result in `out`, using tiled matrix multiplication with shared memory. This version handles matrices larger than a single thread block by processing tiles.

<div class="solution-tips">
Update your [shared memory code](./shared_memory.md) to compute a partial dot-product and iteratively move the part you copied into shared memory. You should be able to do the hard case in 6 global reads.
</div>

## Key concepts

In this puzzle, you'll learn about:
- Processing large matrices in smaller chunks
- Coordinating multiple thread blocks
- Managing shared memory efficiently
- Handling matrix boundaries

The key insight is understanding how to break down matrix operations into tiles that can be processed efficiently in shared memory while maintaining correct synchronization.

Configuration:
- Matrix size: \(SIZE\_TILED = 8\) elements
- Threads per block: \(TPB \times TPB = 3 \times 3\)
- Grid dimensions: \(3 \times 3\) blocks
- Shared memory: Two \(TPB \times TPB\) arrays per block

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
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p14/p14.mojo" class="filename">View full file: problems/p14/p14.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Calculate global thread positions from block and thread indices
2. Clear shared memory before loading new tiles
3. Load tiles with proper bounds checking
4. Accumulate results across tiles with proper synchronization
</div>
</details>

## Solution

<details>
<summary>Click to see the solution</summary>

```mojo
{{#include ../../../solutions/p14/p14.mojo:matmul_tiled_solution}}
```

## Running the code

To test your solution, run the following command in your terminal:

```bash
magic run p14 --tiled
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([140.0, 364.0, 588.0, 812.0, 1036.0, 1260.0, 1484.0, 1708.0, 364.0, 1100.0, 1836.0, 2572.0, 3308.0, 4044.0, 4780.0, 5516.0, 588.0, 1836.0, 3084.0, 4332.0, 5580.0, 6828.0, 8076.0, 9324.0, 812.0, 2572.0, 4332.0, 6092.0, 7852.0, 9612.0, 11372.0, 13132.0, 1036.0, 3308.0, 5580.0, 7852.0, 10124.0, 12396.0, 14668.0, 16940.0, 1260.0, 4044.0, 6828.0, 9612.0, 12396.0, 15180.0, 17964.0, 20748.0, 1484.0, 4780.0, 8076.0, 11372.0, 14668.0, 17964.0, 21260.0, 24556.0, 1708.0, 5516.0, 9324.0, 13132.0, 16940.0, 20748.0, 24556.0, 28364.0])
```

<div class="solution-explanation">

The solution implements tiled matrix multiplication by breaking down the computation into manageable chunks:

1. Thread organization:
   ```mojo
   global_row = block_idx.x * TPB + thread_idx.x
   global_col = block_idx.y * TPB + thread_idx.y
   ```
   Each thread knows its global position in the output matrix.

2. Shared memory management:
   - Two TPB×TPB buffers (`a_shared` and `b_shared`)
   - Clear buffers before each tile load
   - Use barriers to ensure memory coherency

3. Tile processing:
   ```mojo
   for tile in range((size + TPB - 1) // TPB):
   ```
   - Load a tile from matrix A and corresponding elements from B
   - Compute partial dot products within the tile
   - Accumulate results in local variable

4. Memory access pattern:
   - Matrix A: `global_row * size + (tile * TPB + local_col)`
   - Matrix B: `(tile * TPB + local_row) + global_col * size`
   - Shared memory: `local_row * TPB + local_col`

Key optimizations:
- Minimizes global memory accesses
- Uses shared memory for frequently accessed data
- Proper synchronization between load and compute phases
- Handles matrix boundaries correctly
</div>
</details>

## Block and tile layout

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
