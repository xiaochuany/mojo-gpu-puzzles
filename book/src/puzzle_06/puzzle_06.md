# Puzzle 6: Blocks

Implement a kernel that adds 10 to each position of `a` and stores it in `out`.
You have fewer threads per block than the size of `a`.

## Problem

The file for this puzzle is [problems/p06.mojo](../problems/p06.mojo).

```mojo
alias SIZE = 9
alias BLOCKS_PER_GRID = (3, 1)
alias THREADS_PER_BLOCK = (4, 1)
alias dtype = DType.float32


fn add_10_blocks(
    out: UnsafePointer[Scalar[dtype]],
    a: UnsafePointer[Scalar[dtype]],
    size: Int,
):
    global_i = block_dim.x * block_idx.x + thread_idx.x
    # FILL ME IN (roughly 2 lines)
```

## Visual Representation

![Blocks visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_31_1.svg)

## Running the Code

```bash
magic run p06
```

## Expected Output

```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0])
```

## Key Concepts

In this puzzle, you'll learn about:
- Working with multiple blocks of threads
- Computing global thread indices
- Understanding the block/thread hierarchy in GPU programming

A block is a group of threads. The number of threads per block is limited, but we can have many different blocks. The variable [block_idx](https://docs.modular.com/mojo/stdlib/gpu/id#aliases) tells us what block we are in.

The key insight is understanding how to compute the global thread index using the block index, and ensuring that this index doesn't exceed the data size.
