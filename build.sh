#!/bin/bash

# remove previous build artifacts
rm -r bin &>/dev/null 
rm -r build &>/dev/null

mkdir build
cd build
cmake ..
cd ..
cmake --build build

