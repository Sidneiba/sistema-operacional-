// keyboard.rs - Driver PS/2 para Teclado no TRI-OS

use core::arch::asm;

// Portas PS/2
const PS2_DATA_PORT: u16 = 0x60;
const PS2_STATUS_PORT: u16 = 0x64;

// Mapa de Scancodes (Set 1 - QEMU/PC antigo) - 128 ELEMENTOS EXATOS
static SCANCODE_MAP: [u8; 128] = [
    // Primeiros 64 elementos (linhas 1-4)
    0, 0, b'1', b'2', b'3', b'4', b'5', b'6', b'7', b'8', b'9', b'0', b'-', b'=', 0, 0,
    b'q', b'w', b'e', b'r', b't', b'y', b'u', b'i', b'o', b'p', b'[', b']', b'\n', 0, 0, 0,
    b'a', b's', b'd', b'f', b'g', b'h', b'j', b'k', b'l', b';', b'\'', b'`', 0, b'\\', 0, 0,
    b'z', b'x', b'c', b'v', b'b', b'n', b'm', b',', b'.', b'/', 0, b'*', 0, b' ', 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
];

// Buffer para teclas
static mut KEY_BUFFER: [u8; 32] = [0; 32];
static mut BUFFER_IDX: usize = 0;

// Funções I/O
unsafe fn inb(port: u16) -> u8 {
    let result: u8;
    asm!("in al, dx", in("dx") port, out("al") result, options(nomem, nostack));
    result
}

unsafe fn outb(port: u16, value: u8) {
    asm!("out dx, al", in("dx") port, in("al") value, options(nomem, nostack));
}

// Inicializar teclado
pub fn init_keyboard() {
    unsafe {
        // Reset e enable
        outb(PS2_DATA_PORT, 0xFF);
        delay(50000);
        outb(PS2_DATA_PORT, 0xF4);
        delay(50000);
        
        // Limpar buffer
        while inb(PS2_STATUS_PORT) & 1 != 0 {
            inb(PS2_DATA_PORT);
        }
    }
}

// Ler scancode
fn read_scancode() -> Option<u8> {
    unsafe {
        if inb(PS2_STATUS_PORT) & 1 != 0 {
            Some(inb(PS2_DATA_PORT))
        } else {
            None
        }
    }
}

// Converter scancode para ASCII
fn scancode_to_ascii(scancode: u8) -> Option<u8> {
    if scancode < 128 {
        let ascii = SCANCODE_MAP[scancode as usize];
        if ascii != 0 { Some(ascii) } else { None }
    } else {
        None
    }
}

// Delay
fn delay(count: u32) {
    let mut i = 0;
    while i < count {
        unsafe { asm!("nop"); }
        i += 1;
    }
}

// Processar teclado
pub fn keyboard_poll() {
    if let Some(scancode) = read_scancode() {
        if let Some(ascii) = scancode_to_ascii(scancode) {
            unsafe {
                KEY_BUFFER[BUFFER_IDX] = ascii;
                BUFFER_IDX = (BUFFER_IDX + 1) % 32;
                
                // Mostrar na tela (linha 10)
                let vga_buffer = 0xb8000 as *mut u8;
                for i in 0..32 {
                    let ch = KEY_BUFFER[i];
                    if ch != 0 {
                        *vga_buffer.offset((10 * 160 + i * 2) as isize) = ch;
                        *vga_buffer.offset((10 * 160 + i * 2 + 1) as isize) = 0x0F;
                    }
                }
            }
        }
    }
}

