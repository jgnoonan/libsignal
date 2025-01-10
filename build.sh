#!/bin/bash

if [ -z "${PROJECT_TEMP_DIR}" ]; then
    echo "PROJECT_TEMP_DIR is not set. Falling back to a default directory."
    PROJECT_TEMP_DIR="/tmp/libsignal_temp"
fi

echo "Using PROJECT_TEMP_DIR: $PROJECT_TEMP_DIR"

# Define the workspace root
WORKSPACE_ROOT="/Users/jgnoonan/libsignal"

# Define the temporary directory expected by Xcode
LIBSIGNAL_FFI_TEMP_DIR="${PROJECT_TEMP_DIR}/libsignal_ffi"

# Set the Rust target triple for each architecture
IOS_TARGET="aarch64-apple-ios"
IOS_SIM_TARGET="aarch64-apple-ios-sim"

# Navigate to the workspace root
cd "$WORKSPACE_ROOT" || exit

# Clean previous builds
echo "Cleaning previous build artifacts..."
cargo clean

# Build for iOS (device)
echo "Building for iOS target: $IOS_TARGET"
cargo build --release --target "$IOS_TARGET" --manifest-path "rust/bridge/ffi/Cargo.toml"

# Build for iOS Simulator (arm64)
echo "Building for iOS Simulator target: $IOS_SIM_TARGET"
cargo build --release --target "$IOS_SIM_TARGET" --manifest-path "rust/bridge/ffi/Cargo.toml"

# Create directories in the expected location
echo "Preparing directories in $LIBSIGNAL_FFI_TEMP_DIR"
mkdir -p "$LIBSIGNAL_FFI_TEMP_DIR/target/$IOS_TARGET/release"
mkdir -p "$LIBSIGNAL_FFI_TEMP_DIR/target/$IOS_SIM_TARGET/release"

# Copy built libraries to the expected locations
echo "Copying libraries to $LIBSIGNAL_FFI_TEMP_DIR"
cp "target/$IOS_TARGET/release/libsignal_ffi.a" "$LIBSIGNAL_FFI_TEMP_DIR/target/$IOS_TARGET/release/"
cp "target/$IOS_SIM_TARGET/release/libsignal_ffi.a" "$LIBSIGNAL_FFI_TEMP_DIR/target/$IOS_SIM_TARGET/release/"

echo "Build complete. Libraries are available in $LIBSIGNAL_FFI_TEMP_DIR"

