## Simple case

![Prefix Sum visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_58_1.svg)


Configuration:
- Array size: \\(\\text{SIZE} = 8\\) elements
- Threads per block: \\(\\text{TPB} = 8\\)
- Number of blocks: \\(1\\)
- Shared memory: \\(\\text{TPB}\\) elements

- **Data loading**: Each thread loads one element
- **Memory pattern**: Shared memory for intermediate results
- **Thread sync**: Coordination between computation phases
- **Access pattern**: Stride-based parallel computation

### Code to complete

```mojo
{{#include ../../../problems/p12/p12.mojo:prefix_sum_simple}}
```
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p12/p12.mojo" class="filename">View full file: problems/p12/p12.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Load data into `shared[local_i]`
2. Use `offset = 1` and double it each step
3. Add elements where `local_i >= offset`
4. Call `barrier()` between steps
</div>
</details>

### Running the code

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

This solution implements a parallel prefix sum in \\(O(\log n)\\) steps:

1. Initial load:
   - Each thread loads its element: `shared[local_i] = a[global_i]`
   - Input `[0,1,2,3,4,5,6,7]` → shared memory
   - Synchronize with `barrier()`

2. Parallel reduction:
   - Uses `offset` starting at 1 and doubling each step
   - Iterates `log2(TPB)` times (3 iterations for TPB=8)
   - Each thread where `local_i >= offset`:
     - Adds `shared[local_i - offset]` to `shared[local_i]`
   - Synchronizes after each step with `barrier()`

3. Step-by-step progression:
   ```
   Initial:  [0, 1, 2, 3, 4, 5, 6, 7]
   Offset=1: [0, 1, 3, 6, 7, 9, 11, 13]  (each adds previous)
   Offset=2: [0, 1, 3, 7, 10, 15, 18, 22] (each adds 2 back)
   Offset=4: [0, 1, 3, 7, 10, 16, 21, 28] (each adds 4 back)
   ```

4. Final write:
   - Each thread writes its final value: `out[global_i] = shared[local_i]`
   - Produces inclusive prefix sum: `[0,1,3,7,10,16,21,28]`

The solution ensures correct synchronization between phases and handles array bounds checking with `if global_i < size`.
</div>
</details>
