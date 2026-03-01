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

# Get the commit hash that nightly-2025-09-02 was built from
RUSTC_COMMIT=$(rustc +nightly-2025-09-02 -vV | grep 'commit-hash' | awk '{print $2}')
echo "nightly-2025-09-02 commit: $RUSTC_COMMIT"

# Clone rustc source at the matching commit
if [ ! -d rust ]; then
    git clone https://github.com/rust-lang/rust.git
    cd rust
    git checkout "$RUSTC_COMMIT"
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
