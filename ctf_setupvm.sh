#!/bin/bash -eux

### RUN THIS SCRIPT WITH ROOT USER!!!!
dpkg --add-architecture i386
apt update -y 

## development tooling
apt install -y vim git flex bison manpages nkf libncurses5 patch expect screen lsof lshw mlocate 
apt install -y git zip unzip rar unrar cpio p7zip-full lzip
apt install -y gcc g++ clang make automake autogen autoconf cmake ninja
apt install -y binutils strace ltrace gdb gdbserver elfutils nasm radare2 rr dwarfdump 
apt install -y gcc-multilib g++-multilib binutils-multiarch gdb-multiarch  
apt install -y libc6-dbg libmpc-dev libmpfr-dev libelf-dev libc6:i386 libncurses5:i386 libstdc++6:i386 libc6-dbg:i386

## scripting 
apt install -y perl python3 python3-dev ruby ruby-dev php 

## forensic
apt install -y binwalk foremost scalpel zbar-tools ffmpeg sox qpdf testdisk sleuthkit kpartx pciutils squashfs-tools 

## networking 
apt install -y iproute2 wget curl tcpdump tshark netcat socat tcpick tcpflow ngrep

## ssl/crypto
apt install -y aespipe john hashcash openssl

## server infra 
apt install -y openssh-server dnsutils

## emulator/vmm
apt install -y busybox-static docker.io qemu-user qemu-utils fakeroot u-boot-tools

## non-apt tools for pwnable
python3 -m pip --upgrade pip hexdump pwntools z3-solver angr
gem install one_gadget
gem install seccomp-tools

### checksec
wget https://raw.githubusercontent.com/slimm609/checksec.sh/master/checksec -O /usr/local/bin/checksec && chmod +x /usr/local/bin/checksec

### rp++
mkdir -p ~/dl && cd ~/dl
git clone https://github.com/0vercl0k/rp
cd rp/src/build 
chmod u+x build-release.sh && ./build-release.sh
cp -p ~/dl/rp/src/build/rp-lin-x64 /usr/local/bin/rp-lin-x64

### gef
wget -q https://raw.githubusercontent.com/bata24/gef/dev/install.sh -O- | bash
wget -q https://github.com/1u991yu24k1/my_ctf_tools/blob/main/gdb_init.txt -O ~/.gdbinit

### add debug symbols
sed -i -e 's/^# \(deb-src\)/\1/g' /etc/apt/sources.list
apt update -y
cd /usr/src/
apt source libc6
cd glibc-*
mv ../glibc_*.debian.tar.xz ../glibc_*.dsc ../glibc_*.orig.tar.xz .

## my development env setup 
wget -q https://raw.githubusercontent.com/1u991yu24k1/my_ctf_tools/main/vimrc -O ~/.vimrc
git config --global user.name "1u991yu24k1"
git config --global user.email mycd9427@gmail.com
git config --global core.editor /usr/bin/vim

## -> gdbinit 
echo "dir $(pwd)/elf/"             >> ~/.gdbinit
echo "dir $(pwd)/io/"              >> ~/.gdbinit
echo "dir $(pwd)/libio/"           >> ~/.gdbinit
echo "dir $(pwd)/stdlib/"          >> ~/.gdbinit
echo "dir $(pwd)/malloc/"          >> ~/.gdbinit
echo "dir $(pwd)/string/"          >> ~/.gdbinit
echo "dir $(pwd)/stdio-common/"    >> ~/.gdbinit
echo "dir $(pwd)/signal/"          >> ~/.gdbinit
echo "dir $(pwd)/setjmp/"          >> ~/.gdbinit
echo "dir $(pwd)/posix/"           >> ~/.gdbinit
echo "dir $(pwd)/sysdeps/$(uname -p)" >> ~/.gdbinit

## optinal tools( for my analysis )
mkdir -p /exports
cd /exports 
git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git

## qemu system(i386, x86_64, arm, aarch64, riscv32, riscv64)
apt build-dep qemu
QEMU_VERSION="6.2.0"
QM_VER="62"

wget https://download.qemu.org/qemu-$(QEMU_VERSION).tar.xz
tar xvJf qemu-$(QEMU_VERSION).tar.xz
cd qemu-$(QEMU_VERSION)
cp -r pc-bios /usr/local/share/qemu

make clean

### i386
./configure --target-list=i386-softmmu && make -j
mv i386-softmmu/qemu-system-i386 /usr/local/bin/qemu"$QM_VER"-system-i386
make clean
echo "$"

### x64
./configure --target-list=x86_64-softmmu && make -j
mv x86_64-softmmu/qemu-system-x86_64 /usr/local/bin/qemu"$QM_VER"-system-x64
make clean

### arm
./configure --target-list=arm-softmmu && make -j
mv arm-softmmu/qemu-system-arm /usr/local/bin/qemu"$QM_VER"-system-arm
make clean

### aarch64
./configure --target-list=aarch64-softmmu && make -j
mv aarch64-softmmu/qemu-system-aarch64 /usr/local/bin/qemu"$QM_VER"-system-aarch64
make clean

### riscv32
./configure --target-list=risv32-softmmu && make -j
mv riscv32-softmmu/qemu-system-risv32 /usr/local/bin/qemu"$QM_VER"-system-riscv32
make clean

### riscv64
./configure --target-list=risv64-softmmu && make -j
mv riscv64-softmmu/qemu-system-arm /usr/local/bin/qemu"$QM_VER"-system-riscv64
make clean

unset QEMU_VERSION
unset QM_VER

## Linux kernel source code
cd /exports
glt clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
