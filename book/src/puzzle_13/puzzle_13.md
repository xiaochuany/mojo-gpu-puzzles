# Puzzle 13: Axis Sum

Implement a kernel that computes a sum over each column of `a` and stores it in `out`.

## Problem

The file for this puzzle is [problems/p13.mojo](../problems/p13.mojo).

```mojo
alias TPB = 8
alias BATCH = 4
alias SIZE = 6
alias BLOCKS_PER_GRID = (1, BATCH)
alias THREADS_PER_BLOCK = (TPB, 1)
alias dtype = DType.float32

fn axis_sum(
    out: UnsafePointer[Scalar[dtype]],
    a: UnsafePointer[Scalar[dtype]],
    size: Int,
):
    cache = stack_allocation[
        TPB * sizeof[dtype](),
        Scalar[dtype],
        address_space = AddressSpace.SHARED,
    ]()
    global_i = block_dim.x * block_idx.x + thread_idx.x
    local_i = thread_idx.x
    batch = block_idx.y
    # FILL ME IN (roughly 12 lines)
```

## Visual Representation

![Axis Sum visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_64_1.svg)

## Running the Code

```bash
magic run p13
```

## Expected Output

```txt
out: DeviceBuffer([0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([15.0, 51.0, 87.0, 123.0])
```

## Key Concepts

In this puzzle, you'll learn about:
- Computing reductions along specific dimensions (axes)
- Using multiple thread blocks to process different parts of data
- Mapping thread blocks to specific data columns/regions

The key insight is organizing your computation to have separate thread blocks handle different columns of the input array, then using shared memory within each block to compute the sum efficiently.
