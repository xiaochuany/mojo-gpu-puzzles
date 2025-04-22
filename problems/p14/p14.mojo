from memory import UnsafePointer, stack_allocation
from gpu import thread_idx, block_idx, block_dim, barrier
from gpu.host import DeviceContext
from gpu.memory import AddressSpace
from sys import sizeof, argv
from testing import assert_equal

alias TPB = 3
alias SIZE = 2
alias BLOCKS_PER_GRID = (1, 1)
alias THREADS_PER_BLOCK = (TPB, TPB)
alias dtype = DType.float32


# ANCHOR: naive_matmul
fn naive_matmul(
    out: UnsafePointer[Scalar[dtype]],
    a: UnsafePointer[Scalar[dtype]],
    b: UnsafePointer[Scalar[dtype]],
    size: Int,
):
    global_i = block_dim.x * block_idx.x + thread_idx.x
    global_j = block_dim.y * block_idx.y + thread_idx.y
    # FILL ME IN (roughly 5 lines)


# ANCHOR_END: naive_matmul


# ANCHOR: single_block_matmul
fn single_block_matmul(
    out: UnsafePointer[Scalar[dtype]],
    a: UnsafePointer[Scalar[dtype]],
    b: UnsafePointer[Scalar[dtype]],
    size: Int,
):
    global_i = block_dim.x * block_idx.x + thread_idx.x
    global_j = block_dim.y * block_idx.y + thread_idx.y
    local_i = thread_idx.x
    local_j = thread_idx.y
    # FILL ME IN (roughly 8 lines)


# ANCHOR_END: single_block_matmul

# ANCHOR: matmul_tiled
alias SIZE_TILED = 8
alias BLOCKS_PER_GRID_TILED = (
    3,
    3,
)  # each block convers 3x3 elements and 3=ceil(8/3)
alias THREADS_PER_BLOCK_TILED = (TPB, TPB)


fn matmul_tiled(
    out: UnsafePointer[Scalar[dtype]],
    a: UnsafePointer[Scalar[dtype]],
    b: UnsafePointer[Scalar[dtype]],
    size: Int,
):
    # FILL ME IN (roughly 22 lines)
    ...


# ANCHOR_END: matmul_tiled


def main():
    with DeviceContext() as ctx:
        size = SIZE_TILED if argv()[1] == "--tiled" else SIZE
        out = ctx.enqueue_create_buffer[dtype](size * size).enqueue_fill(0)
        inp1 = ctx.enqueue_create_buffer[dtype](size * size).enqueue_fill(0)
        inp2 = ctx.enqueue_create_buffer[dtype](size * size).enqueue_fill(0)
        expected = ctx.enqueue_create_host_buffer[dtype](
            size * size
        ).enqueue_fill(0)
        with inp1.map_to_host() as inp1_host, inp2.map_to_host() as inp2_host:
            for row in range(size):
                for col in range(size):
                    # row major: placing elements row by row
                    inp1_host[row * size + col] = row * size + col
                    # also row major for inp2 (not column major)
                    inp2_host[row * size + col] = row * size + col

            # inp1 @ inp2.T
            for i in range(size):
                for j in range(size):
                    for k in range(size):
                        expected[i * size + j] += (
                            inp1_host[i * size + k] * inp2_host[k + j * size]
                        )

        if argv()[1] == "--naive":
            ctx.enqueue_function[naive_matmul](
                out.unsafe_ptr(),
                inp1.unsafe_ptr(),
                inp2.unsafe_ptr(),
                size,
                grid_dim=BLOCKS_PER_GRID,
                block_dim=THREADS_PER_BLOCK,
            )
        elif argv()[1] == "--single-block":
            ctx.enqueue_function[single_block_matmul](
                out.unsafe_ptr(),
                inp1.unsafe_ptr(),
                inp2.unsafe_ptr(),
                size,
                grid_dim=BLOCKS_PER_GRID,
                block_dim=THREADS_PER_BLOCK,
            )
        elif argv()[1] == "--tiled":
            ctx.enqueue_function[matmul_tiled](
                out.unsafe_ptr(),
                inp1.unsafe_ptr(),
                inp2.unsafe_ptr(),
                size,
                grid_dim=BLOCKS_PER_GRID_TILED,
                block_dim=THREADS_PER_BLOCK_TILED,
            )
        else:
            raise Error("Invalid argument")

        ctx.synchronize()

        with out.map_to_host() as out_host:
            print("out:", out_host)
            print("expected:", expected)
            for col in range(size):
                for row in range(size):
                    assert_equal(
                        out_host[col * size + row], expected[col * size + row]
                    )
