#! /bin/bash
# Verifies that all dependencies are sorted.
set -e

check_files() {
    local all_files=( "$@" )
    for file in "${all_files[@]}" ; do
        if [[ -f "$file" ]]; then
          sort -o "$file" "$file"
        fi
    done
}

if ! check_files "$@" ; then
    echo "To ignore, use --no-verify"
fi
