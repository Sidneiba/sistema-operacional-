bits 16
org 0x7e00

start:
    ; Configurar segmento de vídeo
    mov ax, 0xB800
    mov es, ax
    mov di, 0
    
    ; Mensagem inicial
    mov si, msg_hello
    mov ah, 0x1E  ; Amarelo sobre azul
    call print_str
    
    ; Inicializar teclado
    call init_keyboard
    
    ; Mensagem de instrução
    mov si, msg_instructions
    mov di, 160  ; Linha 1
    mov ah, 0x0F ; Branco
    call print_str_at

keyboard_loop:
    ; Polling do teclado
    call keyboard_poll
    jmp keyboard_loop

; ========== ROTINAS DO TECLADO ==========

init_keyboard:
    ; Reset do teclado
    mov al, 0xFF
    out 0x60, al
    call delay
    
    ; Enable scanning
    mov al, 0xF4
    out 0x60, al
    call delay
    ret

keyboard_poll:
    ; Verificar se há tecla disponível
    in al, 0x64
    test al, 1
    jz .no_key
    
    ; Ler scancode
    in al, 0x60
    
    ; Converter scancode para ASCII
    call scancode_to_ascii
    cmp al, 0
    je .no_key
    
    ; Mostrar tecla na tela
    call show_key
    
.no_key:
    ret

scancode_to_ascii:
    ; Mapeamento direto de scancodes
    cmp al, 0x1E  ; A
    je .key_a
    cmp al, 0x1F  ; S
    je .key_s
    cmp al, 0x20  ; D
    je .key_d
    cmp al, 0x21  ; F
    je .key_f
    cmp al, 0x22  ; G
    je .key_g
    cmp al, 0x23  ; H
    je .key_h
    cmp al, 0x24  ; J
    je .key_j
    cmp al, 0x25  ; K
    je .key_k
    cmp al, 0x26  ; L
    je .key_l
    cmp al, 0x10  ; Q
    je .key_q
    cmp al, 0x11  ; W
    je .key_w
    cmp al, 0x12  ; E
    je .key_e
    cmp al, 0x13  ; R
    je .key_r
    cmp al, 0x14  ; T
    je .key_t
    cmp al, 0x15  ; Y
    je .key_y
    cmp al, 0x16  ; U
    je .key_u
    cmp al, 0x17  ; I
    je .key_i
    cmp al, 0x18  ; O
    je .key_o
    cmp al, 0x19  ; P
    je .key_p
    cmp al, 0x2C  ; Z
    je .key_z
    cmp al, 0x2D  ; X
    je .key_x
    cmp al, 0x2E  ; C
    je .key_c
    cmp al, 0x2F  ; V
    je .key_v
    cmp al, 0x30  ; B
    je .key_b
    cmp al, 0x31  ; N
    je .key_n
    cmp al, 0x32  ; M
    je .key_m
    cmp al, 0x02  ; 1
    je .key_1
    cmp al, 0x03  ; 2
    je .key_2
    cmp al, 0x04  ; 3
    je .key_3
    cmp al, 0x05  ; 4
    je .key_4
    cmp al, 0x06  ; 5
    je .key_5
    cmp al, 0x07  ; 6
    je .key_6
    cmp al, 0x08  ; 7
    je .key_7
    cmp al, 0x09  ; 8
    je .key_8
    cmp al, 0x0A  ; 9
    je .key_9
    cmp al, 0x0B  ; 0
    je .key_0
    cmp al, 0x39  ; Espaço
    je .key_space
    cmp al, 0x1C  ; Enter
    je .key_enter
    mov al, 0
    ret

.key_a: mov al, 'A' ret
.key_s: mov al, 'S' ret  
.key_d: mov al, 'D' ret
.key_f: mov al, 'F' ret
.key_g: mov al, 'G' ret
.key_h: mov al, 'H' ret
.key_j: mov al, 'J' ret
.key_k: mov al, 'K' ret
.key_l: mov al, 'L' ret
.key_q: mov al, 'Q' ret
.key_w: mov al, 'W' ret
.key_e: mov al, 'E' ret
.key_r: mov al, 'R' ret
.key_t: mov al, 'T' ret
.key_y: mov al, 'Y' ret
.key_u: mov al, 'U' ret
.key_i: mov al, 'I' ret
.key_o: mov al, 'O' ret
.key_p: mov al, 'P' ret
.key_z: mov al, 'Z' ret
.key_x: mov al, 'X' ret
.key_c: mov al, 'C' ret
.key_v: mov al, 'V' ret
.key_b: mov al, 'B' ret
.key_n: mov al, 'N' ret
.key_m: mov al, 'M' ret
.key_1: mov al, '1' ret
.key_2: mov al, '2' ret
.key_3: mov al, '3' ret
.key_4: mov al, '4' ret
.key_5: mov al, '5' ret
.key_6: mov al, '6' ret
.key_7: mov al, '7' ret
.key_8: mov al, '8' ret
.key_9: mov al, '9' ret
.key_0: mov al, '0' ret
.key_space: mov al, ' ' ret
.key_enter: mov al, 0x0D ret

show_key:
    ; Mostrar tecla na linha 10
    mov di, 10 * 160
    add di, [key_position]
    mov [es:di], al
    mov byte [es:di+1], 0x0E  ; Amarelo
    
    ; Avançar posição
    add word [key_position], 2
    cmp word [key_position], 160
    jb .done
    mov word [key_position], 0
.done:
    ret

; ========== ROTINAS GERAIS ==========

print_str:
    lodsb
    test al, al
    jz .done
    stosw
    jmp print_str
.done:
    ret

print_str_at:
    ; DI = posição inicial
    mov bx, di
.print_char:
    lodsb
    test al, al
    jz .done
    mov [es:di], al
    inc di
    mov [es:di], ah
    inc di
    jmp .print_char
.done:
    ret

delay:
    mov cx, 0xFFFF
.delay_loop:
    dec cx
    jnz .delay_loop
    ret

; ========== DADOS ==========

msg_hello db "TRI-OS Kernel Assembly com Teclado PS/2!", 0
msg_instructions db "Pressione teclas (A-Z, 0-9, ESPACO, ENTER):", 0
key_position dw 0

times 1024 - ($ - $$) db 0  ; 2 setores
