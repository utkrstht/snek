BITS 16
ORG 0x8000

%define BOARD_X      20
%define BOARD_Y      3
%define BOARD_W      40
%define BOARD_H      18
%define MAX_LEN      64

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
    cmp byte [paused], 0
    jne .draw_only
    call step_snake

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
    jmp .wait_key

.paused:
    call handle_input
    call draw_frame

    cmp byte [game_over], 0
    je main_loop
    jmp .wait_key

init_game:
    mov ax, 0x0003
    int 0x10

    mov byte [game_over], 0
    mov byte [paused], 0
    mov byte [snake_len], 3
    mov byte [dir], 1

    mov byte [snake_x + 0], 20
    mov byte [snake_y + 0], 9
    mov byte [snake_x + 1], 19
    mov byte [snake_y + 1], 9
    mov byte [snake_x + 2], 18
    mov byte [snake_y + 2], 9

    mov ah, 0x00
    int 0x1A
    mov [last_tick], dx

    call spawn_food
    call draw_frame
    ret

wait_tick:
    mov bx, [last_tick]
.wait:
    mov ah, 0x00
    int 0x1A
    mov ax, dx
    sub ax, bx
    xor cx, cx
    mov cl, [tick_delay]
    cmp ax, cx
    jb .wait
    mov [last_tick], dx
    ret

handle_input:
    mov ah, 0x01
    int 0x16
    jz .done

    mov ah, 0x00
    int 0x16

    cmp al, 'p'
    je .toggle_pause
    cmp al, 'P'
    je .toggle_pause

    cmp byte [paused], 0
    jne .done

    cmp al, 'w'
    je .up
    cmp al, 'W'
    je .up
    cmp ah, 0x48
    je .up

    cmp al, 'd'
    je .right
    cmp al, 'D'
    je .right
    cmp ah, 0x4D
    je .right

    cmp al, 's'
    je .down
    cmp al, 'S'
    je .down
    cmp ah, 0x50
    je .down

    cmp al, 'a'
    je .left
    cmp al, 'A'
    je .left
    cmp ah, 0x4B
    je .left
    jmp .done

.up:
    cmp byte [dir], 2
    je .done
    mov byte [dir], 0
    jmp .done

.right:
    cmp byte [dir], 3
    je .done
    mov byte [dir], 1
    jmp .done

.down:
    cmp byte [dir], 0
    je .done
    mov byte [dir], 2
    jmp .done

.left:
    cmp byte [dir], 1
    je .done
    mov byte [dir], 3
    jmp .done

.toggle_pause:
    xor byte [paused], 1

.done:
    ret

step_snake:
    cmp byte [game_over], 0
    jne .done

    mov al, [snake_x]
    mov bl, [snake_y]

    cmp byte [dir], 0
    jne .not_up
    dec bl
    jmp .moved
.not_up:
    cmp byte [dir], 1
    jne .not_right
    inc al
    jmp .moved
.not_right:
    cmp byte [dir], 2
    jne .left
    inc bl
    jmp .moved
.left:
    dec al

.moved:
    mov [new_head_x], al
    mov [new_head_y], bl

    cmp al, BOARD_W
    jae .dead
    cmp bl, BOARD_H
    jae .dead

    xor si, si
    xor cx, cx
    mov cl, [snake_len]
.self_check:
    cmp cx, 0
    je .self_ok
    mov dl, [snake_x + si]
    cmp dl, al
    jne .next_self
    mov dl, [snake_y + si]
    cmp dl, bl
    je .dead
.next_self:
    inc si
    dec cx
    jmp .self_check

.self_ok:
    mov byte [ate_food], 0
    mov dl, [food_x]
    cmp al, dl
    jne .shift
    mov dl, [food_y]
    cmp bl, dl
    jne .shift
    mov byte [ate_food], 1

.shift:
    xor cx, cx
    mov cl, [snake_len]
    cmp byte [ate_food], 0
    jne .do_shift
    dec cx

.do_shift:
    cmp cx, 0
    je .set_head
    mov si, cx
.shift_loop:
    mov dl, [snake_x + si - 1]
    mov [snake_x + si], dl
    mov dl, [snake_y + si - 1]
    mov [snake_y + si], dl
    dec si
    jnz .shift_loop

.set_head:
    mov al, [new_head_x]
    mov bl, [new_head_y]
    mov [snake_x], al
    mov [snake_y], bl

    cmp byte [ate_food], 0
    je .done
    cmp byte [snake_len], MAX_LEN
    jae .respawn
    inc byte [snake_len]

.respawn:
    call update_best_score
    call spawn_food
    jmp .done

.dead:
    mov byte [game_over], 1

.done:
    ret

spawn_food:
    mov byte [spawn_retry], 48

.retry:
    mov ah, 0x00
    int 0x1A

    mov ax, dx
    xor dx, dx
    mov bx, BOARD_W
    div bx
    mov [food_x], dl

    mov ax, cx
    xor dx, dx
    mov bx, BOARD_H
    div bx
    mov [food_y], dl

    xor si, si
    xor cx, cx
    mov cl, [snake_len]
.check_loop:
    cmp cx, 0
    je .ok
    mov al, [snake_x + si]
    cmp al, [food_x]
    jne .next
    mov al, [snake_y + si]
    cmp al, [food_y]
    je .collide
.next:
    inc si
    dec cx
    jmp .check_loop

.collide:
    inc byte [food_x]
    cmp byte [food_x], BOARD_W
    jb .dec_retry
    mov byte [food_x], 0
    inc byte [food_y]
    cmp byte [food_y], BOARD_H
    jb .dec_retry
    mov byte [food_y], 0

.dec_retry:
    dec byte [spawn_retry]
    jnz .retry

.ok:
    ret

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
    mov al, [food_x]
    add al, BOARD_X + 1
    mov dl, al
    mov al, [food_y]
    add al, BOARD_Y + 1
    mov dh, al
    mov al, '*'
    mov bl, 0x0C
    call putc_at
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

    cmp si, 0
    jne .body
    mov al, '@'
    mov bl, 0x0E
    call putc_at
    jmp .next

.body:
    mov al, 'o'
    mov bl, 0x02
    call putc_at

.next:
    inc si
    dec cx
    jmp .loop

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

title_screen:
    mov ax, 0x0003
    int 0x10

    call clear_screen
    call draw_title_screen

.wait_key:
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

hud_title_msg: db "SNEK", 0
hud_score_msg: db "SCORE:", 0
hud_len_msg: db "LEN:", 0
hud_best_msg: db "BEST:", 0
title_big_1: db " ####   ##  ##  ######  ##   ## ", 0
title_big_2: db "##      ### ##  ##      ##  ##  ", 0
title_big_3: db " ####   ## ###  ####    #####   ", 0
title_big_4: db "    ##  ##  ##  ##      ##  ##  ", 0
title_big_5: db " ####   ##  ##  ######  ##   ## ", 0
title_screen_controls: db "Move: WASD/Arrows   Start: Enter/Space", 0
diff_label_msg: db "Select Difficulty", 0
diff_slow_msg: db "1) Slow", 0
diff_normal_msg: db "2) Normal", 0
diff_fast_msg: db "3) Fast", 0
pause_msg: db "[ PAUSED ]", 0
over_msg:    db "GAME OVER - PRESS R TO RESTART", 0

last_tick:   dw 0
game_over:   db 0
paused:      db 0
dir:         db 1
snake_len:   db 3
best_score:  db 0
tick_delay:  db 4
difficulty_idx: db 1
food_x:      db 0
food_y:      db 0
ate_food:    db 0
spawn_retry: db 0
new_head_x:  db 0
new_head_y:  db 0

snake_x:     times MAX_LEN + 1 db 0
snake_y:     times MAX_LEN + 1 db 0

times 4096-($-$$) db 0
