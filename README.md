# Heb-Transcribe — build scripts

Builds the command-line tools bundled with the Hebrew Captions panel for Premiere Pro:

| Tool | Source | License |
|---|---|---|
| `whisper-cli` | [whisper.cpp](https://github.com/ggml-org/whisper.cpp) | MIT |
| `ffmpeg` (minimal, with libass) | [FFmpeg](https://ffmpeg.org) + libass, freetype, fribidi, harfbuzz | LGPL 2.1+ |

Targets: `mac-arm64`, `mac-x64` (macOS 12+, fully static) and `win-x64` (FFmpeg from [BtbN/FFmpeg-Builds](https://github.com/BtbN/FFmpeg-Builds), LGPL shared).

Run: **Actions → build-binaries → Run workflow**. Each target is uploaded as the artifact `bin-<target>`.

The ffmpeg build is LGPL only (no `--enable-gpl`, no nonfree); the exact configure flags are in `build/ffmpeg-configure.sh`, so anyone can rebuild it.
