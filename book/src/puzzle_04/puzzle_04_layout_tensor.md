## Code to Complete

Implement a kernel that adds 10 to each position of 2D `LayoutTensor` `a` and stores it in 2D `LayoutTensor` `out`. You have more threads than positions.

```mojo
{{#include ../../../problems/p04/p04_layout_tensor.mojo:add_10_2d_layout_tensor}}
```
<a href="../../../problems/p04/p04_layout_tensor.mojo" class="filename">View full file: problems/p04/p04_layout_tensor.mojo</a>

## Running the Code

To test your solution, run the following command in your terminal:

```bash
magic run p04_layout_tensor
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([10.0, 11.0, 12.0, 13.0])
```

## Solution

<details>
<summary>Click to see the solution</summary>

```mojo
{{#include ../../../solutions/p04/p04_layout_tensor.mojo:add_10_2d_layout_tensor_solution}}
```

<div class="solution-explanation">

This solution:
- Uses `tensor[i, j]` syntax to get the elements at position `(i, j)`
- Checks if both coordinates are within the array bounds
- Adds 10 to the value when the guard conditions are met

</div>
</details>
