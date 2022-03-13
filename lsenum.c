#define _GNU_SOURCE

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/ptrace.h>

int main(int argc, char **argv){
    puts("======== ERROR ENUMS =========");
    printf("EACCES \t: %4d : 0x%lx\n", -EACCES, (unsigned long)(-EACCES));
    printf("EINVAL \t: %4d : 0x%lx\n", -EINVAL, (unsigned long)(-EINVAL));
    printf("EBUSY  \t: %4d : 0x%lx\n", -EBUSY,  (unsigned long)(-EBUSY));
    printf("EDQUOT \t: %4d : 0x%lx\n", -EDQUOT, (unsigned long)(-EDQUOT));
    printf("EEXSIST\t: %4d : 0x%lx\n", -EACCES, (unsigned long)(-EEXIST));
    printf("EFAULT \t: %4d : 0x%lx\n", -EFAULT, (unsigned long)(-EFAULT));

    printf("EFBIG  \t: %4d : 0x%lx\n", -EFBIG,  (unsigned long)(-EFBIG));
    printf("EINTR  \t: %4d : 0x%lx\n", -EINTR,  (unsigned long)(-EINTR));
    printf("EISDIR \t: %4d : 0x%lx\n", -EISDIR, (unsigned long)(-EISDIR));
    printf("ELOOP  \t: %4d : 0x%lx\n", -ELOOP,  (unsigned long)(-ELOOP));
    
    printf("EMFILE \t: %4d : 0x%lx\n", -EMFILE, (unsigned long)(-EMFILE));
    printf("EINTR  \t: %4d : 0x%lx\n", -EINTR,  (unsigned long)(-EINTR));
    printf("EISDIR \t: %4d : 0x%lx\n", -EISDIR, (unsigned long)(-EISDIR));
    printf("ENAMETOOLONG \t: %4d : 0x%lx\n", -ENAMETOOLONG, (unsigned long)(-ENAMETOOLONG));
    
    printf("ENFILE \t: %4d : 0x%lx\n", -ENFILE, (unsigned long)(-ENFILE));
    printf("ENODEV \t: %4d : 0x%lx\n", -ENODEV, (unsigned long)(-ENODEV));
    printf("ENOENT \t: %4d : 0x%lx\n", -ENOENT, (unsigned long)(-ENOENT));
    printf("ENOMEM \t: %4d : 0x%lx\n", -ENOMEM, (unsigned long)(-ENOMEM));
    
    printf("ENOSPC \t: %4d : 0x%lx\n", -ENOSPC, (unsigned long)(-ENOSPC));
    printf("ENOTDIR\t: %4d : 0x%lx\n", -ENOTDIR,(unsigned long)(-ENOTDIR));
    printf("ENXIO  \t: %4d : 0x%lx\n", -ENXIO,  (unsigned long)(-ENXIO));
    printf("EOPNOTSUPP\t: %4d : 0x%lx\n", -EOPNOTSUPP, (unsigned long)(-EOPNOTSUPP));
    
    printf("EOVERFLOW\t: %4d : 0x%lx\n", -EOVERFLOW, (unsigned long)(-EOVERFLOW));
    printf("EPERM  \t: %4d : 0x%lx\n", -EPERM,  (unsigned long)(-EPERM));
    printf("EROFS  \t: %4d : 0x%lx\n", -EROFS,  (unsigned long)(-EROFS));
    printf("ETXTBSY\t: %4d : 0x%lx\n", -ETXTBSY,(unsigned long)(-ETXTBSY));

    printf("EWOULDBLOCK\t: %4d : 0x%lx\n", -EWOULDBLOCK, (unsigned long)(-EWOULDBLOCK));
    printf("EBADF  \t: %4d : 0x%lx\n", -EBADF,  (unsigned long)(-EBADF));
    printf("ENOTDIR\t: %4d : 0x%lx\n", -ENOTDIR,(unsigned long)(-ENOTDIR));
    printf("EIO    \t: %4d : 0x%lx\n", -EIO,    (unsigned long)(-EIO));
    printf("ELOOP  \t: %4d : 0x%lx\n", -ELOOP,  (unsigned long)(-ELOOP));
    printf("EMLINK \t: %4d : 0x%lx\n", -EMLINK, (unsigned long)(-EMLINK));
    printf("EXDEV  \t: %4d : 0x%lx\n", -EXDEV,  (unsigned long)(-EXDEV));
    printf("ESRCH  \t: %4d : 0x%lx\n", -ESRCH,  (unsigned long)(-ESRCH));    
    
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
    
    puts("====== PTRACE EVENT ENUMS =====");
    printf("PTRACE_EVENT_FORK        : 0x%08x\n", PTRACE_EVENT_FORK);
    printf("PTRACE_EVENT_VFORK       : 0x%08x\n", PTRACE_EVENT_VFORK);
    printf("PTRACE_EVENT_CLONE       : 0x%08x\n", PTRACE_EVENT_CLONE);    
    printf("PTRACE_EVENT_VFORK_DONE  : 0x%08x\n", PTRACE_EVENT_VFORK_DONE); 
    printf("PTRACE_EVENT_EXIT        : 0x%08x\n", PTRACE_EVENT_EXIT);   
    return 0;
}
