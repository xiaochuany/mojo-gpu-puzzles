## Complete version: Block boundary case

![1D Convolution visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_53_1.svg)

Configuration:
- Input array size: \\(\\text{SIZE} = 15\\) elements
- Kernel size: \\(\\text{CONV} = 4\\) elements
- Threads per block: \\(\\text{TPB} = 8\\)
- Number of blocks: \\(2\\)
- Shared memory: \\(\\text{TPB} + \\text{CONV} - 1\\) elements for input

- **Extended loading**: Account for boundary overlap
- **Block edges**: Handle data across block boundaries
- **Memory layout**: Efficient shared memory usage
- **Synchronization**: Proper thread coordination

### Code to complete

```mojo
{{#include ../../../problems/p11/p11.mojo:conv_1d_block_boundary}}
```
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p11/p11.mojo" class="filename">View full file: problems/p11/p11.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Load main data: `shared_a[local_i] = a[global_i]`
2. Load boundary: `if local_i < CONV - 1` handle next block data
3. Load kernel: `shared_b[local_i] = b[local_i]`
4. Sum within extended bounds: `if local_i + j < TPB + CONV - 1`
</div>
</details>

### Running the code

To test your solution, run the following command in your terminal:

```bash
magic run p11 --block-boundary
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([5.0, 8.0, 11.0, 14.0, 5.0, 0.0])
```

## Solution

<details>
<summary>Click to see the solution</summary>

```mojo
{{#include ../../../solutions/p11/p11.mojo:conv_1d_block_boundary_solution}}
```

<div class="solution-explanation">

This solution:
- Allocates shared memory with padding for boundary elements
- Loads input data and boundary elements from next block
- Synchronizes threads after loading
- Computes convolution with proper bounds checking
- Handles block boundaries correctly
</div>
</details>
