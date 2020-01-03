#!/bin/bash

set -euo pipefail

source ./config.sh

ARCH=$(uname -s | tr '[:upper:]' '[:lower:]')
NDK_DIR=android-ndk-${ANDROID_NDK_VERSION_SHORT}-${ARCH}-x86_64
NDK_ZIP=${NDK_DIR}.zip
ANDROID_NDK_HOME=$(pwd)/${NDK_DIR}
echo "export PATH=\${PATH}:${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/${ARCH}-x86_64/bin" > android-ndk-path.sh

# figure out the current ndk version to download and use
echo "Android NDK version is ${ANDROID_NDK_VERSION_LONG} aka ${ANDROID_NDK_VERSION_SHORT} ARCH = ${ARCH} ANDROID_NDK_HOME=${ANDROID_NDK_HOME}"

# Skip the NDK download if it already exists and is the correct version
if [ -d ${ANDROID_NDK_HOME} ]; then
  export ANDROID_NDK_VERSION_INSTALLED=$(grep "Pkg.Revision" ${ANDROID_NDK_HOME}/source.properties|cut -d'=' -f2)
  echo "Installed Android NDK version is ${ANDROID_NDK_VERSION_INSTALLED}"
  if [ ${ANDROID_NDK_VERSION_LONG} == ${ANDROID_NDK_VERSION_INSTALLED} ]; then
    echo "NDK versions match, skipping installtion..."
    exit 0;
  fi

  echo "NDK versions do not match, installing version ${ANDROID_NDK_VERSION_LONG}..."
  rm -rf ${ANDROID_NDK_HOME}
fi
# Otherwise install it
rm -rf ${ANDROID_NDK_HOME}-tmp
mkdir ${ANDROID_NDK_HOME}-tmp
cd ${ANDROID_NDK_HOME}-tmp
echo "Fetching https://dl.google.com/android/repository/${NDK_ZIP} ..."
curl --silent https://dl.google.com/android/repository/${NDK_ZIP} --output ${NDK_ZIP}
echo "Unzipping ${NDK_ZIP} ..."
unzip -q ${NDK_ZIP}
mv ./android-ndk-${ANDROID_NDK_VERSION_SHORT} ${ANDROID_NDK_HOME}
cd ${ANDROID_NDK_HOME}
rm -rf ${ANDROID_NDK_HOME}-tmp

# Setup the symlinks so that rust's builder scripts can find clang
(cd ${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/${ARCH}-x86_64/bin; \
 ln -s aarch64-linux-android28-clang aarch64-linux-android-clang; \
 ln -s armv7a-linux-androideabi28-clang arm-linux-androideabi-clang; \
 ln -s i686-linux-android28-clang i686-linux-android-clang; \
 ln -s x86_64-linux-android28-clang x86_64-linux-android-clang; \
)
