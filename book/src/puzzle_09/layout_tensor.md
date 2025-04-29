## Key concepts

In this puzzle, you'll learn about:

- Using LayoutTensor for sliding window operations
- Managing shared memory with `LayoutTensorBuilder` that we saw in [puzzle_08](../puzzle_08/layout_tensor.md)
- Efficient neighbor access patterns
- Boundary condition handling

The key insight is how LayoutTensor simplifies shared memory management while maintaining efficient window-based operations.

## Configuration
- Array size: `SIZE = 8` elements
- Threads per block: `TPB = 8`
- Window size: 3 elements
- Shared memory: `TPB` elements

Notes:
- **Tensor builder**: Use `LayoutTensorBuilder[dtype]().row_major[TPB]().shared().alloc()`
- **Window access**: Natural indexing for 3-element windows
- **Edge handling**: Special cases for first two positions
- **Memory pattern**: One shared memory load per thread

## Code to complete

```mojo
{{#include ../../../problems/p09/p09_layout_tensor.mojo:pooling_layout_tensor}}
```
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p09/p09_layout_tensor.mojo" class="filename">View full file: problems/p09/p09_layout_tensor.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Create shared memory with tensor builder
2. Load data with natural indexing: `shared[local_i] = a[global_i]`
3. Handle special cases for first two elements
4. Use shared memory for window operations
5. Guard against out-of-bounds access
</div>
</details>

## Running the code

To test your solution, run the following command in your terminal:

```bash
magic run p09_layout_tensor
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
{{#include ../../../solutions/p09/p09_layout_tensor.mojo:pooling_layout_tensor_solution}}
```

<div class="solution-explanation">

The solution implements a sliding window sum using LayoutTensor with these key steps:

1. **Shared Memory Setup**:
   - Uses tensor builder for clean shared memory allocation
   - Natural indexing for data loading
   - Thread synchronization with `barrier()`

2. **Boundary Cases**:
   - Position 0: Single element output
   - Position 1: Sum of first two elements
   - Clean indexing with LayoutTensor bounds checking

3. **Main Window Operation**:
   - Natural indexing for 3-element window
   - Safe access to neighboring elements
   - Automatic bounds checking

4. **Memory Access Pattern**:
   - Efficient shared memory usage
   - Type-safe operations
   - Layout-aware indexing
   - Automatic alignment handling

Benefits over raw approach:
- Cleaner shared memory allocation
- Safer memory access
- Natural indexing syntax
- Built-in bounds checking
- Layout management
</div>
</details>
