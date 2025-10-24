#!/bin/bash

# Corrige a toolchain do Rust
rustup default stable
rustup target add i686-unknown-none

# Limpa e recompila o projeto
cd ~/tri-os
make clean
make run
