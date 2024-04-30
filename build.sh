#!/bin/bash
git clone https://github.com/forresti/osu-micro-benchmarks.git
cd osu-micro-benchmarks/
export CUDA_HOME=/soft/compilers/cudatoolkit/cuda-12.4.1
export CRAY_ACCEL_TARGET=nvidia80
export MPICH_GPU_SUPPORT_ENABLED=1
./configure CC='cc -target-accel=nvidia80' CXX='CC -target-accel=nvidia80' --enable-cuda  --with-cuda-include=${CUDA_HOME}/include --with-cuda-libpath=${CUDA_HOME}/lib64
make all -j
