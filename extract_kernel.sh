#!/bin/bash

echo "🔧 Iniciando extração do kernel Rust..."

cd kernel

# Encontrar o arquivo do kernel compilado
KERNEL_PATH=$(find target/ -name "trios-kernel" -type f | head -1)

if [ -z "$KERNEL_PATH" ]; then
    echo "❌ ERRO: Arquivo do kernel não encontrado!"
    echo "📁 Procurando em:"
    find target/ -type f -name "*trios*" | head -10
    exit 1
fi

echo "✅ Kernel encontrado em: $KERNEL_PATH"
echo "📏 Tamanho original: $(ls -la "$KERNEL_PATH")"

# Extrair seções importantes do ELF
echo "📦 Extraindo seções do ELF..."

# Extrair .text (código executável)
objcopy -O binary --only-section=.text "$KERNEL_PATH" text.bin 2>/dev/null
TEXT_SIZE=$(stat -c%s text.bin 2>/dev/null || echo 0)

# Extrair .rodata (dados somente leitura)
objcopy -O binary --only-section=.rodata "$KERNEL_PATH" rodata.bin 2>/dev/null
RODATA_SIZE=$(stat -c%s rodata.bin 2>/dev/null || echo 0)

# Extrair .data (dados inicializados)
objcopy -O binary --only-section=.data "$KERNEL_PATH" data.bin 2>/dev/null
DATA_SIZE=$(stat -c%s data.bin 2>/dev/null || echo 0)

echo "📊 Seções extraídas:"
echo "   .text: $TEXT_SIZE bytes"
echo "   .rodata: $RODATA_SIZE bytes" 
echo "   .data: $DATA_SIZE bytes"

# Combinar todas as seções
echo "🔄 Combinando seções..."
cat text.bin rodata.bin data.bin > kernel.bin

# Verificar resultado
FINAL_SIZE=$(stat -c%s kernel.bin)
echo "✅ Kernel final: $FINAL_SIZE bytes"

if [ "$FINAL_SIZE" -lt 100 ]; then
    echo "⚠️  AVISO: Kernel muito pequeno! Verificando alternativas..."
    
    # Tentar método alternativo: extrair tudo exceto cabeçalho
    objcopy -O binary "$KERNEL_PATH" kernel_full.bin 2>/dev/null
    FULL_SIZE=$(stat -c%s kernel_full.bin 2>/dev/null || echo 0)
    
    if [ "$FULL_SIZE" -gt 100 ]; then
        echo "✅ Método alternativo funcionou: $FULL_SIZE bytes"
        mv kernel_full.bin kernel.bin
    else
        echo "❌ Método alternativo também falhou"
    fi
fi

# Limpar arquivos temporários
rm -f text.bin rodata.bin data.bin kernel_full.bin

echo "🎉 Extração concluída!"
ls -la kernel.bin
