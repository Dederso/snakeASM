
; DADOS DO JOGO - VARIÁVEIS GLOBAIS

align 2                     ; Alinha variáveis em endereços pares

    curr_state      db 0    ; Guarda o estado atual (Menu, Jogo, etc.)
    menu_option     db 1    ; Opção selecionada no menu (1, 2 ou 3)
    game_running    db 0    ; Flag auxiliar
    winner          db 0    ; ID de quem ganhou
    difficulty      dw 6    ; Valor atual do delay (padrão inicial)

    ; DADOS JOGADOR 1
    p1_lives        db 3            ; Vidas restantes
    p1_dir          db 3            ; Direção atual (0=Cima, 1=Baixo, 2=Esq, 3=Dir)
    p1_next_dir     db 3            ; Próxima direção (buffer para evitar bug de 180º)
    p1_len          dw 5            ; Comprimento atual da cobra
    p1_score        dw 0            ; Pontuação
    p1_body_x       times 200 dw 0  ; Array com posições X de cada segmento
    p1_body_y       times 200 dw 0  ; Array com posições Y de cada segmento

    ; DADOS JOGADOR 2
    p2_lives        db 3            ; Vidas restantes
    p2_dir          db 2            ; Direção inicial diferente
    p2_next_dir     db 2            ; Buffer direção
    p2_len          dw 5            ; Comprimento
    p2_score        dw 0            ; Pontuação
    p2_body_x       times 200 dw 0  ; Array X
    p2_body_y       times 200 dw 0  ; Array Y

    ; COMIDAS
    food1_x         dw 0    ; Posição X da maçã do P1
    food1_y         dw 0    ; Posição Y da maçã do P1
    food2_x         dw 0    ; Posição X da maçã do P2
    food2_y         dw 0    ; Posição Y da maçã do P2

    ; SISTEMA
    old_int9_off    dw 0    ; Guarda o offset original da interrupção de teclado
    old_int9_seg    dw 0    ; Guarda o segmento original da interrupção
    key_pressed     times 128 db 0 ; Mapa de teclas (1 = pressionada, 0 = solta)

    ; TEXTOS (Strings terminadas em 0 para o print manual ou $ para DOS)
    msg_title       db 'SNAKE COMPETITIVO', 0
    msg_diff        db 'Escolha a Dificuldade:', 0
    msg_pause       db 'PAUSA - (P) Voltar', 0
    msg_quit        db 'Sair? (Y/N)', 0
    msg_gameover    db 'GAME OVER - (Y) Reset (N) Sair', 0
    
    txt_opt1        db '1. Facil', 0
    txt_opt2        db '2. Medio', 0
    txt_opt3        db '3. Dificil', 0
    txt_arrow       db '<- Selecionado', 0
    txt_esc         db 'ESC para Sair', 0
    txt_bye         db 'Obrigado por jogar!', 13, 10, '$' ; $ para INT 21h/09h

    txt_hud_p1      db 'P1 Vidas: ', 0
    txt_hud_p2      db 'P2 Vidas: ', 0