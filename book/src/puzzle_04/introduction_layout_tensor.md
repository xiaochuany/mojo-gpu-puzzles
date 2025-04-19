## Introduction to LayoutTensor

[LayoutTensor](https://docs.modular.com/mojo/stdlib/layout/layout_tensor/LayoutTensor/) provides a powerful abstraction for multi-dimensional data with precise control over memory organization. It supports various memory layouts (row-major, column-major, tiled), hardware-specific optimizations, and efficient parallel access patterns.

Given a `LayoutTensor` instance `a`

```mojo
from gpu.host import DeviceContext
from layout import Layout, LayoutTensor

alias HEIGHT = 2
alias WIDTH = 3
alias dtype = DType.float32
alias layout = Layout.row_major(HEIGHT, WIDTH)

def main():
    ctx = DeviceContext()
    a = ctx.enqueue_create_buffer[dtype](HEIGHT * WIDTH).enqueue_fill(0)
    a_tensor = LayoutTensor[mut=True, dtype, layout](a_ptr)
    a_tensor[0, 1] += 10
    ctx.synchronize()
```

we can get the `(i, j)` elements with the more familiar syntax `a_tensor[i, j]` which in the row-major case is the same as `a_ptr[j * WIDTH + i]`.

This abstraction makes multi-dimensional array access more intuitive and less error-prone, as it handles the complex linear memory mapping internally. Instead of manually calculating indices with formulas like `j * WIDTH + i`, we can use the natural `[i, j]` notation. We will explore more powerful features of `LayoutTensor` in upcoming puzzles, including different memory layouts, tiling, and optimized access patterns.
