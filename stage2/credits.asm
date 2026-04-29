credits_input_handler:
    mov byte [menu_state], 0
    mov byte [menu_idx], 0
    call draw_title_screen
    ret

draw_credits_menu:
    mov dh, 7
    mov dl, 15
    mov bl, 0x0B
    mov si, credits_title
    call print_at

    mov dh, 9
    mov dl, 18
    mov bl, 0x0E
    mov si, credits_made
    call print_at

    mov dh, 10
    mov dl, 14
    mov bl, 0x0E
    mov si, credits_for
    call print_at

    mov dh, 12
    mov dl, 17
    mov bl, 0x0A
    mov si, credits_by
    call print_at

    mov dh, 13
    mov dl, 13
    mov bl, 0x0A
    mov si, credits_hackclub
    call print_at

    mov dh, 15
    mov dl, 12
    mov cx, 68
    mov bl, 0x08
    call clear_text_region

    mov dh, 15
    mov dl, 12
    mov bl, 0x0D
    mov si, credits_cats_1
    call print_at

    mov dh, 17
    mov dl, 20
    mov bl, 0x0F
    mov si, credits_github
    call print_at

    mov dh, 19
    mov dl, 12
    mov bl, 0x0D
    mov si, credits_cats_2
    call print_at

    mov dh, 22
    mov dl, 21
    mov bl, 0x08
    mov si, credits_back_hint
    call print_at
    ret