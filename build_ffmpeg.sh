#!/bin/env bash

set -ex
CURRENT_DIR="$(realpath "$(dirname -- "$0")")"

# some options for local tools
WASI_SDK="/opt/wasi-sdk" # wasi-sdk root dir
TMP_BUILD_DIR="/tmp/build" # temp build dir
INSTALL_DIR="${CURRENT_DIR}/install" # install dir
FFMPEG_DIR=""   # user defined ffmpeg git repo dir
FFMPEG_VERSION="release/6.0"


# options for ffmpeg
DISABLES="--disable-runtime-cpudetect --disable-autodetect --disable-doc --disable-network --disable-w32threads --disable-os2threads --disable-alsa --disable-appkit --disable-avfoundation --disable-bzlib --disable-coreimage --disable-iconv --disable-metal --disable-sndio --disable-schannel --disable-sdl2 --disable-securetransport --disable-vulkan --disable-xlib --disable-zlib --disable-amf --disable-audiotoolbox --disable-cuda-llvm --disable-cuvid --disable-d3d11va --disable-dxva2 --disable-ffnvcodec --disable-nvdec --disable-nvenc --disable-v4l2-m2m --disable-vaapi --disable-vdpau --disable-videotoolbox --disable-asm --disable-altivec --disable-vsx --disable-power8 --disable-amd3dnow --disable-amd3dnowext --disable-xop --disable-fma3 --disable-fma4 --disable-aesni --disable-armv5te --disable-armv6 --disable-armv6t2 --disable-vfp --disable-neon --disable-inline-asm --disable-x86asm --disable-mipsdsp --disable-mipsdspr2 --disable-msa --disable-mipsfpu --disable-mmi --disable-lsx --disable-lasx --disable-rvv --disable-debug"

OS=android # can not use native os
ARCH=wasm32

NM="${WASI_SDK}/bin/nm"
AR="${WASI_SDK}/bin/llvm-ar"
AS="${WASI_SDK}/bin/llvm-as"
RANLIB="${WASI_SDK}/bin/ranlib"
STRIP="${WASI_SDK}/bin/llvm-strip"
CC="${WASI_SDK}/bin/clang"
CXX="${WASI_SDK}/bin/clang++"
LD="${WASI_SDK}/bin/clang"

# detect pthread support
VERSION=$(${CC} --version | head -n 1 | grep -oE "[0-9][0-9].")
# pthread since wasi-sdk-20 (llvm-16.0)
if [[ "${VERSION}" == "16." ]]; then
    echo "Build with pthread support!"
    EXTRA_C_FLAGS='-DWASM32_WASI -D_WASI_EMULATED_PROCESS_CLOCKS -D_WASI_EMULATED_SIGNAL --target=wasm32-wasi-threads'
    EXTRA_LD_FLAGS='-lwasi-emulated-process-clocks -lwasi-emulated-signal --target=wasm32-wasi-threads -Wl,--import-memory,--export-memory,--max-memory=2147483648'
    DISABLES="${DISABLES} --enable-pthreads"
else
    EXTRA_C_FLAGS='-DWASM32_WASI -D_WASI_EMULATED_PROCESS_CLOCKS'
    EXTRA_LD_FLAGS='-lwasi-emulated-process-clocks'
    DISABLES="${DISABLES} --disable-pthreads"
fi


TOOLCHAIN="--enable-cross-compile --arch=${ARCH} --target-os=${OS} --nm=${NM} --ar=${AR} --as=${AS} --strip=${STRIP} --cc=${CC} --cxx=${CXX} --objcc=${CC} --dep-cc=${CC} --ld=${LD} --ranlib=${RANLIB} --enable-pic --enable-lto"

if ! [[ -d "${FFMPEG_DIR}" ]]; then
    FFMPEG_DIR="${CURRENT_DIR}/ffmpeg"  # default ffmpeg git repo dir
    if ! [[ -d "${FFMPEG_DIR}" ]]; then
        pushd "${CURRENT_DIR}"
        git clone "https://git.ffmpeg.org/ffmpeg.git"
    fi
fi

pushd "${FFMPEG_DIR}"
git checkout -- .
git checkout "${FFMPEG_VERSION}"

# apply patch
PATCH_FILE="${CURRENT_DIR}/modify.patch"
git apply "${PATCH_FILE}"


mkdir -p "${TMP_BUILD_DIR}"
pushd "${TMP_BUILD_DIR}"

CONFIGURE="${FFMPEG_DIR}/configure"
${CONFIGURE} --prefix="${INSTALL_DIR}" ${DISABLES} ${DISABLE_ASMS} ${TOOLCHAIN} --extra-cflags="${EXTRA_C_FLAGS}" --extra-ldflags="${EXTRA_LD_FLAGS}"

make -j
make install
