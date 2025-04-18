#!/bin/bash

cd solutions || exit 1

for dir in p*/; do
  if [ -d "$dir" ]; then
    echo "=== Testing solutions in ${dir} ==="
    cd "$dir" || continue

    for f in *.mojo; do
      if [ -f "$f" ]; then
        echo "=== Running $f ==="
        mojo "$f" || echo "Failed: $f"
      fi
    done

    cd ..
  fi
done

cd ..
