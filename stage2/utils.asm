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

clear_text_region:
    push ax
    push cx

    mov al, ' '
.loop:
    test cx, cx
    jz .done
    call putc_at
    inc dl
    dec cx
    jmp .loop

.done:
    pop cx
    pop ax
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

sound_food_eat:
    mov bx, 1800
    mov cx, 10
    call sound_play_tone
    ret

sound_pause_on:
    mov bx, 1400
    mov cx, 7
    call sound_play_tone
    ret

sound_pause_off:
    mov bx, 2200
    mov cx, 5
    call sound_play_tone
    ret

sound_game_over:
    mov bx, 1200
    mov cx, 10
    call sound_play_tone
    mov bx, 1600
    mov cx, 10
    call sound_play_tone
    mov bx, 2200
    mov cx, 14
    call sound_play_tone
    ret

sound_play_tone:
    push ax
    push bx
    push cx
    push dx

    mov al, 0xB6
    out 0x43, al
    mov al, bl
    out 0x42, al
    mov al, bh
    out 0x42, al

    in al, 0x61
    mov ah, al
    or al, 0x03
    out 0x61, al

.dur_outer:
    mov dx, 1800
.dur_inner:
    dec dx
    jnz .dur_inner
    loop .dur_outer

    mov al, ah
    and al, 0xFC
    out 0x61, al

    pop dx
    pop cx
    pop bx
    pop ax
    ret
