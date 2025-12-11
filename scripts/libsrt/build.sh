#!/bin/bash
(
      set -r

      

      # Point to where OpenSSL was installed by the previous script
      DEP_INSTALL_DIR=${BUILD_DIR_EXTERNAL}/${ANDROID_ABI}


      if [ ! -f "${DEP_INSTALL_DIR}/lib/libssl.a" ]; then
            echo "ERROR: OpenSSL not found at ${DEP_INSTALL_DIR}/lib/libssl.a"
            exit 1
      fi


      mkdir -p build_cmake
      cd build_cmake

      # Configure CMake
      cmake -Wno-dev \
            -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_HOME}/build/cmake/android.toolchain.cmake \
            -DANDROID_ABI=${ANDROID_ABI} \
            -DANDROID_PLATFORM=android-${ANDROID_PLATFORM} \
            -DCMAKE_INSTALL_PREFIX=${DEP_INSTALL_DIR} \
            -DENABLE_SHARED=OFF \
            -DENABLE_STATIC=ON \
            -DENABLE_APPS=OFF \
            -DENABLE_BONDING=OFF \
            -DENABLE_ENCRYPTION=ON \
            -DUSE_ENCLIB=openssl \
            -DOPENSSL_USE_STATIC_LIBS=ON \
            -DOPENSSL_ROOT_DIR=${DEP_INSTALL_DIR} \
            -DOPENSSL_INCLUDE_DIR="${INSTALL_DIR}/include" \
            -DOPENSSL_CRYPTO_LIBRARY="${DEP_INSTALL_DIR}/lib/libcrypto.a" \
            -DOPENSSL_SSL_LIBRARY="${DEP_INSTALL_DIR}/lib/libssl.a" \
            -DCMAKE_BUILD_TYPE=Release \
            ${SOURCES_DIR_libsrt}

      # Build and Install

      echo "_______ BUILDING SRT _________"

      make -j$(nproc)
      make install
)