# Puzzle 5: Broadcast

Implement a kernel that adds `a` and `b` and stores it in `out`.
Inputs `a` and `b` are vectors. You have more threads than positions.

## Problem

The file for this puzzle is [problems/p05.mojo](../problems/p05.mojo).

```mojo
alias SIZE = 2
alias BLOCKS_PER_GRID = 1
alias THREADS_PER_BLOCK = (3, 3)
alias dtype = DType.float32


fn broadcast_add(
    out: UnsafePointer[Scalar[dtype]],
    a: UnsafePointer[Scalar[dtype]],
    b: UnsafePointer[Scalar[dtype]],
    size: Int,
):
    local_i = thread_idx.x
    local_j = thread_idx.y
    # FILL ME IN (roughly 2 lines)
```

## Visual Representation

![Broadcast visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_27_1.svg)

## Running the Code

```bash
magic run p05
```

## Expected Output

```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([0.0, 1.0, 1.0, 2.0])
```

## Key Concepts

In this puzzle, you'll learn about:
- Broadcasting operations across dimensions
- Processing 1D data with 2D thread configurations
- Coordinate conversion between thread and data indices

The key insight is understanding how to map 2D thread coordinates to 1D memory indices for the operation, while also ensuring proper boundary checking.
