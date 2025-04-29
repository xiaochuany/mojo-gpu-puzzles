# Puzzle 1: Map

## Overview

GPU programming is all about parallelism. In this puzzle, each thread will process a single element of the input array independently.
Implement a kernel that adds 10 to each position of vector `a` and stores it in vector `out`.

**Note:** _You have 1 thread per position._

![Map](./media/videos/720p30/puzzle_01_viz.gif)

## Key concepts

In this puzzle, you'll learn about:
- Basic GPU kernel structure
- Thread indexing with `thread_idx.x`
- Simple parallel operations

The key insight is that each thread \\(i\\) computes:
\\[\Large out[i] = a[i] + 10\\]

- **Parallelism**: Each thread executes independently
- **Thread indexing**: Access element at position \\(i = \\text{thread\_idx.x}\\)
- **Memory access**: Read from \\(a[i]\\) and write to \\(out[i]\\)
- **Data independence**: Each output depends only on its corresponding input

- [Tranditional way](./traditional.md)
- [LayoutTensor Preview](./layout_tensor_preview.md)
