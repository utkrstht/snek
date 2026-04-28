title_screen:
    mov ax, 0x0003
    int 0x10

    mov byte [menu_state], 0
    mov byte [menu_idx], 0
    call draw_title_screen

    mov ah, 0x00
    int 0x1A
    mov [title_anim_tick], dx
    mov byte [title_rainbow_phase], 0

    mov ax, dx
    xor dx, dx
    mov bx, 3
    div bx
    mov [title_hint_idx], dl

.wait_key:
    call maybe_animate_title_hint

    mov ah, 0x01
    int 0x16
    jz .wait_key

    mov ah, 0x00
    int 0x16
    
    mov bl, [menu_state]
    cmp bl, 0
    je .main_menu_input
    cmp bl, 1
    je .handle_settings
    cmp bl, 2
    je .handle_credits
    jmp .wait_key

.handle_settings:
    call settings_input_handler
    jmp .wait_key

.handle_credits:
    call credits_input_handler
    jmp .wait_key

.main_menu_input:
    cmp al, 'w'
    je .menu_up
    cmp al, 'W'
    je .menu_up
    cmp ah, 0x48
    je .menu_up

    cmp al, 's'
    je .menu_down
    cmp al, 'S'
    je .menu_down
    cmp ah, 0x50
    je .menu_down

    cmp al, 0x0D
    je .menu_select
    cmp al, ' '
    je .menu_select
    jmp .wait_key

.menu_up:
    cmp byte [menu_idx], 0
    je .wait_key
    dec byte [menu_idx]
    call draw_title_screen
    jmp .wait_key

.menu_down:
    cmp byte [menu_idx], 2
    jge .wait_key
    inc byte [menu_idx]
    call draw_title_screen
    jmp .wait_key

.menu_select:
    mov al, [menu_idx]
    cmp al, 0
    je .start_game
    cmp al, 1
    je .enter_settings
    cmp al, 2
    je .enter_credits
    jmp .wait_key

.start_game:
    call apply_difficulty
    ret

.enter_settings:
    mov byte [menu_state], 1
    mov byte [menu_idx], 0
    call draw_title_screen
    jmp .wait_key

.enter_credits:
    mov byte [menu_state], 2
    mov byte [menu_idx], 0
    call draw_title_screen
    jmp .wait_key

.back_to_main:
    mov byte [menu_state], 0
    mov byte [menu_idx], 0
    call draw_title_screen
    jmp .wait_key

draw_title_screen:
    call clear_screen

    mov bl, [menu_state]
    cmp bl, 2
    je .draw_credits_only

    call draw_menu_box
    call draw_big_title

    mov dh, 14
    mov dl, 21
    mov bl, 0x08
    mov si, title_screen_controls
    call print_at

    call draw_rainbow_hint

    mov bl, [menu_state]
    cmp bl, 0
    je .draw_main_menu
    cmp bl, 1
    je .draw_settings_menu
    ret
    
.draw_credits_only:
    call .draw_credits_menu
    ret

.draw_main_menu:
    mov al, [menu_idx]
    
    mov dh, 18
    mov dl, 20
    cmp al, 0
    jne .play_not_selected
    mov bl, 0x70
    jmp .play_print

.play_not_selected:
    mov bl, 0x07

.play_print:
    mov si, main_menu_play_msg
    call print_at

    mov al, [menu_idx]
    mov dh, 19
    mov dl, 20
    cmp al, 1
    jne .settings_not_selected
    mov bl, 0x70

    jmp .settings_print

.settings_not_selected:
    mov bl, 0x07

.settings_print:
    mov si, main_menu_settings_msg
    call print_at

    mov al, [menu_idx]
    mov dh, 20
    mov dl, 20
    cmp al, 2
    jne .credits_not_selected
    mov bl, 0x70
    jmp .credits_print

.credits_not_selected:
    mov bl, 0x07
    
.credits_print:
    mov si, main_menu_credits_msg
    call print_at
    ret

.draw_settings_menu:
    call draw_settings_menu
    ret

.draw_credits_menu:
    call draw_credits_menu
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



apply_difficulty:
    mov al, [difficulty_idx]
    cmp al, 0
    jne .normal
    mov byte [tick_delay], 6
    jmp .apply_food

.normal:
    cmp al, 1
    jne .fast
    mov byte [tick_delay], 4
    jmp .apply_food

.fast:
    mov byte [tick_delay], 2
    
.apply_food:
    mov al, [food_spawn_idx]
    cmp al, 0
    jne .food_normal
    mov byte [food_count], 1
    ret

.food_normal:
    cmp al, 1
    jne .food_high
    mov byte [food_count], 3
    ret

.food_high:
    mov byte [food_count], 5
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

    mov al, [title_hint_idx]
    cmp al, 1
    je .hint2
    cmp al, 2
    je .hint3
    cmp al, 3
    je .hint4
    mov si, title_hint_msg
    jmp .hint_chosen

.hint2:
    mov si, title_hint_msg2
    jmp .hint_chosen

.hint3:
    mov si, title_hint_msg3

.hint4:
    mov si, title_hint_msg4

.hint_chosen:
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
