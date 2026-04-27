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

confirm_menu_popup:
    call draw_frame

    mov bl, 0x01

    mov dh, 10
    mov dl, 24
.top:
    mov al, '='
    call putc_at
    inc dl
    cmp dl, 56
    jbe .top

    mov dh, 15
    mov dl, 24
.bottom:
    mov al, '='
    call putc_at
    inc dl
    cmp dl, 56
    jbe .bottom

    mov dh, 11
.sides:
    mov dl, 24
    mov al, '|'
    call putc_at
    mov dl, 56
    mov al, '|'
    call putc_at
    inc dh
    cmp dh, 15
    jb .sides

    mov dh, 10
    mov dl, 24
    mov al, '+'
    call putc_at
    mov dl, 56
    mov al, '+'
    call putc_at

    mov dh, 15
    mov dl, 24
    mov al, '+'
    call putc_at
    mov dl, 56
    mov al, '+'
    call putc_at

    mov dh, 11
    mov dl, 32
    mov bl, 0x04
    mov si, menu_confirm_title_msg
    call print_at

    mov byte [menu_confirm_choice], 0
    call .draw_choices

.wait_key:
    mov ah, 0x00
    int 0x16
    cmp al, 'y'
    je .yes
    cmp al, 'Y'
    je .yes
    cmp al, 'n'
    je .no
    cmp al, 'N'
    je .no
    cmp al, 0x0D
    je .enter
    cmp ah, 0x4B
    je .toggle_choice
    cmp ah, 0x4D
    je .toggle_choice
    cmp ah, 0x48
    je .toggle_choice
    cmp ah, 0x50
    je .toggle_choice
    cmp al, 0x1B
    je .no
    jmp .wait_key

.toggle_choice:
    xor byte [menu_confirm_choice], 1
    call .draw_choices
    jmp .wait_key

.enter:
    cmp byte [menu_confirm_choice], 1
    je .yes
    jmp .no

.draw_choices:
    mov dh, 13
    mov dl, 32
    cmp byte [menu_confirm_choice], 1
    jne .yes_normal
    mov bl, 0x70
    jmp .yes_print

.yes_normal:
    mov bl, 0x07

.yes_print:
    mov si, menu_confirm_yes_msg
    call print_at

    mov dh, 13
    mov dl, 42
    cmp byte [menu_confirm_choice], 0
    jne .no_normal
    mov bl, 0x70
    jmp .no_print

.no_normal:
    mov bl, 0x07

.no_print:
    mov si, menu_confirm_no_msg
    call print_at
    ret

.yes:
    mov al, 1
    ret

.no:
    call draw_frame
    mov al, 0
    ret
