# Puzzle 1: Map

GPU programming is all about parallelism. In this puzzle, each thread will process a single element of the input array independently.
Implement a kernel that adds \\(10\\) to each position of vector \\(a\\) and stores it in vector \\(out\\). You have 1 thread per position.

original

![Map operation visualization](https://raw.githubusercontent.com/srush/GPU-Puzzles/main/GPU_puzzlers_files/GPU_puzzlers_14_1.svg)


vs mermaid with a lot more

<div class="mermaid-container">
    <div class="zoom-controls">
        <button onclick="zoomMermaid(1.2)" title="Zoom In">+</button>
        <button onclick="zoomMermaid(0.8)" title="Zoom Out">-</button>
        <button onclick="resetMermaidZoom()" title="Reset">Reset</button>
    </div>

```mermaid
%%{init: {
  'theme': 'neutral',
  'flowchart': {
    'diagramPadding': 20,
    'nodeSpacing': 150,
    'rankSpacing': 150,
    'width': 2000,
    'height': 1000
  },
  'themeVariables': {
    'fontSize': '24px',
    'fontFamily': 'arial'
  }
}}%%
graph LR
    classDef inputArray fill:#e1f5fe,stroke:#0288d1,stroke-width:3px,color:black
    classDef threadBlock fill:#fff9c4,stroke:#fbc02d,stroke-width:3px,color:black,rx:10,ry:10
    classDef outputArray fill:#e8f5e9,stroke:#4caf50,stroke-width:3px,color:black
    classDef threadText font-weight:bold,font-family:monospace

    subgraph Input["Input Array a"]
        A0["a[0] = 0"] --- A1["a[1] = 1"] --- A2["a[2] = 2"] --- A3["a[3] = 3"]
    end

    subgraph ThreadBlock["GPU Thread Block (BLOCKS_PER_GRID=1, THREADS_PER_BLOCK=4)"]
        T0["Thread 0<br><code>local_i = 0</code>"] ---
        T1["Thread 1<br><code>local_i = 1</code>"] ---
        T2["Thread 2<br><code>local_i = 2</code>"] ---
        T3["Thread 3<br><code>local_i = 3</code>"]
    end

    subgraph Output["Output Array out"]
        O0["out[0] = 10"] --- O1["out[1] = 11"] --- O2["out[2] = 12"] --- O3["out[3] = 13"]
    end

    A0 -. "Read a[local_i]" .-> T0
    A1 -. "Read a[local_i]" .-> T1
    A2 -. "Read a[local_i]" .-> T2
    A3 -. "Read a[local_i]" .-> T3

    T0 -- "<code>a[local_i] + 10</code>" --> O0
    T1 -- "<code>a[local_i] + 10</code>" --> O1
    T2 -- "<code>a[local_i] + 10</code>" --> O2
    T3 -- "<code>a[local_i] + 10</code>" --> O3

    class A0,A1,A2,A3 inputArray
    class T0,T1,T2,T3 threadBlock
    class O0,O1,O2,O3 outputArray
```

</div>

## Key concepts

In this puzzle, you'll learn about:
- Basic GPU kernel structure
- Thread indexing with `thread_idx.x`
- Simple parallel operations

The key insight is that each thread \\(i\\) computes: \\[out[i] = a[i] + 10\\]

- **Parallelism**: Each thread executes independently
- **Thread indexing**: Access element at position \\(i = \\text{thread\_idx.x}\\)
- **Memory access**: Read from \\(a[i]\\) and write to \\(out[i]\\)
- **Data independence**: Each output depends only on its corresponding input

## Code to complete

```mojo
{{#include ../../../problems/p01/p01.mojo:add_10}}
```
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p01/p01.mojo" class="filename">View full file: problems/p01/p01.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Store `thread_idx.x` in `local_i`
2. Add 10 to `a[local_i]`
3. Store result in `out[local_i]`
</div>
</details>

## Running the code

To test your solution, run the following command in your terminal:

```bash
magic run p01
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
{{#include ../../../solutions/p01/p01.mojo:add_10_solution}}
```

<div class="solution-explanation">

This solution:
- Gets thread index with `local_i = thread_idx.x`
- Adds 10 to input value: `out[local_i] = a[local_i] + 10.0`
</div>
</details>



