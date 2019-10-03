#!/bin/sh

# Re-sync constraints file using Makefile in constraints directory
# Hook runs from project's top-level directory, so paths are relative to that
make --directory=source/constraints clean constraints 1>/dev/null 2>&1
