import sys

MEM_WORDS = 8192

def bin_to_mem(bin_file, mem_file):
    with open(bin_file, 'rb') as f:
        data = f.read()

    if len(data) % 4 != 0:
        data += b'\x00' * (4 - (len(data) % 4))

    word_count = len(data) // 4

    with open(mem_file, 'w') as f:
        for i in range(0, len(data), 4):
            word = data[i] | (data[i+1] << 8) | (data[i+2] << 16) | (data[i+3] << 24)
            f.write(f"{word:08x}\n")
        for _ in range(word_count, MEM_WORDS):
            f.write("00000000\n")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 hexgen.py <input.bin> <output.mem>")
        sys.exit(1)
    bin_to_mem(sys.argv[1], sys.argv[2])