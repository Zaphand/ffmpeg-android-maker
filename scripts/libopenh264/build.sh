#!/bin/bash
(
    set -e
    unset CC CXX CFLAGS LDFLAGS AR AS RANLIB STRIP NM

    case $ANDROID_ABI in
      "armeabi-v7a") TARGET_ARCH="arm";;
      "arm64-v8a")   TARGET_ARCH="arm64";;
      "x86")         TARGET_ARCH="x86";;
      "x86_64")      TARGET_ARCH="x86_64";;
    esac

    echo "__________BUILDING OPENH264 FOR $TARGET_ARCH ______________"

    make -j$(nproc) \
        OS=android \
        NDKROOT=${ANDROID_NDK_HOME} \
        TARGET=android-${ANDROID_PLATFORM} \
        ARCH=${TARGET_ARCH} \
        PREFIX="${BUILD_DIR_EXTERNAL}/${ANDROID_ABI}" \
        install-static
)