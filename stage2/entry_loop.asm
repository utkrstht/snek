start2:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    sti

    mov ah, 0x0E
    mov al, '2'
    mov bh, 0x00
    mov bl, 0x0F
    int 0x10

    call title_screen

game_restart:
    call init_game

main_loop:
    cmp byte [paused], 0
    jne .paused

    call wait_tick
    call handle_input
    cmp byte [return_to_menu], 0
    jne .menu
    cmp byte [paused], 0
    jne .draw_only
    call step_snake
    call update_eat_animation

.draw_only:
    call draw_frame

    cmp byte [game_over], 0
    je main_loop

    call draw_game_over

.wait_key:
    mov ah, 0x00
    int 0x16
    cmp al, 'r'
    je game_restart
    cmp al, 'R'
    je game_restart
    cmp al, 'm'
    je .menu
    cmp al, 'M'
    je .menu
    jmp .wait_key

.paused:
    call handle_input
    cmp byte [return_to_menu], 0
    jne .menu
    call wait_tick
    call draw_frame

    cmp byte [game_over], 0
    je main_loop
    jmp .wait_key

.menu:
    call title_screen
    jmp game_restart
