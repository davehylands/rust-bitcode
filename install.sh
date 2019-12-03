#!/bin/bash
set -euxo
source config.sh

WORKING_DIR="$(pwd)/build"
DEST_TOOLCHAIN="$HOME/.fs-rust/toolchain-${TOOLCHAIN_NAME}"

mkdir -p "$DEST_TOOLCHAIN"

# Note: Any changes made here need corresponding changes in dist.sh
cp -r "$WORKING_DIR/rust-build/build/x86_64-apple-darwin/stage2"/* "$DEST_TOOLCHAIN"
( \
  cd "${WORKING_DIR}/rust-build/build/x86_64-apple-darwin/stage2-tools/x86_64-apple-darwin/release"; \
  cp cargo cargo-clippy cargo-fmt cargo-miri clippy-driver git-rustfmt miri rls rustfmt rustfmt-format-diff "${DEST_TOOLCHAIN}/bin"
)

rustup toolchain link ${TOOLCHAIN_NAME} "$DEST_TOOLCHAIN"
