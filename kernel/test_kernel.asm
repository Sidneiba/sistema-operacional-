bits 16
org 0x1000

start:
    mov ax, 0xB800
    mov es, ax
    mov di, 0
    
    mov si, msg
    mov ah, 0x1E
print_loop:
    lodsb
    cmp al, 0
    je hang
    stosw
    jmp print_loop

hang:
    jmp hang

msg db "KERNEL ASSEMBLY FUNCIONANDO!", 0

times 512 db 0
