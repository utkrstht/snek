init_game:
    mov ax, 0x0003
    int 0x10

    mov byte [game_over], 0
    mov byte [paused], 0
    mov byte [return_to_menu], 0
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

    call draw_frame
    call spawn_all_food
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

    cmp al, 'm'
    je .to_menu
    cmp al, 'M'
    je .to_menu

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
    cmp byte [paused], 0
    je .pause_off
    call sound_pause_on
    jmp .done

.pause_off:
    call sound_pause_off
    jmp .done

.to_menu:
    call confirm_menu_popup
    cmp al, 1
    jne .done
    mov byte [return_to_menu], 1
    mov byte [paused], 0

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
    mov byte [eaten_food_idx], 0xFF
    xor si, si
    mov cx, FOOD_COUNT
.food_check:
    cmp cx, 0
    je .shift
    mov dl, [food_x + si]
    cmp al, dl
    jne .next_food
    mov dl, [food_y + si]
    cmp bl, dl
    jne .next_food
    mov byte [ate_food], 1
    mov ax, si
    mov [eaten_food_idx], al
    jmp .shift

.next_food:
    inc si
    dec cx
    jmp .food_check

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
    call sound_food_eat
    mov al, [eaten_food_idx]
    call spawn_food_at_idx
    jmp .done

.dead:
    mov byte [game_over], 1
    call sound_game_over

.done:
    ret

spawn_all_food:
    xor si, si
    mov cx, FOOD_COUNT

.loop:
    cmp cx, 0
    je .done
    mov ax, si
    call spawn_food_at_idx
    inc si
    dec cx
    jmp .loop

.done:
    ret

spawn_food_at_idx:
    push ax
    push bx
    push cx
    push dx
    push si

    mov [spawn_idx], al
    mov byte [spawn_retry], 255

.retry:
    mov ah, 0x00
    int 0x1A

    mov ax, dx
    xor dx, dx
    mov bx, BOARD_W
    div bx
    mov [spawn_x_tmp], dl

    mov ax, [last_tick]
    ror ax, 5
    add al, [spawn_idx]
    xor al, [snake_len]
    xor dx, dx
    mov bx, BOARD_H
    div bx
    mov [spawn_y_tmp], dl

    xor si, si
    xor cx, cx
    mov cl, [snake_len]
.check_loop:
    cmp cx, 0
    je .check_food
    mov al, [snake_x + si]
    cmp al, [spawn_x_tmp]
    jne .next
    mov al, [snake_y + si]
    cmp al, [spawn_y_tmp]
    je .collide
.next:
    inc si
    dec cx
    jmp .check_loop

.check_food:
    xor bx, bx
    mov cx, FOOD_COUNT

.check_food_loop:
    cmp cx, 0
    je .ok

    mov al, [spawn_idx]
    cmp bl, al
    je .next_food_slot

    mov al, [food_x + bx]
    cmp al, [spawn_x_tmp]
    jne .next_food_slot
    mov al, [food_y + bx]
    cmp al, [spawn_y_tmp]
    je .collide

.next_food_slot:
    inc bx
    dec cx
    jmp .check_food_loop

.collide:
    inc byte [spawn_x_tmp]
    cmp byte [spawn_x_tmp], BOARD_W
    jb .dec_retry
    mov byte [spawn_x_tmp], 0
    inc byte [spawn_y_tmp]
    cmp byte [spawn_y_tmp], BOARD_H
    jb .dec_retry
    mov byte [spawn_y_tmp], 0

.dec_retry:
    dec byte [spawn_retry]
    jnz .retry

.ok:
    xor bx, bx
    mov bl, [spawn_idx]
    mov al, [spawn_x_tmp]
    mov [food_x + bx], al
    mov al, [spawn_y_tmp]
    mov [food_y + bx], al

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
