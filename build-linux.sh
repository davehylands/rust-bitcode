#!/bin/bash

set -euo pipefail

./install-ndk.sh
source ./android-ndk-path.sh
./build.sh
