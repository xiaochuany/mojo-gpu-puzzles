# Introduction to LayoutTensor

After dealing with manual indexing, bounds checking, and growing complexity in the previous puzzles, it's time to introduce a powerful abstraction that will make GPU programming more intuitive and safer.

## Why [LayoutTensor](https://docs.modular.com/mojo/stdlib/layout/layout_tensor/LayoutTensor/)?

Let's look at the challenges we've faced:

```mojo
# Puzzle 1: Simple indexing
out[local_i] = a[local_i] + 10.0

# Puzzle 2: Multiple array management
out[local_i] = a[local_i] + b[local_i]

# Puzzle 3: Bounds checking
if local_i < size:
    out[local_i] = a[local_i] + 10.0
```

As dimensions grow, code becomes more complex:
```mojo
# Traditional 2D indexing for row-major 2D matrix
idx = col * WIDTH + row
if row < height and col < width:
    out[idx] = a[idx] + 10.0
```

## The LayoutTensor solution

[LayoutTensor](https://docs.modular.com/mojo/stdlib/layout/layout_tensor/LayoutTensor/) provides:
1. **Natural Indexing**: Use `tensor[i, j]` instead of manual offset calculations
2. **Automatic Bounds Checking**: Built-in protection against out-of-bounds access
3. **Flexible Memory Layouts**: Support for row-major, column-major, and tiled organizations
4. **Performance Optimization**: Efficient memory access patterns for GPU

### Basic usage

```mojo
from layout import Layout, LayoutTensor

# Define layout
alias HEIGHT = 2
alias WIDTH = 3
alias layout = Layout.row_major(HEIGHT, WIDTH)

# Create tensor
tensor = LayoutTensor[dtype, layout](buffer.unsafe_ptr())

# Access elements naturally
tensor[0, 0] = 1.0  # First element
tensor[1, 2] = 2.0  # Last element
```

### Memory layout control

LayoutTensor supports different memory organizations:
```mojo
# Row-major (default)
layout_row = Layout.row_major(HEIGHT, WIDTH)

# Column-major
layout_col = Layout.col_major(HEIGHT, WIDTH)

# Tiled (for better cache utilization)
layout_tiled = tensor.tiled[4, 4](HEIGHT, WIDTH)
```

### Understanding memory layouts

Memory layout affects performance dramatically. LayoutTensor supports:

- **Row-major**: Elements in a row are contiguous
  ```mojo
  # [1 2 3]
  # [4 5 6] -> [1 2 3 4 5 6]
  layout_row = Layout.row_major(2, 3)
  ```

- **Column-major**: Elements in a column are contiguous
  ```mojo
  # [1 2 3]
  # [4 5 6] -> [1 4 2 5 3 6]
  layout_col = Layout.col_major(2, 3)
  ```

- **Tiled**: Elements grouped in tiles for cache efficiency
  ```mojo
  # [[1 2] [3 4]] in 2x2 tiles
  layout_tiled = Layout.tiled[2, 2](4, 4)
  ```

### Benefits over traditional approach

1. **Readability**:
   ```mojo
   # Traditional
   out[col * WIDTH + row] = a[col * WIDTH + row] + 10.0

   # LayoutTensor
   out[row, col] = a[row, col] + 10.0
   ```

2. **Flexibility**:
   - Easy to change memory layouts without modifying computation code
   - Support for complex access patterns
   - Built-in optimizations

## Advanced features preview

While we'll start with basic operations, LayoutTensor's true power shines in advanced GPU optimizations:

### 1. Memory hierarchy management
```mojo
# Shared memory allocation
shared_mem = tb[dtype]().row_major[BM, BK]().shared().alloc()

# Register allocation
reg_tile = tb[dtype]().row_major[TM, TN]().local().alloc()
```

### 2. Tiling strategies
```mojo
# Block tiling
block_tile = tensor.tile[BM, BN](block_idx.y, block_idx.x)

# Register tiling
reg_tile = block_tile.tile[TM, TN](thread_row, thread_col)
```

### 3. Memory access patterns
```mojo
# Vectorized access
vec_tensor = tensor.vectorize[1, simd_width]()

# Asynchronous transfers
copy_dram_to_sram_async[thread_layout=layout](dst, src)
```

### 4. Hardware acceleration
```mojo
# Tensor Core operations (coming in later puzzles)
mma_op = TensorCore[dtype, out_type, Index(M, N, K)]()
result = mma_op.mma_op(a_reg, b_reg, c_reg)
```

💡 **Looking Ahead**: As we progress through the puzzles, you'll learn how to:

- Use shared memory for faster data access
- Implement efficient tiling strategies
- Leverage vectorized operations
- Utilize hardware accelerators
- Optimize memory access patterns

Each puzzle will introduce these concepts gradually, building on the fundamentals to create highly optimized GPU code.

Ready to start your journey from basic operations to advanced GPU programming? Let's begin with the fundamentals!

## Quick example

Let's put everything together with a simple example that demonstrates the basics of LayoutTensor:

```mojo
{{#include ./intro.mojo}}
```

When we run this code with `magic run layout_tensor_intro`, we see:

```txt
Before:
0.0 0.0 0.0
0.0 0.0 0.0
After:
1.0 0.0 0.0
0.0 0.0 0.0
```

Let's break down what's happening:
1. We create a `2 x 3` tensor with row-major layout
2. Initially, all elements are zero
3. Using natural indexing, we modify a single element
4. The change is reflected in our output

This simple example demonstrates key LayoutTensor benefits:
- Clean syntax for tensor creation and access
- Automatic memory layout handling
- Built-in bounds checking
- Natural multi-dimensional indexing

While this example is straightforward, the same patterns will scale to complex GPU operations in upcoming puzzles. You'll see how these basic concepts extend to:
- Multi-threaded GPU operations
- Shared memory optimizations
- Complex tiling strategies
- Hardware-accelerated computations

Ready to start your GPU programming journey with LayoutTensor? Let's dive into the puzzles!

💡 **Tip**: Keep this example in mind as we progress - we'll build upon these fundamental concepts to create increasingly sophisticated GPU programs.
