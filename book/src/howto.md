## How to Use This Book

Each puzzle follows a consistent format designed to progressively build your skills:

- **Overview**: Clear problem statement and key concepts introduced in each puzzle
- **Configuration**: Setup parameters and memory organization specific to each challenge
- **Code to Complete**: Skeleton code with specific sections for you to implement
- **Tips**: Optional hints if you get stuck, without giving away complete solutions
- **Solution**: Detailed explanations of the implementation, performance considerations, and underlying concepts

The puzzles gradually increase in complexity, introducing new concepts while reinforcing fundamentals. We recommend solving them in order, as later puzzles build on skills developed in earlier ones.

## Running the code

All puzzles are designed to be run with the provided testing framework that verifies your implementation against expected results. Each puzzle includes instructions for running the code and validating your solution.

## Prerequisites

### Compatible GPU

You'll need a [compatible GPU](https://docs.modular.com/max/faq#gpu-requirements) to run the puzzles.

### Setting up your environment

1. [Clone the GitHub repository](https://github.com/modular/mojo-gpu-puzzles) and navigate to the repository:

    ```bash
    # Clone the repository
    git clone https://github.com/modular/mojo-gpu-puzzles
    cd mojo-gpu-puzzles
    ```

2. Install a package manager to run the Mojo🔥 programs:

    #### Option 1: [`uv`](https://docs.astral.sh/uv/getting-started/installation/) (recommended for users)

    **Install:**
    ```bash
    curl -fsSL https://astral.sh/uv/install.sh | sh
    ```

    **Update:**
    ```bash
    uv self update
    ```

    **Create a virtual environment:**
    ```bash
    uv venv && source .venv/bin/activate
    ```

    #### Option 2: [pixi](https://pixi.sh/latest/#installation) (recommended for contributors)

    **Install:**
    ```bash
    curl -fsSL https://pixi.sh/install.sh | sh
    ```

    **Update:**
    ```bash
    pixi self-update
    ```

3. Run the puzzles via `uv` or `pixi` as follows:

    <div class="code-tabs" data-tab-group="package-manager">
      <div class="tab-buttons">
        <button class="tab-button">uv</button>
        <button class="tab-button">pixi</button>
      </div>
      <div class="tab-content">

    ```bash
    uv run poe pXX  # Replace XX with the puzzle number
    ```

      </div>
      <div class="tab-content">

    ```bash
    pixi run pXX  # Replace XX with the puzzle number
    ```

      </div>
    </div>

For example, to run puzzle 01:
- `uv run poe p01` or
- `pixi run p01`

### Knowledge prerequisites

Basic knowledge of:

- Programming fundamentals (variables, loops, conditionals, functions)
- Parallel computing concepts (threads, synchronization, race conditions)
- Basic familiarity with [Mojo](https://docs.modular.com/mojo/manual/) (language basics parts and [intro to pointers](https://docs.modular.com/mojo/manual/pointers/) section)
- [A tour of GPU basics in Mojo](https://docs.modular.com/mojo/manual/gpu/basics) is helpful

No prior GPU programming experience is necessary! We'll build that knowledge through the puzzles.

Let's begin our journey into the exciting world of GPU computing with Mojo 🔥!

## Join the community

<p align="center" style="display: flex; justify-content: center; gap: 10px;">
  <a href="https://www.modular.com/company/talk-to-us">
    <img src="https://img.shields.io/badge/Subscribe-Updates-00B5AD?logo=mail.ru" alt="Subscribe for Updates">
  </a>
  <a href="https://forum.modular.com/c/">
    <img src="https://img.shields.io/badge/Modular-Forum-9B59B6?logo=discourse" alt="Modular Forum">
  </a>
  <a href="https://discord.com/channels/1087530497313357884/1098713601386233997">
    <img src="https://img.shields.io/badge/Discord-Join_Chat-5865F2?logo=discord" alt="Discord">
  </a>
</p>

Join our vibrant community to discuss GPU programming, share solutions, and get help!
