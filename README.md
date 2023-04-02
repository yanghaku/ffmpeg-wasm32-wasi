# Introduction

Use ffmpeg library in Webassembly.

There are 2 patches:

1. ```dup```: WASI has no ```dup```, so just return an error now.
2. ```tempnam```: [WASI has no temp directory support](https://github.com/WebAssembly/WASI/issues/306), so just return
   an error now.

The binary programs:

* [ ] ffmpeg
* [ ] ffplay
* [x] ffprobe

The static libraries:

* [x] libavcodec.a
* [x] libavfilter.a
* [x] libavutil.a     (with patch, cannot use temp file)
* [x] libswscale.a
* [x] libavdevice.a
* [x] libavformat.a   (with patch, cannot use dup)
* [x] libswresample.a

## build ffmpeg from source

Requirement: wasi-sdk

The script [build_ffmpeg.sh](./build_ffmpeg.sh) can compile ffmpeg source to wasm32-wasi.

# C Examples

Requirements: 
* wasi-sdk
* ffmpeg static library (wasm32-wasi target)

Build script: [build_ffmpeg_examples.sh](./build_ffmpeg_examples.sh)

The ffmpeg C examples which can be built:

* [ ] avio_http_serve_files
* [x] avio_list_dir
* [x] avio_read_callback
* [x] decode_audio
* [x] decode_filter_audio
* [ ] decode_filter_video
* [x] decode_video
* [x] demux_decode
* [x] encode_audio
* [x] encode_video
* [x] extract_mvs
* [x] hw_decode
* [x] mux
* [ ] remux
* [x] resample_audio
* [x] scale_video
* [x] show_metadata
* [x] transcode
* [x] transcode_aac


# Rust Examples

## Requirements:

* wasi-sysroot
* libclang_rt.builtins-wasm32.a (because [rust compiler-rt missing some f128 functions](https://github.com/rust-lang/compiler-builtins#unimplemented-functions)
* ffmpeg static library (wasm32-wasi target)
* rust (with wasm32-wasi target)

wasi-sysroot and libclang_rt.builtins-wasm32.a is bundled in wasi-sdk, or download these separately from [wasi-sdk release page](https://github.com/WebAssembly/wasi-sdk/releases)

## Build:

1. Config the wasi-sysroot and ffmpeg path in ```rust-examples/.cargo/config.toml```

```toml
[env]
# ffmpeg install path (default is ```../install```)
FFMPEG_DIR = { value = "../install", relative = true }
# config wasi-sysroot path (default is ```/opt/wasi-sdk/share/wasi-sysroot```)
BINDGEN_EXTRA_CLANG_ARGS = "--sysroot=/opt/wasi-sdk/share/wasi-sysroot --target=wasm32-wasi -fvisibility=default"

[build]
# default build target
target = "wasm32-wasi"
# config clang_rt.builtins-wasm32 path (default is ```/opt/wasi-sdk/lib/clang/15.0.7/lib/wasi/```)
# config wasi-sysroot path (default is ```/opt/wasi-sdk/share/wasi-sysroot```)
rustflags = [
    "-L", "/opt/wasi-sdk/lib/clang/15.0.7/lib/wasi/",
    "-l", "clang_rt.builtins-wasm32",
    "-L", "/opt/wasi-sdk/share/wasi-sysroot/lib/wasm32-wasi",
    "-l", "wasi-emulated-process-clocks",
]
```

2. Build using the cargo

```shell
cd rust-examples
cargo build --release
```

# Test Data

download from: https://github.com/ffmpegwasm/testdata.git

