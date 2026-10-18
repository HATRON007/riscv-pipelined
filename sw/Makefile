TOOLCHAIN_PREFIX = riscv64-unknown-elf-
CC = $(TOOLCHAIN_PREFIX)gcc
OBJCOPY = $(TOOLCHAIN_PREFIX)objcopy

CFLAGS = -march=rv32im -mabi=ilp32 -mcmodel=medany -ffreestanding -nostdlib -O2

RUNTIME = runtime/crt0.S
LINKER_SCRIPT = runtime/link.ld
BUILD_DIR = build

all: $(BUILD_DIR)/quicksort.mem

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/quicksort.elf: $(RUNTIME) programs/quicksort.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -T $(LINKER_SCRIPT) $^ -o $@

$(BUILD_DIR)/quicksort.bin: $(BUILD_DIR)/quicksort.elf
	$(OBJCOPY) -O binary $< $@

$(BUILD_DIR)/quicksort.mem: $(BUILD_DIR)/quicksort.bin
	python3 hexgen.py $< $@

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean