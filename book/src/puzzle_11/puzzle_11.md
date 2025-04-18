# Puzzle 11: 1D Convolution

Implement a kernel that computes a 1D convolution between `a` and `b` and stores it in `out`.
You need to handle the general case. You only need 2 global reads and 1 global write per thread.

## Problem

The file for this puzzle is [problems/p11.mojo](../problems/p11.mojo).

```mojo
alias TPB = 8
alias SIZE = 6
alias CONV = 3
alias BLOCKS_PER_GRID = (1, 1)
alias THREADS_PER_BLOCK = (TPB, 1)
alias dtype = DType.float32

fn conv_1d_simple(
    out: UnsafePointer[Scalar[dtype]],
    a: UnsafePointer[Scalar[dtype]],
    b: UnsafePointer[Scalar[dtype]],
    a_size: Int,
    b_size: Int,
):
    shared_a = stack_allocation[
        SIZE * sizeof[dtype](),
        Scalar[dtype],
        address_space = AddressSpace.SHARED,
    ]()
    shared_b = stack_allocation[
        CONV * sizeof[dtype](),
        Scalar[dtype],
        address_space = AddressSpace.SHARED,
    ]()
    global_i = block_dim.x * block_idx.x + thread_idx.x
    local_i = thread_idx.x
    # FILL ME IN (roughly 11 lines)
```

## Visual Representation

![1D Convolution visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_50_1.svg)

## Running the Code

```bash
magic run p11
```

## Expected Output

```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([5.0, 8.0, 11.0, 14.0, 5.0, 0.0])
```

## Key Concepts

In this puzzle, you'll learn about:
- Implementing convolution operations on GPUs
- Managing boundary conditions in convolution
- Efficient shared memory usage for sliding window operations

The key insight is understanding how to load both the input array and the convolution kernel into shared memory, then compute the convolution result for each position while handling boundary conditions correctly.
