# Puzzle 7: Blocks 2D

Implement the same kernel in 2D. You have fewer threads per block
than the size of `a` in both directions.

## Problem

The file for this puzzle is [problems/p07.mojo](../problems/p07.mojo).

```mojo
alias SIZE = 5
alias BLOCKS_PER_GRID = (2, 2)
alias THREADS_PER_BLOCK = (3, 3)
alias dtype = DType.float32


fn add_10_blocks_2d(
    out: UnsafePointer[Scalar[dtype]],
    a: UnsafePointer[Scalar[dtype]],
    size: Int,
):
    global_i = block_dim.x * block_idx.x + thread_idx.x
    global_j = block_dim.y * block_idx.y + thread_idx.y
    # FILL ME IN (roughly 2 lines)
```

## Visual Representation

![Blocks 2D visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_34_1.svg)

## Running the Code

```bash
magic run p07
```

## Expected Output

```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0])
```

## Key Concepts

In this puzzle, you'll learn about:
- Working with 2D block configurations
- Computing global thread indices in multiple dimensions
- Mapping 2D thread/block indices to memory locations

The key insight is understanding how to compute global thread indices in a 2D grid, convert them to a linear memory index, and ensure that these indices don't exceed the data size in either dimension.
