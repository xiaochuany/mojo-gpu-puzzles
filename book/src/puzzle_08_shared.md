# Puzzle 8: Shared

Implement a kernel that adds 10 to each position of `a` and stores it in `out`.
You have fewer threads per block than the size of `a`.

## Problem

The file for this puzzle is [problems/p08.mojo](../problems/p08.mojo).

```mojo
alias TPB = 4
alias SIZE = 8
alias BLOCKS_PER_GRID = (2, 1)
alias THREADS_PER_BLOCK = (TPB, 1)
alias dtype = DType.float32


fn add_10_shared(
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
    # local data into shared memory
    if global_i < size:
        shared[local_i] = a[global_i]

    # wait for all threads to complete
    # works within a thread block
    barrier()

    # FILL ME IN (roughly 2 lines)
```

## Visual Representation

![Shared memory visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_39_1.svg)

## Running the Code

```bash
magic run p08
```

## Expected Output

```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0])
```

## Key Concepts

In this puzzle, you'll learn about:
- Using shared memory within a thread block
- Synchronizing threads with barriers
- The importance of thread synchronization in shared memory operations

**Warning**: Each block can only have a *constant* amount of shared memory that threads in that block can read and write to. This needs to be a literal python constant, not a variable. After writing to shared memory you need to call [barrier](https://docs.modular.com/mojo/stdlib/gpu/sync/barrier/) to ensure that threads do not cross.

Even though this example doesn't strictly require shared memory or barriers, it introduces these concepts for more complex operations in future puzzles.
