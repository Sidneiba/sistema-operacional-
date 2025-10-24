#!/bin/bash
echo "🔨 Compilando kernel Rust bare-metal..."
rustc +nightly \
    -C panic=abort \
    --target x86_64-unknown-none \
    --edition 2021 \
    -O \
    -o kernel.elf \
    src/main.rs

echo "📦 Convertendo para binário..."
rust-objcopy -O binary kernel.elf kernel.bin

echo "✅ Kernel compilado! Tamanho:"
ls -la kernel.bin
