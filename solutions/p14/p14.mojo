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


# ANCHOR: naive_matmul_solution
fn naive_matmul(
    out: UnsafePointer[Scalar[dtype]],
    a: UnsafePointer[Scalar[dtype]],
    b: UnsafePointer[Scalar[dtype]],
    size: Int,
):
    global_i = block_dim.x * block_idx.x + thread_idx.x
    global_j = block_dim.y * block_idx.y + thread_idx.y

    if global_i < size and global_j < size:
        total = Scalar[dtype](0)
        for k in range(size):
            total += a[global_i * size + k] * b[k + global_j * size]

        out[global_i * size + global_j] = total


# ANCHOR_END: naive_matmul_solution


# ANCHOR: single_block_matmul_solution
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

    if global_i < size and global_j < size:
        a_shared[local_i * size + local_j] = a[global_i * size + global_j]
        # storing b as is similar to a
        b_shared[local_i * size + local_j] = b[global_i * size + global_j]

    barrier()

    for k in range(size):
        out[local_i * size + local_j] += (
            a_shared[local_i * size + k] * b_shared[k + local_j * size]
        )


# ANCHOR_END: single_block_matmul_solution


alias SIZE_TILED = 8
alias BLOCKS_PER_GRID_TILED = (3, 3)  # each block convers 3x3 elements
alias THREADS_PER_BLOCK_TILED = (TPB, TPB)


# ANCHOR: matmul_tiled_solution
fn matmul_tiled(
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

    global_row = block_idx.x * TPB + thread_idx.x
    global_col = block_idx.y * TPB + thread_idx.y
    local_row = thread_idx.x
    local_col = thread_idx.y
    acc = Scalar[dtype](0)

    for tile in range((size + TPB - 1) // TPB):
        if local_row < TPB and local_col < TPB:
            a_shared[local_row * TPB + local_col] = 0
            b_shared[local_row * TPB + local_col] = 0

        barrier()

        # Load tile of A
        if global_row < size and (tile * TPB + local_col) < size:
            a_shared[local_row * TPB + local_col] = a[
                global_row * size + (tile * TPB + local_col)
            ]

        # Load tile of B (transposed access)
        if (tile * TPB + local_row) < size and global_col < size:
            b_shared[local_row * TPB + local_col] = b[
                (tile * TPB + local_row) + global_col * size
            ]

        barrier()

        # Compute partial dot product
        if global_row < size and global_col < size:
            for k in range(min(TPB, size - tile * TPB)):
                acc += (
                    a_shared[local_row * TPB + k]
                    * b_shared[k * TPB + local_col]
                )

        barrier()

    if global_row < size and global_col < size:
        out[global_row * size + global_col] = acc


# ANCHOR_END: matmul_tiled_solution


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
