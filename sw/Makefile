TOOLCHAIN_PREFIX = riscv64-unknown-elf-
CC      = $(TOOLCHAIN_PREFIX)gcc
OBJCOPY = $(TOOLCHAIN_PREFIX)objcopy
OBJDUMP = $(TOOLCHAIN_PREFIX)objdump
NM      = $(TOOLCHAIN_PREFIX)nm
HOST_CC = gcc

COMMON_FLAGS = -mabi=ilp32 -mcmodel=medlow -O2 \
               -ffreestanding -nostdlib -fno-builtin -mno-relax \
               -fno-if-conversion -fno-if-conversion2 \
               -fno-tree-loop-distribute-patterns -fno-unroll-loops \
               -fno-tree-vectorize -fno-jump-tables -fno-pic \
               -fno-stack-protector -Ibench

CFLAGS_BP   = -march=rv32i $(COMMON_FLAGS)
CFLAGS_IMUL = -march=rv32im $(COMMON_FLAGS)

BP_DEFS ?=

RUNTIME       = runtime/crt0.S
LINKER_SCRIPT = runtime/link.ld
BUILD_DIR     = build

PROG_SRCS  = $(wildcard programs/*.c)
BENCH_SRCS = $(wildcard bench/*.c)
ALL_SRCS   = $(PROG_SRCS) $(BENCH_SRCS)

MEMS  = $(patsubst %.c, $(BUILD_DIR)/%.mem, $(notdir $(ALL_SRCS)))
DUMPS = $(patsubst %.c, $(BUILD_DIR)/%.dump, $(notdir $(ALL_SRCS)))

vpath %.c programs bench

all: $(MEMS) $(DUMPS)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/bp_%.elf: $(RUNTIME) bp_%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS_BP) $(BP_DEFS) -T $(LINKER_SCRIPT) -Wl,-Map=$(BUILD_DIR)/bp_$*.map $^ -o $@
	@! $(NM) -u $@ | grep -q . || (echo "Error: Undefined symbols in $@" && exit 1)

$(BUILD_DIR)/%.elf: $(RUNTIME) %.c | $(BUILD_DIR)
	$(CC) $(CFLAGS_IMUL) -T $(LINKER_SCRIPT) -Wl,-Map=$(BUILD_DIR)/$*.map $^ -o $@
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

host-check: | $(BUILD_DIR)
	@for src in $(BENCH_SRCS); do \
		name=$$(basename $$src .c); \
		$(HOST_CC) -O2 -DHOST_RUN -Ibench $$src -o $(BUILD_DIR)/$$name.host && \
		printf "%-16s: " $$name && ./$(BUILD_DIR)/$$name.host || exit 1; \
	done

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean host-check