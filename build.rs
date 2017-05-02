use std::path::{PathBuf, Path};
use std::process::Command;
use std::io::Write;
use std::fs::File;
use std::env;

fn main() {
    let crt0path = PathBuf::from("asm/crt0.s").canonicalize().unwrap();
    let out_dir = env::var("OUT_DIR").unwrap();    
    
    File::create(&PathBuf::from(&out_dir).join("layout.ld"))
        .unwrap()
        .write_all(include_bytes!("asm/layout.ld"))
        .unwrap();

    Command::new("arm-none-eabi-as").args(&[crt0path.to_str().unwrap(), "-o"])
                       .arg(&format!("{}/crt0.o", out_dir))
                       .status().unwrap();

    Command::new("arm-none-eabi-ar").args(&["crus", "libcrt0.a", "crt0.o"])
                      .current_dir(&Path::new(&out_dir))
                      .status().unwrap();

    println!("cargo:rustc-link-search={}", out_dir);
    println!("cargo:rustc-link-lib=static=crt0");
    println!("cargo:rerun-if-changed=build.rs");
    println!("cargo:rerun-if-changed=asm/lnkscript");
    println!("cargo:rerun-if-changed=asm/crt0.s");
}