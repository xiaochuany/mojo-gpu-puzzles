# Complete version: Block Boundary Case

## Configuration
- Input array size: `SIZE = 15` elements
- Kernel size: `CONV = 4` elements
- Threads per block: `TPB = 8`
- Number of blocks: 2
- Shared memory: `TPB + CONV - 1` elements for input

Notes:
- **Extended loading**: Account for boundary overlap
- **Block edges**: Handle data across block boundaries
- **Memory layout**: Efficient shared memory usage
- **Synchronization**: Proper thread coordination

## Code to complete

```mojo
{{#include ../../../problems/p11/p11.mojo:conv_1d_block_boundary}}
```
<a href="{{#include ../_includes/repo_url.md}}/blob/main/problems/p11/p11.mojo" class="filename">View full file: problems/p11/p11.mojo</a>

<details>
<summary><strong>Tips</strong></summary>

<div class="solution-tips">

1. Load main data: `shared_a[local_i] = a[global_i]`
2. Load boundary: `if local_i < CONV - 1` handle next block data
3. Load kernel: `shared_b[local_i] = b[local_i]`
4. Sum within extended bounds: `if local_i + j < TPB + CONV - 1`
</div>
</details>

### Running the code

To test your solution, run the following command in your terminal:

```bash
magic run p11 --block-boundary
```

Your output will look like this if the puzzle isn't solved yet:
```txt
out: HostBuffer([0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
expected: HostBuffer([5.0, 8.0, 11.0, 14.0, 5.0, 0.0])
```

## Solution

<details class="solution-details">
<summary></summary>

```mojo
{{#include ../../../solutions/p11/p11.mojo:conv_1d_block_boundary_solution}}
```

<div class="solution-explanation">

The solution handles block boundary cases in 1D convolution using extended shared memory. Here's a detailed analysis:

### Memory Layout
```txt
Block 0 shared memory:  [0 1 2 3 4 5 6 7|8 9 10]  // TPB elements + (CONV-1) padding
Block 1 shared memory:  [8 9 10 11 12 13 14|0 0]  // Second block with padding
```

### Key Implementation Features:

1. **Extended Shared Memory**:
   ```txt
   Size = TPB + (CONV-1) elements
   |<-- Thread Block Data -->|<-- Overlap -->|
   [    TPB elements        ][  CONV-1 elems ]
   ```

2. **Data Loading Strategy**:
   - Main data: `shared_a[local_i] = a[global_i]`
   - Boundary data: Load `CONV - 1` elements from next block
   - Kernel data: Load once per block

3. **Boundary Handling**:
   ```mojo
   if local_i < CONV - 1:
       next_idx = global_i + TPB
       if next_idx < a_size:
           shared_a[TPB + local_i] = a[next_idx]
   ```

4. **Convolution Computation**:
   - Each thread processes one output element
   - Accesses data across block boundaries seamlessly
   - Handles edge cases with proper bounds checking

### Performance Considerations:

1. **Memory Access Pattern**:
   - Coalesced global memory loads
   - Efficient shared memory utilization
   - Minimal thread divergence

2. **Synchronization**:
   - Single barrier after all loads complete
   - No additional synchronization needed during computation

3. **Boundary Optimization**:
   - Only necessary threads load boundary data
   - Zero padding handled implicitly
   - Efficient handling of block edges

This implementation provides efficient cross-block convolution while maintaining memory coalescing and minimizing thread divergence.
</div>
</details>
