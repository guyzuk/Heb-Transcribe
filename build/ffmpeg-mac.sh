#!/bin/bash
# בונה ffmpeg מינימלי ב-LGPL עם libass סטטי: קובץ אחד, בלי ספריות של Homebrew, רץ מ-macOS 12.
# שימוש: ffmpeg-mac.sh <tag> <out-dir>
set -euo pipefail
REF="$1"; OUT="$2"
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$PWD"; SRC="$ROOT/ffmpeg-src"; DEPS="$ROOT/deps-prefix"; PREFIX="$ROOT/ffmpeg-prefix"
export MACOSX_DEPLOYMENT_TARGET=12.0
export CFLAGS="-mmacosx-version-min=12.0" CXXFLAGS="-mmacosx-version-min=12.0" LDFLAGS="-mmacosx-version-min=12.0"

bash "$HERE/deps.sh" "$DEPS"

git clone --depth 1 --branch "$REF" https://github.com/FFmpeg/FFmpeg "$SRC"
cd "$SRC"
PKG_CONFIG_PATH="$DEPS/lib/pkgconfig" bash "$HERE/ffmpeg-configure.sh" "$PREFIX" \
  --pkg-config-flags=--static \
  --extra-cflags="-mmacosx-version-min=12.0" --extra-ldflags="-mmacosx-version-min=12.0" \
  --extra-libs="-lc++"
make -j"$(sysctl -n hw.ncpu)"
make install

mkdir -p "$OUT"
cp "$PREFIX/bin/ffmpeg" "$OUT/"
cp "$SRC/COPYING.LGPLv2.1" "$OUT/FFMPEG-LICENSE.txt"
echo "$REF" > "$OUT/FFMPEG-BUILD.txt"

# בדיקה: אסור שתהיה תלות בספרייה מחוץ למערכת
if otool -L "$OUT/ffmpeg" | tail -n +2 | grep -v -E "/usr/lib/|/System/Library/"; then
  echo "ffmpeg links to non-system libraries" >&2; exit 1
fi
