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

# Shallow-clone rustc source at the exact nightly-2025-09-02 commit
RUSTC_COMMIT=7aef4bec4bec16cb6204d51eb633873e23b18771
if [ ! -d rust ]; then
    mkdir rust
    cd rust
    git init
    git remote add origin https://github.com/rust-lang/rust.git
    git fetch --depth 1 origin "$RUSTC_COMMIT"
    git checkout FETCH_HEAD
    cd ..
fi

# Create seed directory and add a minimal example
mkdir -p seeds
if [ -z "$(ls -A seeds 2>/dev/null)" ]; then
    echo 'fn main() {}' > seeds/minimal.rs
    echo 'fn main() { let x: i32 = 42; println!("{}", x); }' > seeds/hello.rs
fi

echo ""
echo "Setup complete."
echo "  - Add .rs files to ./seeds/ as starting inputs for the fuzzer."
echo "  - Run ./run-fuzzer.sh to start fuzzing."
