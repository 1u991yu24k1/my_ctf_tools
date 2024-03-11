#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

#define N 1024
#define PROCFS "/proc/self/maps"
// #define LIBCRT "/lib/x86_64-linux-gnu/libc-2.27.so" // Ubuntu 18.04 LTS(x64)
#define LIBCRT "/usr/lib/x86_64-linux-gnu/libc.so.6" // Ubuntu 22.04 LTS(x64)

unsigned long getlibc(void){
    unsigned long libc = 0U;
    char buf[N] = {'\0'};
    char tmp[0x20u] = {'\0'};
    FILE *fp = fopen("/proc/self/maps", "r");
	
    if(!fp){
        fprintf(stderr, "[!] Can't Open %s\n", tmp);
		    exit(EXIT_FAILURE);
	  }
    while(fgets(buf, N, fp) != NULL){
        memset(tmp, '\0', 0x20u);
		    if(strstr(buf, LIBCRT) != NULL){
			      strncpy(tmp, buf, 12); // 48bit addr(userland)
			      libc = strtoul(tmp, NULL, 0x10u);
			      break;
		    }
    }
    fclose(fp);
    return libc;
}

static _sleep(long sec) {
    long timespec[2] = {0};
    timespec[0] = sec;
    __asm__(
        "mov rax, 35\n\t"
        "mov rdi, %0\n\t"
        "syscall"
        :
        : "r"(timespec)
        : "rax", "rdi"
    );
}

int main(int argc, char **argv){
	  printf("[+] libc base 0x%lx\n", getlibc());
	  return 0;
}
