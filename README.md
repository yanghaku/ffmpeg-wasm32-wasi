# Use ffmpeg library in C/C++/Rust and compile to Wasm32-wasi target.

## Rust Examples

Rust can use easily use ffmpeg library using ```ffmpeg-next``` crate.

### Requirements:

* wasi-sysroot
* libclang_rt.builtins-wasm32.a (
  because [rust compiler-rt missing some f128 functions](https://github.com/rust-lang/compiler-builtins#unimplemented-functions))
* ffmpeg static library (wasm32-wasi target)
* rust (with wasm32-wasi target)

> 1. wasi-sysroot and libclang_rt.builtins-wasm32.a is bundled in wasi-sdk, or download these separately
     from [wasi-sdk release page](https://github.com/WebAssembly/wasi-sdk/releases)
> 2. now stable rustc 1.68.2 (llvm 15.0.6) cannot use the wasi-sdk-20 (llvm 16.0.0), so the static library is built by
     wasi-sdk-19

### Build Examples:

#### 1. Config the wasi-sysroot and ffmpeg path in ```rust-examples/.cargo/config.toml```

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

#### 2. Build using the cargo

```shell
cd rust-examples
cargo build --release
```

#### 3. Run the examples using the WasmEdge/Wasmer/Wasmtime

```shell
# use wasmedge
wasmedge --dir .:. ./target/wasm32-wasi/release/codec-info.wasm aac
# use wasmer
wasmer run ./target/wasm32-wasi/release/codec-info.wasm aac
# use wasmtime
wasmtime --dir . ./target/wasm32-wasi/release/codec-info.wasm aac
```

## C Examples

Requirements:

* examples source code in ffmpeg repo
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

## Details

There are 2 patches:

1. ```dup```: WASI has no ```dup```, so just return an error now.
2. ```tempnam```: [WASI has no temp directory support](https://github.com/WebAssembly/WASI/issues/306), so just return
   an error now.

The binary programs:

* [x] ffmpeg (wasm32-wasi-threads target only)
* [ ] ffplay (no sdl support now)
* [x] ffprobe

The static libraries:

* [x] libavcodec.a
* [x] libavfilter.a
* [x] libavutil.a     (with patch, cannot use temp file)
* [x] libswscale.a
* [x] libavdevice.a
* [x] libavformat.a   (with patch, cannot use dup)
* [x] libswresample.a

### Build ffmpeg from source

Requirement: wasi-sdk

The script [build_ffmpeg.sh](./build_ffmpeg.sh) can compile ffmpeg source to wasm32-wasi.

### Use the ffmpeg binary programs:

Now ```ffmpeg.wasm``` can only run in ```wasmtime```:

```console
wasmtime --wasm-features all --wasi-modules wasi-common,experimental-wasi-threads --dir . ./ffmpeg.wasm -- --help
```

## Test Data

download from: https://github.com/ffmpegwasm/testdata.git

## Reference

* https://github.com/yamt/FFmpeg-WASI

> When I searched how to use the new feature of wasi-sdk-20, I found this repo: https://github.com/yamt/FFmpeg-WASI,
> which has already compiled the ffmpeg to wasm32-wasi and support thread.

