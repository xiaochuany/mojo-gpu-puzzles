from memory import UnsafePointer, stack_allocation
from gpu import thread_idx, block_idx, block_dim, barrier
from gpu.host import DeviceContext
from gpu.memory import AddressSpace
from sys import sizeof, argv
from math import log2
from testing import assert_equal

alias TPB = 8
alias SIZE = 8
alias BLOCKS_PER_GRID = (1, 1)
alias THREADS_PER_BLOCK = (TPB, 1)
alias dtype = DType.float32


# ANCHOR: prefix_sum_simple_solution
fn prefix_sum_simple(
    out: UnsafePointer[Scalar[dtype]],
    a: UnsafePointer[Scalar[dtype]],
    size: Int,
):
    global_i = block_dim.x * block_idx.x + thread_idx.x
    local_i = thread_idx.x
    shared = stack_allocation[
        TPB * sizeof[dtype](),
        Scalar[dtype],
        address_space = AddressSpace.SHARED,
    ]()
    if global_i < size:
        shared[local_i] = a[global_i]

    barrier()

    # sequential:
    # out[0] = shared[0]
    # out[1] = out[0] + shared[1]
    # out[2] = out[1] + shared[2]
    # ...
    # out[k] = out[k-1] + shared[k]

    # The Parallel (inclusive) Prefix-Sum Algorithm:

    # ===============================================================================
    # SETUP & CONFIGURATION
    # ===============================================================================
    # TPB (Threads Per Block) = 8
    # SIZE (Array Size) = 8
    # BLOCKS = 1

    # ===============================================================================
    # THREAD MAPPING
    # ===============================================================================
    # thread_idx.x: [0   1   2   3   4   5   6   7]  (local_i)
    # block_idx.x:  [0   0   0   0   0   0   0   0]
    # global_i:     [0   1   2   3   4   5   6   7]  (block_idx.x * TPB + thread_idx.x)

    # ===============================================================================
    # INITIAL LOAD TO SHARED MEMORY
    # ===============================================================================
    # Threads:      T0   T1   T2   T3   T4   T5   T6   T7
    # Input array:  [0    1    2    3    4    5    6    7]
    # shared[]:     [0    1    2    3    4    5    6    7]
    #                ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑
    #               T0   T1   T2   T3   T4   T5   T6   T7

    # ===============================================================================
    # OFFSET = 1: FIRST PARALLEL STEP
    # ===============================================================================
    # Active threads: T1 T2 T3 T4 T5 T6 T7 (where local_i >= 1)

    # Before:      [0    1    2    3    4    5    6    7]
    # Add:              +0   +1   +2   +3   +4   +5   +6
    #                    |    |    |    |    |    |    |
    # Result:      [0    1    3    6    7    9    11   13]
    #                    ↑    ↑    ↑    ↑    ↑    ↑    ↑
    #                   T1   T2   T3   T4   T5   T6   T7

    # ===============================================================================
    # OFFSET = 2: SECOND PARALLEL STEP
    # ===============================================================================
    # Active threads: T2 T3 T4 T5 T6 T7 (where local_i >= 2)

    # Before:      [0    1    3    6    7    9    11   13]
    # Add:                   +0   +1   +3   +6   +7   +9
    #                         |    |    |    |    |    |
    # Result:      [0    1    3    7    10   15   18   22]
    #                         ↑    ↑    ↑    ↑    ↑    ↑
    #                         T2   T3   T4   T5   T6   T7

    # ===============================================================================
    # OFFSET = 4: THIRD PARALLEL STEP
    # ===============================================================================
    # Active threads: T4 T5 T6 T7 (where local_i >= 4)

    # Before:      [0    1    3    7    10   15   18   22]
    # Add:                              +0   +1   +3   +7
    #                                   |    |    |    |
    # Result:      [0    1    3    7    10   16   21   28]
    #                                   ↑    ↑    ↑    ↑
    #                                   T4   T5   T6   T7

    # ===============================================================================
    # FINAL WRITE TO OUTPUT
    # ===============================================================================
    # Threads:      T0   T1   T2   T3   T4   T5   T6   T7
    # global_i:     0    1    2    3    4    5    6    7
    # out[]:       [0    1    3    7    10   16   21   28]
    #               ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑
    #               T0   T1   T2   T3   T4   T5   T6   T7

    # ===============================================================================
    # THREAD-BY-THREAD EXECUTION
    # ===============================================================================
    # T0 (local_i=0):
    # - Loads shared[0] = 0
    # - Never adds (local_i < offset always)
    # - Writes out[0] = 0

    # T1 (local_i=1):
    # - Loads shared[1] = 1
    # - Offset=1: adds shared[0] = 1
    # - Offset=2,4: no action (local_i < offset)
    # - Writes out[1] = 1

    # T2 (local_i=2):
    # - Loads shared[2] = 2
    # - Offset=1: adds shared[1] = 3
    # - Offset=2: adds shared[0] = 3
    # - Offset=4: no action
    # - Writes out[2] = 3

    # T3 (local_i=3):
    # - Loads shared[3] = 3
    # - Offset=1: adds shared[2] = 6
    # - Offset=2: adds shared[1] = 7
    # - Offset=4: no action
    # - Writes out[3] = 7

    # T4 (local_i=4):
    # - Loads shared[4] = 4
    # - Offset=1: adds shared[3] = 7
    # - Offset=2: adds shared[2] = 10
    # - Offset=4: adds shared[0] = 10
    # - Writes out[4] = 10

    # ... and so on

    offset = 1
    for _ in range(Int(log2(Scalar[dtype](TPB)))):
        if local_i >= offset and local_i < size:
            shared[local_i] += shared[local_i - offset]

        barrier()
        offset *= 2

    if global_i < size:
        out[global_i] = shared[local_i]


# ANCHOR_END: prefix_sum_simple_solution


alias SIZE_2 = 15
alias BLOCKS_PER_GRID_2 = (2, 1)
alias THREADS_PER_BLOCK_2 = (TPB, 1)


# ANCHOR: prefix_sum_complete_solution
fn prefix_sum(
    out: UnsafePointer[Scalar[dtype]],
    a: UnsafePointer[Scalar[dtype]],
    size: Int,
):
    global_i = block_dim.x * block_idx.x + thread_idx.x
    local_i = thread_idx.x
    shared = stack_allocation[
        TPB * sizeof[dtype](),
        Scalar[dtype],
        address_space = AddressSpace.SHARED,
    ]()
    if global_i < size:
        shared[local_i] = a[global_i]

    barrier()

    # Idea: two passes
    # SIZE=15, TPB=8, BLOCKS=2
    # buffer: [0,1,2,...,7 | 8,...,14]

    # Step 1: Each block computes local prefix sum
    # Block 0: [0,1,2,3,4,5,6,7] → [0,1,3,6,10,15,21,28]
    # Block 1: [8,9,10,11,12,13,14] → [8,17,27,38,50,63,77]

    # Step 2: Store block sums
    # Block 0's sum (28) → position 8

    # Step 3: Add previous block's sum
    # Block 1: Each element += 28
    # [8,17,27,38,50,63,77] → [36,45,55,66,78,91,105]

    # Final result combines both blocks:
    # [0,1,3,6,10,15,21,28, 36,45,55,66,78,91,105]

    # local prefix-sum for each block
    offset = 1
    for _ in range(Int(log2(Scalar[dtype](TPB)))):
        if local_i >= offset and local_i < size:
            shared[local_i] += shared[local_i - offset]

        barrier()
        offset *= 2

    # store block results
    if global_i < size:
        out[global_i] = shared[local_i]

    # store block sum in first element of next block:
    # - Only last thread (local_i == 7) in each block except last block executes
    # - Block 0: Thread 7 stores 28 (sum of 0-7) at position 8 (start of Block 1)
    # - Calculation: TPB * (block_idx.x + 1)
    # Block 0: 8 * (0 + 1) = position 8
    # Block 1: No action (last block)
    # Memory state:
    # [0,1,3,6,10,15,21,28 | 28,45,55,66,78,91,105]
    #                        ↑
    #                       Block 0's sum stored here
    if local_i == TPB - 1 and block_idx.x < size // TPB - 1:
        out[TPB * (block_idx.x + 1)] = shared[local_i]

    # wait for all blocks to store their sums
    barrier()

    # second pass: add previous block's sum which becomes:
    # Before: [8,9,10,11,12,13,14]
    # Add 28: [36,37,38,39,40,41,42]
    if block_idx.x > 0 and global_i < size:
        shared[local_i] += out[block_idx.x * TPB - 1]

    # final result
    if global_i < size:
        out[global_i] = shared[local_i]


# ANCHOR_END: prefix_sum_complete_solution


def main():
    with DeviceContext() as ctx:
        out = ctx.enqueue_create_buffer[dtype](SIZE).enqueue_fill(0)
        a = ctx.enqueue_create_buffer[dtype](SIZE).enqueue_fill(0)
        with a.map_to_host() as a_host:
            for i in range(SIZE):
                a_host[i] = i

        if argv()[1] == "--simple":
            ctx.enqueue_function[prefix_sum_simple](
                out.unsafe_ptr(),
                a.unsafe_ptr(),
                SIZE,
                grid_dim=BLOCKS_PER_GRID,
                block_dim=THREADS_PER_BLOCK,
            )
        elif argv()[1] == "--complete":
            ctx.enqueue_function[prefix_sum](
                out.unsafe_ptr(),
                a.unsafe_ptr(),
                SIZE,
                grid_dim=BLOCKS_PER_GRID_2,
                block_dim=THREADS_PER_BLOCK_2,
            )
        else:
            raise Error("Invalid argument")

        expected = ctx.enqueue_create_host_buffer[dtype](SIZE).enqueue_fill(0)

        ctx.synchronize()

        with a.map_to_host() as a_host:
            expected[0] = a_host[0]
            for i in range(1, SIZE):
                expected[i] = expected[i - 1] + a_host[i]

        with out.map_to_host() as out_host:
            print("out:", out)
            print("expected:", expected)
            for i in range(SIZE):
                assert_equal(out_host[i], expected[i])
