settings_input_handler:
    cmp al, 'w'
    je .settings_up
    cmp al, 'W'
    je .settings_up
    cmp ah, 0x48
    je .settings_up

    cmp al, 's'
    je .settings_down
    cmp al, 'S'
    je .settings_down
    cmp ah, 0x50
    je .settings_down
    
    cmp al, 'a'
    je .settings_left
    cmp al, 'A'
    je .settings_left
    cmp ah, 0x4B
    je .settings_left
    
    cmp al, 'd'
    je .settings_right
    cmp al, 'D'
    je .settings_right
    cmp ah, 0x4D
    je .settings_right

    cmp al, 0x0D
    je .settings_select
    cmp al, ' '
    je .settings_select
    ret

.settings_up:
    cmp byte [menu_idx], 0
    je .handler_return
    dec byte [menu_idx]
    call draw_title_screen
    ret

.settings_down:
    cmp byte [menu_idx], 3
    je .handler_return
    inc byte [menu_idx]
    call draw_title_screen
    ret
    
.settings_left:
    mov al, [menu_idx]
    cmp al, 0
    jne .set_left_food_check
    cmp byte [difficulty_idx], 0
    je .handler_return
    dec byte [difficulty_idx]
    call draw_title_screen
    ret

.set_left_food_check:
    cmp al, 1
    jne .set_left_style_check
    cmp byte [food_spawn_idx], 0
    je .handler_return
    dec byte [food_spawn_idx]
    call draw_title_screen
    ret

.set_left_style_check:
    cmp al, 2
    jne .handler_return
    cmp byte [snek_style_idx], 0
    je .handler_return
    dec byte [snek_style_idx]
    call draw_title_screen
    ret
    
.settings_right:
    mov al, [menu_idx]
    cmp al, 0
    jne .set_right_food_check
    cmp byte [difficulty_idx], 2
    je .handler_return
    inc byte [difficulty_idx]
    call draw_title_screen
    ret

.set_right_food_check:
    cmp al, 1
    jne .set_right_style_check
    cmp byte [food_spawn_idx], 2
    je .handler_return
    inc byte [food_spawn_idx]
    call draw_title_screen
    ret

.set_right_style_check:
    cmp al, 2
    jne .handler_return
    cmp byte [snek_style_idx], 1
    je .handler_return
    inc byte [snek_style_idx]
    call draw_title_screen
    ret

.settings_select:
    mov al, [menu_idx]
    cmp al, 3
    jne .handler_return
    mov byte [menu_state], 0
    mov byte [menu_idx], 0
    call draw_title_screen

.handler_return:
    ret

draw_settings_menu:
    mov al, [menu_idx]

    mov dh, 17
    mov dl, 20
    cmp al, 0
    jne .diff_row_normal
    mov bl, 0x70
    jmp .diff_row_print
.diff_row_normal:
    mov bl, 0x07
.diff_row_print:
    mov si, settings_difficulty_msg
    call print_at

    mov al, [difficulty_idx]
    cmp al, 0
    je .diff_slow_value
    cmp al, 1
    je .diff_normal_value
    mov si, diff_fast_msg
    jmp .diff_value_print
.diff_slow_value:
    mov si, diff_slow_msg
    jmp .diff_value_print
.diff_normal_value:
    mov si, diff_normal_msg
.diff_value_print:
    mov dh, 17
    mov dl, 34
    mov bl, 0x0E
    call print_at

    mov al, [menu_idx]
    mov dh, 19
    mov dl, 20
    cmp al, 1
    jne .food_row_normal
    mov bl, 0x70
    jmp .food_row_print
.food_row_normal:
    mov bl, 0x07
.food_row_print:
    mov si, settings_food_msg
    call print_at

    mov al, [food_spawn_idx]
    cmp al, 0
    je .food_low_value
    cmp al, 1
    je .food_med_value
    mov si, food_high_msg
    jmp .food_value_print
.food_low_value:
    mov si, food_low_msg
    jmp .food_value_print
.food_med_value:
    mov si, food_med_msg
.food_value_print:
    mov dh, 19
    mov dl, 34
    mov bl, 0x0E
    call print_at

    mov al, [menu_idx]
    mov dh, 21
    mov dl, 20
    cmp al, 2
    jne .style_row_normal
    mov bl, 0x70
    jmp .style_row_print
.style_row_normal:
    mov bl, 0x07
.style_row_print:
    mov si, settings_snek_msg
    call print_at

    mov al, [snek_style_idx]
    cmp al, 0
    je .style_one_value
    mov si, snek_style2_msg
    jmp .style_value_print
.style_one_value:
    mov si, snek_style1_msg
.style_value_print:
    mov dh, 21
    mov dl, 34
    mov bl, 0x0E
    call print_at

    mov al, [menu_idx]
    mov dh, 23
    mov dl, 20
    cmp al, 3
    jne .back_row_normal
    mov bl, 0x70
    jmp .back_row_print
.back_row_normal:
    mov bl, 0x07
.back_row_print:
    mov si, settings_back_msg
    call print_at
    ret
