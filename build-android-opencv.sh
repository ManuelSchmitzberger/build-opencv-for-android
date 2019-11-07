#!/bin/bash
NDK_ROOT="${1:-${NDK_ROOT}}"

### path setup
SCRIPT=$(readlink -f $0)
WD=`dirname $SCRIPT`
OPENCV_ROOT="${WD}/opencv"
N_JOBS=${N_JOBS:-4}

### Download android-cmake
#if [ ! -d "${WD}/android-cmake" ]; then
#    echo 'Cloning android-cmake'
#    git clone https://github.com/taka-no-me/android-cmake.git
#fi

INSTALL_DIR="${WD}/android_opencv"
rm -rf "${INSTALL_DIR}/opencv"

### Make each ABI target iteratly and sequentially
build() {
    ANDROID_ABI_NAME=$1
    ANDROID_ABI=$2
    shift
    shift
    echo "Start building ${ANDROID_ABI_NAME} version"

    API_LEVEL=18

    temp_build_dir="${OPENCV_ROOT}/platforms/build_android_${ANDROID_ABI_NAME}"
    ### Remove the build folder first, and create it
    rm -rf "${temp_build_dir}"
    mkdir -p "${temp_build_dir}"
    cd "${temp_build_dir}"

    cmake -G "Unix Makefiles" \
          -D CMAKE_BUILD_WITH_INSTALL_RPATH=ON \
          -D CMAKE_TOOLCHAIN_FILE="$NDK_ROOT/build/cmake/android.toolchain.cmake" \
          -D ANDROID_NDK="${NDK_ROOT}" \
          -D ANDROID_NATIVE_API_LEVEL=${API_LEVEL} \
          -D ANDROID_ABI="${ANDROID_ABI}" \
          -D OPENCV_EXTRA_MODULES_PATH="${WD}/opencv_contrib/modules/"  \
          -D CMAKE_INSTALL_PREFIX="${INSTALL_DIR}/opencv" \
          -D CMAKE_BUILD_TYPE=RelWithDebInfo \
          -D ANDROID=ON \
          -D ANDROID_TOOLCHAIN=clang \
          -D BUILD_SHARED_LIBS=OFF \
          -D BUILD_ANDROID_PROJECTS=OFF \
          -D BUILD_ANDROID_EXAMPLES=OFF \
          -D WITH_1394=OFF \
          -D WITH_VTK=OFF \
          -D WITH_CUDA=OFF \
          -D WITH_NVCUVID=OFF \
          -D WITH_EIGEN=OFF \
          -D WITH_FFMPEG=ON \
          -D WITH_GSTREAMER=OFF \
          -D WITH_GTK=OFF \
          -D WITH_JASPER=OFF \
          -D WITH_WEBP=OFF \
          -D WITH_OPENGL=OFF \
          -D WITH_OPENCL=OFF \
          -D WITH_PTHREADS_PF=OFF \
          -D WITH_TIFF=OFF \
          -D WITH_V4L=OFF \
          -D WITH_GPHOTO2=OFF \
          -D WITH_LAPACK=OFF \
          -D WITH_OPENEXR=OFF \
          -D BUILD_TESTS=OFF \
          -D BUILD_PERF_TESTS=OFF \
          -D BUILD_EXAMPLES=OFF \
          -D BUILD_DOCKS=OFF \
          "$@" \
          ../..

    # Build it
    make -j${N_JOBS}
    # Install it
    make install/strip
    ### Remove temp build folder
    cd "${WD}"
    rm -rf "${temp_build_dir}"
    echo "end building ${ANDROID_ABI_NAME} version"
}

build "armeabi-v7a" "armeabi-v7a with NEON" -D ENABLE_VFPV3=ON -D ENABLE_NEON=ON
build "arm64-v8a" "arm64-v8a" # NEON enabled by default$
build "x86" "x86"
build "x86_64" "x86_64"
