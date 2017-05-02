BINUTILS_PREFIX=arm-none-eabi-

default: out build

out:
	mkdir -p out

build:
	xargo build  --target=gba --release
	$(BINUTILS_PREFIX)as -o out/crt0.o asm/crt0.s
	$(BINUTILS_PREFIX)ld -T asm/lnkscript -o out/test.elf out/crt0.o target/gba/release/libgame.a
	$(BINUTILS_PREFIX)objcopy -O binary out/test.elf out/test.gba
	gbafix out/test.gba

clean:
	xargo clean
	rm -rf out Cargo.lock