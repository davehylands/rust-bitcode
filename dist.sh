#!/bin/bash
set -euxo

UNAME=$(uname -s)
case "${UNAME}" in

  Linux)
    ARCH=linux
    TRIPLE=unknown-linux-gnu
    ;;

  Darwin)
    ARCH=darwin
    TRIPLE=apple-darwin
    ;;

  *)
    echo "Unsupported uname: ${UNAME}"
    exit 1
    ;;
esac

source config.sh

WORKING_DIR="$(pwd)/build"
DEST="$(pwd)/dist/rust-${TOOLCHAIN_NAME}-${ARCH}"
TOOLCHAIN_DIR=${TOOLCHAIN_NAME}-${ARCH}
TOOLCHAIN_DEST="${DEST}/toolchain-${TOOLCHAIN_DIR}"

rm -rf "$TOOLCHAIN_DEST"
mkdir -p "$TOOLCHAIN_DEST"

# Note: Any changes made here need corresponding changes in install.sh
cp -r "$WORKING_DIR/rust-build/build/x86_64-${TRIPLE}/stage2"/* "$TOOLCHAIN_DEST"
( \
  cd "${WORKING_DIR}/rust-build/build/x86_64-${TRIPLE}/stage2-tools/x86_64-${TRIPLE}/release"; \
  cp cargo cargo-clippy cargo-fmt cargo-miri clippy-driver git-rustfmt miri rls rustfmt rustfmt-format-diff "${TOOLCHAIN_DEST}/bin"
)

cp LICENSE* README.md "${DEST}"

rm -rf "${DEST}/install.sh"
echo "#!/bin/bash" >> "${DEST}/install.sh"
echo "DEST_TOOLCHAIN=\"\$HOME/.fs-rust/toolchain-${TOOLCHAIN_DIR}\"" >> "${DEST}/install.sh"
echo "mkdir -p \"\${DEST_TOOLCHAIN}\"" >> ${DEST}/install.sh
echo "cp -r \"toolchain-${TOOLCHAIN_DIR}\"/* \"\${DEST_TOOLCHAIN}\"" >> "${DEST}/install.sh"
echo "rustup toolchain link ${TOOLCHAIN_NAME} \"\${DEST_TOOLCHAIN}\"" >> "${DEST}/install.sh"
chmod +x "${DEST}/install.sh"

cd dist
zip -r "rust-${TOOLCHAIN_DIR}.zip" "rust-${TOOLCHAIN_DIR}"
cd ..
