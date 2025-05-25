from memory import UnsafePointer
from gpu import thread_idx
from gpu.host import DeviceContext
from testing import assert_equal

alias SIZE = 2
alias BLOCKS_PER_GRID = 1
alias THREADS_PER_BLOCK = (3, 3)
alias dtype = DType.float32

#  2d block, 1d input, 1d output
fn add_10_2d(
    out: UnsafePointer[Scalar[dtype]],
    a: UnsafePointer[Scalar[dtype]],
    size: Int,
):
    row = thread_idx.y
    col = thread_idx.x
    if row < size and col<size: # prevent out of bounds
        out[row * size + col] = a[row * size + col] + 10

def main():
    with DeviceContext() as ctx:
        out = ctx.enqueue_create_buffer[dtype](SIZE * SIZE).enqueue_fill(0)
        expected = ctx.enqueue_create_host_buffer[dtype](
            SIZE * SIZE
        ).enqueue_fill(0)
        a = ctx.enqueue_create_buffer[dtype](SIZE * SIZE).enqueue_fill(0)
        with a.map_to_host() as a_host:
            # row-major
            for i in range(SIZE):
                for j in range(SIZE):
                    a_host[i * SIZE + j] = i * SIZE + j
                    expected[i * SIZE + j] = a_host[i * SIZE + j] + 10

        ctx.enqueue_function[add_10_2d](
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
                for j in range(SIZE):
                    assert_equal(out_host[i * SIZE + j], expected[i * SIZE + j])
