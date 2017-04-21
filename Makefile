BINUTILS_PREFIX=arm-none-eabi-
RUST_LIBS=libs

default: out build

out:
	mkdir -p out

build:
	xargo build --release --target=gba
	$(BINUTILS_PREFIX)as -o out/crt0.o base/crt0.s
	$(BINUTILS_PREFIX)ld -T base/lnkscript -o out/test.elf out/crt0.o target/gba/release/libgbatest.a
	$(BINUTILS_PREFIX)objcopy -O binary out/test.elf out/test.gba
