#
# arm64 makefile
#
# Authors: Andrew Jones <drjones@redhat.com>
#
bits = 64
ldarch = elf64-littleaarch64
kernel_offset = 0x80000

cstart.o = $(TEST_DIR)/cstart64.o
cflatobjs += lib/arm64/processor.o
cflatobjs += lib/arm64/spinlock.o

# arm64 specific tests
tests = $(TEST_DIR)/test-exinj.flat

include config/config-arm-common.mak

arch_clean: arm_clean
	$(RM) lib/arm64/.*.d

$(TEST_DIR)/test-exinj.elf: $(cstart.o) $(TEST_DIR)/test-exinj.o
