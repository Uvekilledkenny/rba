BINUTILS_PREFIX=arm-none-eabi-

default: release

out:
	mkdir -p build

release: out
	xargo build --release
	$(BINUTILS_PREFIX)objcopy -O binary target/gba/release/game build/test.gba
	gbafix build/test.gba

debug: out
	xargo build
	$(BINUTILS_PREFIX)objcopy -O binary target/gba/debug/game build/test_debug.gba
	gbafix build/test_debug.gba

clean:
	xargo clean
	rm -rf build