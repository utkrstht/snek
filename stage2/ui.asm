draw_pause_overlay:
    cmp byte [paused], 0
    je .done

    mov dh, 1
    mov dl, 30
    mov bl, 0x1E
    mov si, pause_msg
    call print_at

.done:
    ret

draw_menu_box:
    mov bl, 0x01

    mov dh, 6
    mov dl, 18
.top:
    mov al, '='
    call putc_at
    inc dl
    cmp dl, 62
    jbe .top

    mov dh, 16
    mov dl, 18
.bottom:
    mov al, '='
    call putc_at
    inc dl
    cmp dl, 62
    jbe .bottom

    mov dh, 7
.sides:
    mov dl, 18
    mov al, '|'
    call putc_at
    mov dl, 62
    mov al, '|'
    call putc_at
    inc dh
    cmp dh, 16
    jb .sides

    mov dh, 6
    mov dl, 18
    mov al, '+'
    call putc_at
    mov dl, 62
    mov al, '+'
    call putc_at

    mov dh, 16
    mov dl, 18
    mov al, '+'
    call putc_at
    mov dl, 62
    mov al, '+'
    call putc_at
    ret

draw_game_over:
    mov dh, BOARD_Y + BOARD_H + 3
    mov dl, BOARD_X
    mov bl, 0x4F
    mov si, over_msg
    call print_at
    ret
