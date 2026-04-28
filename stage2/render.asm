draw_frame:
    call clear_screen
    call draw_border
    call draw_food
    call draw_snake
    call draw_hud
    call draw_pause_overlay
    ret

clear_screen:
    mov ax, 0x0600
    mov bh, 0x00
    mov cx, 0x0000
    mov dx, 0x184F
    int 0x10
    ret

draw_border:
    mov bl, 0x09

    mov dh, BOARD_Y
    mov dl, BOARD_X
.top:
    mov al, '#'
    call putc_at
    inc dl
    cmp dl, BOARD_X + BOARD_W + 2
    jb .top

    mov dh, BOARD_Y + BOARD_H + 1
    mov dl, BOARD_X
.bot:
    mov al, '#'
    call putc_at
    inc dl
    cmp dl, BOARD_X + BOARD_W + 2
    jb .bot

    mov dh, BOARD_Y + 1
.sides:
    mov dl, BOARD_X
    mov al, '#'
    call putc_at
    mov dl, BOARD_X + BOARD_W + 1
    mov al, '#'
    call putc_at
    inc dh
    cmp dh, BOARD_Y + BOARD_H + 1
    jb .sides
    ret

draw_food:
    xor si, si
    xor cx, cx
    mov cl, [food_count]

.loop:
    cmp cx, 0
    je .done

    mov al, [food_x + si]
    add al, BOARD_X + 1
    mov dl, al
    mov al, [food_y + si]
    add al, BOARD_Y + 1
    mov dh, al
    mov al, '*'
    mov bl, 0x0C
    call putc_at

    inc si
    dec cx
    jmp .loop

.done:
    ret

draw_snake:
    xor si, si
    xor cx, cx
    mov cl, [snake_len]
.loop:
    cmp cx, 0
    je .done

    mov al, [snake_x + si]
    add al, BOARD_X + 1
    mov dl, al
    mov al, [snake_y + si]
    add al, BOARD_Y + 1
    mov dh, al

    mov al, [snek_style_idx]
    cmp al, 0
    je .draw_style_classic

    cmp si, 0
    jne .not_head

    mov al, [dir]
    cmp al, 0
    jne .head_right
    mov al, '^'
    jmp .draw_head

.head_right:
    cmp al, 1
    jne .head_down
    mov al, '>'
    jmp .draw_head

.head_down:
    cmp al, 2
    jne .head_left
    mov al, 'v'
    jmp .draw_head

.head_left:
    mov al, '<'

.draw_head:
    mov bl, 0x0E
    call putc_at
    jmp .next

.not_head:
    cmp cx, 1
    je .tail

    test si, 1
    jz .body_even
    mov al, 'o'
    mov bl, 0x02
    call putc_at
    jmp .next

.body_even:
    mov al, 'O'
    mov bl, 0x0A
    call putc_at
    jmp .next

.tail:
    mov al, '.'
    mov bl, 0x03
    call putc_at

.next:
    inc si
    dec cx
    jmp .loop

.draw_style_classic:
    cmp si, 0
    jne .classic_not_head

    mov al, '@'
    mov bl, 0x0E
    call putc_at
    jmp .next

.classic_not_head:
    cmp cx, 1
    je .classic_tail

    mov al, 'o'
    mov bl, 0x0A
    call putc_at
    jmp .next

.classic_tail:
    mov al, 'o'
    mov bl, 0x02
    call putc_at
    jmp .next

.done:
    ret

draw_hud:
    mov dh, 0
    mov dl, 2
    mov bl, 0x0B
    mov si, hud_title_msg
    call print_at

    mov dh, 0
    mov dl, 14
    mov bl, 0x0F
    mov si, hud_score_msg
    call print_at

    mov al, [snake_len]
    sub al, 3
    mov dh, 0
    mov dl, 21
    mov bl, 0x0E
    call print_u8_2

    mov dh, 0
    mov dl, 27
    mov bl, 0x0F
    mov si, hud_len_msg
    call print_at

    mov al, [snake_len]
    mov dh, 0
    mov dl, 32
    mov bl, 0x0A
    call print_u8_2

    mov dh, 0
    mov dl, 38
    mov bl, 0x0F
    mov si, hud_best_msg
    call print_at

    mov al, [best_score]
    mov dh, 0
    mov dl, 44
    mov bl, 0x0E
    call print_u8_2
    ret
