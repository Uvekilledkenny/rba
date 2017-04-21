#![no_std]
#![feature(lang_items)]
#![feature(asm)]

extern crate baselib;
use baselib::*;

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
        x += 1;
    }
}