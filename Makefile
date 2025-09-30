build-shell:
	nasm -f elf64 -o shell.o ./src/shellcodes/shell.asm
	ld -o shellcode shell.o

build-reverse:
	nasm -f elf64 -o reverse.o ./src/shellcodes/reverse.asm
	ld -o shellcode reverse.o

extract-shell:
	nasm -f bin -o shell.bin ./src/shellcodes/shell.asm
	xxd -i shell.bin > shell.c
	cat shell.c
	rm shell.bin

extract-reverse:
	nasm -f bin -o reverse.bin ./src/shellcodes/reverse.asm
	xxd -i reverse.bin > reverse.c
	cat reverse.c
	rm reverse.bin

test:
	rm -f test
	@echo "\nDon't forget: if you want to test another shellcode, extract it and modify the tester.c"
	gcc -g -o test src/tester.c -z execstack -fno-stack-protector

clean:
	rm -f shellcode*
	rm -f test