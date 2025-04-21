from memory import UnsafePointer, stack_allocation
from gpu import thread_idx, block_idx, block_dim, barrier
from gpu.host import DeviceContext
from gpu.memory import AddressSpace
from sys import sizeof, argv
from testing import assert_equal


# ANCHOR: naive_matmul
alias TPB = 3
alias SIZE = 2
alias BLOCKS_PER_GRID = (1, 1)
alias THREADS_PER_BLOCK = (TPB, TPB)
alias dtype = DType.float32


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
alias BLOCKS_PER_GRID_TILED = (3, 3)  # each block convers 3x3 elements
alias THREADS_PER_BLOCK_TILED = (TPB, TPB)

# Block Layout (each block is 3x3 threads):
# [B00][B01][B02]
# [B10][B11][B12]
# [B20][B21][B22]

# Each Block's Thread Layout (3x3):
# [T00 T01 T02]
# [T10 T11 T12]
# [T20 T21 T22]


# Update your prev code to compute a partial dot-product and
# iteratively move the part you copied into shared memory.
# You should be able to do the hard case in 6 global reads.


fn matmul_tiled(
    out: UnsafePointer[Scalar[dtype]],
    a: UnsafePointer[Scalar[dtype]],
    b: UnsafePointer[Scalar[dtype]],
    size: Int,
):
    # FILL ME IN (roughly 23 lines)
    ...


# ANCHOR_END: matmul_tiled


def main():
    with DeviceContext() as ctx:
        out = ctx.enqueue_create_buffer[dtype](SIZE * SIZE).enqueue_fill(0)
        inp1 = ctx.enqueue_create_buffer[dtype](SIZE * SIZE).enqueue_fill(0)
        inp2 = ctx.enqueue_create_buffer[dtype](SIZE * SIZE).enqueue_fill(0)
        expected = ctx.enqueue_create_host_buffer[dtype](SIZE * SIZE).enqueue_fill(0)
        with inp1.map_to_host() as inp1_host, inp2.map_to_host() as inp2_host:
            for row in range(SIZE):
                for col in range(SIZE):
                    # row major: placing elements row by row
                    inp1_host[row * SIZE + col] = row * SIZE + col
                    # column major: placing elements column by column to make `transpose(inp1)`
                    # bonus: which one is more efficient? whether to store `inp2` colum-major
                    # as below or row-major and then transpose when doing the naive matmul
                    inp2_host[row + col * SIZE] = row + col * SIZE

            # inp1 @ inp2.T
            for i in range(SIZE):
                for j in range(SIZE):
                    for k in range(SIZE):
                        expected[i * SIZE + j] += inp1_host[i * SIZE + k] * inp2_host[k + j * SIZE]
        if argv()[1] == "--naive":
            ctx.enqueue_function[naive_matmul](
                out.unsafe_ptr(),
                inp1.unsafe_ptr(),
                inp2.unsafe_ptr(),
                SIZE,
                grid_dim=BLOCKS_PER_GRID,
                block_dim=THREADS_PER_BLOCK,
            )
        elif argv()[1] == "--single-block":
            ctx.enqueue_function[single_block_matmul](
                out.unsafe_ptr(),
                inp1.unsafe_ptr(),
                inp2.unsafe_ptr(),
                SIZE,
                grid_dim=BLOCKS_PER_GRID,
                block_dim=THREADS_PER_BLOCK,
            )
        elif argv()[1] == "--tiled":
            ctx.enqueue_function[matmul_tiled](
                out.unsafe_ptr(),
                inp1.unsafe_ptr(),
                inp2.unsafe_ptr(),
                SIZE,
                grid_dim=BLOCKS_PER_GRID_TILED,
                block_dim=THREADS_PER_BLOCK_TILED,
            )
        else:
            raise Error("Invalid argument")

        ctx.synchronize()

        with out.map_to_host() as out_host:
            print("out:", out_host)
            print("expected:", expected)
            for i in range(SIZE):
                for j in range(SIZE):
                    assert_equal(out_host[i * SIZE + j], expected[i * SIZE + j])
