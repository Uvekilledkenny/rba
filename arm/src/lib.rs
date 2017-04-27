#![no_std]
#![feature(lang_items)]
#![feature(asm)]

extern crate baselib;

use baselib::*;

type CFunc = extern "C" fn();

#[allow(non_snake_case)]
#[no_mangle]
#[link_section=".iwram"]
pub extern "C" fn VBlank() {
    hw::write_regifbios(1);
    hw::write_regif(1);
}

pub extern "C" fn default() {}

#[no_mangle]
#[link_section = ".iwram"]
pub static IntrTable: [CFunc; 13] = 
    [VBlank, default, default, default, default, default, 
    default, default, default, default, default, default, default];
