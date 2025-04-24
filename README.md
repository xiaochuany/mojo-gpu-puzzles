# Mojo 🔥 GPU Puzzles

[![Github Pages](https://github.com/modularml/mojo-gpu-puzzles/actions/workflows/gh-pages.yml/badge.svg?branch=main)](https://github.com/modularml/mojo-gpu-puzzles/actions/workflows/gh-pages.yml)


## Development

1. Make sure to have `magic` installed

    ```bash
    curl -ssL https://magic.modular.com/ | bash
    ```

    or is updated

    ```bash
    magic self-update

    ```

> Need to have latex installed **only if** generating the GIFs.Note it can take a long time.
```bash
sudo apt update
sudo apt install -y \
texlive-full \
dvipng \
dvisvgm

# Verify latex installation
latex --version
```

2. Build the book and open [localhost:3000](localhost:3000)

    ```bash
    magic run book
    ```

3. Test solutions on a compatible GPU

    ```bash
    magic run tests
    ```

4. Format

    ```bash
    magic run format
    ```
