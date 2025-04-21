# Tiled Matrix Multiplication

Implement a kernel that multiplies square matrices `a` and `b` and stores the result in `out`, using tiled matrix multiplication with shared memory. This version handles matrices larger than a single thread block by processing tiles.

## Visual Representation

![Matrix Multiply Tiled](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_67_1.svg)

## Key Concepts

In this puzzle, you'll learn about:

- Tiled matrix multiplication algorithm
- Handling large matrices with multiple blocks
- Efficient shared memory usage with tiles
- Block coordination for partial results

The key insight is breaking the computation into tiles that fit in shared memory, where each block computes a portion of the output matrix by loading and processing tiles sequentially.

For example, with:

- Matrix size: 8×8 elements
- Threads per block: 3×3 (TPB×TPB)
- Number of blocks: 3×3
- Shared memory: Two TPB×TPB buffers per block
- Each block processes multiple tiles

- **Tiling Strategy**: Breaking matrices into manageable chunks
- **Block Grid**: Multiple blocks covering output matrix
- **Partial Products**: Accumulating results across tiles
- **Memory Efficiency**: Reusing shared memory for tiles

## Code to Complete

```mojo
{{#include ../../../problems/p14/p14.mojo:matmul_tiled}}
```
<a href="../../../problems/p14/p14.mojo" class="filename">View full file: problems/p14/p14.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Calculate tile indices and sizes:
   - Elements per `block = (size + BLOCKS_PER_GRID - 1) // BLOCKS_PER_GRID`
   - Tile coordinates = `block_idx * elements_per_block + thread_idx`

2. For each tile:
   - Clear shared memory
   - Load tile from matrix A: `a[tile_i * size + (tile * TPB + local_j)]`
   - Load tile from matrix B: `b[(tile * TPB + local_i) + tile_j * size]`
   - Synchronize with `barrier()`
   - Compute partial dot products for this tile
   - Synchronize before next tile

3. Remember:
   - Handle boundary conditions for all dimensions
   - Accumulate results across tiles
   - Use `barrier()` between tile operations
   - Check indices against matrix size
</div>
</details>

## Running the Code

To test your solution, run the following command in your terminal:

```bash
magic run p14 --tiled
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0, 0, 0, 00])
expected: HostBuffer([1.0, 3.0, 3.0, 13.0])
```

## Solution

<details>
<summary>Click to see the solution</summary>

```mojo
{{#include ../../../solutions/p14/p14.mojo:matmul_tiled_solution}}
```

<div class="solution-explanation">

This solution:
- Calculates elements per block for tiling
- Determines tile coordinates for each thread
- For each tile:
  - Clears shared memory buffers
  - Loads tile portions from matrices A and B
  - Synchronizes threads after loading
  - Computes partial dot products
  - Accumulates results across tiles
- Handles boundary conditions:
  - Partial tiles at matrix edges
  - Thread indices beyond matrix size
  - Tile size adjustments
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
