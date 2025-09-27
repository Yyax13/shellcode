build:
	nasm -f elf64 -o shellcode.o main.asm
	ld -o shellcode shellcode.o

extract:
	objcopy -O binary -j .text shellcode.o shellcode.bin
	xxd -i shellcode.bin > shellcode.c
	cat shellcode.c
	rm shellcode.bin shellcode.o

test:
	gcc -o test tester.c -z execstack -fno-stack-protector

clean:
	rm -f shell*
	rm -f test