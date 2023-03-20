#!/bin/env bash
set -ex

# assume the ffmpeg has been built and installed.
INSTALL_DIR=""
WASI_SDK="/opt/wasi-sdk" # wasi-sdk root dir

if ! [[ -d "${INSTALL_DIR}" ]]; then
    # default install dir
    CURRENT_DIR="$(realpath "$(dirname -- "$0")")"
    INSTALL_DIR="${CURRENT_DIR}/install"
    if ! [[ -d "${INSTALL_DIR}" ]]; then
        echo "NO install dir found";
    fi
fi

export PKG_CONFIG_PATH="${INSTALL_DIR}/lib/pkgconfig"
export CC="${WASI_SDK}/bin/clang"
export LDFLAGS='-lwasi-emulated-process-clocks'

pushd "${INSTALL_DIR}/share/ffmpeg/examples"
make -j
