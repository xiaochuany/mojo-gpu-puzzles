from memory import UnsafePointer
from gpu import thread_idx, block_idx, block_dim
from gpu.host import DeviceContext
from testing import assert_equal

# ANCHOR: add_10_blocks
alias SIZE = 9
alias BLOCKS_PER_GRID = (3, 1)
alias THREADS_PER_BLOCK = (4, 1)
alias dtype = DType.float32


fn add_10_blocks(
    out: UnsafePointer[Scalar[dtype]],
    a: UnsafePointer[Scalar[dtype]],
    size: Int,
):
    i = block_dim.x * block_idx.x + thread_idx.x
    # FILL ME IN (roughly 2 lines)
    if i<SIZE:
        out[i] = a[i] + 10


# ANCHOR_END: add_10_blocks


def main():
    with DeviceContext() as ctx:
        out = ctx.enqueue_create_buffer[dtype](SIZE).enqueue_fill(0)
        a = ctx.enqueue_create_buffer[dtype](SIZE).enqueue_fill(0)
        expected = ctx.enqueue_create_host_buffer[dtype](SIZE).enqueue_fill(0)
        with a.map_to_host() as a_host:
            for i in range(SIZE):
                a_host[i] = i
                expected[i] = i + 10    

        ctx.enqueue_function[add_10_blocks](
            out.unsafe_ptr(),
            a.unsafe_ptr(),
            SIZE,
            grid_dim=BLOCKS_PER_GRID,
            block_dim=THREADS_PER_BLOCK,
        )

        ctx.synchronize()

        with out.map_to_host() as out_host:
            print("out:", out_host)
            print("expected:", expected)
            for i in range(SIZE):
                assert_equal(out_host[i], expected[i])
