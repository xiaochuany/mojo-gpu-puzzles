# Simple Version: Single Block

## Key concepts

In this puzzle, you'll learn about:
- Implementing sliding window operations on GPUs
- Managing data dependencies across threads
- Using shared memory for overlapping regions

The key insight is understanding how to efficiently access overlapping elements while maintaining correct boundary conditions.

## Configuration
- Input array size: `SIZE = 6` elements
- Kernel size: `CONV = 3` elements
- Threads per block: `TPB = 8`
- Number of blocks: 1
- Shared memory: Two arrays of size `SIZE` and `CONV`

Notes:
- **Data loading**: Each thread loads one element from input and kernel
- **Memory pattern**: Shared arrays for input and convolution kernel
- **Thread sync**: Coordination before computation

## Code to complete

```mojo
{{#include ../../../problems/p11/p11.mojo:conv_1d_simple}}
```
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p11/p11.mojo" class="filename">View full file: problems/p11/p11.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Load input to `shared_a[local_i]` and kernel to `shared_b[local_i]`
2. Call `barrier()` after loading
3. Sum products within bounds: `if local_i + j < SIZE`
4. Write result if `global_i < a_size`
</div>
</details>

### Running the code

To test your solution, run the following command in your terminal:

```bash
magic run p11 --simple
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([5.0, 8.0, 11.0, 14.0, 5.0, 0.0])
```

## Solution

<details class="solution-details">
<summary></summary>

```mojo
{{#include ../../../solutions/p11/p11.mojo:conv_1d_simple_solution}}
```

<div class="solution-explanation">

The solution implements a 1D convolution using shared memory for efficient access to overlapping elements. Here's a detailed breakdown:

### Memory Layout
```txt
Input array a:   [0  1  2  3  4  5]
Kernel b:        [0  1  2]
```

### Computation Steps

1. **Data Loading**:
   ```txt
   shared_a: [0  1  2  3  4  5]  // Input array
   shared_b: [0  1  2]           // Convolution kernel
   ```

2. **Convolution Process** for each position i:
   ```txt
   out[0] = a[0]*b[0] + a[1]*b[1] + a[2]*b[2] = 0*0 + 1*1 + 2*2 = 5
   out[1] = a[1]*b[0] + a[2]*b[1] + a[3]*b[2] = 1*0 + 2*1 + 3*2 = 8
   out[2] = a[2]*b[0] + a[3]*b[1] + a[4]*b[2] = 2*0 + 3*1 + 4*2 = 11
   out[3] = a[3]*b[0] + a[4]*b[1] + a[5]*b[2] = 3*0 + 4*1 + 5*2 = 14
   out[4] = a[4]*b[0] + a[5]*b[1] + 0*b[2]    = 4*0 + 5*1 + 0*2 = 5
   out[5] = a[5]*b[0] + 0*b[1]   + 0*b[2]     = 5*0 + 0*1 + 0*2 = 0
   ```

### Key Implementation Features:

1. **Memory Management**:
   - Uses shared memory for both input array and kernel
   - Single load per thread from global memory
   - Efficient reuse of loaded data

2. **Boundary Handling**:
   - Checks `if local_i + j < SIZE` for valid access
   - Implicitly handles zero-padding at boundaries
   - Prevents out-of-bounds memory access

3. **Thread Coordination**:
   - `barrier()` ensures all data is loaded before computation
   - Each thread computes one output element
   - Maintains coalesced memory access pattern

4. **Performance Optimizations**:
   - Minimizes global memory access
   - Uses shared memory for fast data access
   - Avoids thread divergence in main computation loop
</div>
</details>
