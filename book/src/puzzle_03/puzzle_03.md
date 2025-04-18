# Puzzle 3: Guards

Implement a kernel that adds 10 to each position of `a` and stores it in `out`.
You have more threads than positions.

## Problem

The file for this puzzle is [problems/p03.mojo](../problems/p03.mojo).

```mojo
alias SIZE = 4
alias BLOCKS_PER_GRID = 1
alias THREADS_PER_BLOCK = (8, 1)
alias dtype = DType.float32


fn add_10_guard(
    out: UnsafePointer[Scalar[dtype]],
    a: UnsafePointer[Scalar[dtype]],
    size: Int,
):
    local_i = thread_idx.x
    # FILL ME IN (roughly 2 lines)
```

## Visual Representation

![Guards visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_21_1.svg)

## Running the Code

```bash
magic run p03
```

## Expected Output

```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([10.0, 11.0, 12.0, 13.0])
```

## Key Concepts

In this puzzle, you'll learn about:
- Using guards to handle thread/data size mismatches
- Preventing out-of-bounds memory access
- Conditional execution in GPU kernels

The key insight is that you need to check if a thread's index is within the valid range of the data array before performing any operations.
