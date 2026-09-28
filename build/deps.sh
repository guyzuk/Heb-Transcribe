#!/bin/bash
# בונה את libass והתלויות שלה (freetype, fribidi, harfbuzz) כספריות סטטיות לתוך PREFIX.
# כך ffmpeg יוצא קובץ אחד בלי תלות בספריות של Homebrew, ורץ גם על גרסאות macOS ישנות.
# שימוש: deps.sh <prefix>
set -euo pipefail
PREFIX="$1"
FREETYPE=2.13.3
FRIBIDI=1.0.16
HARFBUZZ=10.4.0
LIBASS=0.17.3

mkdir -p "$PREFIX" deps-src
cd deps-src
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
export CFLAGS="${CFLAGS:-} -fPIC"
export CXXFLAGS="${CXXFLAGS:-} -fPIC"
J=$( (sysctl -n hw.ncpu 2>/dev/null || nproc) )

fetch() { [ -d "$2" ] || { curl -fsSL "$1" -o "$2.tar" && mkdir "$2" && tar xf "$2.tar" -C "$2" --strip-components 1; }; }

[ -d freetype ] || git clone -q --depth 1 --branch "VER-${FREETYPE//./-}" https://github.com/freetype/freetype freetype
cmake -S freetype -B freetype/b -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DBUILD_SHARED_LIBS=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  -DFT_DISABLE_ZLIB=ON -DFT_DISABLE_BZIP2=ON -DFT_DISABLE_PNG=ON -DFT_DISABLE_HARFBUZZ=ON -DFT_DISABLE_BROTLI=ON
cmake --build freetype/b -j "$J" && cmake --install freetype/b

fetch "https://github.com/fribidi/fribidi/releases/download/v$FRIBIDI/fribidi-$FRIBIDI.tar.xz" fribidi
meson setup fribidi/b fribidi --prefix="$PREFIX" --libdir=lib --buildtype=release \
  --default-library=static -Ddocs=false -Dtests=false -Dbin=false
ninja -C fribidi/b install

fetch "https://github.com/harfbuzz/harfbuzz/releases/download/$HARFBUZZ/harfbuzz-$HARFBUZZ.tar.xz" harfbuzz
meson setup harfbuzz/b harfbuzz --prefix="$PREFIX" --libdir=lib --buildtype=release \
  --default-library=static -Dfreetype=enabled -Dglib=disabled -Dgobject=disabled -Dcairo=disabled \
  -Dicu=disabled -Dgraphite2=disabled -Dchafa=disabled -Dtests=disabled -Ddocs=disabled \
  -Dutilities=disabled -Dintrospection=disabled -Dcoretext=disabled
ninja -C harfbuzz/b install

fetch "https://github.com/libass/libass/releases/download/$LIBASS/libass-$LIBASS.tar.xz" libass
( cd libass && ./configure --prefix="$PREFIX" --disable-shared --enable-static --with-pic \
    --disable-fontconfig --disable-libunibreak --disable-require-system-font-provider \
    && make -j "$J" && make install )

echo "deps ready in $PREFIX"
