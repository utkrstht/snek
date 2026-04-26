title_screen:
    mov ax, 0x0003
    int 0x10

    call clear_screen
    call draw_title_screen

    mov ah, 0x00
    int 0x1A
    mov [title_anim_tick], dx
    mov byte [title_rainbow_phase], 0

.wait_key:
    call maybe_animate_title_hint

    mov ah, 0x01
    int 0x16
    jz .wait_key

    mov ah, 0x00
    int 0x16

    cmp al, 'w'
    je .up
    cmp al, 'W'
    je .up
    cmp ah, 0x48
    je .up

    cmp al, 's'
    je .down
    cmp al, 'S'
    je .down
    cmp ah, 0x50
    je .down

    cmp al, '1'
    je .set_slow
    cmp al, '2'
    je .set_normal
    cmp al, '3'
    je .set_fast

    cmp al, 0x0D
    je .start
    cmp al, ' '
    je .start
    jmp .wait_key

.up:
    cmp byte [difficulty_idx], 0
    je .wait_key
    dec byte [difficulty_idx]
    call draw_title_screen
    jmp .wait_key

.down:
    cmp byte [difficulty_idx], 2
    je .wait_key
    inc byte [difficulty_idx]
    call draw_title_screen
    jmp .wait_key

.set_slow:
    mov byte [difficulty_idx], 0
    call draw_title_screen
    jmp .wait_key

.set_normal:
    mov byte [difficulty_idx], 1
    call draw_title_screen
    jmp .wait_key

.set_fast:
    mov byte [difficulty_idx], 2
    call draw_title_screen
    jmp .wait_key

.start:
    call apply_difficulty
    ret

draw_title_screen:
    call clear_screen
    call draw_menu_box

    call draw_big_title

    mov dh, 14
    mov dl, 21
    mov bl, 0x08
    mov si, title_screen_controls
    call print_at

    call draw_rainbow_hint

    mov dh, 18
    mov dl, 23
    mov bl, 0x0F
    mov si, diff_label_msg
    call print_at

    mov dh, 19
    mov dl, 24
    mov bl, 0x07
    mov si, diff_slow_msg
    call print_at

    mov dh, 20
    mov dl, 24
    mov bl, 0x07
    mov si, diff_normal_msg
    call print_at

    mov dh, 21
    mov dl, 24
    mov bl, 0x07
    mov si, diff_fast_msg
    call print_at

    call draw_difficulty_cursor
    ret

draw_big_title:
    mov dh, 8
    mov dl, 21
    mov bl, 0x0E
    mov si, title_big_1
    call print_at

    mov dh, 9
    mov dl, 21
    mov bl, 0x0E
    mov si, title_big_2
    call print_at

    mov dh, 10
    mov dl, 21
    mov bl, 0x0E
    mov si, title_big_3
    call print_at

    mov dh, 11
    mov dl, 21
    mov bl, 0x0E
    mov si, title_big_4
    call print_at

    mov dh, 12
    mov dl, 21
    mov bl, 0x0E
    mov si, title_big_5
    call print_at
    ret

draw_difficulty_cursor:
    mov dh, 19
    mov dl, 22
    mov bl, 0x08
    mov al, ' '
    call putc_at

    mov dh, 20
    mov dl, 22
    mov bl, 0x08
    mov al, ' '
    call putc_at

    mov dh, 21
    mov dl, 22
    mov bl, 0x08
    mov al, ' '
    call putc_at

    mov al, [difficulty_idx]
    cmp al, 0
    jne .check_normal
    mov dh, 19
    jmp .mark

.check_normal:
    cmp al, 1
    jne .mark_fast
    mov dh, 20
    jmp .mark

.mark_fast:
    mov dh, 21

.mark:
    mov dl, 22
    mov bl, 0x0E
    mov al, '>'
    call putc_at
    ret

apply_difficulty:
    mov al, [difficulty_idx]
    cmp al, 0
    jne .normal
    mov byte [tick_delay], 6
    ret

.normal:
    cmp al, 1
    jne .fast
    mov byte [tick_delay], 4
    ret

.fast:
    mov byte [tick_delay], 2
    ret

maybe_animate_title_hint:
    push ax
    push dx

    mov ah, 0x00
    int 0x1A
    mov ax, dx
    sub ax, [title_anim_tick]
    cmp ax, 6
    jb .done

    mov [title_anim_tick], dx
    inc byte [title_rainbow_phase]
    and byte [title_rainbow_phase], 7
    call draw_rainbow_hint

.done:
    pop dx
    pop ax
    ret

draw_rainbow_hint:
    push ax
    push bx
    push cx
    push dx
    push si

    mov dh, 15
    mov dl, 21
    mov si, title_hint_msg

    mov al, [title_rainbow_phase]
    and al, 7
    xor bx, bx
    mov bl, al
    mov bl, [rainbow_colors + bx]

.loop:
    lodsb
    test al, al
    jz .done

    call putc_at
    inc dl
    jmp .loop

.done:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
