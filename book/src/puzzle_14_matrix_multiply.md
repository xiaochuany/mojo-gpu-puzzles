# Puzzle 14: Matrix Multiply

Implement a kernel that multiplies square matrices `a` and `b` and
stores the result in `out`.

## Problem

The file for this puzzle is [problems/p14.mojo](../problems/p14.mojo).

```mojo
alias TPB = 3
alias SIZE = 2
alias BLOCKS_PER_GRID = (1, 1)
alias THREADS_PER_BLOCK = (TPB, TPB)

fn single_block_matmul(
    out: UnsafePointer[Scalar[dtype]],
    a: UnsafePointer[Scalar[dtype]],
    b: UnsafePointer[Scalar[dtype]],
    size: Int,
):
    a_shared = stack_allocation[
        TPB * TPB * sizeof[dtype](),
        Scalar[dtype],
        address_space = AddressSpace.SHARED,
    ]()
    b_shared = stack_allocation[
        TPB * TPB * sizeof[dtype](),
        Scalar[dtype],
        address_space = AddressSpace.SHARED,
    ]()
    global_i = block_dim.x * block_idx.x + thread_idx.x
    global_j = block_dim.y * block_idx.y + thread_idx.y
    local_i = thread_idx.x
    local_j = thread_idx.y
    # FILL ME IN (roughly 6 lines)
```

## Visual Representation

![Matrix Multiply visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_67_1.svg)

## Running the Code

```bash
magic run p14
```

## Expected Output

```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([1.0, 3.0, 3.0, 13.0])
```

## Key Concepts

In this puzzle, you'll learn about:
- Implementing matrix multiplication on GPU
- Using shared memory to optimize memory access patterns
- Organizing thread blocks for matrix operations

The key insight is loading blocks of both matrices into shared memory and computing partial products efficiently. This is a fundamental operation in many GPU applications, particularly in machine learning and scientific computing.
