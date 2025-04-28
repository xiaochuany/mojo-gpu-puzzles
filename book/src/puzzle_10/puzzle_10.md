# Puzzle 10: Dot Product

Implement a kernel that computes the dot-product of vector \\(a\\) and vector \\(b\\) and stores it in \\(out\\).
You have 1 thread per position. You only need 2 global reads and 1 global write per thread.

![Dot product visualization](./media/videos/720p30/puzzle_10_viz.gif)

## Key concepts

In this puzzle, you'll learn about:
- Implementing parallel reduction operations
- Using shared memory for intermediate results
- Coordinating threads for collective operations

The key insight is understanding how to efficiently combine multiple values into a single result using parallel computation and shared memory.

Configuration:
- Vector size: \\(\\text{SIZE} = 8\\) elements
- Threads per block: \\(\\text{TPB} = 8\\)
- Number of blocks: \\(1\\)
- Output size: \\(1\\) element
- Shared memory: \\(\\text{TPB}\\) elements

- **Element access**: Each thread reads corresponding elements from `a` and `b`
- **Partial results**: Computing and storing intermediate values
- **Thread coordination**: Synchronizing before combining results
- **Final reduction**: Converting partial results to scalar output

*Note: For this problem, you don't need to worry about number of shared reads. We will
handle that challenge later.*

## Code to complete

```mojo
{{#include ../../../problems/p10/p10.mojo:dot_product}}
```
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p10/p10.mojo" class="filename">View full file: problems/p10/p10.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Store `a[global_i] * b[global_i]` in `shared[local_i]`
2. Call `barrier()` to synchronize
3. Use thread 0 to sum all products in shared memory
4. Write final sum to `out[0]`
</div>
</details>

## Running the code

To test your solution, run the following command in your terminal:

```bash
magic run p10
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0])
expected: HostBuffer([140.0])
```

## Solution

<details class="solution-details">
<summary></summary>

```mojo
{{#include ../../../solutions/p10/p10.mojo:dot_product_solution}}
```

<div class="solution-explanation">

The parallel reduction algorithm for dot product works as follows:

### Initial State
Each thread multiplies corresponding elements from vectors \\(a\\) and \\(b\\):
```txt
Threads:     T0   T1   T2   T3   T4   T5   T6   T7
a:          [0    1    2    3    4    5    6    7]
b:          [0    1    2    3    4    5    6    7]
shared:     [0    1    4    9    16   25   36   49]
             ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑
            T0   T1   T2   T3   T4   T5   T6   T7
```

### Parallel Reduction Steps

#### Step 1: stride = \\(\\text{TPB} / 2 = 4\\)
Active threads: \\(T_0, T_1, T_2, T_3\\)
```txt
Before:     [0    1    4    9    16   25   36   49]
Add:         +16  +25  +36  +49
             |    |    |    |
Result:     [16   26   40   58   16   25   36   49]
             ↑    ↑    ↑    ↑
            T0   T1   T2   T3
```

#### Step 2: stride = \\(\\text{TPB} / 4 = 2\\)
Active threads: \\(T_0, T_1\\)
```txt
Before:     [16   26   40   58   16   25   36   49]
Add:         +40  +58
             |    |
Result:     [56   84   40   58   16   25   36   49]
             ↑    ↑
            T0   T1
```

#### Step 3: stride = \\(\\text{TPB} / 8 = 1\\)
Active thread: \\(T_0\\)
```txt
Before:     [56   84   40   58   16   25   36   49]
Add:         +84
             |
Result:     [140  84   40   58   16   25   36   49]
             ↑
            T0
```

### Final Write
Only thread \\(T_0\\) writes the final result:
```txt
Thread T0: out[0] = 140
```

Key Implementation Details:
1. Uses `shared` memory for fast intermediate results
2. Halves the stride in each step: \\(4 \\rightarrow 2 \\rightarrow 1\\)
3. Calls `barrier()` between steps for synchronization
4. Only active threads where `local_i < stride` perform additions
5. Final result is sum of all element-wise products: \\(\sum_{i=0}^{7} a[i] \cdot b[i] = 140\\)

This parallel reduction approach reduces the time complexity from \\(O(n)\\) to \\(O(\log n)\\) by performing additions in parallel.
</div>
</details>
