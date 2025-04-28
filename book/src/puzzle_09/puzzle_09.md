# Puzzle 9: Pooling

## Overview
Implement a kernel that sums together the last 3 positions of vector `a` and stores it in vector `out`.

**Note:** _You have 1 thread per position. You only need 1 global read and 1 global write per thread._

![Pooling visualization](./media/videos/720p30/puzzle_09_viz.gif)

## Key concepts

In this puzzle, you'll learn about:
- Using shared memory for sliding window operations
- Handling boundary conditions in pooling
- Coordinating thread access to neighboring elements

The key insight is understanding how to efficiently access a window of elements using shared memory, with special handling for the first elements in the sequence.

## Configuration
- Array size: `SIZE = 8` elements
- Threads per block: `TPB = 8`
- Window size: 3 elements
- Shared memory: `TPB` elements

Notes:

- **Window access**: Each output depends on up to 3 previous elements
- **Edge handling**: First two positions need special treatment
- **Memory pattern**: One shared memory load per thread
- **Thread sync**: Coordination before window operations

## Code to complete

```mojo
{{#include ../../../problems/p09/p09.mojo:pooling}}
```
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p09/p09.mojo" class="filename">View full file: problems/p09/p09.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Load data and call `barrier()`
2. Special cases: `out[0] = shared[0]`, `out[1] = shared[0] + shared[1]`
3. General case: `if 1 < global_i < size`
4. Sum three elements: `shared[local_i - 2] + shared[local_i - 1] + shared[local_i]`
</div>
</details>

## Running the code

To test your solution, run the following command in your terminal:

```bash
magic run p09
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([0.0, 1.0, 3.0, 6.0, 9.0, 12.0, 15.0, 18.0])
```

## Solution

<details class="solution-details">
<summary></summary>

```mojo
{{#include ../../../solutions/p09/p09.mojo:pooling_solution}}
```

<div class="solution-explanation">

The solution implements a sliding window sum using shared memory with these key steps:

1. **Shared Memory Setup**:
   - Allocates `TPB` elements in shared memory
   - Each thread loads one element from global memory
   - Uses `barrier()` to ensure all data is loaded

2. **Boundary Cases**:
   - Position 0: `out[0] = shared[0]` (only first element)
   - Position 1: `out[1] = shared[0] + shared[1]` (sum of first two elements)

3. **Main Window Operation**:
   - For positions 2 and beyond: `out[i] = shared[i-2] + shared[i-1] + shared[i]`
   - Uses local indices for shared memory access
   - Maintains coalesced memory access pattern

4. **Memory Access Pattern**:
   - One global read per thread into shared memory
   - One global write per thread from shared memory
   - Uses shared memory for efficient neighbor access
   - Avoids redundant global memory loads

This approach is efficient because:
- Minimizes global memory access
- Uses shared memory for fast neighbor lookups
- Handles boundary conditions without branching in the main case
- Maintains good memory coalescing
</div>
</details>
