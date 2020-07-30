#!/bin/bash

pushd "{{dwm_dir}}"
rm -fv config.h && make && sudo make clean install
popd
