# Puzzle 4: 2D Map

## Overview
Implement a kernel that adds 10 to each position of 2D square matrix `a` and stores it in 2D square matrix `out`.

**Note:** _You have more threads than positions_.

![2D Matrix Mapping](./media/videos/720p30/puzzle_04_viz.gif)

## Key concepts
- 2D thread indexing
- Matrix operations on GPU
- Handling excess threads
- Memory layout patterns

For each position \\((i,j)\\):
\\[\Large out[i,j] = a[i,j] + 10\\]


## Implementation approaches

### [🔰 Raw memory approach](./raw.md)
Learn how 2D indexing works with manual memory management.

### [📚 Learn about LayoutTensor](./introduction_layout_tensor.md)
Discover a powerful abstraction that simplifies multi-dimensional array operations and memory management on GPU.

### [🚀 Modern 2D operations](./layout_tensor.md)
Put LayoutTensor into practice with natural 2D indexing and automatic bounds checking.

💡 **Note**: From this puzzle onward, we'll primarily use LayoutTensor for cleaner, safer GPU code.
