#!/bin/bash

cd solutions || exit 1

for dir in p*/; do
  if [ -d "$dir" ]; then
    echo "=== Testing solutions in ${dir} ==="
    cd "$dir" || continue

    for f in *.mojo; do
      if [ -f "$f" ]; then
        echo "=== Running $f ==="
        # Extract flags
        flags=$(grep -o 'argv()\[1\] == "--[^"]*"' "$f" | cut -d'"' -f2)

        if [ -z "$flags" ]; then
          mojo "$f" || echo "Failed: $f"
        else
          # Run with each flag
          for flag in $flags; do
            echo "Running with $flag"
            mojo "$f" "$flag" || echo "Failed: $f with $flag"
          done
        fi
      fi
    done

    cd ..
  fi
done

cd ..
