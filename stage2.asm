BITS 16
ORG 0x8000

start2:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    sti

    mov si, msg
    call print_string

hang:
    jmp hang

print_string:
.next:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    mov bh, 0x00
    mov bl, 0x0A
    int 0x10
    jmp .next
.done:
    ret

msg: db "omg. it actualy working", 0

times 2048-($-$$) db 0
