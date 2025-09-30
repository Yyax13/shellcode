build-shell:
	nasm -f elf64 -o shell.o ./src/shellcodes/shell.asm
	ld -o shellcode shell.o

build-reverse:
	nasm -f elf64 -o reverse.o ./src/shellcodes/reverse.asm
	ld -o shellcode reverse.o

extract-shell:
	objcopy -O binary -j .text shell.o shell.bin
	xxd -i shell.bin > shell.c
	cat shell.c
	rm shell.bin shell.o

extract-reverse:
	objcopy -O binary -j .text reverse.o reverse.bin
	xxd -i reverse.bin > reverse.c
	cat reverse.c
	rm reverse.bin reverse.o

test:
	echo -e "\nDon't forget: if you want to test another shellcode, extract it and modify the tester.c\n\n\"
	gcc -o test src/tester.c -z execstack -fno-stack-protector

clean:
	rm -f shellcode*
	rm -f test