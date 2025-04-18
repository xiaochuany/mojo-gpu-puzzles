# Puzzle 2: Zip

Implement a kernel that adds together each position of `a` and `b` and stores it in `out`.
You have 1 thread per position.

## Problem

The file for this puzzle is [problems/p02.mojo](../problems/p02.mojo).

```mojo
alias SIZE = 4
alias BLOCKS_PER_GRID = 1
alias THREADS_PER_BLOCK = SIZE
alias dtype = DType.float32


fn add(
    out: UnsafePointer[Scalar[dtype]],
    a: UnsafePointer[Scalar[dtype]],
    b: UnsafePointer[Scalar[dtype]],
):
    local_i = thread_idx.x
    # FILL ME IN (roughly 1 line)
```

## Visual Representation

![Zip operation visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_17_1.svg)

## Running the Code

```bash
magic run p02
```

## Expected Output

```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([0.0, 2.0, 4.0, 6.0])
```

## Key Concepts

In this puzzle, you'll learn about:
- Processing multiple input arrays in parallel
- Element-wise operations with multiple inputs
- Maintaining thread-to-data mapping across arrays

Each thread should read one element from each input array, add them together, and write the result to the output array.
