# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]\$ '
fi

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \W\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias gdb='gdb -q'
alias dbg='gdb'
alias readelf='readelf -W'
alias vi='vim'
alias vw='view'
alias clip='xclip -selection c' # <some_command> | clip ; => copy content to clipboard
alias py='python3 -q'
alias valgrind='valgrind -q'
alias grep='grep --color=auto'
alias nocolor="sed 's/\x1b\[[0-9;]*m//g'"
alias nnln="grep -v '^$'"
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias statparse='awk "{printf(\"pid:%ld, %s, state:%c, ppid:%ld, pgrp:%ld\nutime:%lu, stime:%lu, cutime:%ld, cstime:%ld, priority:%ld, nice:%ld\nnum_threads:%ld, processor:%ld, starttime:%lu, vsize:0x%x\nstartcode:0x%x, endcode:0x%x\nstartstack:0x%x, kstkesp:0x%x, kstkeip:0x%x\nstart_data:0x%x, end_data:0x%x, start_brk:0x%x\narg_start:0x%x, arg_end:0x%x\nenv_start:0x%x, env_end:0x%x\n\", \$1,\$2,\$3,\$4,\$5,\$14,\$15,\$16,\$17,\$18,\$19,\$20,\$39,\$22,\$23,\$26,\$27,\$28,\$29,\$30,\$45,\$46,\$47,\$48,\$49,\$50,\$51);}"'
alias statparselong='awk "{printf(\"pid:%ld, %s, state:%c\nppid:%ld, pgrp:%ld, session:%ld, tty_nr:%ld, tpgid:%ld, flags:0x%x\nminflt:%lu, cminflt:%lu, majflt:%lu, cmajflt:%lu\nutime:%lu, stime:%lu, cutime:%ld, cstime:%ld, priority:%ld, nice:%ld\nnum_threads:%ld, starttime:%lu\nvsize:0x%x, rss:%ld, rsslim:%ld\nstartcode:0x%x, endcode:0x%x\nstartstack:0x%x, kstkesp:0x%x, kstkeip:0x%x\nnswap:%ld, cnswap:%ld, exit_signal:%ld, processor:%ld\nrt_priority:%ld, policy:%ld, delayacct_blkio_status:%ld\nguest_time:%ld, cguest_time:%ld\nstart_data:0x%x, end_data:0x%x, start_brk:0x%x\narg_start:0x%x, arg_end:0x%x\nenv_start:0x%x, env_end:0x%x\nexit_code:%ld\n\", \$1,\$2,\$3,\$4,\$5,\$6,\$7,\$8,\$9,\$10,\$11,\$12,\$13,\$14,\$15,\$16,\$17,\$18,\$19,\$20,\$22,\$23,\$24,\$25,\$26,\$27,\$28,\$29,\$30,\$36,\$37,\$38,\$39,\$40,\$41,\$42,\$43,\$44,\$45,\$46,\$47,\$48,\$49,\$50,\$51,\$52);}"'
alias sshlist='grep -oP "^Host\s+([-.\w]+)" ~/.ssh/config'
export PATH=$PATH:/exports/sde/sde-external-8.69.1-2021-07-18-lin
export PYTHONWARNINGS='ignore';

## pwnable utilities
alias checksec='gdb -ex "checksec" -ex "quit"'
alias libc='ldd /bin/ls | grep "libc.so.6" | awk "{print \$3}"'
alias musl-gcc='/usr/local/musl/bin/musl-gcc'
alias musl-libc='/usr/lib/local/musl/lib/libc.so'

## bata24/gef wrapper 
function gef-lscmd() {
  cat ~/.gdbinit-gef.py | perl -lne 'print $1 if /_cmdline_\s=\s"(\S+)"/' | sort
}

function gef-checksec () {
  gdb -ex 'checksec' -ex 'quit' $1;  
}

function gef-lssyscall() {
  gdb -ex 'syscall-search -a X86 -m 64 ".*"' -ex 'quit'
}

function gef-update() {
  python3 /root/.gdbinit-gef.py --upgrade
}

function aslr() {
  arg="$1";
  aslr_procfs="/proc/sys/kernel/randomize_va_space";
  if [ "x$arg" == "xon" ]; then
    echo 2 > $aslr_procfs; 
  elif [ "x$arg" == "xoff" ]; then
    echo 0 > $aslr_procfs;
  else
    if [ "$#" -eq 0 ]; then
      # display status
      if [ $(cat "$aslr_procfs") -eq 0 ]; then
        echo "ASLR OFF";
      else
        echo "ASLR ON"; 
      fi      
    else
      echo "Usage: aslr [on|off]";
    fi
  fi
}

function ptrace_scope() {
  arg="$1";
  ptrace_scope_procfs="/proc/sys/kernel/yama/ptrace_scope";
  if [ "x$arg" == "xon" ]; then
    echo 1 > $ptrace_scope_procfs; 
  elif [ "x$arg" == "xoff" ]; then
    echo 0 > $ptrace_scope_procfs;
  else
    if [ "$#" -eq 0 ]; then
      # display status
      current_val=$(cat "$ptrace_scope_procfs")
      if [ $current_val -eq 0 ]; then
        echo "ptrace is allowed to ANY (ptrace_scope: 0)";
      elif [ $current_val -eq 1 ]; then
        echo "ptrace is allowed to child (ptrace_scope: 1)"; 
      elif [ $current_val -eq 2 ]; then
        echo "ptrace is allowed by only admin (ptrace_scope: 2)";
      else
        echo "ptrace is NOT allowed (ptrace_scope: 3)"
      fi
    else
      echo "Usage: ptrace_scope [on|off]";
    fi
  fi
 
}

function io_uring_stat () {
  arg="$1";
  procfs_iouring_stat="/proc/sys/kernel/io_uring_disabled";
  if [ $# -eq 0 ]; then
    stat=$(cat $procfs_iouring_stat);
    if [ $stat -eq 0 ]; then
      echo "io_uring is allowed";
    elif [ $stat -eq 1 ]; then
      echo "io_uring is restricted (available users: $(cat /proc/sys/kernel/io_uring_disabled))";
    else:
      echo "io_uring is disallowed";
    fi 
  elif [ $# -eq 1 ]; then
    if [ "x$arg" == "xon" ]; then
      echo 0 > $procfs_iouring_stat;
    elif [ "x$arg" == "xrestricted" ]; then
      echo 1 > $procfs_iouring_stat; 
    elif [ "x$arg" == "xoff" ]; then
      echo 2 > $procfs_iouring_stat; 
    else:
        echo "Unknown number arg (available only: \"on\"|\"restricted\"|\"off\")";
    fi 
  fi 
}

### shellcode utilities 
function disas() {
  objdump -M intel -j.text -d $1
}

function scc(){
  SCS="$1.s";
  SCO="$1.o";
  SCR="$1.raw";
  SCB="$1.b";
  if [ -f $SCS ]; then
    nasm -f elf64 -o $SCO $SCS;
    if [ -f $SCO ]; then
      objcopy --dump-section .text=$SCR $SCO;
      # check nullfree
      objdump -M intel -d $SCO | grep -v '^$' | perl -pe 's/\b(00)\b/\033[31m\1\033[0m/g';
      BYTESZ=$(wc -c $SCR | cut -d' ' -f1);
      echo -e "\033[33m[+] shellcode assembled ${BYTESZ} bytes\033[0m"; 
      base64 $SCR > $SCB;
    fi
  else
    echo "[!] File $SCS not found ...";
  fi
}

function scc32(){
  SCS="$1.s";
  SCO="$1.o";
  SCR="$1.raw";
  SCB="$1.b";
  if [ -f $SCS ]; then
    nasm -f elf32 -o $SCO $SCS;
    if [ -f $SCO ]; then
      objcopy --dump-section .text=$SCR $SCO;
      objdump -M intel -d $SCO | grep -v '^$' | perl -pe 's/\b(00)\b/\033[31m\1\033[0m/g';
      BYTESZ=$(wc -c $SCR | cut -d' ' -f1);
      echo -e "\033[33m[+] shellcode assembled ${BYTESZ} bytes\033[0m"; 
      base64 $SCR > $SCB;
    fi
  else
    echo "[!] File $SCS not found ...";
  fi
}

### Docker Utilities
function dockenter () {
  docker exec -it $1 /bin/bash;
}
alias dim='docker images'
alias dps='docker ps'
