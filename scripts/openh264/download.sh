#!/bin/bash
export SOURCES_DIR_openh264=${SOURCES_DIR}/openh264

# Clone the latest stable release (v2.4.1)
git clone --depth 1 --branch v2.4.1 https://github.com/cisco/openh264.git .