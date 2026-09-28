#!/bin/bash
# הגדרת ffmpeg: LGPL בלבד (בלי --enable-gpl), רק הרכיבים שהתוסף משתמש בהם.
PREFIX="$1"; shift
./configure --prefix="$PREFIX" \
  --disable-debug --disable-doc --disable-ffplay --disable-ffprobe --disable-network --disable-autodetect \
  --disable-everything --enable-static --disable-shared \
  --enable-zlib --enable-libass --enable-libfreetype --enable-libfribidi --enable-libharfbuzz \
  --enable-protocol=file,pipe \
  --enable-indev=lavfi \
  --enable-demuxer=mov,mxf,mp3,wav,aiff,matroska,flac,ogg,aac,mpegts,avi,w64,caf,ass,srt,image2 \
  --enable-decoder=aac,aac_latm,mp3,mp3float,mp2,alac,flac,opus,vorbis,ac3,eac3,pcm_s16le,pcm_s16be,pcm_s24le,pcm_s24be,pcm_s32le,pcm_s32be,pcm_f32le,pcm_f32be,pcm_f64le,pcm_u8,adpcm_ima_qt,wrapped_avframe,rawvideo,ass,ssa,srt,subrip,png \
  --enable-parser=aac,aac_latm,mpegaudio,flac,opus,vorbis,ac3 \
  --enable-encoder=pcm_s16le,prores_ks,png \
  --enable-muxer=wav,mov,image2 \
  --enable-filter=aformat,aresample,adelay,amix,alimiter,anull,anullsrc,format,scale,subtitles,color,null,crop,setpts,trim,atrim \
  "$@"
