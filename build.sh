#!/bin/bash

# Set the Rust target triple for each architecture
IOS_TARGET="aarch64-apple-ios"
IOS_SIM_TARGET="aarch64-apple-ios-sim"

# Set the output directory for Rust builds
OUTPUT_DIR="target"

# Step 1: Clean the build environment
echo "Cleaning previous build artifacts..."
cargo clean

# Function to build for a specific target
build_target() {
    local target=$1
    echo "Building for target: $target"
    cargo build --release --target "$target"
}

# Step 2: Build for iOS (device)
build_target $IOS_TARGET

# Step 3: Build for iOS Simulator (arm64)
build_target $IOS_SIM_TARGET

# Output paths for the resulting libraries
echo "Build complete. Libraries are located in:"
echo "$OUTPUT_DIR/$IOS_TARGET/release/libsignal_ffi.a"
echo "$OUTPUT_DIR/$IOS_SIM_TARGET/release/libsignal_ffi.a"
