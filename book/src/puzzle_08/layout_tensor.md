## Key concepts

In this puzzle, you'll learn about:
- Using LayoutTensor's shared memory features
- Thread synchronization with shared memory
- Block-local data management with tensor builder

The key insight is how LayoutTensor simplifies shared memory management while maintaining the performance benefits of block-local storage.

## Configuration

- Array size: `SIZE = 8` elements
- Threads per block: `TPB = 4`
- Number of blocks: 2
- Shared memory: `TPB` elements per block

## Key differences from raw approach

1. **Memory allocation**: We will use [LayoutTensorBuild](https://docs.modular.com/mojo/stdlib/layout/tensor_builder/LayoutTensorBuild) instead of [stack_allocation](https://docs.modular.com/mojo/stdlib/memory/memory/stack_allocation/)

   ```mojo
   # Raw approach
   shared = stack_allocation[TPB * sizeof[dtype](), ...]()

   # LayoutTensor approach
   shared = LayoutTensorBuild[dtype]().row_major[TPB]().shared().alloc()
   ```

2. **Memory access**: Same syntax

   ```mojo
   # Raw approach
   shared[local_i] = a[global_i]

   # LayoutTensor approach
   shared[local_i] = a[global_i]
   ```

3. **Safety features**:

   - Type safety
   - Layout management
   - Memory alignment handling

> **Note**: LayoutTensor handles memory layout, but you still need to manage thread synchronization with `barrier()` when using shared memory.

## Code to complete

```mojo
{{#include ../../../problems/p08/p08_layout_tensor.mojo:add_10_shared_layout_tensor}}
```
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p08/p08_layout_tensor.mojo" class="filename">View full file: problems/p08/p08_layout_tensor.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Create shared memory with tensor builder
2. Load data with natural indexing: `shared[local_i] = a[global_i]`
3. Synchronize with `barrier()`
4. Process data using shared memory indices
5. Guard against out-of-bounds access
</div>
</details>

## Running the code

To test your solution, run the following command in your terminal:

```bash
magic run p08_layout_tensor
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0])
```


## Solution

<details class="solution-details">
<summary></summary>

```mojo
{{#include ../../../solutions/p08/p08_layout_tensor.mojo:add_10_shared_layout_tensor_solution}}
```

<div class="solution-explanation">

This solution:
- Creates shared memory using tensor builder's fluent API
- Guards against out-of-bounds with `if global_i < size`
- Uses natural indexing for both shared and global memory
- Ensures thread synchronization with `barrier()`
- Leverages LayoutTensor's built-in safety features

Key steps:
1. Allocate shared memory with proper layout
2. Load global data into shared memory
3. Synchronize threads
4. Process data using shared memory
5. Write results back to global memory
</div>
</details>
