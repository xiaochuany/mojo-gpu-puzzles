from gpu import thread_idx, block_idx, block_dim, barrier
from gpu.host import DeviceContext
from layout import Layout, LayoutTensor
from layout.tensor_builder import LayoutTensorBuild as tb
from sys import sizeof, argv
from math import log2
from testing import assert_equal

alias TPB = 8
alias SIZE = 8
alias BLOCKS_PER_GRID = (1, 1)
alias THREADS_PER_BLOCK = (TPB, 1)
alias dtype = DType.float32
alias layout = Layout.row_major(SIZE)


# ANCHOR: prefix_sum_simple_solution
fn prefix_sum_simple[layout: Layout](
    out: LayoutTensor[mut=False, dtype, layout],
    a: LayoutTensor[mut=False, dtype, layout],
    size: Int,
):
    global_i = block_dim.x * block_idx.x + thread_idx.x
    local_i = thread_idx.x
    shared = tb[dtype]().row_major[TPB]().shared().alloc()
    if global_i < size:
        shared[local_i] = a[global_i]

    barrier()

    offset = 1
    for i in range(Int(log2(Scalar[dtype](TPB)))):
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
fn prefix_sum[layout: Layout](
    out: LayoutTensor[mut=False, dtype, layout],
    a: LayoutTensor[mut=False, dtype, layout],
    size: Int,
):
    global_i = block_dim.x * block_idx.x + thread_idx.x
    local_i = thread_idx.x
    shared = tb[dtype]().row_major[TPB]().shared().alloc()
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
    for i in range(Int(log2(Scalar[dtype](TPB)))):
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

        out_tensor = LayoutTensor[mut=False, dtype, layout](out.unsafe_ptr())
        a_tensor = LayoutTensor[mut=False, dtype, layout](a.unsafe_ptr())

        if argv()[1] == "--simple":
            ctx.enqueue_function[prefix_sum_simple[layout]](
                out_tensor,
                a_tensor,
                SIZE,
                grid_dim=BLOCKS_PER_GRID,
                block_dim=THREADS_PER_BLOCK,
            )
        elif argv()[1] == "--complete":
            ctx.enqueue_function[prefix_sum[layout]](
                out_tensor,
                a_tensor,
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
