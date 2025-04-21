## Complete case

![Prefix Sum visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_61_1.svg)

Configuration:
- Array size: \\(\\text{SIZE} = 15\\) elements
- Threads per block: \\(\\text{TPB} = 8\\)
- Number of blocks: \\(2\\)
- Shared memory: \\(\\text{TPB}\\) elements per block

- **Block handling**: Multiple blocks process array segments
- **Partial blocks**: Last block may not be full
- **Block sums**: Store running totals between blocks
- **Global result**: Combine local and block sums

### Code to complete

```mojo
{{#include ../../../problems/p12/p12.mojo:prefix_sum_complete}}
```
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p12/p12.mojo" class="filename">View full file: problems/p12/p12.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Compute local prefix sums like in [Simple Version](./simple.md)
2. Last thread stores block sum at `TPB * (block_idx.x + 1)`
3. Add previous block's sum to current block
4. Handle array bounds for all operations
</div>
</details>

### Running the code

To test your solution, run the following command in your terminal:

```bash
magic run p12 --complete
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: DeviceBuffer([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([0.0, 1.0, 3.0, 6.0, 10.0, 15.0, 21.0, 28.0])
```

## Solution

<details>
<summary>Click to see the solution</summary>

```mojo
{{#include ../../../solutions/p12/p12.mojo:prefix_sum_complete_solution}}
```

<div class="solution-explanation">
This solution handles multi-block prefix sum in three main phases:

1. Local prefix sum (per block):
   ```
   Block 0 (8 elements):    [0,1,2,3,4,5,6,7]
   After local prefix sum:  [0,1,3,7,10,16,21,28]

   Block 1 (7 elements):    [8,9,10,11,12,13,14]
   After local prefix sum:  [8,17,27,38,50,63,77]
   ```

2. Block sum communication:
   - Last thread (local_i == TPB-1) in each non-final block
   - Stores its block's sum at next block's start:

   ```mojo
   if local_i == TPB - 1 and block_idx.x < size // TPB - 1:
       out[TPB * (block_idx.x + 1)] = shared[local_i]
   ```

   - Block 0's sum (28) stored at position 8
   - Memory layout: `[0,1,3,7,10,16,21,28 | 28,17,27,38,50,63,77]`
                                          ↑
                                     Block 0's sum

3. Final adjustment:
   - Each block after first adds previous block's sum

   ```mojo
   if block_idx.x > 0 and global_i < size:
       shared[local_i] += out[block_idx.x * TPB - 1]
   ```
   - Block 1: Each element += 28
   - Final result: `[0,1,3,7,10,16,21,28, 36,45,55,66,78,91,105]`

Key implementation details:
- Uses `barrier()` after shared memory operations
- Handles partial blocks (last block size < TPB)
- Guards all operations with proper bounds checking
- Maintains correct thread and block synchronization
- Achieves \\(O(\log n)\\) complexity per block

The solution scales to arbitrary-sized inputs by combining local prefix sums with efficient block-to-block communication.
</div>
</details>
