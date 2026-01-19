
; MÓDULO DE TECLADO (INT 9h) - Substitui o driver padrão do DOS

install_keyboard:
    cli                     ; Desliga interrupções para não travar no meio da troca
    xor ax, ax              ; Zera AX
    mov es, ax              ; Define ES = 0 (Acesso à Tabela de Vetores de Interrupção - IVT)
    
    ; 1. Salvar vetor antigo (Backup)
    mov ax, [es:0x09*4]     ; Lê o Offset antigo da INT 9 (Endereço 0000:0024)
    mov [old_int9_off], ax  ; Salva na variável
    mov ax, [es:0x09*4+2]   ; Lê o Segmento antigo
    mov [old_int9_seg], ax  ; Salva na variável
    
    ; 2. Instalar novo vetor (Nossa função)
    mov word [es:0x09*4], keyboard_handler ; Aponta o Offset para nossa função
    mov word [es:0x09*4+2], cs             ; Aponta o Segmento para o nosso código (CS)
    
    ; 3. Limpar lixo do buffer antes de ligar
    call flush_keyboard_buffer
    
    sti                     ; Liga interrupções novamente
    ret

uninstall_keyboard:
    cli                     ; Desliga interrupções (segurança)
    xor ax, ax
    mov es, ax              ; ES = 0 novamente
    
    ; Verificação: Se nunca salvamos (seg=0), não tente restaurar (evita crash)
    mov ax, [old_int9_seg]
    cmp ax, 0
    je .skip_restore
    
    ; Restaura os valores originais da BIOS/DOS
    mov ax, [old_int9_off]
    mov [es:0x09*4], ax
    mov ax, [old_int9_seg]
    mov [es:0x09*4+2], ax
    
    ; Resetar Flags da BIOS (no endereço 0040:0017)
    ; Isso evita que o DOS ache que Alt ou Ctrl continuam apertados ao sair
    mov ax, 0x0040
    mov es, ax
    mov byte [es:0x0017], 0x00 

.skip_restore:
    sti                     ; Reativa interrupções
    call flush_keyboard_buffer ; Limpeza final
    ret

flush_keyboard_buffer:
    push ax                 ; Salva registradores usados
    push cx
    mov cx, 30              ; Tenta limpar até 30 vezes (segurança)
.flush_loop:
    in al, 0x64             ; Lê porta de status do teclado
    test al, 1              ; Bit 0 = 1? (Existe dado esperando?)
    jz .done                ; Se 0, buffer vazio, acabou
    in al, 0x60             ; Se tem dado, lê a porta de dados (0x60) para consumir
    loop .flush_loop        ; Repete
.done:
    pop cx
    pop ax
    ret

keyboard_handler:
    pusha                   ; Salva TODOS os registradores gerais
    push ds
    push cs
    pop ds                  ; Garante que DS aponte para nosso segmento de dados (CS=DS em .COM)
    
    in al, 0x60             ; Lê o Scan Code direto da porta 0x60
    push ax                 ; Salva o código lido
    
    ; Avisar ao controlador de interrupção (PIC) que recebemos o dado
    mov al, 0x20
    out 0x20, al            ; Envia comando EOI (End of Interrupt) para porta 0x20
    
    pop ax                  ; Recupera o Scan Code
    
    test al, 0x80           ; Testa o bit mais significativo (Bit 7)
    jnz .release            ; Se Bit 7 = 1, é soltura de tecla (Break Code)
    
    ; Pressionou (Make Code)
    xor ah, ah              ; Zera parte alta
    mov si, ax              ; SI = Scan Code
    mov byte [key_pressed + si], 1 ; Marca 1 no vetor na posição da tecla
    jmp .end_k
    
.release:
    ; Soltou
    and al, 0x7F            ; Remove o bit de 'soltura' para pegar o ID da tecla
    xor ah, ah
    mov si, ax
    mov byte [key_pressed + si], 0 ; Marca 0 no vetor (tecla solta)
    
.end_k:
    pop ds                  ; Restaura segmento de dados
    popa                    ; Restaura registradores gerais
    iret                    ; Retorno de interrupção (restaura Flags e IP)