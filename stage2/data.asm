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
title_hint_msg: db "press P in-game to pause", 0
title_hint_msg2: db "shocked this even works", 0
title_hint_msg3: db "making this was absolute torture", 0
title_hint_msg4: db "press M in-game to return to the menu!", 0
diff_label_msg: db "Select Difficulty", 0
diff_slow_msg: db "1) Slow", 0
diff_normal_msg: db "2) Normal", 0
diff_fast_msg: db "3) Fast", 0
pause_msg: db "[ PAUSED ]", 0
over_msg:    db "GAME OVER - PRESS R TO RESTART OR M FOR MENU", 0
menu_confirm_title_msg: db "RETURN TO MENU?", 0
menu_confirm_hint_msg: db "Arrows/Enter or Y/N", 0
menu_confirm_yes_msg: db "[ YES ]", 0
menu_confirm_no_msg: db "[ NO ]", 0
main_menu_play_msg: db "[ PLAY ]", 0
main_menu_settings_msg: db "[ SETTINGS ]", 0
main_menu_credits_msg: db "[ CREDITS ]", 0
settings_difficulty_msg: db "Difficulty", 0
settings_food_msg: db "Food Spawn", 0
settings_snek_msg: db "Snek Style", 0
settings_back_msg: db "[ BACK ]", 0
food_low_msg: db "[ 1 Food ]", 0
food_med_msg: db "[ 3 Foods ]", 0
food_high_msg: db "[ 5 Foods ]", 0
snek_style1_msg: db "[ @ooooo ]", 0
snek_style2_msg: db "[ <oOoOo ]", 0
credits_title: db ":3 :3 :3  CREDITS  :3 :3 :3", 0
credits_made: db "Made in x86 Assembly", 0
credits_for: db "", 0
credits_by: db "Created by: utkrstht", 0
credits_hackclub: db "Made for Horizons @ HackClub!", 0
credits_cats_1: db "^_^    ^_^    ^_^    ^_^", 0
credits_cats_2: db "^_^    ^_^    ^_^    ^_^", 0
credits_github: db "Source: github.com/utkrstht/snek", 0
credits_back_hint: db "Press any key to return", 0

rainbow_colors: db 0x0C, 0x0E, 0x0A, 0x0B, 0x09, 0x0D, 0x05, 0x0F

last_tick:   dw 0
game_over:   db 0
paused:      db 0
return_to_menu: db 0
menu_confirm_choice: db 0
dir:         db 1
snake_len:   db 3
best_score:  db 0
tick_delay:  db 4
difficulty_idx: db 1
food_count:  db 3
food_x:      times FOOD_COUNT db 0
food_y:      times FOOD_COUNT db 0
ate_food:    db 0
spawn_retry: db 0
spawn_idx:   db 0
spawn_x_tmp: db 0
spawn_y_tmp: db 0
eaten_food_idx: db 0
new_head_x:  db 0
new_head_y:  db 0
title_rainbow_phase: db 0
title_hint_idx: db 0
title_anim_tick: dw 0
menu_state: db 0
menu_idx: db 0
food_spawn_idx: db 1
snek_style_idx: db 0
eat_anim_active: db 0
eat_anim_pos: db 0
eat_anim_counter: db 0

snake_x:     times MAX_LEN + 1 db 0
snake_y:     times MAX_LEN + 1 db 0
