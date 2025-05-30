from gpu import thread_idx, block_idx, block_dim, barrier
from gpu.host import DeviceContext
from layout import Layout, LayoutTensor
from layout.tensor_builder import LayoutTensorBuild as tb

# ANCHOR: conv1d_kernel
alias TPB = 15
alias BLOCKS_PER_GRID = (2, 1)


fn conv1d_kernel[
    in_layout: Layout,
    out_layout: Layout,
    conv_layout: Layout,
    input_size: Int,
    conv_size: Int,
    dtype: DType = DType.float32,
](
    out: LayoutTensor[mut=True, dtype, out_layout],
    input: LayoutTensor[mut=True, dtype, in_layout],
    kernel: LayoutTensor[mut=True, dtype, conv_layout],
):
    global_i = block_dim.x * block_idx.x + thread_idx.x
    local_i = thread_idx.x
    # first: need to account for padding
    shared_a = tb[dtype]().row_major[TPB + conv_size - 1]().shared().alloc()
    shared_b = tb[dtype]().row_major[conv_size]().shared().alloc()
    if global_i < input_size:
        shared_a[local_i] = input[global_i]

    # second: load elements needed for convolution at block boundary
    if local_i < conv_size - 1:
        # indices from next block
        next_idx = global_i + TPB
        if next_idx < input_size:
            shared_a[TPB + local_i] = input[next_idx]

    if local_i < conv_size:
        shared_b[local_i] = kernel[local_i]

    barrier()

    if global_i < input_size:
        var local_sum: out.element_type = 0

        @parameter
        for j in range(conv_size):
            if local_i + j < TPB + conv_size - 1:
                local_sum += shared_a[local_i + j] * shared_b[j]

        out[global_i] = local_sum


# ANCHOR_END: conv1d_kernel


# ANCHOR: conv1d_custom_op
import compiler
from runtime.asyncrt import DeviceContextPtr
from tensor import InputTensor, OutputTensor
from memory import UnsafePointer
from gpu.host import DeviceBuffer


@compiler.register("conv1d")
struct Conv1DCustomOp:
    @staticmethod
    fn execute[
        # The kind of device this will be run on: "cpu" or "gpu"
        target: StaticString,
        input_size: Int,
        conv_size: Int,
        dtype: DType = DType.float32,
    ](
        out: OutputTensor[rank=1],
        input: InputTensor[type = out.type, rank = out.rank],
        kernel: InputTensor[type = out.type, rank = out.rank],
        # the context is needed for some GPU calls
        ctx: DeviceContextPtr,
    ) raises:
        out_tensor = out.to_layout_tensor()
        input_tensor = input.to_layout_tensor()
        kernel_tensor = kernel.to_layout_tensor()
        alias in_layout = input_tensor.layout
        alias out_layout = out_tensor.layout
        alias conv_layout = kernel_tensor.layout

        @parameter
        if target == "gpu":
            gpu_ctx = ctx.get_device_context()
            # making sure the output tensor is zeroed out before the kernel is called
            gpu_ctx.enqueue_memset(
                DeviceBuffer[out.type](
                    gpu_ctx,
                    rebind[UnsafePointer[Scalar[out.type]]](out_tensor.ptr),
                    input_size,
                    owning=False,
                ),
                0,
            )

            # FILL ME IN with 1 line calling our conv1d_kernel

        elif target == "cpu":
            # we can fallback to CPU
            pass
        else:
            raise Error("Unsupported target: " + target)


# ANCHOR_END: conv1d_custom_op
