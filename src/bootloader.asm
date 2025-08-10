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
