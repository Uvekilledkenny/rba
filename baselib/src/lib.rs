#![no_std]
#![feature(lang_items)]
#![feature(asm)]

#[lang = "eh_personality"]
pub extern "C" fn rust_eh_personality() {}

#[lang = "panic_fmt"]
pub extern "C" fn rust_begin_panic() {}

pub mod hw {
    use core::ptr::{read_volatile, write_volatile};
    
    #[allow(dead_code)]
    unsafe fn read16(addr: u32) -> u16 {
        read_volatile(addr as *const u16)
    }

    unsafe fn write16(addr: u32, value: u16) {
        write_volatile(addr as *mut u16, value);
    }

    macro_rules! hw_reg {
            (rw $addr: expr, $read:ident, $write: ident) => {
                #[allow(dead_code)]
                pub fn $read() -> u16 {
                    unsafe { read16($addr) }
                }

                #[allow(dead_code)]
                pub fn $write(value: u16) {
                    unsafe { write16($addr, value) }
                }
            };
            (r $addr: expr, $read: ident) => {
                #[allow(dead_code)]
                pub fn $read() -> u16 {
                    unsafe { read16($addr) }
                }
            };
            (w $addr: expr, $write: ident) => {
                #[allow(dead_code)]
                pub fn $write(value: u16) {
                    unsafe { write16($addr, value) }
                }
            };
    }

    hw_reg!(w  0x03007FF8, write_regifbios);
    hw_reg!(rw 0x04000000, read_dispcnt, write_dispcnt);
    hw_reg!(rw 0x04000004, read_dispstat, write_dispstat);
    hw_reg!(rw 0x04000008, read_bg0cnt, write_bg0cnt);
    hw_reg!(w  0x04000200, write_regie);
    hw_reg!(w  0x04000202, write_regif);
    hw_reg!(w  0x04000208, write_regime);

    pub fn write_pal(index: u32, col: u16) {
        if index < 512 {
            unsafe { write16(0x5000000u32 + (index * 2) as u32, col) }
        }
    }

    pub fn write_vram16(offset: u32, data: u16) {
        if offset < 0xc000 {
            unsafe { write16(0x6000000u32 + offset * 2, data) }
        }
    }

    pub fn wait_vblank() {
        unsafe {
            asm!("swi #0x5" ::: "r0", "r1", "r2", "r3" : "volatile");
        }
    }
}