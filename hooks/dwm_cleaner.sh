#! /bin/bash
# Cheks that all aux files are deleted.
set -e

pushd ./dwm
rm -fv config.h
make clean
popd
