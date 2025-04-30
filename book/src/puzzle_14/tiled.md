# Tiled Matrix Multiplication

## Overview

Implement a kernel that multiplies square matrices \\(A\\) and \\(\text{transpose}(A)\\) using tiled matrix multiplication with LayoutTensor. This approach handles large matrices by processing them in smaller chunks (tiles).

## Key concepts

- Matrix tiling with LayoutTensor for large-scale computation
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
- Input B: `Layout.row_major(SIZE_TILED, SIZE_TILED)` (transpose of A)
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

1. Load tile from matrix A into shared memory using LayoutTensor indexing
2. Load corresponding tile from matrix B into shared memory
3. Compute partial products using shared memory
4. Accumulate results in registers
5. Move to next tile
6. Repeat until all tiles are processed

### Memory access pattern
```txt
For each tile using LayoutTensor:
  Input Tiles:                Output Computation:
    A[i:i+TPB, k:k+TPB]   ×    Result tile
    B[k:k+TPB, j:j+TPB]   →    C[i:i+TPB, j:j+TPB]
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

## Solution

<details class="solution-details">
<summary></summary>

```mojo
{{#include ../../../solutions/p14/p14.mojo:matmul_tiled_solution}}
```



<div class="solution-explanation">

The tiled implementation with LayoutTensor handles large matrices efficiently by processing them in blocks. Here's a comprehensive analysis:

### Implementation Architecture

1. **Layout Configuration**:
   ```mojo
   alias layout_tiled = Layout.row_major(SIZE_TILED, SIZE_TILED)
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

3. **Thread and Block Organization**:
   ```mojo
   local_row = thread_idx.x
   local_col = thread_idx.y
   global_row = block_idx.x * TPB + local_row
   global_col = block_idx.y * TPB + local_col
   ```
   - Maps threads to matrix elements
   - Handles 2D indexing efficiently
   - Maintains proper boundary checks

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
   if local_row < TPB and local_col < TPB:
       a_shared[local_row, local_col] = 0
       b_shared[local_row, local_col] = 0
   ```
   - Clears previous tile data
   - Ensures clean state for new tile
   - Prevents data corruption

3. **Tile Loading**:
   ```mojo
   # Load A tile
   if global_row < size and (tile * TPB + local_col) < size:
       a_shared[local_row, local_col] = a[global_row, tile * TPB + local_col]

   # Load B tile
   if (tile * TPB + local_row) < size and global_col < size:
       b_shared[local_row, local_col] = b[tile * TPB + local_row, global_col]
   ```
   - Handles boundary conditions
   - Uses LayoutTensor indexing
   - Maintains memory coalescing

4. **Computation**:
   ```mojo
   @parameter
   for k in range(min(TPB, size - tile * TPB)):
       acc += a_shared[local_row, k] * b_shared[k, local_col]
   ```
   - Processes current tile
   - Uses shared memory for efficiency
   - Handles partial tiles correctly

### Memory Access Optimization

1. **Global Memory Pattern**:
   ```txt
   A[global_row, tile * TPB + local_col] → Coalesced reads
   B[tile * TPB + local_row, global_col] → Transposed access
   ```
   - Maximizes memory coalescing
   - Minimizes bank conflicts
   - Efficient for transposed access

2. **Shared Memory Usage**:
   ```txt
   a_shared[local_row, k] → Row-wise access
   b_shared[k, local_col] → Column-wise access
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
   if global_row < size and global_col < size:
       out[global_row, global_col] = acc
   ```
   - Prevents out-of-bounds access
   - Handles matrix edges
   - Safe result writing

### Performance Characteristics

1. **Memory Efficiency**:
   - Reduced global memory traffic through tiling
   - Efficient shared memory reuse
   - Coalesced memory access patterns

2. **Computational Throughput**:
   - High data locality in shared memory
   - Efficient thread utilization
   - Minimal thread divergence

3. **Scalability**:
   - Handles arbitrary matrix sizes
   - Efficient for large matrices
   - Good thread occupancy

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
