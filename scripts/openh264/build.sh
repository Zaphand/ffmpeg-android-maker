#!/bin/bash

cd ${SOURCES_DIR_openh264}

# 1. Map Android ABI names to OpenH264 'ARCH' names
TARGET_ARCH="arm"
if [ "$ANDROID_ABI" == "arm64-v8a" ]; then
  TARGET_ARCH="arm64"
elif [ "$ANDROID_ABI" == "x86" ]; then
  TARGET_ARCH="x86"
elif [ "$ANDROID_ABI" == "x86_64" ]; then
  TARGET_ARCH="x86_64"
fi

# 2. Clean previous build artifacts (Vital because we build in-tree)
make clean > /dev/null 2>&1

# 3. Build static library
# We manually specify the NDK path and API level
make -j$(nproc) \
    OS=android \
    NDKROOT=${ANDROID_NDK_HOME} \
    TARGET=android-${API_LEVEL} \
    ARCH=${TARGET_ARCH} \
    binaries

# 4. Install headers and libs to the common external folder
# 'install-static' ensures we don't get a shared .so file
make \
    OS=android \
    NDKROOT=${ANDROID_NDK_HOME} \
    TARGET=android-${API_LEVEL} \
    ARCH=${TARGET_ARCH} \
    PREFIX=${BUILD_DIR_EXTERNAL}/${ANDROID_ABI} \
    install-static