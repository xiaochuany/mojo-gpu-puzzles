# Puzzle 3: Guards

Implement a kernel that adds 10 to each position of vector `a` and stores it in vector `out`.
**You have more threads than positions.**

## Visual Representation

![Guards visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_21_1.svg)

## Key Concepts

In this puzzle, you'll learn about:
- Using guards to handle thread/data size mismatches
- Preventing out-of-bounds memory access
- Conditional execution in GPU kernels

The key insight is that you need to check if a thread's index is within the valid range of the data array before performing any operations.

- **Thread Safety**: Guards prevent threads from accessing invalid memory
- **Conditional Execution**: Only threads with valid indices perform the operation
- **Memory Protection**: Avoiding out-of-bounds access is crucial for GPU programming
- **Data Boundaries**: Handling cases where thread count exceeds data size

## Code to Complete

```mojo
{{#include ../../../problems/p03/p03.mojo:add_10_guard}}
```
<a href="../../../problems/p03/p03.mojo" class="filename">View full file: problems/p03/p03.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Check if `local_i` is less than `size` before performing any operations
2. Only threads with valid indices should modify the output array
3. Use an if-statement to implement the guard condition

</div>
</details>

## Running the Code

To test your solution, run the following command in your terminal:

```bash
magic run p03
```

Your output will look like this if the puzzle isn't solved yet:

```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([10.0, 11.0, 12.0, 13.0])
```

## Solution

<details>
<summary>Click to see the solution</summary>

```mojo
{{#include ../../../solutions/p03/p03.mojo:add_10_guard_solution}}
```

<div class="solution-explanation">

This solution:

- Checks if the thread index is within valid range
- Only processes array elements for valid indices
- Adds 10 to the value when the guard condition is met

</div>
</details>
