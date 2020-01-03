#!/bin/bash

#
# Download and upack
echo Running build-darwin.sh

./install-ndk.sh
source ./android-ndk-path.sh
./build.sh
