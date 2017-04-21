BINUTILS_PREFIX=arm-none-eabi-

default: out build

out:
	mkdir -p out

build:
	xargo build --release --target=gba --verbose
	$(BINUTILS_PREFIX)as -o out/crt0.o base/crt0.s
	$(BINUTILS_PREFIX)ld -T base/lnkscript -o out/test.elf out/crt0.o target/gba/release/libgbatest.a
	$(BINUTILS_PREFIX)objcopy -O binary out/test.elf out/test.gba
	gbafix out/test.gba

clean:
	xargo clean
	rm -rf out Cargo.lock