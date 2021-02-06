#!/bin/bash

[[ $# -gt 2 ]] && echo "WARNING: only 2 arguments <python_script_path> <output_database_path> required. Only the first 2 arguments will be considered."

# Before running, change the value of `EXTERNAL_PYTHON_EXEC`
# to the correct path to your Python executable.
# To check the correct path, run `which python3` on the Terminal (i.e. from outside Xcode).
# Make sure that your Python executable has already had the library
# `Beautiful Soup` installed.
EXTERNAL_PYTHON_EXEC=~/opt/anaconda3/bin/python3

$EXTERNAL_PYTHON_EXEC $1 $2
