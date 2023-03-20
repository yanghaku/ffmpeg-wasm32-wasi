The script ```./build.sh``` can compile ffmpeg library to wasm32-wasi.

There are 2 patches:
1. ```dup```: WASI has no ```dup```, so just return an error now.
2. ```tempnam```: [WASI has no temp directory support](https://github.com/WebAssembly/WASI/issues/306), so just return an error now.

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

The examples which can be built:
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
