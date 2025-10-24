#![no_std]
#![no_main]

use core::panic::PanicInfo;

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

#[no_mangle]
pub extern "C" fn _start() -> ! {
    // Escrever diretamente na memória de vídeo VGA
    let vga_buffer = 0xB8000 as *mut u8;
    
    let message = b"TRI-OS RUST BARE-METAL FUNCIONANDO!";
    
    for (i, &byte) in message.iter().enumerate() {
        unsafe {
            *vga_buffer.offset(i as isize * 2) = byte;
            *vga_buffer.offset(i as isize * 2 + 1) = 0x1E; // Cor amarela
        }
    }
    
    loop {}
}
