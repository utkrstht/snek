update_best_score:
    mov al, [snake_len]
    sub al, 3
    cmp al, [best_score]
    jbe .done
    mov [best_score], al
.done:
    ret

print_at:
.loop:
    lodsb
    test al, al
    jz .done
    call putc_at
    inc dl
    jmp .loop
.done:
    ret

print_u8_2:
    push ax
    push bx
    push dx

    xor ah, ah
    mov bl, 10
    div bl

    ; tens in ah, ones in al
    mov bh, ah
    add al, '0'
    call putc_at
    inc dl
    mov al, bh
    add al, '0'
    call putc_at

    pop dx
    pop bx
    pop ax
    ret

putc_at:
    push ax
    push bx
    push cx
    push dx

    mov cl, al
    mov ch, bl

    mov ah, 0x02
    mov bh, 0x00
    int 0x10

    ; write character with color attr at cursor
    mov al, cl
    mov bl, ch
    mov ah, 0x09
    mov bh, 0x00
    mov cx, 0x0001
    int 0x10

    pop dx
    pop cx
    pop bx
    pop ax
    ret
