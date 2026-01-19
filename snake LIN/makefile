# ===== Configurações =====
DOSBOX = dosbox
DIR := $(CURDIR)

ASM = main.asm
OUT = snake.com
NASM = nasm.exe

# ===== Regra padrão =====
all: build run

# ===== Compilar =====
build:
	$(DOSBOX) -c "mount c $(DIR)" \
	          -c "c:" \
	          -c "$(NASM) -f bin $(ASM) -o $(OUT)" \
	          -c "exit"

# ===== Executar =====
run:
	$(DOSBOX) -c "mount c $(DIR)" \
	          -c "c:" \
	          -c "$(OUT)"

# ===== Limpar =====
clean:
	rm -f $(DIR)/$(OUT)