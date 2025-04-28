# Puzzle 11: 1D Convolution

## Overview
In signal processing and image analysis, convolution is a fundamental operation that combines two sequences to produce a third sequence. This puzzle challenges you to implement a 1D convolution on the GPU, where each output element is computed by sliding a kernel over an input array.

Implement a kernel that computes a 1D convolution between vector `a` and vector `b` and stores it in `out`.

**Note:** _You need to handle the general case. You only need 2 global reads and 1 global write per thread._

![1D Convolution](./media/videos/720p30/puzzle_11_viz.gif)

For those new to convolution, think of it as a weighted sliding window operation. At each position, we multiply the kernel values with the corresponding input values and sum the results. In mathematical notation, this is often written as:

\\[\Large out[i] = \sum_{j=0}^{\text{CONV}-1} a[i+j] \cdot b[j] \\]

In pseudocode, 1D convolution is:
```python
for i in range(SIZE):
    for j in range(CONV):
        if i + j < SIZE:
            ret[i] += a_host[i + j] * b_host[j]
```

This puzzle is split into two parts to help you build understanding progressively:

- [Simple version: Single block](./simple.md)
  Start here to learn the basics of implementing convolution with shared memory in a single block.

- [Complete version: Block boundary](./complete.md)
  Then tackle the more challenging case where data needs to be shared across block boundaries.

Each version presents unique challenges in terms of memory access patterns and thread coordination. The simple version helps you understand the basic convolution operation, while the complete version tests your ability to handle more complex scenarios that arise in real-world GPU programming.
