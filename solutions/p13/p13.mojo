from memory import UnsafePointer, stack_allocation
from gpu import thread_idx, block_idx, block_dim, barrier
from gpu.host import DeviceContext
from gpu.memory import AddressSpace
from sys import sizeof
from testing import assert_equal

alias TPB = 8
alias BATCH = 4
alias SIZE = 6
alias BLOCKS_PER_GRID = (1, BATCH)
alias THREADS_PER_BLOCK = (TPB, 1)
alias dtype = DType.float32


# ANCHOR: axis_sum_solution
fn axis_sum(
    out: UnsafePointer[Scalar[dtype]],
    a: UnsafePointer[Scalar[dtype]],
    size: Int,
):
    cache = stack_allocation[
        TPB * sizeof[dtype](),
        Scalar[dtype],
        address_space = AddressSpace.SHARED,
    ]()
    global_i = block_dim.x * block_idx.x + thread_idx.x
    local_i = thread_idx.x
    batch = block_idx.y

    # Visualize:
    # Block(0,0): [T0,T1,T2,T3,T4,T5,T6,T7] -> Row 0: [0,1,2,3,4,5]
    # Block(0,1): [T0,T1,T2,T3,T4,T5,T6,T7] -> Row 1: [6,7,8,9,10,11]
    # Block(0,2): [T0,T1,T2,T3,T4,T5,T6,T7] -> Row 2: [12,13,14,15,16,17]
    # Block(0,3): [T0,T1,T2,T3,T4,T5,T6,T7] -> Row 3: [18,19,20,21,22,23]

    # each row is handled by each block bc we have grid_dim=(1, BATCH)

    if global_i < size:
        # the following is wrong bc it doesn't account for which row i.e batch we're
        # cache[local_i] = a[global_i]
        # moreover,
        # cache[local_i] = a[batch * size + global_i]
        # reaches beyond the size limit so
        cache[local_i] = a[batch * size + local_i]

    barrier()

    # do reduction sum per each block
    stride = TPB // 2
    while stride > 0:
        if local_i < size:
            cache[local_i] += cache[local_i + stride]

        barrier()
        stride //= 2

    # writing with local thread = 0 that has the sum
    if local_i == 0:
        # write to position based on batch number
        out[batch] = cache[0]


# ANCHOR_END: axis_sum_solution


def main():
    with DeviceContext() as ctx:
        out = ctx.enqueue_create_buffer[dtype](BATCH).enqueue_fill(0)
        inp = ctx.enqueue_create_buffer[dtype](BATCH * SIZE).enqueue_fill(0)
        with inp.map_to_host() as inp_host:
            for i in range(BATCH * SIZE):
                inp_host[i] = i

        ctx.enqueue_function[axis_sum](
            out.unsafe_ptr(),
            inp.unsafe_ptr(),
            SIZE,
            grid_dim=BLOCKS_PER_GRID,
            block_dim=THREADS_PER_BLOCK,
        )

        expected = ctx.enqueue_create_host_buffer[dtype](BATCH).enqueue_fill(0)
        with inp.map_to_host() as inp_host:
            for row in range(BATCH):
                for col in range(SIZE):
                    expected[row] += inp_host[row * SIZE + col]

        ctx.synchronize()

        with out.map_to_host() as out_host:
            print("out:", out)
            print("expected:", expected)
            for i in range(BATCH):
                assert_equal(out_host[i], expected[i])
