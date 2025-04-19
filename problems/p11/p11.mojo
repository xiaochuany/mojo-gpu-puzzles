from memory import UnsafePointer, stack_allocation
from gpu import thread_idx, block_idx, block_dim, barrier
from gpu.host import DeviceContext
from gpu.memory import AddressSpace
from sys import sizeof, argv
from testing import assert_equal

# ANCHOR: conv_1d_simple
alias MAX_CONV = 4
alias TPB = 8
alias TPB_MAX_CONV = TPB + MAX_CONV
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
    global_i = block_dim.x * block_idx.x + thread_idx.x
    local_i = thread_idx.x
    # FILL ME IN (roughly 12 lines)


# ANCHOR_END: conv_1d_simple


# ANCHOR: conv_1d_block_boundary
alias SIZE_2 = 15
alias CONV_2 = 4
alias BLOCKS_PER_GRID_2 = (2, 1)
alias THREADS_PER_BLOCK_2 = (TPB, 1)


fn conv_1d_block_boundary(
    out: UnsafePointer[Scalar[dtype]],
    a: UnsafePointer[Scalar[dtype]],
    b: UnsafePointer[Scalar[dtype]],
    a_size: Int,
    b_size: Int,
):
    global_i = block_dim.x * block_idx.x + thread_idx.x
    local_i = thread_idx.x
    # FILL ME IN (roughly 17 lines)


# ANCHOR_END: conv_1d_block_boundary


def main():
    with DeviceContext() as ctx:
        out = ctx.enqueue_create_buffer[dtype](SIZE).enqueue_fill(0)
        a = ctx.enqueue_create_buffer[dtype](SIZE).enqueue_fill(0)
        b = ctx.enqueue_create_buffer[dtype](CONV).enqueue_fill(0)
        with a.map_to_host() as a_host:
            for i in range(SIZE):
                a_host[i] = i

        with b.map_to_host() as b_host:
            for i in range(CONV):
                b_host[i] = i

        if argv()[1] == "--simple":
            ctx.enqueue_function[conv_1d_simple](
                out.unsafe_ptr(),
                a.unsafe_ptr(),
                b.unsafe_ptr(),
                SIZE,
                CONV,
                grid_dim=BLOCKS_PER_GRID,
                block_dim=THREADS_PER_BLOCK,
            )
        elif argv()[1] == "--block-boundary":
            ctx.enqueue_function[conv_1d_block_boundary](
                out.unsafe_ptr(),
                a.unsafe_ptr(),
                b.unsafe_ptr(),
                SIZE,
                CONV,
                grid_dim=BLOCKS_PER_GRID_2,
                block_dim=THREADS_PER_BLOCK_2,
            )
        else:
            raise Error("Invalid argument")

        expected = ctx.enqueue_create_host_buffer[dtype](SIZE).enqueue_fill(0)

        ctx.synchronize()

        with a.map_to_host() as a_host, b.map_to_host() as b_host:
            for i in range(SIZE):
                for j in range(CONV):
                    if i + j < SIZE:
                        expected[i] += a_host[i + j] * b_host[j]

        with out.map_to_host() as out_host:
            print("out:", out_host)
            print("expected:", expected)
            for i in range(SIZE):
                for j in range(CONV):
                    if i + j < SIZE:
                        assert_equal(out_host[i + j], expected[i + j])
