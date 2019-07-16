!/bin/bash
echo "进入编译ffmpeg脚本"
#5.0
NDK=../android-ndk-r14b
PLATFORM=$NDK/platforms/android-21/arch-arm
TOOLCHAIN=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64
CPU=armv7-a
#输出路径
PREFIX=$(pwd)/android/$CPU
CFLAG="-I$PLATFORM/usr/include -fPIC -DANDROID -mfpu=neon -mfloat-abi=softfp "

echo "开始编译ffmpeg"
./configure \
--prefix=$PREFIX \
--target-os=android \
--cross-prefix=$TOOLCHAIN/bin/arm-linux-androideabi- \
--arch=arm \
--cpu=$CPU  \
--sysroot=$PLATFORM \
--extra-cflags="$CFLAG" \
--cc=$TOOLCHAIN/bin/arm-linux-androideabi-gcc \
--nm=$TOOLCHAIN/bin/arm-linux-androideabi-nm \
--disable-everything \
--enable-static \
--enable-runtime-cpudetect \
--enable-gpl \
--enable-cross-compile \
--enable-encoder=mpeg4 \
--disable-decoders \
--enable-decoder=mjpeg \
--disable-muxers \
--enable-muxer=mp4 \
--disable-protocols \
--enable-protocol=file \
--disable-demuxers \
--enable-demuxer=h264 \
--enable-mediacodec \
--disable-debug \
--enable-small \
--enable-asm \
--enable-neon \
--enable-jni \
--enable-hwaccel=h264_mediacodec \
--enable-decoder=h264_mediacodec
echo "configure 结束"
make -j8
make install
echo "编译结束！"
###########################################################


#--rpath-link DIR            Add DIR to link time shared library search path
#  -L DIR, --library-path DIR  Add directory to search path
#--whole-archive             Include all archive contents
#--no-whole-archive          Include only needed archive contents
# --no-undefined              Report undefined symbols (even with --shared)
# -nostdlib                   Only search directories specified on the command line.
#  -o FILE, --output FILE      Set output file name
$TOOLCHAIN/bin/arm-linux-androideabi-ld \
-rpath-link=$PLATFORM/usr/lib \
-L$PLATFORM/usr/lib \
-soname libav_thirdparty.so \
-shared -nostdlib  \
--whole-archive --no-undefined \
-o $PREFIX/libav_thirdparty.so \
$PREFIX/lib/libavcodec.a \
$PREFIX/lib/libavfilter.a \
$PREFIX/lib/libswresample.a \
$PREFIX/lib/libavformat.a \
$PREFIX/lib/libavutil.a \
$PREFIX/lib/libswscale.a \
-lc -lm -lz -ldl -llog \
$TOOLCHAIN/lib/gcc/arm-linux-androideabi/4.9.x/libgcc.a

echo "original $(openssl dgst ../out/libav_thirdparty.so)"
echo "dst      $(openssl dgst android/armv7-a/libav_thirdparty.so)"

rm -rf ../out/libav_thirdparty.so
cp android/armv7-a/libav_thirdparty.so ../out/
###########################################################
#echo "编译不支持neon和硬解码"
#CPU=armv7-a
#PREFIX=./android/$CPU
#CFLAG="-I$PLATFORM/usr/include -fPIC -DANDROID -mfpu=vfp -mfloat-abi=softfp "
#ADD=
#buildFF
