from memory import UnsafePointer, stack_allocation
from gpu import thread_idx, block_idx, block_dim, barrier
from gpu.host import DeviceContext
from gpu.memory import AddressSpace
from sys import sizeof
from testing import assert_equal

alias MAX_CONV = 4
alias TPB = 8
alias TPB_MAX_CONV = TPB + MAX_CONV
# test 1
alias SIZE = 6
alias CONV = 3
alias BLOCKS_PER_GRID = (1, 1)
alias THREADS_PER_BLOCK = (TPB, 1)

# comment out above and uncomment below for test #2
# alias SIZE = 15
# alias CONV = 4
# alias BLOCKS_PER_GRID = (2, 1)
# alias THREADS_PER_BLOCK = (TPB, 1)

alias dtype = DType.float32


# this is good enough to pass test 1 but why it doesn't work for test 2
fn conv_1d_simple(
    out: UnsafePointer[Scalar[dtype]],
    a: UnsafePointer[Scalar[dtype]],
    b: UnsafePointer[Scalar[dtype]],
    a_size: Int,
    b_size: Int,
):
    shared_a = stack_allocation[
        SIZE * sizeof[dtype](),
        Scalar[dtype],
        address_space = AddressSpace.SHARED,
    ]()
    shared_b = stack_allocation[
        CONV * sizeof[dtype](),
        Scalar[dtype],
        address_space = AddressSpace.SHARED,
    ]()
    global_i = block_dim.x * block_idx.x + thread_idx.x
    local_i = thread_idx.x
    if global_i < a_size:
        shared_a[local_i] = a[global_i]

    if global_i < b_size:
        shared_b[local_i] = b[global_i]

    barrier()

    # Note: this is unsafe as it enforces no guard so could access `shared_a` beyond its bounds
    # local_sum = Scalar[dtype](0)
    # for j in range(CONV):
    #     if local_i + j < SIZE:
    #         local_sum += shared_a[local_i + j] * shared_b[j]

    # if global_i < a_size:
    #     out[global_i] = local_sum

    # Safe and correct:
    if global_i < a_size:
        local_sum = Scalar[dtype](0)
        for j in range(CONV):
            # Bonus: do we need this check for this specific example with fixed SIZE, CONV
            if local_i + j < SIZE:
                local_sum += shared_a[local_i + j] * shared_b[j]

        out[global_i] = local_sum


fn conv_1d_block_boundary(
    out: UnsafePointer[Scalar[dtype]],
    a: UnsafePointer[Scalar[dtype]],
    b: UnsafePointer[Scalar[dtype]],
    a_size: Int,
    b_size: Int,
):
    # first: need to account for padding
    shared_a = stack_allocation[
        (TPB + CONV - 1) * sizeof[dtype](),
        Scalar[dtype],
        address_space = AddressSpace.SHARED,
    ]()
    shared_b = stack_allocation[
        CONV * sizeof[dtype](),
        Scalar[dtype],
        address_space = AddressSpace.SHARED,
    ]()
    global_i = block_dim.x * block_idx.x + thread_idx.x
    local_i = thread_idx.x
    if global_i < a_size:
        shared_a[local_i] = a[global_i]

    # second: load elements needed for convolution at block boundary
    if local_i < CONV - 1:
        # indices from next block
        next_idx = global_i + TPB
        if next_idx < a_size:
            shared_a[TPB + local_i] = a[next_idx]

    if local_i < b_size:
        shared_b[local_i] = b[local_i]

    barrier()

    if global_i < a_size:
        local_sum = Scalar[dtype](0)
        for j in range(CONV):
            if local_i + j < TPB + CONV - 1:
                local_sum += shared_a[local_i + j] * shared_b[j]

        out[global_i] = local_sum


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

        ctx.enqueue_function[conv_1d_simple](
            out.unsafe_ptr(),
            a.unsafe_ptr(),
            b.unsafe_ptr(),
            SIZE,
            CONV,
            grid_dim=BLOCKS_PER_GRID,
            block_dim=THREADS_PER_BLOCK,
        )

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
