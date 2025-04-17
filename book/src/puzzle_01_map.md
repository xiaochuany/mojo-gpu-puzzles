# Puzzle 1: Map

Implement a "kernel" (GPU function) that adds 10 to each position of vector `a`
and stores it in vector `out`. You have 1 thread per position.

## Problem

The file for this puzzle is [problems/p01.mojo](../problems/p01.mojo).

```mojo
alias SIZE = 4
alias BLOCKS_PER_GRID = 1
alias THREADS_PER_BLOCK = SIZE
alias dtype = DType.float32

fn add_10(out: UnsafePointer[Scalar[dtype]], a: UnsafePointer[Scalar[dtype]]):
    local_i = thread_idx.x
    # FILL ME IN (roughly 1 line)
```

## Visual Representation

![Map operation visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_14_1.svg)

## Running the Code

```bash
magic run p01
```

## Expected Output

```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([10.0, 11.0, 12.0, 13.0])
```

## Key Concepts

In this puzzle, you'll learn about:
- Basic GPU kernel structure
- Mapping thread indices to data indices
- Parallel execution of independent operations

The key insight is that each thread (identified by `thread_idx.x`) should process one element of the input array.
