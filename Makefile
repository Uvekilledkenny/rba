BINUTILS_PREFIX=arm-none-eabi-
THUMB=thumb
ARM=arm

CHDIR_SHELL := $(SHELL)
define chdir
   $(eval _D=$(firstword $(1) $(@D)))
   $(info $(MAKE): cd $(_D)) $(eval SHELL = cd $(_D); $(CHDIR_SHELL))
endef

default: out thumb/build arm/build build

out:
	mkdir -p out

thumb/build:
	$(call chdir)
	xargo build  --target=gba --release

arm/build:
	$(call chdir)
	xargo build  --target=gba --release

build:
	$(call chdir)
	$(BINUTILS_PREFIX)as -o out/crt0.o asm/crt0.s
	$(BINUTILS_PREFIX)ld -T asm/lnkscript -o out/test.elf out/crt0.o arm/target/gba/release/libarm.a thumb/target/gba/release/libthumb.a
	$(BINUTILS_PREFIX)objcopy -O binary out/test.elf out/test.gba
	gbafix out/test.gba

clean:
	xargo clean
	rm -rf out Cargo.lock