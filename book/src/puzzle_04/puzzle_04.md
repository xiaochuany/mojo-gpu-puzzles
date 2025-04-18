# Puzzle 4: Map 2D

Implement a kernel that adds 10 to each position of `a` and stores it in `out`.
Input `a` is 2D and square. You have more threads than positions.

## Problem

The file for this puzzle is [problems/p04.mojo](../problems/p04.mojo).

```mojo
alias SIZE = 2
alias BLOCKS_PER_GRID = 1
alias THREADS_PER_BLOCK = (3, 3)
alias dtype = DType.float32


fn add_10_2d(
    out: UnsafePointer[Scalar[dtype]],
    a: UnsafePointer[Scalar[dtype]],
    size: Int,
):
    local_i = thread_idx.x
    local_j = thread_idx.y
    # FILL ME IN (roughly 2 lines)
```

## Visual Representation

![Map 2D visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_24_1.svg)

## Running the Code

```bash
magic run p04
```

## Expected Output

```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([10.0, 11.0, 12.0, 13.0])
```

## Key Concepts

In this puzzle, you'll learn about:
- Working with 2D thread configurations
- Mapping 2D thread indices to 1D memory
- Implementing boundary checks in multiple dimensions

The key insight is understanding how to convert 2D coordinates to a 1D memory index using row-major ordering, and ensuring that your thread indices are within the bounds of the 2D data.
