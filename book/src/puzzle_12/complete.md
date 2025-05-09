# Complete Version

Implement a kernel that computes a prefix-sum over 1D LayoutTensor `a` and stores it in 1D LayoutTensor `out`.

**Note:** _If the size of `a` is greater than the block size, we need to synchronize across multiple blocks to get the correct result._

## Configuration

- Array size: `SIZE_2 = 15` elements
- Threads per block: `TPB = 8`
- Number of blocks: 2
- Shared memory: `TPB` elements per block

Notes:

- **Multiple blocks**: When the input array is larger than one block, we need a multi-phase approach
- **Block-level sync**: Within a block, use `barrier()` to synchronize threads
- **Host-level sync**: Between blocks, use `ctx.synchronize()` at the host level
- **Auxiliary storage**: Use extra space to store block sums for cross-block communication

## Code to complete

You need to complete two separate kernel functions for the multi-block prefix sum:

1. **First kernel** (`prefix_sum_local_phase`): Computes local prefix sums within each block and stores block sums
2. **Second kernel** (`prefix_sum_block_sum_phase`): Adds previous block sums to elements in subsequent blocks

The main function will handle the necessary host-side synchronization between these kernels.

```mojo
{{#include ../../../problems/p12/p12.mojo:prefix_sum_complete}}
```
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p12/p12.mojo" class="filename">View full file: problems/p12/p12.mojo</a>

The key to this puzzle is understanding that [barrier](https://docs.modular.com/mojo/stdlib/gpu/sync/barrier/) only synchronizes threads within a block, not across blocks. For cross-block synchronization, you need to use host-level synchronization:

```mojo
{{#include ../../../solutions/p12/p12.mojo:prefix_sum_complete_block_level_sync}}
```

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

### 1. Build on the simple prefix sum

The [Simple Version](./simple.md) shows how to implement a single-block prefix sum. You'll need to extend that approach to work across multiple blocks:

```
Simple version (single block): [0,1,2,3,4,5,6,7] → [0,1,3,6,10,15,21,28]

Complete version (two blocks):
Block 0: [0,1,2,3,4,5,6,7] → [0,1,3,6,10,15,21,28]
Block 1: [8,9,10,11,12,13,14] → [8,17,27,38,50,63,77]
```

But how do we handle the second block's values? They need to include sums from the first block!

### 2. Two-phase approach

The simple prefix sum can't synchronize across blocks, so split the work:

1. **First phase**: Each block computes its own local prefix sum (just like the simple version)
2. **Second phase**: Blocks incorporate the sums from previous blocks

Remember: `barrier()` only synchronizes threads within one block. You need host-level synchronization between phases.

### 3. Extended memory strategy

Since blocks can't directly communicate, you need somewhere to store block sums:

- Allocate extra memory at the end of your output buffer
- Last thread in each block stores its final sum in this extra space
- Subsequent blocks can read these sums and add them to their elements

### 4. Key implementation insights

- **Different layouts**: Input and output may have different shapes
- **Boundary handling**: Always check `global_i < size` for array bounds
- **Thread role specialization**: Only specific threads (e.g., last thread) should store block sums
- **Two kernel synchronization**: Use `ctx.synchronize()` between kernel launches

### 5. Debugging Strategy

If you encounter issues, try visualizing the intermediate state after the first phase:
```
After first phase: [0,1,3,6,10,15,21,28, 8,17,27,38,50,63,77, ???,???]
```

Where `???` should contain your block sums that will be used in the second phase.

</div>
</details>

### Running the code

To test your solution, run the following command in your terminal:

```bash
magic run p12 --complete
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([0.0, 1.0, 3.0, 6.0, 10.0, 15.0, 21.0, 28.0, 36.0, 45.0, 55.0, 66.0, 78.0, 91.0, 105.0])
```

## Solution

<details class="solution-details">
<summary></summary>

```mojo
{{#include ../../../solutions/p12/p12.mojo:prefix_sum_complete_solution}}
```

<div class="solution-explanation">
This solution implements multi-block prefix sum using a two-kernel approach:

### Phase 1: Local Prefix Sums and Block Sum Storage
In the first kernel, each block computes its local prefix sum:

```
Block 0 (elements 0-7):   Initial: [0,1,2,3,4,5,6,7]
                          Result:  [0,1,3,6,10,15,21,28]

Block 1 (elements 8-14):  Initial: [8,9,10,11,12,13,14]
                          Result:  [8,17,27,38,50,63,77]
```

The computation progresses through log₂(TPB) iterations:
1. Offset=1: Each element adds previous element
2. Offset=2: Each element adds element two positions before
3. Offset=4: Each element adds element four positions before

After computing local sums, the last thread in each block stores its block's total at designated positions in an extended output buffer:
```
// Store block sums after the main array
if local_i == TPB - 1:
    out[size + block_idx.x] = shared[local_i]
```

This results in:
```
Output buffer: [0,1,3,6,10,15,21,28, 8,17,27,38,50,63,77, 28,77]
                                                           ↑  ↑
                                                Block sums stored here
```

### Host-level Synchronization
The critical insight is that we **cannot synchronize across blocks within a single kernel**. Instead:

```mojo
# Wait for all blocks to complete with host synchronization
ctx.synchronize()
```

This ensures all blocks in the first kernel have completed and all block sums are stored before we start the second kernel.

### Phase 2: Adding Block Sums
The second kernel adds each block's prefix sum to all elements in subsequent blocks:

```
Block 0: No changes (already correct)
Block 1: Each element adds Block 0's sum (28)
   Before: [8,17,27,38,50,63,77]
   After:  [36,45,55,66,78,91,105]
```

The final result combines both blocks:
```
[0,1,3,6,10,15,21,28, 36,45,55,66,78,91,105]
```

### Key Implementation Details
1. **Extended buffer**: We allocate extra space to store block sums
2. **Different layouts**: The input and output tensors have different layouts
3. **Two-phase approach**: Essential for correct cross-block communication
4. **Barrier usage**: Used within kernels for thread synchronization
5. **Host synchronization**: Used between kernels for block synchronization

This approach scales efficiently to arbitrary input sizes by properly handling block-to-block dependencies.
</div>
</details>
