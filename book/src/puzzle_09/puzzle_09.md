# Puzzle 9: Pooling

Implement a kernel that sums together the last 3 position of `a` and stores it in `out`.
You have 1 thread per position. You only need 1 global read and 1 global write per thread.

## Problem

The file for this puzzle is [problems/p09.mojo](../problems/p09.mojo).

```mojo
alias TPB = 8
alias SIZE = 8
alias BLOCKS_PER_GRID = (1, 1)
alias THREADS_PER_BLOCK = (TPB, 1)
alias dtype = DType.float32


fn pooling(
    out: UnsafePointer[Scalar[dtype]],
    a: UnsafePointer[Scalar[dtype]],
    size: Int,
):
    shared = stack_allocation[
        TPB * sizeof[dtype](),
        Scalar[dtype],
        address_space = AddressSpace.SHARED,
    ]()
    global_i = block_dim.x * block_idx.x + thread_idx.x
    local_i = thread_idx.x
    # FILL ME IN (roughly 8 lines)
```

## Visual Representation

![Pooling visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_43_1.svg)

## Running the Code

```bash
magic run p09
```

## Expected Output

```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([0.0, 1.0, 3.0, 6.0, 9.0, 12.0, 15.0, 18.0])
```

## Key Concepts

In this puzzle, you'll learn about:
- Implementing pooling operations using shared memory
- Accessing adjacent elements in shared memory
- Managing thread synchronization for dependent operations

*Tip: Remember to be careful about syncing when accessing shared memory.
Each thread needs to load its data and wait for others before performing the pooling operation.*

The key insight is understanding how to efficiently implement a sliding window operation using shared memory, where each thread's output depends on multiple input values.
