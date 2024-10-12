// #define _GNU_SOURCE

#include <stdio.h>
#include <wchar.h>
#include <string.h>
#include <stdbool.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>
#include <sched.h>
#include <signal.h>
#include <errno.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/ptrace.h>
#include <seccomp.h>
#include <asm/prctl.h>
#include <sys/prctl.h>
#if __has_include(<linux/io_uring.h>)
#include <linux/io_uring.h>
#define HAS_IORING
#endif
#include <linux/memfd.h>

#define FORMAT_ERROR(E) \
    "  :\t%4d\t: 0x%016lx : %s\n", -(E), (unsigned long)(-(E)), strerror((E))

#define PRINT_FMT_ERROR(E) \
    printf(#E FORMAT_ERROR(E))

 

int main(int argc, char **argv){
    puts("======== sizeof(X)   =========");
    printf("sizeof(void)               : %lu\n", sizeof(void));
    printf("sizeof(void *)             : %lu\n", sizeof(void *));
    printf("sizeof(char)               : %lu\n", sizeof(char));
    printf("sizeof(unsigned char)      : %lu\n", sizeof(unsigned char));
    printf("sizeof(wchar_t)            : %lu\n", sizeof(wchar_t));
    
    printf("sizeof(short)              : %lu\n", sizeof(short));
    printf("sizeof(unsigned short)     : %lu\n", sizeof(unsigned short));
    printf("sizeof(int)                : %lu\n", sizeof(int));
    printf("sizeof(unsigned int)       : %lu\n", sizeof(unsigned int));
    printf("sizeof(long)               : %lu\n", sizeof(long));
    printf("sizeof(long long)          : %lu\n", sizeof(long long));
    printf("sizeof(unsigned long)      : %lu\n", sizeof(unsigned long));
    printf("sizeof(unsigned long long) : %lu\n", sizeof(unsigned long long));
    printf("sizeof(time_t)             : %lu\n", sizeof(time_t));
    printf("sizeof(bool)               : %lu\n", sizeof(bool));
    
    puts("======== ERROR ENUMS =========");
    /*
        for e in $(seq 1 1 133); do errno $e |grep '^#' | cut -d' ' -f2 | perl -pe 's/(\w+)/PRINT_FMT_ERROR(\1);/';done
    */
    PRINT_FMT_ERROR(EPERM);
    PRINT_FMT_ERROR(ENOENT);
    PRINT_FMT_ERROR(ESRCH);
    PRINT_FMT_ERROR(EINTR);
    PRINT_FMT_ERROR(EIO);
    PRINT_FMT_ERROR(ENXIO);
    PRINT_FMT_ERROR(E2BIG);
    PRINT_FMT_ERROR(ENOEXEC);
    PRINT_FMT_ERROR(EBADF);
    PRINT_FMT_ERROR(ECHILD);
    PRINT_FMT_ERROR(EAGAIN);
    PRINT_FMT_ERROR(ENOMEM);
    PRINT_FMT_ERROR(EACCES);
    PRINT_FMT_ERROR(EFAULT);
    PRINT_FMT_ERROR(ENOTBLK);
    PRINT_FMT_ERROR(EBUSY);
    PRINT_FMT_ERROR(EEXIST);
    PRINT_FMT_ERROR(EXDEV);
    PRINT_FMT_ERROR(ENODEV);
    PRINT_FMT_ERROR(ENOTDIR);
    PRINT_FMT_ERROR(EISDIR);
    PRINT_FMT_ERROR(EINVAL);
    PRINT_FMT_ERROR(ENFILE);
    PRINT_FMT_ERROR(EMFILE);
    PRINT_FMT_ERROR(ENOTTY);
    PRINT_FMT_ERROR(ETXTBSY);
    PRINT_FMT_ERROR(EFBIG);
    PRINT_FMT_ERROR(ENOSPC);
    PRINT_FMT_ERROR(ESPIPE);
    PRINT_FMT_ERROR(EROFS);
    PRINT_FMT_ERROR(EMLINK);
    PRINT_FMT_ERROR(EPIPE);
    PRINT_FMT_ERROR(EDOM);
    PRINT_FMT_ERROR(ERANGE);
    PRINT_FMT_ERROR(EDEADLOCK);
    PRINT_FMT_ERROR(ENAMETOOLONG);
    PRINT_FMT_ERROR(ENOLCK);
    PRINT_FMT_ERROR(ENOSYS);
    PRINT_FMT_ERROR(ENOTEMPTY);
    PRINT_FMT_ERROR(ELOOP);
    PRINT_FMT_ERROR(ENOMSG);
    PRINT_FMT_ERROR(EIDRM);
    PRINT_FMT_ERROR(ECHRNG);
    PRINT_FMT_ERROR(EL2NSYNC);
    PRINT_FMT_ERROR(EL3HLT);
    PRINT_FMT_ERROR(EL3RST);
    PRINT_FMT_ERROR(ELNRNG);
    PRINT_FMT_ERROR(EUNATCH);
    PRINT_FMT_ERROR(ENOCSI);
    PRINT_FMT_ERROR(EL2HLT);
    PRINT_FMT_ERROR(EBADE);
    PRINT_FMT_ERROR(EBADR);
    PRINT_FMT_ERROR(EXFULL);
    PRINT_FMT_ERROR(ENOANO);
    PRINT_FMT_ERROR(EBADRQC);
    PRINT_FMT_ERROR(EBADSLT);
    PRINT_FMT_ERROR(EBFONT);
    PRINT_FMT_ERROR(ENOSTR);
    PRINT_FMT_ERROR(ENODATA);
    PRINT_FMT_ERROR(ETIME);
    PRINT_FMT_ERROR(ENOSR);
    PRINT_FMT_ERROR(ENONET);
    PRINT_FMT_ERROR(ENOPKG);
    PRINT_FMT_ERROR(EREMOTE);
    PRINT_FMT_ERROR(ENOLINK);
    PRINT_FMT_ERROR(EADV);
    PRINT_FMT_ERROR(ESRMNT);
    PRINT_FMT_ERROR(ECOMM);
    PRINT_FMT_ERROR(EPROTO);
    PRINT_FMT_ERROR(EMULTIHOP);
    PRINT_FMT_ERROR(EDOTDOT);
    PRINT_FMT_ERROR(EBADMSG);
    PRINT_FMT_ERROR(EOVERFLOW);
    PRINT_FMT_ERROR(ENOTUNIQ);
    PRINT_FMT_ERROR(EBADFD);
    PRINT_FMT_ERROR(EREMCHG);
    PRINT_FMT_ERROR(ELIBACC);
    PRINT_FMT_ERROR(ELIBBAD);
    PRINT_FMT_ERROR(ELIBSCN);
    PRINT_FMT_ERROR(ELIBMAX);
    PRINT_FMT_ERROR(ELIBEXEC);
    PRINT_FMT_ERROR(EILSEQ);
    PRINT_FMT_ERROR(ERESTART);
    PRINT_FMT_ERROR(ESTRPIPE);
    PRINT_FMT_ERROR(EUSERS);
    PRINT_FMT_ERROR(ENOTSOCK);
    PRINT_FMT_ERROR(EDESTADDRREQ);
    PRINT_FMT_ERROR(EMSGSIZE);
    PRINT_FMT_ERROR(EPROTOTYPE);
    PRINT_FMT_ERROR(ENOPROTOOPT);
    PRINT_FMT_ERROR(EPROTONOSUPPORT);
    PRINT_FMT_ERROR(ESOCKTNOSUPPORT);
    PRINT_FMT_ERROR(ENOTSUP);
    PRINT_FMT_ERROR(EPFNOSUPPORT);
    PRINT_FMT_ERROR(EAFNOSUPPORT);
    PRINT_FMT_ERROR(EADDRINUSE);
    PRINT_FMT_ERROR(EADDRNOTAVAIL);
    PRINT_FMT_ERROR(ENETDOWN);
    PRINT_FMT_ERROR(ENETUNREACH);
    PRINT_FMT_ERROR(ENETRESET);
    PRINT_FMT_ERROR(ECONNABORTED);
    PRINT_FMT_ERROR(ECONNRESET);
    PRINT_FMT_ERROR(ENOBUFS);
    PRINT_FMT_ERROR(EISCONN);
    PRINT_FMT_ERROR(ENOTCONN);
    PRINT_FMT_ERROR(ESHUTDOWN);
    PRINT_FMT_ERROR(ETOOMANYREFS);
    PRINT_FMT_ERROR(ETIMEDOUT);
    PRINT_FMT_ERROR(ECONNREFUSED);
    PRINT_FMT_ERROR(EHOSTDOWN);
    PRINT_FMT_ERROR(EHOSTUNREACH);
    PRINT_FMT_ERROR(EALREADY);
    PRINT_FMT_ERROR(EINPROGRESS);
    PRINT_FMT_ERROR(ESTALE);
    PRINT_FMT_ERROR(EUCLEAN);
    PRINT_FMT_ERROR(ENOTNAM);
    PRINT_FMT_ERROR(ENAVAIL);
    PRINT_FMT_ERROR(EISNAM);
    PRINT_FMT_ERROR(EREMOTEIO);
    PRINT_FMT_ERROR(EDQUOT);
    PRINT_FMT_ERROR(ENOMEDIUM);
    PRINT_FMT_ERROR(EMEDIUMTYPE);
    PRINT_FMT_ERROR(ECANCELED);
    PRINT_FMT_ERROR(ENOKEY);
    PRINT_FMT_ERROR(EKEYEXPIRED);
    PRINT_FMT_ERROR(EKEYREVOKED);
    PRINT_FMT_ERROR(EKEYREJECTED);
    PRINT_FMT_ERROR(EOWNERDEAD);
    PRINT_FMT_ERROR(ENOTRECOVERABLE);
    PRINT_FMT_ERROR(ERFKILL);   

    puts("========= Signal Number ======= ");
    printf("SIGHUP     : %04x\n", SIGHUP);
    printf("SIGINT     : %04x\n", SIGINT);
    printf("SIGQUIT    : %04x\n", SIGQUIT);
    printf("SIGILL     : %04x\n", SIGILL);
    printf("SIGTRAP    : %04x\n", SIGTRAP);
    printf("SIGABRT    : %04x\n", SIGABRT);
    printf("SIGSEGV    : %04x\n", SIGSEGV);
    
    puts("========= OPEN FLAGS ==========");
    printf("O_RDONLY   : 0x%08x\n", O_RDONLY);
    printf("O_WRONLY   : 0x%08x\n", O_WRONLY);
    printf("O_RDWR     : 0x%08x\n", O_RDWR);
    printf("O_CLOEXEC  : 0x%08x\n", O_CLOEXEC);
    printf("O_CREAT    : 0x%08x\n", O_CREAT);
    printf("O_DIRECTORY: 0x%08x\n", O_DIRECTORY);
    printf("O_EXCL     : 0x%08x\n", O_EXCL);
    printf("O_NOCTTY   : 0x%08x\n", O_NOCTTY);
    printf("O_NOFOLLOW : 0x%08x\n", O_NOFOLLOW);
    printf("O_TMPFILE  : 0x%08x\n", O_TMPFILE);
    printf("O_TRUNC    : 0x%08x\n", O_TRUNC);
    printf("O_DIRECT   : 0x%08x\n", O_DIRECT);
    printf("O_DSYNC    : 0x%08x\n", O_DSYNC);
    printf("O_LARGEFILE: 0x%08x\n", O_LARGEFILE);
    printf("O_NOATIME  : 0x%08x\n", O_NOATIME);
    printf("O_PATH     : 0x%08x\n", O_PATH);
    printf("O_NONBLOCK : 0x%08x\n", O_NONBLOCK);
    printf("O_NDELAY   : 0x%08x\n", O_NDELAY);
    printf("O_SYNC     : 0x%08x\n", O_SYNC);
    
    printf("_IONBF     : 0x%08x\n", _IONBF);
    printf("_IOLBF     : 0x%08x\n", _IOLBF);
    printf("_IOFBF     : 0x%08x\n", _IOFBF);
    
    puts("======== OPENAT/LINKAT FLAG ========");
    printf("AT_EMPTY_PATH        : 0x%08x\n", AT_EMPTY_PATH);
    printf("AT_FDCWD             : 0x%08x\n", AT_FDCWD);
    printf("AT_SYMLINK_FOLLOW    : 0x%08x\n", AT_SYMLINK_FOLLOW);
    printf("AT_SYMLINK_NOFOLLOW  : 0x%08x\n", AT_SYMLINK_NOFOLLOW);
    printf("AT_REMOVEDIR         : 0x%08x\n", AT_REMOVEDIR);
    printf("AT_NO_AUTOMOUNT      : 0x%08x\n", AT_NO_AUTOMOUNT);
    printf("AT_EMPTY_PATH        : 0x%08x\n", AT_EMPTY_PATH);
#ifdef AT_STATX_SYNC_TYPE
    printf("AT_STATX_SYNC_TYPE   : 0x%08x\n", AT_STATX_SYNC_TYPE);
#endif /* AT_STATX_SYNC_TYPE */
#ifdef AT_STATX_SYNC_AS_STAT
    printf("AT_STATX_SYNC_AS_STAT: 0x%08x\n", AT_STATX_SYNC_AS_STAT);
#endif /* AT_STATX_SYNC_AS_STAT */
#ifdef AT_RECURSIVE
    printf("AT_RECURSIVE         : 0x%08x\n", AT_RECURSIVE);
#endif /* AT_RECURSIVE */
#ifdef AT_EACCESS
    printf("AT_EACCESS           : 0x%08x\n", AT_EACCESS);
#endif /* AT_EACCESS */
    puts("======== MPROTECT/MMAP PROTS =========");
    printf("PROT_NONE      : 0x%08x\n", PROT_NONE);
    printf("PROT_READ      : 0x%08x\n", PROT_READ);
    printf("PROT_WRITE     : 0x%08x\n", PROT_WRITE);
    printf("PROT_EXEC      : 0x%08x\n", PROT_EXEC);
#ifdef PROT_SEM
    printf("PROT_SEM       : 0x%08x\n", PROT_SEM);
#endif /* PROT_SET */
#ifdef PROT_SAO
    printf("PROT_SAO       : 0x%08x\n", PROT_SAO);
#endif
    printf("PROT_GROWSUP   : 0x%08x\n", PROT_GROWSUP);    
    printf("PROT_GROWSDOWN : 0x%08x\n", PROT_GROWSDOWN);    
 
    puts("======== MMAP/MREMAP FLAGS =========");
    printf("MAP_SHARED       : 0x%08x\n", MAP_SHARED);
    printf("MAP_PRIVATE      : 0x%08x\n", MAP_PRIVATE);
    printf("MAP_32BIT        : 0x%08x\n", MAP_32BIT);
    printf("MAP_ANON         : 0x%08x\n", MAP_ANON);
    printf("MAP_ANONYMOUS    : 0x%08x\n", MAP_ANONYMOUS);
    printf("MAP_DENYWRITE    : 0x%08x\n", MAP_DENYWRITE);
    
    printf("MAP_EXECUTABLE   : 0x%08x\n", MAP_EXECUTABLE);
    printf("MAP_FILE         : 0x%08x\n", MAP_FILE);
    printf("MAP_FIXED        : 0x%08x\n", MAP_FIXED);
    printf("MAP_GROWSDOWN    : 0x%08x\n", MAP_GROWSDOWN);
    printf("MAP_HUGETLB      : 0x%08x\n", MAP_HUGETLB);
    printf("MAP_LOCKED       : 0x%08x\n", MAP_LOCKED);

    printf("MAP_NONBLOCK     : 0x%08x\n", MAP_NONBLOCK);
    printf("MAP_NORESERVE    : 0x%08x\n", MAP_NORESERVE);
    printf("MAP_POPULATE     : 0x%08x\n", MAP_POPULATE);
    printf("MAP_STACK        : 0x%08x\n", MAP_STACK);
    printf("MAP_UNINITIALIZED: 0x%08x\n", MAP_STACK);

#ifdef MAP_AUTOGROW
    printf("MAP_AUTOGROW     : 0x%08x\n", MAP_AUTOGROW);
#endif /* MAP_AUTOGROW */
#ifdef MAP_AUTORESRV
    printf("MAP_AUTORESRV    : 0x%08x\n", MAP_AUTORESRV);
#endif /* MAP_AUTORESRV */
#ifdef MAP_COPY
    printf("MAP_COPY         : 0x%08x\n", MAP_COPY);
#endif /* MAP_COPY */
#ifdef MAP_LOCAL
    printf("MAP_LOCAL        : 0x%08x\n", MAP_LOCAL);
#endif /* MAP_LOCAL */
    printf("MAP_FAILED       : 0x%lx\n", (unsigned long)MAP_FAILED);
    printf("MREMAP_MAYMOVE   : 0x%08x\n", MREMAP_MAYMOVE);
    printf("MREMAP_FIXED     : 0x%08x\n", MREMAP_FIXED);
    puts("====== MSYNC FLAGS =======");
    printf("MS_ASYNC         : 0x%08x\n", MS_ASYNC);
    printf("MS_INVALIDATE    : 0x%08x\n", MS_INVALIDATE);
    printf("MS_SYNC          : 0x%08x\n", MS_SYNC);

    puts("====== SOCKET ENUMS ======");
    printf("AF_INET          : 0x%08x\n", AF_INET);
    printf("PF_INET          : 0x%08x\n", PF_INET);
    printf("SOCK_STREAM      : 0x%08x\n", SOCK_STREAM);
    printf("SOCK_DGRAM       : 0x%08x\n", SOCK_DGRAM);
    printf("SOCK_RAW         : 0x%08x\n", SOCK_RAW);
    printf("SOCK_RDM         : 0x%08x\n", SOCK_RDM);
    printf("SOCK_SEQPACKET   : 0x%08x\n", SOCK_SEQPACKET);
    printf("SOCK_PACKET      : 0x%08x\n", SOCK_PACKET);
    printf("IPPROTO_TCP      : 0x%08x\n", IPPROTO_TCP);
    printf("IPPROTO_UDP      : 0x%08x\n", IPPROTO_UDP);

    puts("====== PTRACE ENUMS =====");
    printf("PTRACE_TRACEME           : 0x%08x\n", PTRACE_TRACEME);
    printf("PTRACE_PEEKTEXT          : 0x%08x\n", PTRACE_PEEKTEXT);
    printf("PTRACE_PEEKDATA          : 0x%08x\n", PTRACE_PEEKDATA);
    printf("PTRACE_PEEKUSER          : 0x%08x\n", PTRACE_PEEKUSER);
    
    printf("PTRACE_POKETEXT          : 0x%08x\n", PTRACE_POKETEXT);
    printf("PTRACE_POKEDATA          : 0x%08x\n", PTRACE_POKEDATA);
    printf("PTRACE_POKEUSER          : 0x%08x\n", PTRACE_POKEUSER);

    printf("PTRACE_GETREGS           : 0x%08x\n", PTRACE_GETREGS);
    printf("PTRACE_GETFPREGS         : 0x%08x\n", PTRACE_GETFPREGS);
    printf("PTRACE_GETSIGINFO        : 0x%08x\n", PTRACE_GETSIGINFO);
    
    printf("PTRACE_SETREGS           : 0x%08x\n", PTRACE_SETREGS);
    printf("PTRACE_SETFPREGS         : 0x%08x\n", PTRACE_SETFPREGS);
    printf("PTRACE_SETSIGINFO        : 0x%08x\n", PTRACE_SETSIGINFO);
    printf("PTRACE_SETOPTIONS        : 0x%08x\n", PTRACE_SETOPTIONS);
    
    
    printf("PTRACE_GETEVENTMSG       : 0x%08x\n", PTRACE_GETEVENTMSG);
    printf("PTRACE_CONT              : 0x%08x\n", PTRACE_CONT);
    printf("PTRACE_SYSCALL           : 0x%08x\n", PTRACE_SYSCALL);
    printf("PTRACE_SINGLESTEP        : 0x%08x\n", PTRACE_SINGLESTEP);
    
    printf("PTRACE_SYSEMU            : 0x%08x\n", PTRACE_SYSEMU);
    printf("PTRACE_SYSEMU_SINGLESTEP : 0x%08x\n", PTRACE_SYSEMU_SINGLESTEP);
    printf("PTRACE_SYSCALL           : 0x%08x\n", PTRACE_SYSCALL);
    printf("PTRACE_SINGLESTEP        : 0x%08x\n", PTRACE_SINGLESTEP);
    
    printf("PTRACE_KILL              : 0x%08x\n", PTRACE_KILL);
    printf("PTRACE_ATTACH            : 0x%08x\n", PTRACE_ATTACH);
    printf("PTRACE_DETACH            : 0x%08x\n", PTRACE_DETACH);
    
    puts("====== PTRACE OPTION ENUMS =====");
    printf("PTRACE_O_TRACESYSGOOD    : 0x%08x\n", PTRACE_O_TRACESYSGOOD); 
    printf("PTRACE_O_TRACEFORK       : 0x%08x\n", PTRACE_O_TRACEFORK); 
    printf("PTRACE_O_TRACEVFORK      : 0x%08x\n", PTRACE_O_TRACEVFORK); 
    printf("PTRACE_O_TRACECLONE      : 0x%08x\n", PTRACE_O_TRACECLONE); 
    printf("PTRACE_O_TRACEEXEC       : 0x%08x\n", PTRACE_O_TRACEEXEC); 
    printf("PTRACE_O_TRACEVFORKDONE  : 0x%08x\n", PTRACE_O_TRACEVFORKDONE); 
    printf("PTRACE_O_TRACEEXIT       : 0x%08x\n", PTRACE_O_TRACEEXIT); 
    
    puts("--------------------------------------------------------------------  ptrace event consts"); 
    printf("PTRACE_EVENT_FORK        : 0x%08x\n", PTRACE_EVENT_FORK);
    printf("PTRACE_EVENT_VFORK       : 0x%08x\n", PTRACE_EVENT_VFORK);
    printf("PTRACE_EVENT_CLONE       : 0x%08x\n", PTRACE_EVENT_CLONE);    
    printf("PTRACE_EVENT_VFORK_DONE  : 0x%08x\n", PTRACE_EVENT_VFORK_DONE); 
    printf("PTRACE_EVENT_EXIT        : 0x%08x\n", PTRACE_EVENT_EXIT);   

    puts("--------------------------------------------------------------------  arch_prctl consts");
    printf("ARCH_SET_GS              : 0x%08x\n", ARCH_SET_GS);
    printf("ARCH_SET_FS              : 0x%08x\n", ARCH_SET_FS);
    printf("ARCH_SET_CPUID           : 0x%08x\n", ARCH_SET_CPUID);
    printf("ARCH_GET_FS              : 0x%08x\n", ARCH_GET_FS);
    printf("ARCH_GET_GS              : 0x%08x\n", ARCH_GET_GS);
    printf("ARCH_GET_CPUID           : 0x%08x\n", ARCH_GET_CPUID);

    puts("--------------------------------------------------------------------  memfd_crate consts");
    printf("MFD_CLOEXEC              : 0x%08x\n", MFD_CLOEXEC);
    printf("MFD_ALLOW_SEALING        : 0x%08x\n", MFD_ALLOW_SEALING);
    printf("MFD_HUGETLB              : 0x%08x\n", MFD_HUGETLB);
    
    puts("-------------------------------------------------------------------- clone flags");
    printf("CLONE_NEWPID             : 0x%08x\n", CLONE_NEWPID);
    printf("CLONE_NEWNS              : 0x%08x\n", CLONE_NEWNS);
    printf("CLONE_NEWIPC             : 0x%08x\n", CLONE_NEWIPC);
    printf("CLONE_NEWUSER            : 0x%08x\n", CLONE_NEWUSER);
    printf("CLONE_NEWNET             : 0x%08x\n", CLONE_NEWNET);
    printf("CLONE_NEWCGROUP          : 0x%08x\n", CLONE_NEWCGROUP);
    printf("CLONE_NEWUTS             : 0x%08x\n", CLONE_NEWUTS);
    puts("--------------------------------------------------------------------- seccomp consts");
    printf("SECCOMP_SET_MODE_STRICT         : 0x%x\n", SECCOMP_SET_MODE_STRICT);
    printf("SECCOMP_SET_MODE_FILTER         : 0x%x\n", SECCOMP_SET_MODE_FILTER);
    printf("SECCOMP_FILTER_FLAG_NEW_LISTENER: 0x%lx\n", SECCOMP_FILTER_FLAG_NEW_LISTENER);
    printf("SECCOMP_FILTER_FLAG_TSYNC       : 0x%lx\n", SECCOMP_FILTER_FLAG_TSYNC);
    printf("SECCOMP_FILTER_FLAG_TSYNC_ESRCH : 0x%lx\n", SECCOMP_FILTER_FLAG_TSYNC_ESRCH);
    printf("SECCOMP_FILTER_FLAG_LOG         : 0x%lx\n", SECCOMP_FILTER_FLAG_LOG);
    printf("SECCOMP_FILTER_FLAG_SPEC_ALLOW  : 0x%lx\n", SECCOMP_FILTER_FLAG_LOG);

    printf("SECCOMP_USER_NOTIF_FLAG_CONTINUE: 0x%lx\n", SECCOMP_USER_NOTIF_FLAG_CONTINUE);    


#ifdef HAS_IORING
    puts("--------------------------------------------------------------------- io_uring");
    puts(  "================ io_uring_params->features ================");
#ifdef IORING_FEAT_SUBMIT_STABLE
    printf("IORING_FEAT_SINGLE_MMAP         : 0x%x\n", IORING_FEAT_SINGLE_MMAP); 
#endif

#ifdef IORING_FEAT_NODROP
    printf("IORING_FEAT_NODROP              : 0x%x\n", IORING_FEAT_NODROP); 
#endif /* IORING_FEAT_NODROP */
    printf("IORING_FEAT_SUBMIT_STABLE       : 0x%x\n", IORING_FEAT_SUBMIT_STABLE); 
#ifdef IORING_FEAT_RW_CUR_POS
    printf("IORING_FEAT_RW_CUR_POS          : 0x%x\n", IORING_FEAT_RW_CUR_POS); 
#endif /* IORING_FEAT_RW_CUR_POS */
#ifdef IORING_FEAT_SUBMIT_STABLE
    printf("IORING_FEAT_SUBMIT_STABLE       : 0x%x\n", IORING_FEAT_SUBMIT_STABLE); 
#endif /* IORING_FEAT_SUBMIT_STABLE */
#endif /* HAS_IORING */
    return 0;
}
