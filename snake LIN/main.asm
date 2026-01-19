; SNAKE COMPETITIVO - André Guimarães e Klarine Mendonça

org 0x100           ; Origem para arquivo .COM (Code/Data/Stack no mesmo segmento)
    push cs
    pop ds          ; Define DS = CS (importante para acessar variáveis)

%include "consts.inc"

start:
    call install_keyboard   ; Instala nosso driver de teclado INT 9h
    call init_video         ; Inicia modo gráfico VGA 13h

main_loop:
    ; Máquina de Estados: verifica 'curr_state' e pula para a função certa
    cmp byte [curr_state], STATE_MENU
    jne .chk_game
    jmp run_menu        ; Se estado 0, roda menu

.chk_game:
    cmp byte [curr_state], STATE_GAME
    jne .chk_pause
    jmp run_game        ; Se estado 1, roda jogo

.chk_pause:
    cmp byte [curr_state], STATE_PAUSE
    jne .chk_over
    jmp run_pause       ; Se estado 2, roda pausa

.chk_over:
    cmp byte [curr_state], STATE_GAMEOVER
    jne .chk_quit
    jmp run_gameover    ; Se estado 3, roda game over

.chk_quit:
    cmp byte [curr_state], STATE_CONFIRM_Q
    jne .loop_end
    jmp run_confirm_quit ; Se estado 4, confirmação de saída

.loop_end:
    jmp main_loop       ; Volta ao início do loop infinito

; MENU PRINCIPAL

run_menu:
    call clear_screen       ; Limpa tela a cada frame do menu
.menu_loop:
    ; Desenha textos do menu
    mov dh, 4
    mov dl, 10
    mov si, msg_title
    call print_string

    mov dh, 8
    mov dl, 5
    mov si, txt_opt1        ; "1. Facil"
    call print_string
    mov dh, 10
    mov dl, 5
    mov si, txt_opt2        ; "2. Medio"
    call print_string
    mov dh, 12
    mov dl, 5
    mov si, txt_opt3        ; "3. Dificil"
    call print_string
    mov dh, 15
    mov dl, 5
    mov si, txt_esc         ; "ESC para sair"
    call print_string

    ; Desenha a seta de seleção
    mov al, [menu_option]   ; Pega opção (1, 2 ou 3)
    dec al                  ; Transforma em 0, 1 ou 2
    shl al, 1               ; Multiplica por 2 (para ajustar espaçamento vertical)
    add al, 8               ; Soma base da linha (linha 8 é a primeira opção)
    mov dh, al              ; Define linha da seta
    mov dl, 16              ; Coluna da seta
    mov si, txt_arrow
    call print_string

    ; Inputs Numéricos Diretos
    cmp byte [key_pressed + KEY_1], 1
    jne .chk2
    mov byte [menu_option], 1
    mov word [difficulty], DIFF_EASY    ; Define dificuldade Fácil
.chk2:
    cmp byte [key_pressed + KEY_2], 1
    jne .chk3
    mov byte [menu_option], 2
    mov word [difficulty], DIFF_MEDIUM  ; Define dificuldade Média
.chk3:
    cmp byte [key_pressed + KEY_3], 1
    jne .chkesc
    mov byte [menu_option], 3
    mov word [difficulty], DIFF_HARD    ; Define dificuldade Difícil

.chkesc:
    ; Checa ESC ou Q para sair
    cmp byte [key_pressed + KEY_ESC], 1
    je .goto_quit
    cmp byte [key_pressed + KEY_Q], 1
    je .goto_quit
    jmp .chkenter

.goto_quit:
    mov byte [curr_state], STATE_CONFIRM_Q ; Muda estado para confirmar saída
    call wait_debounce                     ; Espera soltar a tecla
    jmp main_loop

.chkenter:
    cmp byte [key_pressed + KEY_ENTER], 1
    jne .chkup
    call reset_game         ; Reseta variáveis para jogo novo
    mov byte [curr_state], STATE_GAME ; Começa o jogo
    call wait_debounce
    jmp main_loop

.chkup:
    ; Navegação com Setas (Cima/Baixo)
    cmp byte [key_pressed + KEY_UP], 1
    jne .chkdown
    mov al, [menu_option]
    dec al                  ; Sobe opção
    cmp al, 1
    jge .saveopt            ; Se >= 1, ok
    mov al, 3               ; Se menor que 1, vai para 3 (loop)
    jmp .saveopt
.chkdown:
    cmp byte [key_pressed + KEY_DOWN], 1
    jne .waitframe
    mov al, [menu_option]
    inc al                  ; Desce opção
    cmp al, 3
    jle .saveopt            ; Se <= 3, ok
    mov al, 1               ; Se maior que 3, vai para 1 (loop)
.saveopt:
    mov [menu_option], al
    ; Atualiza dificuldade baseada na navegação das setas
    cmp al, 1
    jne .s2
    mov word [difficulty], DIFF_EASY
    jmp .db_nav
.s2:
    cmp al, 2
    jne .s3
    mov word [difficulty], DIFF_MEDIUM
    jmp .db_nav
.s3:
    mov word [difficulty], DIFF_HARD
.db_nav:
    call wait_debounce      ; Delay para não rodar o menu rápido demais
    jmp .redraw
.redraw:
    call clear_screen       ; Limpa para redesenhar a seta na nova posição
.waitframe:
    call delay_frame        ; Sincroniza
    jmp .menu_loop

 
; LOOP DO JOGO
run_game:
    ; Verifica Pause
    cmp byte [key_pressed + KEY_P], 1
    jne .chk_q
    mov byte [curr_state], STATE_PAUSE
    call wait_debounce
    jmp .draw_game
.chk_q:
    ; Verifica Quit
    cmp byte [key_pressed + KEY_Q], 1
    jne .game_logic
    mov byte [curr_state], STATE_CONFIRM_Q
    call wait_debounce
    jmp .draw_game

.game_logic:
    call process_input      ; Lê teclado e atualiza direções
    call update_game        ; Move cobras e checa colisões

.draw_game:
    call clear_screen       ; Limpa tela (buffer frame)
    
    call draw_scoreboard    ; Desenha placar de vidas
   
    ; Desenhar Maçã P1 (Verde)
    mov ax, [food1_x]
    mov bx, [food1_y]
    mov dl, COLOR_P1
    call draw_block

    ; Desenhar Maçã P2 (Vermelha)
    mov ax, [food2_x]
    mov bx, [food2_y]
    mov dl, COLOR_P2
    call draw_block

    ; Loop para desenhar corpo P1
    mov cx, [p1_len]
    and cx, cx              ; Verifica se é 0
    jz .skip_p1
    mov si, 0
.dp1:
    mov ax, [p1_body_x + si] ; Pega X do segmento
    mov bx, [p1_body_y + si] ; Pega Y do segmento
    mov dl, COLOR_P1
    call draw_block          ; Desenha
    add si, 2                ; Próximo segmento (word)
    loop .dp1
.skip_p1:

    ; Loop para desenhar corpo P2
    mov cx, [p2_len]
    and cx, cx
    jz .skip_p2
    mov si, 0
.dp2:
    mov ax, [p2_body_x + si]
    mov bx, [p2_body_y + si]
    mov dl, COLOR_P2
    call draw_block
    add si, 2
    loop .dp2
.skip_p2:
    
    call delay_game_loop     ; Controla a velocidade do jogo (dificuldade)
    jmp main_loop


; TELA DE PAUSA
run_pause:
    mov dh, 12
    mov dl, 5
    mov si, msg_pause
    call print_string        ; Mostra texto de pausa
    cmp byte [key_pressed + KEY_P], 1
    jne .wp
    mov byte [curr_state], STATE_GAME ; Se apertar P de novo, volta ao jogo
    call wait_debounce
.wp:
    call delay_frame
    jmp main_loop


; TELA DE GAME OVER
run_gameover:
    call clear_screen       
    
    mov dh, 10
    mov dl, 2
    mov si, msg_gameover
    call print_string       

.gameover_wait_loop:        ; Loop local de espera
    call delay_frame        

    ; Checa Y (Sim - Reiniciar)
    cmp byte [key_pressed + KEY_Y], 1
    jne .chk_n
    
    call reset_game
    mov byte [curr_state], STATE_MENU ; Volta pro menu
    call wait_debounce
    jmp main_loop           

.chk_n:
    ; Checa N (Não - Sair)
    cmp byte [key_pressed + KEY_N], 1
    jne .continue_wait
    jmp exit_prog           ; Mata o programa

.continue_wait:
    jmp .gameover_wait_loop 


; TELA CONFIRMAR SAÍDA
run_confirm_quit:
    call clear_screen
    
    mov dh, 10
    mov dl, 10
    mov si, msg_quit
    call print_string

.quit_wait_loop:
    call delay_frame
    cmp byte [key_pressed + KEY_Y], 1
    je exit_prog            ; Se Y, sai
    cmp byte [key_pressed + KEY_N], 1
    je .cancel_quit         ; Se N, cancela
    jmp .quit_wait_loop

.cancel_quit:
    mov byte [curr_state], STATE_GAME ; Volta pro jogo
    call wait_debounce
    jmp main_loop

; DRAW SCOREBOARD (HUD)
draw_scoreboard:
    ; P1 HUD
    mov dh, 0               
    mov dl, 1               
    mov si, txt_hud_p1
    call print_string       
    
    mov al, [p1_lives]      ; Pega vidas
    add al, '0'             ; Soma '0' (0x30) para virar caractere ASCII
    mov ah, 0x0E            ; Imprime char
    mov bl, COLOR_TEXT      
    int 0x10

    ; P2 HUD
    mov dh, 0               
    mov dl, 25              
    mov si, txt_hud_p2
    call print_string       
    
    mov al, [p2_lives]
    add al, '0'
    mov ah, 0x0E
    mov bl, COLOR_TEXT
    int 0x10

    ret

; UTILITÁRIOS E SAÍDA
exit_prog:
    call flush_keyboard_buffer ; Limpa buffer
    call uninstall_keyboard    ; Restaura teclado original 
    call restore_video         ; Restaura modo texto
    
    mov ah, 0x09
    mov dx, txt_bye            ; Mensagem de tchau
    int 0x21
    
    mov ax, 0x4C00             ; Terminate Program 
    int 0x21

delay_frame:
    mov dx, 0x3DA              ; Porta de status VGA
.w1: in al, dx
    test al, 8                 ; Espera fim do VSync
    jnz .w1
.w2: in al, dx
    test al, 8                 ; Espera começo do VSync
    jz .w2
    ret

delay_game_loop:
    mov cx, [difficulty]       ; Carrega quantia de frames para esperar
    cmp cx, 0
    jne .loop
    mov cx, 1
.loop:
    push cx
    call delay_frame           ; Espera 1 frame vertical (aprox 16ms)
    pop cx
    loop .loop                 ; Repete CX vezes
    ret

wait_debounce:
    mov cx, 15                 ; Espera 15 frames (~0.25s) para evitar click duplo
.db: call delay_frame
    loop .db
    ret

; Inclusão dos outros arquivos no binário final
%include "video.asm"
%include "keyboard.asm"
%include "logic.asm"
%include "vars.inc"