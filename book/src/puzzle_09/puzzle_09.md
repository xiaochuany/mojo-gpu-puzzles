# Puzzle 9: Pooling

Implement a kernel that sums together the last 3 positions of vector \\(a\\) and stores it in vector \\(out\\).
You have 1 thread per position. You only need 1 global read and 1 global write per thread.

In pseudocode:

```python
for i in range(a.shape[0]):
    out[i] = a[max(i - 2, 0) : i + 1].sum()
```

![Pooling visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_43_1.svg)

## Key concepts

In this puzzle, you'll learn about:
- Using shared memory for sliding window operations
- Handling boundary conditions in pooling
- Coordinating thread access to neighboring elements

The key insight is understanding how to efficiently access a window of elements using shared memory, with special handling for the first elements in the sequence.

Configuration:
- Array size: \\(\\text{SIZE} = 8\\) elements
- Threads per block: \\(\\text{TPB} = 8\\)
- Window size: \\(3\\) elements
- Shared memory: \\(\\text{TPB}\\) elements

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

<details>
<summary>Click to see the solution</summary>

```mojo
{{#include ../../../solutions/p09/p09.mojo:pooling_solution}}
```

<div class="solution-explanation">

This solution:
- Loads input into shared memory and synchronizes
- Handles first two elements as special cases
- For remaining elements, sums previous three values
- Uses shared memory for efficient neighbor access
</div>
</details>
