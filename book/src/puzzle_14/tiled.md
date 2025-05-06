# Tiled Matrix Multiplication

## Overview

Implement a kernel that multiplies square matrices \\(A\\) and \\(B\\) using tiled matrix multiplication with LayoutTensor. This approach handles large matrices by processing them in smaller chunks (tiles).

## Key concepts

- Matrix tiling with LayoutTensor for efficient computation
- Multi-block coordination with proper layouts
- Efficient shared memory usage through TensorBuilder
- Boundary handling for tiles with LayoutTensor indexing

## Configuration

- Matrix size: \\(\\text{SIZE\_TILED} = 8\\)
- Threads per block: \\(\\text{TPB} \times \\text{TPB} = 3 \times 3\\)
- Grid dimensions: \\(3 \times 3\\) blocks
- Shared memory: Two \\(\\text{TPB} \times \\text{TPB}\\) LayoutTensors per block

Layout configuration:
- Input A: `Layout.row_major(SIZE_TILED, SIZE_TILED)`
- Input B: `Layout.row_major(SIZE_TILED, SIZE_TILED)`
- Output: `Layout.row_major(SIZE_TILED, SIZE_TILED)`
- Shared Memory: Two `TPB × TPB` LayoutTensors using TensorBuilder

## Tiling strategy

### Block organization
```txt
Grid Layout (3×3):           Thread Layout per Block (3×3):
[B00][B01][B02]               [T00 T01 T02]
[B10][B11][B12]               [T10 T11 T12]
[B20][B21][B22]               [T20 T21 T22]

Each block processes a tile using LayoutTensor indexing
```

### Tile processing steps

1. Calculate global and local indices for thread position
2. Allocate shared memory for A and B tiles
3. For each tile:
   - Reset shared memory
   - Load tile from matrix A and B
   - Compute partial products
   - Accumulate results in registers
4. Write final accumulated result

### Memory access pattern
```txt
For each tile:
  Input Tiles:                Output Computation:
    A[global_i, tile*TPB + j] ×    Result accumulator
    B[tile*TPB + i, global_j] →    C[global_i, global_j]
```

## Code to complete

```mojo
{{#include ../../../problems/p14/p14.mojo:matmul_tiled}}
```
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p14/p14.mojo" class="filename">View full file: problems/p14/p14.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Calculate global thread positions from block and thread indices correctly
2. Clear shared memory before loading new tiles
3. Load tiles with proper bounds checking
4. Accumulate results across tiles with proper synchronization
</div>
</details>

## Running the code

To test your solution, run the following command in your terminal:

```bash
magic run p14 --tiled
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([2240.0, 2296.0, 2352.0, 2408.0, 2464.0, 2520.0, 2576.0, 2632.0, 5824.0, 6008.0, 6192.0, 6376.0, 6560.0, 6744.0, 6928.0, 7112.0, 9408.0, 9720.0, 10032.0, 10344.0, 10656.0, 10968.0, 11280.0, 11592.0, 12992.0, 13432.0, 13872.0, 14312.0, 14752.0, 15192.0, 15632.0, 16072.0, 16576.0, 17144.0, 17712.0, 18280.0, 18848.0, 19416.0, 19984.0, 20552.0, 20160.0, 20856.0, 21552.0, 22248.0, 22944.0, 23640.0, 24336.0, 25032.0, 23744.0, 24568.0, 25392.0, 26216.0, 27040.0, 27864.0, 28688.0, 29512.0, 27328.0, 28280.0, 29232.0, 30184.0, 31136.0, 32088.0, 33040.0, 33992.0])
```

## Solution

<details class="solution-details">
<summary></summary>

```mojo
{{#include ../../../solutions/p14/p14.mojo:matmul_tiled_solution}}
```

<div class="solution-explanation">

The tiled implementation with LayoutTensor handles matrices efficiently by processing them in blocks. Here's a comprehensive analysis:

### Implementation Architecture

1. **Thread and Block Organization**:
   ```mojo
   local_i = thread_idx.x
   local_j = thread_idx.y
   global_i = block_idx.x * TPB + local_i
   global_j = block_idx.y * TPB + local_j
   ```
   - Defines row-major layout for all tensors
   - Ensures consistent memory access patterns
   - Enables efficient 2D indexing

2. **Shared Memory Setup**:
   ```mojo
   a_shared = tb[dtype]().row_major[TPB, TPB]().shared().alloc()
   b_shared = tb[dtype]().row_major[TPB, TPB]().shared().alloc()
   ```
   - Uses TensorBuilder for structured allocation
   - Maintains row-major layout for consistency
   - Enables efficient tile processing

### Tile Processing Pipeline

1. **Tile Iteration**:
   ```mojo
   @parameter
   for tile in range((size + TPB - 1) // TPB):
   ```
   - Compile-time unrolled loop
   - Handles matrix size not divisible by TPB
   - Processes matrix in TPB×TPB tiles

2. **Shared Memory Reset**:
   ```mojo
   if local_i < TPB and local_j < TPB:
       a_shared[local_i, local_j] = 0
       b_shared[local_i, local_j] = 0
   ```
   - Clears previous tile data
   - Ensures clean state for new tile
   - Prevents data corruption

3. **Tile Loading**:
   ```mojo
   # Load A tile - global row stays the same, col determined by tile
   if global_i < size and (tile * TPB + local_j) < size:
       a_shared[local_i, local_j] = a[global_i, tile * TPB + local_j]

   # Load B tile - row determined by tile, global col stays the same
   if (tile * TPB + local_i) < size and global_j < size:
       b_shared[local_i, local_j] = b[tile * TPB + local_i, global_j]
   ```
   - Handles boundary conditions
   - Uses LayoutTensor indexing
   - Maintains memory coalescing

4. **Computation**:
   ```mojo
   @parameter
   for k in range(min(TPB, size - tile * TPB)):
       acc += a_shared[local_i, k] * b_shared[k, local_j]
   ```
   - Processes current tile
   - Uses shared memory for efficiency
   - Handles partial tiles correctly

### Memory Access Optimization

1. **Global Memory Pattern**:
   ```txt
   A[global_i, tile * TPB + local_j] → Row-major access
   B[tile * TPB + local_i, global_j] → Row-major access
   ```
   - Maximizes memory coalescing:
     ```txt
     Coalesced Access (Good):          Non-Coalesced Access (Bad):
     Thread0: [M0][M1][M2][M3]         Thread0: [M0][ ][ ][ ]
     Thread1: [M4][M5][M6][M7]    vs   Thread1: [ ][M1][ ][ ]
     Thread2: [M8][M9][MA][MB]         Thread2: [ ][ ][M2][ ]
     Thread3: [MC][MD][ME][MF]         Thread3: [ ][ ][ ][M3]
     ↓                                 ↓
     1 memory transaction              4 memory transactions
     ```
     When threads access consecutive memory locations (left), the GPU can combine multiple reads into a single transaction.
     When threads access scattered locations (right), each access requires a separate transaction, reducing performance.

2. **Shared Memory Usage**:

   ```txt
   a_shared[local_i, k] → Row-wise access
   b_shared[k, local_j] → Row-wise access
   ```
   - Optimized for matrix multiplication
   - Reduces bank conflicts
   - Enables data reuse

### Synchronization and Safety

1. **Barrier Points**:
   ```mojo
   barrier()  # After shared memory reset
   barrier()  # After tile loading
   barrier()  # After computation
   ```
   - Ensures shared memory consistency
   - Prevents race conditions
   - Maintains thread cooperation

2. **Boundary Handling**:
   ```mojo
   if global_i < size and global_j < size:
       out[global_i, global_j] = acc
   ```
   - Prevents out-of-bounds access
   - Handles matrix edges
   - Safe result writing

### Key Optimizations

1. **Layout Optimization**:
   - Row-major layout for all tensors
   - Efficient 2D indexing
   - Proper alignment

2. **Memory Access**:
   - Coalesced global memory loads
   - Efficient shared memory usage
   - Minimal bank conflicts

3. **Computation**:
   - Register-based accumulation
   - Compile-time loop unrolling
   - Efficient tile processing

This implementation achieves high performance through:
- Efficient use of LayoutTensor for memory access
- Optimal tiling strategy
- Proper thread synchronization
- Careful boundary handling
</div>
</details>
