# Puzzle 7: 2D Blocks

## Overview
Implement a kernel that adds 10 to each position of matrix `a` and stores it in `out`.

**Note:** _You have fewer threads per block than the size of `a` in both directions._

![Blocks 2D visualization](./media/videos/720p30/puzzle_07_viz.gif)

## Key concepts
- Block-based processing
- Grid-block coordination
- Multi-block indexing
- Memory access patterns

## Implementation approaches

### [🔰 Raw memory approach](./raw.md)
Learn how to handle multi-block operations with manual indexing.

### [📐 LayoutTensor Version](./layout_tensor.md)
Use LayoutTensor features to elegantly handle block-based processing.

💡 **Note**: See how LayoutTensor simplifies block coordination and memory access patterns.
