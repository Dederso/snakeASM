%ifndef _CONSTS_INC_
%define _CONSTS_INC_

; CONSTANTES DO JOGO

VIDEO_MEM       equ 0xA000  ; Endereço base da memória de vídeo VGA (0xA0000)
SCREEN_W        equ 320     ; Largura da tela em pixels
SCREEN_H        equ 200     ; Altura da tela em pixels
BLOCK_SIZE      equ 5       ; Tamanho de cada bloco da cobra (5x5 pixels)

; Cores (Índices da paleta VGA padrão)
COLOR_BG        equ 0       ; Preto
COLOR_P1        equ 2       ; Verde (Cobra 1)
COLOR_P2        equ 4       ; Vermelho (Cobra 2)
COLOR_TEXT      equ 15      ; Branco
COLOR_BORDER    equ 8       ; Cinza (não usado no código atual, mas definido)
COLOR_SELECT    equ 14      ; Amarelo (para seleção de menu)

; Scan Codes (Teclas retornadas pelo Hardware INT 9h)
KEY_ESC         equ 0x01    ; Tecla ESC
KEY_1           equ 0x02    ; Tecla 1
KEY_2           equ 0x03    ; Tecla 2
KEY_3           equ 0x04    ; Tecla 3
KEY_W           equ 0x11    ; Tecla W (Cima P1)
KEY_A           equ 0x1E    ; Tecla A (Esquerda P1)
KEY_S           equ 0x1F    ; Tecla S (Baixo P1)
KEY_D           equ 0x20    ; Tecla D (Direita P1)
KEY_UP          equ 0x48    ; Seta Cima (P2)
KEY_LEFT        equ 0x4B    ; Seta Esquerda (P2)
KEY_RIGHT       equ 0x4D    ; Seta Direita (P2)
KEY_DOWN        equ 0x50    ; Seta Baixo (P2)
KEY_ENTER       equ 0x1C    ; Enter
KEY_P           equ 0x19    ; P (Pause)
KEY_Q           equ 0x10    ; Q (Quit)
KEY_Y           equ 0x15    ; Y (Yes)
KEY_N           equ 0x31    ; N (No)

; Estados da Máquina de Estados (Controle de fluxo do jogo)
STATE_MENU      equ 0       ; Tela inicial
STATE_GAME      equ 1       ; Jogo rodando
STATE_PAUSE     equ 2       ; Jogo pausado
STATE_GAMEOVER  equ 3       ; Tela de fim de jogo
STATE_CONFIRM_Q equ 4       ; Tela de confirmação de saída

; Dificuldades (Valores usados em loops de delay)
; Quanto maior o número, mais loops o processador faz = jogo mais lento
DIFF_EASY       equ 8       ; Muito delay (lento)
DIFF_MEDIUM     equ 5       ; Médio delay
DIFF_HARD       equ 2       ; Pouco delay (rápido)

%endif