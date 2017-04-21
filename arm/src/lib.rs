#![no_std]
#![feature(lang_items)]
#![feature(asm)]

extern crate baselib;

use baselib::*;

#[allow(non_snake_case)]
#[no_mangle]
#[link_section=".iwram"]
pub extern "C" fn InterruptProcess() {
    hw::write_regifbios(1);
    hw::write_regif(1);
}
