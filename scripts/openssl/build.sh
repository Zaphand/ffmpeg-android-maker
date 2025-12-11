#!/bin/bash
set -e

# Use a subshell to prevent variable changes from leaking to other scripts
(
    echo "__________PREPARING OPENSSL ENVIRONMENT______________"

    # 1. Define the NDK Toolchain Path manually (Safest method)
    #    We assume linux-x86_64. If you are on Mac, change 'linux' to 'darwin'.
    NDK_TOOLCHAIN="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin"
    
    # 2. Setup a temporary folder for our "Fake GCC"
    FAKE_BIN_DIR="$PWD/android_fake_bin"
    rm -rf "$FAKE_BIN_DIR"
    mkdir -p "$FAKE_BIN_DIR"

    # 3. Create the Symlink: OpenSSL looks for GCC, we give it Clang
    case $ANDROID_ABI in
      "armeabi-v7a") 
          OPENSSL_ARCH="android-arm"
          GCC_NAME="arm-linux-androideabi-gcc"
          ;;
      "arm64-v8a")   
          OPENSSL_ARCH="android-arm64"
          GCC_NAME="aarch64-linux-android-gcc"
          ;;
      "x86")         
          OPENSSL_ARCH="android-x86"
          GCC_NAME="i686-linux-android-gcc"
          ;;
      "x86_64")      
          OPENSSL_ARCH="android-x86_64"
          GCC_NAME="x86_64-linux-android-gcc"
          ;;
    esac

    # Link 'fake-gcc' -> 'real-clang'
    ln -sf "$NDK_TOOLCHAIN/clang" "$FAKE_BIN_DIR/$GCC_NAME"

    # 4. Export Variables for this subshell only
    export PATH="$FAKE_BIN_DIR:$NDK_TOOLCHAIN:$PATH"
    
    # Unset variables that might confuse OpenSSL (it will find our fake GCC instead)
    unset CC CXX AR AS LD RANLIB STRIP NM CFLAGS CXXFLAGS LDFLAGS

    echo "__________CONFIGURING OPENSSL FOR $OPENSSL_ARCH ______________"

    # 5. Configure
    ./Configure $OPENSSL_ARCH \
      -D__ANDROID_API__=$ANDROID_PLATFORM \
      --prefix="${BUILD_DIR_EXTERNAL}/${ANDROID_ABI}" \
      no-shared \
      no-tests \
      no-ui-console \
      no-stdio \
      no-asm

    # 6. Verify Makefile was created
    if [ ! -f "Makefile" ]; then
        echo "ERROR: Configure failed to create a Makefile."
        exit 1
    fi

    echo "__________COMPILING OPENSSL______________"

    # 7. Build
    make clean
    make -j$(nproc)

    echo "__________INSTALLING OPENSSL______________"

    # 8. Install
    make install_sw

    # 9. Final Verification
    if [ ! -f "${BUILD_DIR_EXTERNAL}/${ANDROID_ABI}/lib/libssl.a" ]; then
        echo "ERROR: Build finished but libssl.a is missing!"
        exit 1
    fi
)

# Cleanup the fake directory
rm -rf android_fake_bin