BITS 16
ORG 0x7C00

%define STAGE2_LOAD_SEG 0x0000
%define STAGE2_LOAD_OFF 0x8000
%define STAGE2_SECTORS  8

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov [boot_drive], dl

    ; BIOS INT 13h AH=02h read sectors
    mov ah, 0x02            ; read sectors
    mov al, STAGE2_SECTORS  ; number of sectors
    mov ch, 0x00            ; cylinder 0
    mov cl, 0x02            ; sector 2 (sector 1 is this boot sector)
    mov dh, 0x00            ; head 0
    mov dl, [boot_drive]    ; drive number from BIOS

    mov bx, STAGE2_LOAD_OFF ; ES:BX destination (ES already 0)
    int 0x13
    jc disk_error

    jmp STAGE2_LOAD_SEG:STAGE2_LOAD_OFF

disk_error:
    mov si, disk_error_msg
    call print_string
    jmp $

print_string:
.next:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    mov bh, 0x00
    mov bl, 0x07
    int 0x10
    jmp .next
.done:
    ret

boot_drive:     db 0
disk_error_msg: db "disk read error, whoopsies haha", 0

times 510-($-$$) db 0
dw 0xAA55
