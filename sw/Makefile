TOOLCHAIN_PREFIX = riscv64-unknown-elf-
CC      = $(TOOLCHAIN_PREFIX)gcc
OBJCOPY = $(TOOLCHAIN_PREFIX)objcopy
OBJDUMP = $(TOOLCHAIN_PREFIX)objdump
NM      = $(TOOLCHAIN_PREFIX)nm

COMMON_FLAGS = -mabi=ilp32 -mcmodel=medlow -O2 \
               -ffreestanding -nostdlib -fno-builtin -mno-relax \
               -fno-if-conversion -fno-if-conversion2 \
               -fno-tree-loop-distribute-patterns -fno-unroll-loops \
               -fno-tree-vectorize -fno-jump-tables -fno-pic \
               -fno-stack-protector -Ibench

CFLAGS_BP   = -march=rv32i $(COMMON_FLAGS)
CFLAGS_IMUL = -march=rv32i_zmmul $(COMMON_FLAGS)

RUNTIME       = runtime/crt0.S
LINKER_SCRIPT = runtime/link.ld
BUILD_DIR     = build

TARGETS = bp_bubblesort bp_binsearch bp_sieve \
          imul_matmul_w8 imul_matmul_w16 imul_matmul_w32

MEMS  = $(patsubst %, $(BUILD_DIR)/%.mem, $(TARGETS))
DUMPS = $(patsubst %, $(BUILD_DIR)/%.dump, $(TARGETS))

vpath %.c bench

all: $(MEMS) $(DUMPS)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Branch predictor benchmarks (RV32I)
$(BUILD_DIR)/bp_%.elf: $(RUNTIME) bp_%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS_BP) -T $(LINKER_SCRIPT) -Wl,-Map=$(BUILD_DIR)/bp_$*.map $^ -o $@
	@! $(NM) -u $@ | grep -q . || (echo "Error: Undefined symbols in $@" && exit 1)

# Multiplier benchmarks (RV32I + Zmmul), WIDTH = 8 / 16 / 32
$(BUILD_DIR)/imul_matmul_w%.elf: $(RUNTIME) imul_matmul.c | $(BUILD_DIR)
	$(CC) $(CFLAGS_IMUL) -DWIDTH=$* -T $(LINKER_SCRIPT) -Wl,-Map=$(BUILD_DIR)/imul_matmul_w$*.map $^ -o $@
	@! $(NM) -u $@ | grep -q . || (echo "Error: Undefined symbols in $@" && exit 1)

$(BUILD_DIR)/%.dump: $(BUILD_DIR)/%.elf
	$(OBJDUMP) -d -M no-aliases $< > $@
	@! grep -E '\b(mulh|mulhu|mulhsu|div|divu|rem|remu|csrr|csrw|ecall|ebreak)\b' $@ || \
		(echo "Error: Unsupported instruction in $@" && exit 1)

$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf
	$(OBJCOPY) -O binary $< $@

$(BUILD_DIR)/%.mem: $(BUILD_DIR)/%.bin
	python3 hexgen.py $< $@
	@test $$(wc -l < $@) -le 8192 || (echo "Error: $@ exceeds 8192 words" && exit 1)

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean