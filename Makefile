.PHONY: all build run clean

all: build

build:
	@echo "🔨 Compilando bootloader..."
	cd boot && nasm -f bin boot.asm -o boot.bin
	@echo "🔨 Compilando kernel Rust..."
	cd kernel && ./build.sh
	@echo "📦 Criando imagem..."
	dd if=/dev/zero of=dist/trios.img bs=512 count=10000 2>/dev/null
	dd if=boot/boot.bin of=dist/trios.img conv=notrunc 2>/dev/null
	dd if=kernel/kernel.bin of=dist/trios.img bs=512 seek=1 conv=notrunc 2>/dev/null

run: build
	@echo "🚀 Executando no QEMU..."
	qemu-system-x86_64 -drive format=raw,file=dist/trios.img -m 64M

clean:
	rm -f boot/boot.bin kernel/kernel.bin kernel/kernel.elf dist/trios.img
	@echo "🧹 Limpeza concluída!"
