#!/bin/bash


echo "__________DOWNLOADING OPENSSLL______________"

# We use OpenSSL 3.0.12 as it is stable and compatible with modern NDKs
git clone --depth 1 --branch openssl-3.0.12 https://github.com/openssl/openssl.git .