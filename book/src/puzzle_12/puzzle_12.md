# Puzzle 12: Prefix Sum

Implement a kernel that computes a running sum / prefix-sum over `a` and stores it in `out`.
If the size of `a` is greater than the block size, only store the sum of each block.

## Visual Representation

![Prefix Sum visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_58_1.svg)

## Key Concepts

In this puzzle, you'll learn about:
- Implementing parallel prefix sum (scan) operations
- Using shared memory for efficient parallel computation
- Understanding parallel algorithms with logarithmic complexity

The key insight is implementing the parallel prefix sum algorithm, which consists of two phases:

* an up-sweep phase that builds a sum tree, and
* a down-sweep phase that builds the final prefix sum.

For example, with:

- Array size: 8 elements
- Threads per block: 8
- Number of blocks: 1
- Shared memory: 8 elements

- **Parallel Prefix Sum**: Computing cumulative sums efficiently
- **Up-sweep Phase**: Building a sum tree in shared memory
- **Down-sweep Phase**: Generating final prefix sums
- **Thread Synchronization**: Coordinating threads between phases
- **Shared Memory**: Using block-local storage for intermediate results

## Algorithm Explanation

We will use the [parallel prefix sum](https://en.wikipedia.org/wiki/Prefix_sum) algorithm in shared memory.
That is, each step of the algorithm should sum together half the remaining numbers.
Follow this diagram:

![Prefix Sum Algorithm](https://user-images.githubusercontent.com/35882/178757889-1c269623-93af-4a2e-a7e9-22cd55a42e38.png)

## Part 1: Simple Case (Single Block)

In this part, we'll implement a prefix sum within a single block where the array size equals the block size.

For example, with:
- Array size: 8 elements
- Threads per block: 8
- Number of blocks: 1
- Shared memory: 8 elements
- All threads participate in the computation

<details>
<summary><strong>Tips for Simple Case</strong></summary>

<div class="solution-tips">

1. Load input array into shared memory (one element per thread)
2. Implement the up-sweep phase:
   - Start with `stride = 1`, double each step
   - Each thread with `index < (blockSize - stride)` participates
   - Sum pairs of elements: `shared[i] += shared[i + stride]`
3. Implement the down-sweep phase:
   - Start with `stride = blockSize / 2`, halve each step
   - Each thread with `index < stride` participates
   - Swap and accumulate:
        - `temp = shared[i], shared[i] = shared[i + stride]`,
        - `shared[i + stride] += temp`
4. Write final results to global memory (one element per thread)
5. Remember to call `barrier()` between each step
</div>
</details>

### Code to Complete

```mojo
{{#include ../../../problems/p12/p12.mojo:prefix_sum_simple}}
```
<a href="../../../problems/p12/p12.mojo" class="filename">View full file: problems/p12/p12.mojo</a>

## Running the Code

To test your solution, run the following command in your terminal:

```bash
magic run p12 --simple
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: DeviceBuffer([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([0.0, 1.0, 3.0, 6.0, 10.0, 15.0, 21.0, 28.0])
```

### Solution

<details>
<summary>Click to see the solution</summary>

```mojo
{{#include ../../../solutions/p12/p12.mojo:prefix_sum_simple_solution}}
```

<div class="solution-explanation">

This solution:
- Loads input array into shared memory
- Implements up-sweep phase with logarithmic steps
- Implements down-sweep phase with logarithmic steps
- Synchronizes threads between operations
- Writes final prefix sums to global memory
</div>
</details>

## Part 2: Complete Case (Multiple Blocks)

In this part, we'll handle arrays larger than the block size. Each block computes its local prefix sum and stores its total sum for later use.

For example, with:
- Array size: 15 elements
- Threads per block: 8
- Number of blocks: 2
- Shared memory: 8 elements per block
- Last block handles fewer elements (7 elements)

Key differences from simple case:
- Multiple blocks process different segments of the array
- Need to handle partial blocks (last block may not be full)
- Each block stores its total sum for later use
- Global memory writes are more complex

<details>
<summary><strong>Tips for Complete Case</strong></summary>

<div class="solution-tips">
1. Calculate your block's section of the input array:

   - Start `index = block_idx.x * block_dim.x`
   - End `index = min(start_index + block_dim.x, size)`

2. Load input array into shared memory:
   - Only load if your thread's global index < size
   - Handle partial blocks (last block may not be full)

3. Implement the up-sweep phase within your block:
   - Similar to simple case but only up to valid elements
   - Keep track of the last valid element in your block

4. Implement the down-sweep phase within your block:
   - Similar to simple case but only up to valid elements
   - Ensure partial blocks are handled correctly

5. Write results to global memory:
   - Store local prefix sums for your block's section
   - Last valid thread in block stores total block sum
   - Only write if your global index is valid

6. Remember to:
   - Call `barrier()` between phases
   - Check thread indices against both block size and global size
   - Handle edge cases in the last block
</div>
</details>

### Code to Complete

```mojo
{{#include ../../../problems/p12/p12.mojo:prefix_sum_complete}}
```
<a href="../../../problems/p12/p12.mojo" class="filename">View full file: problems/p12/p12.mojo</a>

### Running the Code

To test your solution, run the following command in your terminal:

```bash
magic run p12 --complete
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: DeviceBuffer([0.0, 1.0, 3.0, 6.0, 10.0, 15.0, 21.0, 28.0])
expected: HostBuffer([0.0, 1.0, 3.0, 6.0, 10.0, 15.0, 21.0, 28.0])
```

### Solution

<details>
<summary>Click to see the solution</summary>

```mojo
{{#include ../../../solutions/p12/p12.mojo:prefix_sum_complete_solution}}
```

<div class="solution-explanation">

This solution:
- Loads input array into shared memory for each block
- Implements up-sweep phase with logarithmic steps within block
- Implements down-sweep phase with logarithmic steps within block
- Handles partial blocks correctly
- Stores local prefix sums and block totals
- Synchronizes threads between operations
- Writes final results to global memory

</div>
</details>
