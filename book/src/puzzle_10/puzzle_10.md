# Puzzle 10: Dot Product

Implement a kernel that computes the dot-product of `a` and `b` and stores it in `out`.
You have 1 thread per position. You only need 2 global reads and 1 global write per thread.

## Problem

The file for this puzzle is [problems/p10.mojo](../problems/p10.mojo).

```mojo
alias TPB = 8
alias SIZE = 8
alias BLOCKS_PER_GRID = (1, 1)
alias THREADS_PER_BLOCK = (SIZE, 1)
alias dtype = DType.float32


fn dot_product(
    out: UnsafePointer[Scalar[dtype]],
    a: UnsafePointer[Scalar[dtype]],
    b: UnsafePointer[Scalar[dtype]],
    size: Int,
):
    shared = stack_allocation[
        TPB * sizeof[dtype](),
        Scalar[dtype],
        address_space = AddressSpace.SHARED,
    ]()
    global_i = block_dim.x * block_idx.x + thread_idx.x
    local_i = thread_idx.x
    # FILL ME IN (roughly 11 lines)
```

## Visual Representation

![Dot product visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_47_1.svg)

## Running the Code

```bash
magic run p10
```

## Expected Output

```txt
out: HostBuffer([0.0])
expected: HostBuffer([140.0])
```

## Key Concepts

In this puzzle, you'll learn about:
- Implementing reduction operations (like dot product)
- Using shared memory for thread collaboration
- Understanding parallel reduction patterns

*Note: For this problem, you don't need to worry about number of shared reads. We will
 handle that challenge later.*

The key insight is understanding how to compute partial results in parallel, then combine them efficiently using shared memory and synchronization to produce a final result.
