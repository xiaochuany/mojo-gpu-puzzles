# Naive matrix multiplication

Implement a kernel that multiplies square matrices \\(a\\) and \\(transpose(a)\\) and stores the result in \\(out\\).
This is the most straightforward implementation where each thread computes one element of the output matrix.

![Matrix Multiply visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_67_1.svg)

## Key concepts

In this puzzle, you'll learn about:
- 2D thread organization for matrix operations
- Global memory access patterns
- Matrix indexing in row-major layout
- Thread-to-output element mapping

The key insight is understanding how to map 2D thread indices to matrix elements and compute dot products in parallel.

Configuration:
- Matrix size: \\(\\text{SIZE} \\times \\text{SIZE} = 2 \\times 2\\)
- Threads per block: \\(\\text{TPB} \\times \\text{TPB} = 3 \\times 3\\)
- Grid dimensions: \\(1 \\times 1\\)

For position \\((i,j)\\) in the output matrix:
\\[ C_{ij} = \sum_{k=0}^{\\text{SIZE}-1} A_{ik} \\cdot B_{kj} \\]

Memory layout (row-major):
- Matrix \\(A\\): \\(A_{ik} = a[i \\cdot \\text{SIZE} + k]\\)
- Matrix \\(B\\): \\(B_{kj} = b[k + j \\cdot \\text{SIZE}]\\)
- Output \\(C\\): \\(C_{ij} = \\text{out}[i \\cdot \\text{SIZE} + j]\\)

## Code to complete

```mojo
{{#include ../../../problems/p14/p14.mojo:naive_matmul}}
```
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p14/p14.mojo" class="filename">View full file: problems/p14/p14.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Calculate `global_i` and `global_j` from thread indices
2. Check if indices are within `size`
3. Accumulate products in a local variable
4. Write final sum to correct output position
</div>
</details>

## Running the code

To test your solution, run the following command in your terminal:

```bash
magic run p14 --naive
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([1.0, 3.0, 3.0, 13.0])
```

## Solution

<details>
<summary>Click to see the solution</summary>

```mojo
{{#include ../../../solutions/p14/p14.mojo:naive_matmul_solution}}
```

<div class="solution-explanation">

This solution implements matrix multiplication by:

1. Thread mapping:
   - Each thread identified by \\((\\text{global}_i, \\text{global}_j)\\)
   - Computed from block and thread indices

2. Bounds checking:
   ```mojo
   if global_i < size and global_j < size:
   ```

3. Dot product computation:
   - Initialize accumulator: `total = 0`
   - For each \\(k\\) in range \\(\\text{SIZE}\\):
     - Access \\(A\\): `a[global_i * size + k]`
     - Access \\(B\\): `b[k + global_j * size]`
     - Accumulate product

4. Result storage:
   - Write to output at correct position in row-major order
   - Uses same indexing as input matrices
</div>
</details>
