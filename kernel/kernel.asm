bits 16
org 0x1000

start:
    ; Configurar segmento de vídeo
    mov ax, 0xB800
    mov es, ax
    mov di, 0
    
    ; Mensagem de sucesso
    mov si, msg
    mov ah, 0x1E  ; Cor: amarelo sobre azul
    
print_loop:
    lodsb
    cmp al, 0
    je hang
    stosw
    jmp print_loop
    
hang:
    jmp hang

msg db "TRI-OS KERNEL FUNCIONANDO! :)", 0

; Preencher até 512 bytes
times 512 - ($ - $$) db 0
