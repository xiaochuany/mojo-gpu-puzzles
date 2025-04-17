#!/bin/bash
cd solutions && for f in *.mojo; do
    echo "=== Running $f ==="
    mojo "$f" || echo "Failed: $f"
done
