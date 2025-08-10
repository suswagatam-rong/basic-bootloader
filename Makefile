# Variables
SRC = src/bootloader.asm
BIN = build/bootloader.bin
IMG = build/bootloader.img

# Targets
all: build $(IMG)

build:
	mkdir -p build

$(BIN): $(SRC)
	nasm -f bin $< -o $@

$(IMG): $(BIN)
	dd if=$< of=$@ bs=512 count=1

clean:
	rm -rf build
