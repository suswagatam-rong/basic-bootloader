# My First Bootloader: Notes

This is my first attempt at writing a bootloader! It's simple, but it works, and I want to make sure I remember everything I’ve learned while setting it up.

---

## Bootloader Code

```asm
bits 16                ; Tell NASM this is 16-bit code
org 0x7c00             ; Start output at offset 0x7c00

boot:
    mov si,hello        ; Point SI register to hello label memory location
    mov ah,0x0e         ; 0x0E means 'Write Character in TTY mode'
.loop:
    lodsb               ; Load the next byte from [SI] into AL
    or al,al            ; Check if AL == 0 (end of string)
    jz halt             ; Jump to halt if AL == 0
    int 0x10            ; BIOS interrupt 0x10 - Video Services
    jmp .loop           ; Repeat

halt:
    cli                 ; Clear interrupt flag
    hlt                 ; Halt execution

hello:
    db "Hello, this is my first bootloader!", 0

times 510 - ($-$$) db 0 ; Pad the remaining bytes with zeroes
dw 0xaa55               ; Bootable sector marker
```

---

## Steps to Assemble and Run

### 1. **Assemble the Bootloader**
Use `nasm` to assemble the code into a binary file:
```bash
nasm -f bin src/bootloader.asm -o build/bootloader.bin
```

### 2. **Create a Bootable Disk Image**
Wrap the binary in a disk image using `dd`:
```bash
dd if=build/bootloader.bin of=build/bootloader.img bs=512 count=1
```

### 3. **Run the Bootloader in QEMU**
Start QEMU with the disk image:
```bash
qemu-system-x86_64 -fda build/bootloader.img
```

---

## Makefile for Automation
Here’s a simple Makefile to automate everything:

```makefile
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
```

### Usage:
1. Build everything:
   ```bash
   make
   ```
2. Run the bootloader:
   ```bash
   qemu-system-x86_64 -fda build/bootloader.img
   ```
3. Clean up:
   ```bash
   make clean
   ```

---

## Things to Remember
1. **The Bootloader is 16-bit**:
   - It uses `bits 16` and starts execution at `0x7C00`.
2. **BIOS Interrupts**:
   - `int 0x10` is used for text output.
   - `ah = 0x0E` selects the "Write Character in TTY mode" service.
3. **Boot Signature**:
   - The last two bytes (`0xAA55`) mark the sector as bootable.
4. **Disk Image Size**:
   - Use `times 510 - ($-$$) db 0` to pad the binary to exactly 512 bytes.

---

## Lessons Learned
- A bootloader is just the first 512 bytes of a bootable disk.
- Always include the `0xAA55` boot signature at the end of the sector.
- BIOS interrupts are handy but limited to 16-bit code.
- QEMU is perfect for testing bootloaders without real hardware.

---

## Next Steps
- Learn to load and execute a second stage (e.g., a kernel).
- Explore protected mode and 32-bit code.
- Maybe try printing something fancier on the screen (colors, anyone?).

---

## Final Thoughts
This is just the beginning, but it's so cool to see the message pop up in QEMU. Writing a bootloader makes me feel like I'm really talking to the hardware. Onward to bigger and better things!

