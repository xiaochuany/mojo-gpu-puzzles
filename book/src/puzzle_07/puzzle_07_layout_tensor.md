## Code to Complete

Implement a kernel that adds 10 to each position of 2D `LayoutTensor` `a` and stores it in 2D `LayoutTensor` `out`. You have fewer threads per block than the size of `a` in both directions.

```mojo
{{#include ../../../problems/p07/p07_layout_tensor.mojo:add_10_blocks_2d_layout_tensor}}
```
<a href="../../../problems/p07/p07.mojo" class="filename">View full file: problems/p07/p07.mojo</a>


## Running the Code

To test your solution, run the following command in your terminal:

```bash
magic run p07_layout_tensor
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0, 0.0, 0.0, ... , 0.0])
expected: HostBuffer([11.0, 11.0, 11.0, ... , 11.0])
```

## Solution

<details>
<summary>Click to see the solution</summary>

```mojo
{{#include ../../../solutions/p07/p07_layout_tensor.mojo:add_10_blocks_2d_layout_tensor_solution}}
```
