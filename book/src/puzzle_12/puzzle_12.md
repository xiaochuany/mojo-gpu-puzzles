# Puzzle 12: Prefix Sum

Implement a kernel that computes a running sum / prefix-sum over `a` and stores it in `out`.
If the size of `a` is greater than the block size, only store the sum of
each block.

## Problem

The file for this puzzle is [problems/p12.mojo](../problems/p12.mojo).

```mojo
alias TPB = 8
alias SIZE = 8
alias BLOCKS_PER_GRID = (1, 1)
alias THREADS_PER_BLOCK = (TPB, 1)
alias dtype = DType.float32

# this only works when there's a single block
fn prefix_sum_simple(
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
    # FILL ME IN (roughly 11 lines)
```

## Algorithm Explanation

We will use the [parallel prefix sum](https://en.wikipedia.org/wiki/Prefix_sum) algorithm in shared memory.
That is, each step of the algorithm should sum together half the remaining numbers.
Follow this diagram:

![Prefix Sum Algorithm](https://user-images.githubusercontent.com/35882/178757889-1c269623-93af-4a2e-a7e9-22cd55a42e38.png)

## Visual Representation

![Prefix Sum visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_58_1.svg)

## Running the Code

```bash
magic run p12
```

## Expected Output

```txt
out: DeviceBuffer([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([0.0, 1.0, 3.0, 6.0, 10.0, 15.0, 21.0, 28.0])
```

## Key Concepts

In this puzzle, you'll learn about:
- Implementing parallel prefix sum (scan) operations
- Using shared memory for efficient parallel computation
- Understanding parallel algorithms with logarithmic complexity

The key insight is implementing the parallel prefix sum algorithm, which consists of two phases: an up-sweep phase that builds a sum tree, and a down-sweep phase that builds the final prefix sum.
