

; LÓGICA DO JOGO

reset_game:
    ; Reseta vidas
    mov byte [p1_lives], 3
    mov byte [p2_lives], 3
    
    ; Define direções iniciais (P1=Dir, P2=Esq) e buffers
    mov byte [p1_dir], 3
    mov byte [p1_next_dir], 3
    mov byte [p2_dir], 2
    mov byte [p2_next_dir], 2
    
    ; Reseta tamanho
    mov word [p1_len], 5
    mov word [p2_len], 5
    
    ; Inicializa corpo do P1 (Loop para criar 5 segmentos alinhados)
    mov cx, 5
    xor si, si          ; Índice do array
    xor di, di          ; Índice de memória (byte offset)
.lp1:
    mov ax, si          ; AX = 0, 1, 2...
    mov bx, 5           ; Tamanho do bloco
    mul bx              ; AX = 0, 5, 10...
    mov bx, 50
    sub bx, ax          ; X = 50, 45, 40... (Cresce para esquerda visualmente na init)
    mov ax, bx
    mov bx, 50          ; Y fixo em 50
    mov [p1_body_x + di], ax
    mov [p1_body_y + di], bx
    inc si
    add di, 2           ; Word = 2 bytes
    loop .lp1

    ; Inicializa corpo do P2 (Lógica similar, posição diferente)
    mov cx, 5
    xor si, si
    xor di, di
.lp2:
    mov ax, si
    mov bx, 5
    mul bx
    add ax, 250         ; X começa em 250 e aumenta
    mov bx, 150         ; Y fixo em 150
    mov [p2_body_x + di], ax
    mov [p2_body_y + di], bx
    inc si
    add di, 2
    loop .lp2
    
    ; Gera primeiras comidas
    call spawn_food1
    call spawn_food2
    ret

; Geração Pseudo-Aleatória de Comida 1
spawn_food1:
    mov ax, [p1_body_x] 
    add ax, [p2_body_y] ; Soma posições de jogadores para criar entropia
    add ax, [food2_x]   ; Soma posição da outra comida
    add ax, 13          ; Adiciona número primo
    and ax, 0xFF        ; Mantém no range 0-255
    add ax, 20          ; Garante margem da borda
    
    ; Alinha à grid de 5 (Multiplo de 5)
    xor dx, dx
    mov bx, 5
    div bx              ; Divide por 5
    mul bx              ; Multiplica por 5 (remove resto)
    mov [food1_x], ax   ; Salva X
    
    ; Mesma lógica para Y
    mov ax, [p1_body_y]
    add ax, [p2_body_x]
    add ax, [food2_y]
    add ax, 7
    and ax, 0x7F        ; Range menor para Y (altura é menor)
    add ax, 20
    
    xor dx, dx
    mov bx, 5
    div bx
    mul bx
    mov [food1_y], ax
    ret

; (spawn_food2 segue a mesma lógica acima, mudando apenas as constantes)
spawn_food2:
    mov ax, [p2_body_x] 
    add ax, [p1_body_y]
    add ax, [food1_x]
    add ax, 29
    and ax, 0xFF        
    add ax, 20
    xor dx, dx
    mov bx, 5
    div bx
    mul bx
    mov [food2_x], ax
    mov ax, [p2_body_y]
    add ax, [p1_body_x]
    add ax, [food1_y]
    add ax, 11
    and ax, 0x7F
    add ax, 20
    xor dx, dx
    mov bx, 5
    div bx
    mul bx
    mov [food2_y], ax
    ret

; Processa teclas e define direções
process_input:
    ; INPUT P1 (WASD)
    cmp byte [key_pressed + KEY_W], 1 ; W apertado?
    jne .is
    cmp byte [p1_dir], 1              ; Está indo para baixo?
    je .is                            ; Se sim, ignora (não pode 180º)
    mov byte [p1_next_dir], 0         ; Define próxima como CIMA
.is:cmp byte [key_pressed + KEY_S], 1
    jne .ia
    cmp byte [p1_dir], 0              ; Está indo para cima?
    je .ia
    mov byte [p1_next_dir], 1         ; Define BAIXO
.ia:cmp byte [key_pressed + KEY_A], 1
    jne .id
    cmp byte [p1_dir], 3              ; Está indo para direita?
    je .id
    mov byte [p1_next_dir], 2         ; Define ESQUERDA
.id:cmp byte [key_pressed + KEY_D], 1
    jne .ip2
    cmp byte [p1_dir], 2              ; Está indo para esquerda?
    je .ip2
    mov byte [p1_next_dir], 3         ; Define DIREITA

.ip2:
    ; INPUT P2 (Setas) - Mesma lógica de bloqueio de 180º
    cmp byte [key_pressed + KEY_UP], 1
    jne .ido
    cmp byte [p2_dir], 1
    je .ido
    mov byte [p2_next_dir], 0
.ido:cmp byte [key_pressed + KEY_DOWN], 1
    jne .idl
    cmp byte [p2_dir], 0
    je .idl
    mov byte [p2_next_dir], 1
.idl:cmp byte [key_pressed + KEY_LEFT], 1
    jne .idr
    cmp byte [p2_dir], 3
    je .idr
    mov byte [p2_next_dir], 2
.idr:cmp byte [key_pressed + KEY_RIGHT], 1
    jne .ifin
    cmp byte [p2_dir], 2
    je .ifin
    mov byte [p2_next_dir], 3
.ifin:
    ; Atualiza a direção real com a direção do buffer
    mov al, [p1_next_dir]
    mov [p1_dir], al
    mov al, [p2_next_dir]
    mov [p2_dir], al
    ret

update_game:
    ; MOVER CORPO P1 (De trás para frente)
    mov cx, [p1_len]    ; Tamanho da cobra
    dec cx              ; Ignora a cabeça no loop
    shl cx, 1           ; Multiplica por 2 (word access)
    mov si, cx          ; SI aponta para o último segmento
.loop_p1_move:
    cmp si, 0           ; Chegou na cabeça?
    je .p1_head
    ; Copia a posição do segmento anterior (si-2) para o atual (si)
    mov ax, [p1_body_x + si - 2]
    mov [p1_body_x + si], ax
    mov ax, [p1_body_y + si - 2]
    mov [p1_body_y + si], ax
    sub si, 2           ; Move para o próximo segmento
    jmp .loop_p1_move

.p1_head:
    ; Move a cabeça baseado na direção
    mov ax, [p1_body_x]
    mov bx, [p1_body_y]
    cmp byte [p1_dir], 0
    je .p1_up
    cmp byte [p1_dir], 1
    je .p1_down
    cmp byte [p1_dir], 2
    je .p1_left
    cmp byte [p1_dir], 3
    je .p1_right
.p1_up:    sub bx, BLOCK_SIZE ; Y diminui
           jmp .p1_warp
.p1_down:  add bx, BLOCK_SIZE ; Y aumenta
           jmp .p1_warp
.p1_left:  sub ax, BLOCK_SIZE ; X diminui
           jmp .p1_warp
.p1_right: add ax, BLOCK_SIZE ; X aumenta

    ; Lógica de Teletransporte (Wrap-around)
.p1_warp:
    cmp ax, 0
    jge .check_w_p1     ; Se X >= 0, checa limite direito
    mov ax, 315         ; Se negativo, vai para o fim da tela
    jmp .save_p1
.check_w_p1:
    cmp ax, 320
    jl .check_h_p1      ; Se X < 320, tá dentro, checa Y
    mov ax, 0           ; Se passou da borda direita, vai para 0
    jmp .save_p1
.check_h_p1:
    cmp bx, 0
    jge .check_h2_p1    ; Se Y >= 0, checa limite baixo
    mov bx, 195         ; Se negativo, vai para baixo
    jmp .save_p1
.check_h2_p1:
    cmp bx, 200
    jl .save_p1         ; Se Y < 200, ok
    mov bx, 0           ; Se passou, vai para cima
.save_p1:
    mov [p1_body_x], ax ; Salva nova posição da cabeça
    mov [p1_body_y], bx

    ; MOVER CORPO P2
    ; (Exatamente a mesma lógica do P1, aplicada às variáveis do P2)
    mov cx, [p2_len]
    dec cx
    shl cx, 1
    mov si, cx
.loop_p2_move:
    cmp si, 0
    je .p2_head
    mov ax, [p2_body_x + si - 2]
    mov [p2_body_x + si], ax
    mov ax, [p2_body_y + si - 2]
    mov [p2_body_y + si], ax
    sub si, 2
    jmp .loop_p2_move

.p2_head:
    mov ax, [p2_body_x]
    mov bx, [p2_body_y]
    cmp byte [p2_dir], 0
    je .p2_up
    cmp byte [p2_dir], 1
    je .p2_down
    cmp byte [p2_dir], 2
    je .p2_left
    cmp byte [p2_dir], 3
    je .p2_right
.p2_up:    sub bx, BLOCK_SIZE
           jmp .p2_warp
.p2_down:  add bx, BLOCK_SIZE
           jmp .p2_warp
.p2_left:  sub ax, BLOCK_SIZE
           jmp .p2_warp
.p2_right: add ax, BLOCK_SIZE
.p2_warp:
    cmp ax, 0
    jge .check_w_p2
    mov ax, 315
    jmp .save_p2
.check_w_p2:
    cmp ax, 320
    jl .check_h_p2
    mov ax, 0
    jmp .save_p2
.check_h_p2:
    cmp bx, 0
    jge .check_h2_p2
    mov bx, 195
    jmp .save_p2
.check_h2_p2:
    cmp bx, 200
    jl .save_p2
    mov bx, 0
.save_p2:
    mov [p2_body_x], ax
    mov [p2_body_y], bx

    ; COLISÕES COM COMIDA (P1)
    ; Verifica se P1 bateu na Comida 1 (Correta)
    mov ax, [p1_body_x]
    cmp ax, [food1_x]
    jne .p1_try_food2       ; Se X não bate, tenta a outra
    mov ax, [p1_body_y]
    cmp ax, [food1_y]
    jne .p1_try_food2       ; Se Y não bate, tenta a outra
    
    ; Comeu a certa
    inc word [p1_len]       ; Cresce
    call spawn_food1        ; Gera nova comida 1
    jmp .check_food_p2      ; Pula verificação da comida errada

.p1_try_food2:
    ; Verifica se P1 bateu na Comida 2 (Errada)
    mov ax, [p1_body_x]
    cmp ax, [food2_x]
    jne .check_food_p2
    mov ax, [p1_body_y]
    cmp ax, [food2_y]
    jne .check_food_p2

    ; Comeu a errada
    cmp word [p1_len], 1    ; Tem mais de 1 pedaço?
    jg .p1_punish
    jmp .kill_p1            ; Se só tem cabeça, morre
.p1_punish:
    dec word [p1_len]       ; Diminui P1
    inc word [p2_len]       ; Aumenta P2
    call spawn_food2        ; Respawna a comida comida
    
    ; COLISÕES COM COMIDA (P2)    
.check_food_p2:
    ; Lógica espelhada para o P2
    mov ax, [p2_body_x]
    cmp ax, [food2_x]
    jne .p2_try_food1
    mov ax, [p2_body_y]
    cmp ax, [food2_y]
    jne .p2_try_food1
    inc word [p2_len]
    call spawn_food2
    jmp .check_self_collision

.p2_try_food1:
    mov ax, [p2_body_x]
    cmp ax, [food1_x]
    jne .check_self_collision
    mov ax, [p2_body_y]
    cmp ax, [food1_y]
    jne .check_self_collision
    cmp word [p2_len], 1
    jg .p2_punish
    jmp .kill_p2
.p2_punish:
    dec word [p2_len]
    inc word [p1_len]
    call spawn_food1

    ; AUTO COLISÃO (Cobreça bate no corpo)
.check_self_collision:
    ; P1
    mov cx, [p1_len]
    sub cx, 1           ; Não checa colisão com a própria cabeça
    cmp cx, 0
    jle .check_self_p2  ; Se tamanho <= 1, não tem como bater
    
    mov ax, [p1_body_x] ; X Cabeça
    mov bx, [p1_body_y] ; Y Cabeça
    mov si, 2           ; Começa do primeiro segmento do corpo
.loop_col_p1:
    cmp ax, [p1_body_x + si] ; Cabeça X == Corpo X?
    jne .next_col_p1
    cmp bx, [p1_body_y + si] ; Cabeça Y == Corpo Y?
    je .kill_p1_jump         ; Se ambos iguais, colisão -> Morre
.next_col_p1:
    add si, 2
    loop .loop_col_p1
    jmp .check_self_p2
.kill_p1_jump:
    jmp .kill_p1

.check_self_p2:
    ; P2 (Mesma lógica)
    mov cx, [p2_len]
    sub cx, 1
    cmp cx, 0
    jg .do_p2_self
    jmp .done_update
.do_p2_self:
    mov ax, [p2_body_x]
    mov bx, [p2_body_y]
    mov si, 2
.loop_col_p2:
    cmp ax, [p2_body_x + si]
    jne .next_col_p2
    cmp bx, [p2_body_y + si]
    je .kill_p2_jump
.next_col_p2:
    add si, 2
    loop .loop_col_p2
    jmp .done_update
.kill_p2_jump:
    jmp .kill_p2

    ; ROTINAS DE MORTE
.kill_p1:
    cmp byte [p1_lives], 0  
    je .skip_dec_p1         ; Segurança contra underflow (0-1)
    dec byte [p1_lives]     ; Perde vida
.skip_dec_p1:
    call reset_positions    ; Volta para posições iniciais
    call spawn_food1        ; Reseta comidas para não nascer em cima
    call spawn_food2
    jmp .check_game_over

.kill_p2:
    cmp byte [p2_lives], 0
    je .skip_dec_p2
    dec byte [p2_lives]
.skip_dec_p2:
    call reset_positions
    call spawn_food1
    call spawn_food2
    jmp .check_game_over

.check_game_over:
    mov al, [p1_lives]      ; Carrega vidas P1
    or al, [p2_lives]       ; Faz OR com vidas P2
    jnz .done_update        ; Se o resultado não for zero, alguém ainda tem vida
    mov byte [curr_state], STATE_GAMEOVER ; Se zero, ambos morreram -> Fim

.done_update:
    ret

reset_positions:
    ; Apenas reseta posições e tamanhos, mantendo as vidas
    mov byte [p1_dir], 3
    mov byte [p1_next_dir], 3
    mov byte [p2_dir], 2
    mov byte [p2_next_dir], 2
    mov word [p1_len], 5
    mov word [p2_len], 5
    mov word [p1_body_x], 50
    mov word [p1_body_y], 50
    mov word [p2_body_x], 250
    mov word [p2_body_y], 150
    ret