BITS 16
ORG 0x8000

%define BOARD_X      20
%define BOARD_Y      3
%define BOARD_W      40
%define BOARD_H      18
%define MAX_LEN      64
%define TICK_DELAY   4

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

game_restart:
    call init_game

main_loop:
    call wait_tick
    call handle_input
    call step_snake
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

init_game:
    mov ax, 0x0003
    int 0x10

    mov byte [game_over], 0
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
    cmp ax, TICK_DELAY
    jb .wait
    mov [last_tick], dx
    ret

handle_input:
    mov ah, 0x01
    int 0x16
    jz .done

    mov ah, 0x00
    int 0x16

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
    call draw_title
    ret

clear_screen:
    mov ax, 0x0600
    mov bh, 0x07
    mov cx, 0x0000
    mov dx, 0x184F
    int 0x10
    ret

draw_border:
    mov bl, 0x07

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
    mov bl, 0x0A
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

draw_title:
    mov dh, 0
    mov dl, 2
    mov bl, 0x0F
    mov si, title_msg
    call print_at
    ret

draw_game_over:
    mov dh, BOARD_Y + BOARD_H + 3
    mov dl, BOARD_X
    mov bl, 0x0C
    mov si, over_msg
    call print_at
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

putc_at:
    push ax
    push bx
    push cx
    push dx

    mov cl, al
    mov ch, bl

    ; Set cursor to DH=row, DL=col on page 0.
    mov ah, 0x02
    mov bh, 0x00
    int 0x10

    ; Write one character at cursor using teletype output.
    mov al, cl
    mov bl, ch
    mov ah, 0x0E
    mov bh, 0x00
    int 0x10

    pop dx
    pop cx
    pop bx
    pop ax
    ret

title_msg:   db "SNEK - USE WASD/ARROWS", 0
over_msg:    db "GAME OVER - PRESS R TO RESTART", 0

last_tick:   dw 0
game_over:   db 0
dir:         db 1
snake_len:   db 3
food_x:      db 0
food_y:      db 0
ate_food:    db 0
spawn_retry: db 0
new_head_x:  db 0
new_head_y:  db 0

snake_x:     times MAX_LEN + 1 db 0
snake_y:     times MAX_LEN + 1 db 0

times 4096-($-$$) db 0
