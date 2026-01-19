DOSBOX = C:\Program Files (x86)\DOSBox-0.74-3\DOSbox.exe
ASM = main.asm
OUT = snake.com

all: run

build:
	$(DOSBOX) -c "mount c ." \
	          -c "c:" \
	          -c "nasm.exe -f bin $(ASM) -o $(OUT)" \
	          -c "exit"

run: build
	$(DOSBOX) -c "mount c ." \
	          -c "c:" \
	          -c "$(OUT)"

clean:
	rm -f $(OUT)
