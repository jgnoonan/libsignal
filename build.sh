#!/bin/bash

set -euo pipefail

# Navigate to the project root
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
cd "${SCRIPT_DIR}"

# Export common Rust build environment variables
export CARGO_PROFILE_RELEASE_DEBUG=1 # Enable line tables for debugging
export RUSTFLAGS="--cfg aes_armv8 ${RUSTFLAGS:-}" # ARMv8 cryptography acceleration

# Set up iOS-specific build settings
export IPHONEOS_DEPLOYMENT_TARGET=13
export CARGO_PROFILE_RELEASE_LTO=fat # Use full LTO to reduce binary size
export CFLAGS="-flto=full -DOPENSSL_SMALL ${CFLAGS:-}" # Optimize for size

# Work around cc crate bug for Catalyst targets
export CFLAGS_aarch64_apple_ios_macabi="--target=arm64-apple-ios-macabi ${CFLAGS:-}"
export CFLAGS_x86_64_apple_ios_macabi="--target=x86_64-apple-ios-macabi ${CFLAGS:-}"

# Function to build for a specific target
build_target() {
  local target=$1
  echo "Building for target: $target"
  cargo build -p libsignal-ffi --release --target "$target"
}

# Build for both iOS targets
build_target "aarch64-apple-ios"
build_target "aarch64-apple-ios-sim"

# Optional: Regenerate FFI headers if needed
generate_ffi_headers() {
  local ffi_header_path="swift/Sources/SignalFfi/signal_ffi.h"
  local ffi_testing_header_path="swift/Sources/SignalFfi/signal_ffi_testing.h"

  if ! command -v cbindgen > /dev/null; then
    echo 'error: cbindgen not found in PATH' >&2
    exit 1
  fi

  echo "Generating FFI headers..."
  cbindgen --profile release -o "$ffi_header_path" rust/bridge/ffi
  cbindgen --profile release -o "$ffi_testing_header_path" rust/bridge/shared/testing --config rust/bridge/ffi/cbindgen-testing.toml
}

# Uncomment the line below if FFI headers need to be regenerated
# generate_ffi_headers

echo "Rust build completed successfully."
