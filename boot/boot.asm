[org 0x7c00]
bits 16

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti

    ; Mensagem inicial
    mov si, loading_msg
    call print_string

    ; Carregar kernel (200 setores = 100KB)
    mov bx, 0x1000      ; Endereço onde carregar o kernel
    mov ah, 0x02        ; Função de leitura
    mov al, 200         ; Número de setores (ajustado para kernel maior)
    mov ch, 0           ; Cylinder 0
    mov cl, 0x02        ; Sector 2 (kernel começa aqui)
    mov dh, 0           ; Head 0
    mov dl, 0x80        ; Drive 0x80 (HD)
    int 0x13
    jc disk_error

    ; Mensagem de sucesso
    mov si, success_msg
    call print_string

    ; Pequeno delay para ver mensagens
    mov cx, 0xFFFF
delay_loop:
    dec cx
    jnz delay_loop

    ; Pular para o kernel
    jmp 0x0000:0x1000

disk_error:
    mov si, error_msg
    call print_string
    jmp $

print_string:
    mov ah, 0x0e
.print_char:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .print_char
.done:
    ret

loading_msg db "Boot: Carregando kernel... ", 0
success_msg db "OK! Executando kernel...", 0x0D, 0x0A, 0
error_msg db "ERRO: Disco!", 0

times 510 - ($ - $$) db 0
dw 0xAA55
