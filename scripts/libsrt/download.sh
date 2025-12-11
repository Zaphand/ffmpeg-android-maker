#!/bin/bash
export SOURCES_DIR_libsrt=${SOURCES_DIR}/libsrt

# Clone the stable version of SRT
git clone --depth 1 --branch v1.5.3 https://github.com/Haivision/srt.git .
