# Puzzle 10: Dot Product

## Overview
Implement a kernel that computes the dot-product of vector `a` and vector `b` and stores it in `out`.

**Note:** _You have 1 thread per position. You only need 2 global reads and 1 global write per thread._

![Dot product visualization](./media/videos/720p30/puzzle_10_viz.gif)

## Key concepts

In this puzzle, you'll learn about:
- Implementing parallel reduction operations
- Using shared memory for intermediate results
- Coordinating threads for collective operations

The key insight is understanding how to efficiently combine multiple values into a single result using parallel computation and shared memory.

## Configuration

- Vector size: `SIZE = 8` elements
- Threads per block: `TPB = 8`
- Number of blocks: 1
- Output size: 1 element
- Shared memory: `TPB` elements

Notes:

- **Element access**: Each thread reads corresponding elements from `a` and `b`
- **Partial results**: Computing and storing intermediate values
- **Thread coordination**: Synchronizing before combining results
- **Final reduction**: Converting partial results to scalar output

*Note: For this problem, you don't need to worry about number of shared reads. We will
handle that challenge later.*

## Code to complete

```mojo
{{#include ../../../problems/p10/p10.mojo:dot_product}}
```
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p10/p10.mojo" class="filename">View full file: problems/p10/p10.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Store `a[global_i] * b[global_i]` in `shared[local_i]`
2. Call `barrier()` to synchronize
3. Use thread 0 to sum all products in shared memory
4. Write final sum to `out[0]`
</div>
</details>

## Running the code

To test your solution, run the following command in your terminal:

```bash
magic run p10
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0])
expected: HostBuffer([140.0])
```

## Solution

<details class="solution-details">
<summary></summary>

```mojo
{{#include ../../../solutions/p10/p10.mojo:dot_product_solution}}
```

<div class="solution-explanation">

The solution implements a parallel reduction algorithm for dot product computation using shared memory. Here's a detailed breakdown:

### Phase 1: Element-wise Multiplication

Each thread performs one multiplication:
```txt
Thread i: shared[i] = a[i] * b[i]
```

### Phase 2: Parallel Reduction
The reduction uses a tree-based approach that halves active threads in each step:

```txt
Initial:  [0*0  1*1  2*2  3*3  4*4  5*5  6*6  7*7]
        = [0    1    4    9    16   25   36   49]

Step 1:   [0+16 1+25 4+36 9+49  16   25   36   49]
        = [16   26   40   58   16   25   36   49]

Step 2:   [16+40 26+58 40   58   16   25   36   49]
        = [56   84   40   58   16   25   36   49]

Step 3:   [56+84  84   40   58   16   25   36   49]
        = [140   84   40   58   16   25   36   49]
```

### Key Implementation Features:

1. **Memory Access Pattern**:
   - Each thread loads exactly two values from global memory (`a[i]`, `b[i]`)
   - Uses shared memory for intermediate results
   - Final result written once to global memory

2. **Thread Synchronization**:
   - `barrier()` after initial multiplication
   - `barrier()` after each reduction step
   - Prevents race conditions between reduction steps

3. **Reduction Logic**:

   ```mojo
   stride = TPB // 2
   while stride > 0:
       if local_i < stride:
           shared[local_i] += shared[local_i + stride]
       barrier()
       stride //= 2
   ```
   - Halves stride in each step
   - Only active threads perform additions
   - Maintains work efficiency

4. **Performance Considerations**:
   - \\(\log_2(n)\\) steps for \\(n\\) elements
   - Coalesced memory access pattern
   - Minimal thread divergence
   - Efficient use of shared memory

This implementation achieves \\(O(\log n)\\) time complexity compared to \\(O(n)\\) in sequential execution, demonstrating the power of parallel reduction algorithms.
</div>
</details>
