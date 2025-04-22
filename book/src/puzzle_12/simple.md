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

The parallel (inclusive) prefix-sum algorithm works as follows:

### Setup & Configuration
- TPB (Threads Per Block) = 8
- SIZE (Array Size) = 8
- BLOCKS = 1

### Thread Mapping

- `thread_idx.x`: `[0   1   2   3   4   5   6   7]  (local_i)`
- `block_idx.x`:  `[0   0   0   0   0   0   0   0]`
- `global_i`:     `[0   1   2   3   4   5   6   7]  (block_idx.x * TPB + thread_idx.x)`

### Initial Load to Shared Memory

```txt
Threads:      T0   T1   T2   T3   T4   T5   T6   T7
Input array:  [0    1    2    3    4    5    6    7]
shared:       [0    1    2    3    4    5    6    7]
               ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑
              T0   T1   T2   T3   T4   T5   T6   T7
```

### Offset = 1: First Parallel Step

Active threads: `T1 T2 T3 T4 T5 T6 T7` (where `local_i >= 1`)

```txt
Before:      [0    1    2    3    4    5    6    7]
Add:              +0   +1   +2   +3   +4   +5   +6
                   |    |    |    |    |    |    |
Result:      [0    1    3    6    7    9    11   13]
                   ↑    ↑    ↑    ↑    ↑    ↑    ↑
                  T1   T2   T3   T4   T5   T6   T7
```

### Offset = 2: Second Parallel Step

Active threads: `T2 T3 T4 T5 T6 T7` (where `local_i >= 2`)

```txt
Before:      [0    1    3    6    7    9    11   13]
Add:                   +0   +1   +3   +6   +7   +9
                        |    |    |    |    |    |
Result:      [0    1    3    7    10   15   18   22]
                        ↑    ↑    ↑    ↑    ↑    ↑
                       T2   T3   T4   T5   T6   T7
```

### Offset = 4: Third Parallel Step

Active threads: `T4 T5 T6 T7` (where `local_i >= 4`)

```txt
Before:      [0    1    3    7    10   15   18   22]
Add:                              +0   +1   +3   +7
                                  |    |    |    |
Result:      [0    1    3    7    10   16   21   28]
                                  ↑    ↑    ↑    ↑
                                  T4   T5   T6   T7
```

### Final Write to Output

```txt
Threads:      T0   T1   T2   T3   T4   T5   T6   T7
global_i:     0    1    2    3    4    5    6    7
out[]:       [0    1    3    7    10   16   21   28]
              ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑
              T0   T1   T2   T3   T4   T5   T6   T7
```

### Thread-by-Thread Execution

**T0 (`local_i=0`):**

- Loads `shared[0] = 0`
- Never adds (`local_i < offset` always)
- Writes `out[0] = 0`

**T1 (`local_i=1`):**

- Loads `shared[1] = 1`
- `offset=1`: adds `shared[0] = 1`
- `offset=2,4`: no action (`local_i < offse`t`)
- Writes `out[1] = 1`

**T2 (`local_i=2`):**

- Loads `shared[2] = 2`
- `offset=1`: adds `shared[1] = 3`
- `offset=2`: adds `shared[0] = 3`
- `offset=4`: no action
- Writes `out[2] = 3`

**T3 (`local_i=3`):**

- Loads `shared[3] = 3`
- `offset=1`: adds `shared[2] = 6`
- `offset=2`: adds `shared[1] = 7`
- `offset=4`: no action
- Writes `out[3] = 7`

**T4 (`local_i=4`):**

- Loads `shared[4] = 4`
- `offset=1`: adds `shared[3] = 7`
- `offset=2`: adds `shared[2] = 10`
- `offset=4`: adds `shared[0] = 10`
- Writes `out[4] = 10`

The solution ensures correct synchronization between phases using `barrier()` and handles array bounds checking with `if global_i < size`.
</div>
</details>
