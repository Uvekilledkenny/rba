#![feature(lang_items, target_feature, asm, cfg_target_feature)]
#![allow(dead_code)]
#![no_std]
#![no_main]

#[lang = "eh_personality"]
pub extern "C" fn rust_eh_personality() {}

#[no_mangle]
#[lang = "panic_fmt"]
pub extern "C" fn panic_fmt() {}

pub mod hw {
    use core::ptr::{read_volatile, write_volatile};
    
    unsafe fn read16(addr: u32) -> u16 {
        read_volatile(addr as *const u16)
    }

    unsafe fn write16(addr: u32, value: u16) {
        write_volatile(addr as *mut u16, value);
    }

    macro_rules! hw_reg {
            (rw $addr: expr, $read:ident, $write: ident) => {
                pub fn $read() -> u16 {
                    unsafe { read16($addr) }
                }

                pub fn $write(value: u16) {
                    unsafe { write16($addr, value) }
                }
            };
            (r $addr: expr, $read: ident) => {
                pub fn $read() -> u16 {
                    unsafe { read16($addr) }
                }
            };
            (w $addr: expr, $write: ident) => {
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
    
    #[inline]
    #[cfg(target_feature = "-thumb-mode")]
    pub fn wait_vblank() {
        unsafe {
            asm!("swi #0x5000" ::: "r0", "r1", "r2", "r3" : "volatile");
        }
    }
    
    #[inline]
    #[cfg(not(target_feature = "-thumb-mode"))]
    pub fn wait_vblank() {
        unsafe {
            asm!("swi #0x5" ::: "r0", "r1", "r2", "r3" : "volatile");
        }
    }
}

type CFunc = extern "C" fn();

#[link_section=".iwram"]
#[target_feature = "-thumb-mode, +long-calls"]
pub extern "C" fn vblank() {
    hw::write_regifbios(1);
    hw::write_regif(1);
}

pub extern "C" fn default() {}

#[no_mangle]
#[link_section = ".iwram"]
#[target_feature = "-thumb-mode, +long-calls"]
#[allow(non_upper_case_globals)]
pub static IntrTable: [CFunc; 13] = 
    [vblank, default, default, default, default, default, 
    default, default, default, default, default, default, default];


#[allow(non_snake_case)]
#[no_mangle]
pub extern "C" fn AgbMain() {
    hw::write_dispstat(1 << 3);
    hw::write_regie(1);
    hw::write_regime(1);

    hw::write_dispcnt(1 << 8);
    hw::write_bg0cnt(1 << 8);
    hw::write_pal(15, 0x7fff);
    hw::write_pal(31, 31 << 5);
    
    for i in 1..7 {
        hw::write_vram16(i * 2, 0xfff0);
        hw::write_vram16(i * 2 + 1, 0x0fff);
    }

    let mut x = 1u16;

    loop {
        hw::write_pal(15, 0x7fff - x);
        hw::wait_vblank();
        x += 5;
    }
}