## Code to Complete

Implement a kernel that broadcast adds vector `a` and vector `b` and stores it in `LayoutTensor` `out`. You have more threads than positions.

```mojo
{{#include ../../../problems/p05/p05_layout_tensor.mojo:broadcast_add_layout_tensor}}
```
<a href="../../../problems/p05/p05_layout_tensor.mojo" class="filename">View full file: problems/p05/p05_layout_tensor.mojo</a>

## Running the Code

To test your solution, run the following command in your terminal:

```bash
magic run p05_layout_tensor
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([0.0, 1.0, 1.0, 2.0])
```

## Solution

<details>
<summary>Click to see the solution</summary>

```mojo
{{#include ../../../solutions/p05/p05.mojo:broadcast_add_solution}}
```
