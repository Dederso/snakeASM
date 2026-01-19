
; MÓDULO DE VÍDEO

init_video:
    mov ax, 0x0013      ; Função 00h (Set Video Mode), Modo 13h (VGA Gráfico)
    int 0x10            ; Chama BIOS
    ret

restore_video:
    mov ax, 0x0003      ; Modo 03h (Texto 80x25 padrão do DOS)
    int 0x10            ; Restaura para o terminal não ficar bugado
    ret

clear_screen:
    push es             ; Salva ES
    push di
    push ax
    push cx
    
    mov ax, VIDEO_MEM   ; AX = 0xA000
    mov es, ax          ; ES aponta para memória de vídeo
    xor di, di          ; DI = 0 (Começo da tela)
    xor ax, ax          ; Cor 0 (Preto)
    mov cx, 32000       ; 320 * 200 = 64000 bytes. Como usamos STOSW (2 bytes), 32000 repetições
    rep stosw           ; Escreve AX (0000) em ES:DI e incrementa DI, repetindo CX vezes
    
    pop cx
    pop ax
    pop di
    pop es
    ret

; Função para desenhar bloco 5x5
; Entrada: AX = X, BX = Y, DL = Cor
draw_block:
    pusha               ; Salva registradores
    push es
    
    ; Verificação de limites (evita desenhar fora e travar)
    cmp ax, 315         ; X > 315? (320 - 5)
    ja .exit_db         ; Se sim, ignora
    cmp bx, 195         ; Y > 195? (200 - 5)
    ja .exit_db         ; Se sim, ignora

    push dx             ; [IMPORTANTE] Salva DL (Cor), pois MUL altera DX
    
    ; Cálculo do Offset de Memória: Endereço = (Y * 320) + X
    push ax             ; Salva X
    mov ax, 320         ; Largura da tela
    mul bx              ; DX:AX = 320 * Y (Aqui DX é sobrescrito!)
    mov di, ax          ; DI recebe parte baixa do resultado
    pop ax              ; Recupera X
    add di, ax          ; DI = (Y*320) + X
    
    pop dx              ; Recupera a cor original em DL
    
    mov ax, VIDEO_MEM
    mov es, ax          ; Configura segmento de vídeo
    
    mov ch, BLOCK_SIZE  ; Contador de Linhas (Altura do bloco)
.row:
    mov cl, BLOCK_SIZE  ; Contador de Colunas (Largura do bloco)
    mov al, dl          ; Move a cor para AL (comando STOSB ou MOV usam AL)
.pix:
    mov [es:di], al     ; Pinta o pixel na memória
    inc di              ; Próximo pixel à direita
    dec cl              ; Decrementa contador de largura
    jnz .pix            ; Continua na linha se não acabou
    
    ; Fim da linha do bloco
    add di, 320 - BLOCK_SIZE ; Pula para a linha de baixo (320 pixels total - os 5 que já andamos)
    dec ch              ; Decrementa contador de altura
    jnz .row            ; Continua desenhando linhas
    
.exit_db:
    pop es
    popa
    ret

; Função de Texto Simples (Usa BIOS)
; SI = Endereço da string
; DH = Linha, DL = Coluna
print_string:
    pusha
    mov ah, 0x02        ; Função BIOS: Posicionar Cursor
    mov bh, 0x00        ; Página 0
    int 0x10            ; Executa posicionamento
.next:
    lodsb               ; Carrega byte de [SI] para AL e incrementa SI
    or al, al           ; Verifica se é 0 (fim da string)
    jz .done            ; Se zero, termina
    mov ah, 0x0E        ; Função BIOS: Teletype Output (escreve caractere)
    mov bl, 0x0F        ; Cor do texto (Branco)
    int 0x10            ; Imprime
    jmp .next           ; Próximo char
.done:
    popa
    ret