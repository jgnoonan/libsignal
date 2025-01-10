#!/bin/bash

# Define the path to the specific Cargo.toml file
CARGO_MANIFEST_PATH="/Users/jgnoonan/libsignal/rust/bridge/ffi/Cargo.toml"

# Set the Rust target triple for each architecture
IOS_TARGET="aarch64-apple-ios"
IOS_SIM_TARGET="aarch64-apple-ios-sim"

# Clean previous builds
echo "Cleaning previous build artifacts..."
cargo clean --manifest-path "$CARGO_MANIFEST_PATH"

# Function to build for a specific target
build_target() {
    local target=$1
    echo "Building for target: $target"
    cargo build --release --target "$target" --manifest-path "$CARGO_MANIFEST_PATH"
}

# Build for iOS (device)
build_target $IOS_TARGET

# Build for iOS Simulator (arm64)
build_target $IOS_SIM_TARGET

# Output paths for the resulting libraries
echo "Build complete. Libraries are located in:"
echo "target/$IOS_TARGET/release/libsignal_ffi.a"
echo "target/$IOS_SIM_TARGET/release/libsignal_ffi.a"
