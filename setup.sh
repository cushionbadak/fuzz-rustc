#!/bin/bash
# Setup script for running fuzz-rustc on a bare Ubuntu machine.
# Targets nightly-2025-09-02 specifically.

set -e
set -x

# Install system dependencies
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    git \
    curl \
    cmake \
    pkg-config \
    libssl-dev

# Install rustup if not already installed
if ! command -v rustup &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

# Install the specific nightly toolchain
rustup toolchain install nightly-2025-09-02
rustup override set nightly-2025-09-02

# Clone the rustc fork with fuzz-friendly modifications (if not already present)
if [ ! -d rust ]; then
    git clone https://github.com/dwrensha/rust.git --branch fuzz
fi

echo ""
echo "Setup complete. Run ./run-fuzzer.sh to start fuzzing."
