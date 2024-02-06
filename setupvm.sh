#!/bin/bash -eux

### RUN THIS SCRIPT WITH ROOT USER!!!!
#  Stop and disable unused service
## cups, cups-browsed
systemctl stop cups && systemctl disable cups
systemctl stop cups-browsed && systemctl disable cups-browsed
## default apache2
systemctl stop apache2 && systemctl disable apache2

## avahi
systemctl mask avahi-daemon && systemctl stop avahi-daemon && systemctl disable avahi-daemon
systemctl stop avahi-daemon.socket && systemctl disable avahi-daemon.socket

## wpa_supplicant
systemctl stop wpa_supplicant && systemctl disable wpa_supplicant

# use japanese repository 
sed -i".bak" -e 's/\/\/us.archive.ubuntu.com/\/\/ftp.jaist.ac.jp/g' /etc/apt/sources.list
# disable ipv6 in apt(for performace)
echo 'Acquire::ForceIPv4 "true";' >> /etc/apt/apt.conf.d/99force-ipv4

# remove libreoffice
apt remove --purge libreoffice*
apt remove --purge thunderbird
apt clean
apt autoremove


apt install aptitude # for conflict avoidance
dpkg --add-architecture i386
apt update -y 

## development tooling
apt install -y open-vm-tools
apt install -y vim git flex bison manpages nkf libncurses5 patch expect screen lsof lshw mlocate 
apt install -y zip unzip rar unrar cpio p7zip-full lzip zstd
apt install -y gcc g++ clang make automake autogen autoconf cmake ninjai llvm lld libclang-dev
apt install -y clang-13 llvm-13 llvm-13-dev llvm-13-tools
apt install -y binutils strace ltrace gdb gdbserver elfutils dwarves nasm rr dwarfdump patchelf
apt install -y gcc-multilib g++-multilib binutils-multiarch gdb-multiarch  
apt install -y libc6-dbg libmpc-dev libmpfr-dev libelf-dev libc6:i386 libncurses5:i386 libstdc++6:i386 libc6-dbg:i386
apt install -y libcapstone-dev libseccomp-dev libssl-dev libelf-dev libmpfr-dev libslirp-dev

## scripting 
apt install -y perl python3 python3-dev ruby ruby-dev php 

## forensic
apt install -y binwalk foremost scalpel zbar-tools ffmpeg sox qpdf testdisk sleuthkit kpartx pciutils squashfs-tools 

## networking 
apt install -y iproute2 wget curl tcpdump tshark netcat socat tcpick tcpflow ngrep

## ssl/crypto
apt install -y aespipe john hashcash openssl

apt install -y libcap-dev libgoogle-perftools-dev libncurses5-dev libsqlite3-dev libtcmalloc-minimal4 graphviz doxygen 
apt install -y python3-pip python3-tabulate exiftool zipinfo 
aptitude install libegl-mesa0

pushd ~/
git clone https://github.com/keyunluo/pkcrack
cd pkcrack
mkdir build
cd build
cmake ..
make 
cp ../bin/{extract,findkey,makekey,pkcrack,zipdecrypt} /usr/local/bin/ 


## server infra 
apt install -y openssh-server dnsutils

## emulator/vmm
apt install -y busybox-static qemu-user-static qemu-utils fakeroot u-boot-tools 

## my development env setup 
git config --global user.name "1u991yu24k1"
git config --global user.email mycd9427@gmail.com
git config --global core.editor /usr/bin/vim

## install non-apt tools
python3 -m pip install --upgrade pip 
python3 -m pip install hexdump pwntools z3-solver angr pycryptodome requests lit wllvm keystone-engine
gem install one_gadget
gem install seccomp-tools
gem install zsteg

# docker/docker-compose
curl -fsSL https://get.docker.com/ | sh
curl -L https://github.com/docker/compose/releases/download/1.6.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

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

### add debug symbols
sed -i -e 's/^# \(deb-src\)/\1/g' /etc/apt/sources.list
apt update -y
cd /usr/src/
apt source libc6
cd glibc-*
mv ../glibc_*.debian.tar.xz ../glibc_*.dsc ../glibc_*.orig.tar.xz .

### -> gdbinit 
echo "dir $(pwd)/elf/"                >> ~/.gdbinit
echo "dir $(pwd)/io/"                 >> ~/.gdbinit
echo "dir $(pwd)/libio/"              >> ~/.gdbinit
echo "dir $(pwd)/stdlib/"             >> ~/.gdbinit
echo "dir $(pwd)/malloc/"             >> ~/.gdbinit
echo "dir $(pwd)/string/"             >> ~/.gdbinit
echo "dir $(pwd)/stdio-common/"       >> ~/.gdbinit
echo "dir $(pwd)/signal/"             >> ~/.gdbinit
echo "dir $(pwd)/setjmp/"             >> ~/.gdbinit
echo "dir $(pwd)/posix/"              >> ~/.gdbinit
echo "dir $(pwd)/sysdeps/$(uname -p)" >> ~/.gdbinit

mkdir -p /exports
cd /exports 

## Rust(rustc, cargo)
apt install -y rustc
curl https://sh.rustup.rs -sSf | sh 
cargo install rustfilt


## qemu system(i386, x86_64, arm, aarch64, riscv32, riscv64)
# uncomment deb-src(for apt build-dep)
sed -i -e 's/^# \(deb-src\)/\1/g' /etc/apt/sources.list
apt build-dep qemu ninja-build
QEMU_VERSION="7.0.0"
QM_VER="70"

wget https://download.qemu.org/qemu-$(QEMU_VERSION).tar.xz
tar xvJf qemu-$(QEMU_VERSION).tar.xz
cd qemu-$(QEMU_VERSION)
cp -r pc-bios /usr/local/share/qemu

make clean

### i386
./configure --target-list=i386-softmmu && make -j
mv build/qemu-system-i386 /usr/local/bin/qemu"$QM_VER"-system-i386
ln -s /usr/local/bin/qemu"$QM_VER"-system-i386 /usr/local/bin/qemu-system-i386
make clean

### x64
./configure --target-list=x86_64-softmmu && make -j
mv build/qemu-system-x86_64 /usr/local/bin/qemu"$QM_VER"-system-x86_64
ln -s /usr/local/bin/qemu"$QM_VER"-system-x86_64 /usr/local/bin/qemu-system-x86_64
make clean

### arm
./configure --target-list=arm-softmmu && make -j
mv build/qemu-system-arm /usr/local/bin/qemu"$QM_VER"-system-arm
ln -s /usr/local/bin/qemu"$QM_VER"-system-arm /usr/local/bin/qemu-system-arm
make clean

### aarch64
./configure --target-list=aarch64-softmmu && make -j
mv build/qemu-system-aarch64 /usr/local/bin/qemu"$QM_VER"-system-aarch64
ln -s /usr/local/bin/qemu"$QM_VER"-system-aarch64 /usr/local/bin/qemu-system-aarch64
make clean

### riscv32
./configure --target-list=riscv32-softmmu && make -j
mv build/qemu-system-riscv32 /usr/local/bin/qemu"$QM_VER"-system-riscv32
ln -s /usr/local/bin/qemu"$QM_VER"-system-riscv32 /usr/local/bin/qemu-system-riscv32
make clean

### riscv64
./configure --target-list=riscv64-softmmu && make -j
mv build/qemu-system-riscv64 /usr/local/bin/qemu"$QM_VER"-system-riscv64
ln -s /usr/local/bin/qemu"$QM_VER"-system-riscv64 /usr/local/bin/qemu-system-riscv64
make clean

unset QEMU_VERSION
unset QM_VER

cd /exports
## Klee
git clone https://github.com/klee/klee.git
cd klee
mkdir -p ./build
cd ./build
### <asm/XXX.h>系のファイルが無い場合の対策.
pushd /usr/include
ln -s asm-generic asm
popd
cmake -DLLVMCC=/usr/bin/clang -DLLVMCXX=/usr/bin/clang++ -DCMAKE_BUILD_TYPE=Release  ..

make check && make install 



## Linux kernel source code
cd /exports
git clone --depth=1 git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
wget -O /usr/local/bin/extract-vmlinux https://raw.githubusercontent.com/torvalds/linux/master/scripts/extract-vmlinux
chmod +x /usr/local/bin/extract-vmlinux
cd linux/
make mrproper

cd /exports
git clone ctftools:1u991yu24k1/my_ctf_tools.git 
cd my_ctf_tools
## lsenum command 
make && cp -p lsenum /usr/local/bin/lsenum && male clean
cat gdb_init.txt >> ~/.gdbinit
cp -r vimrc ~/.vimrc
cp -r bashrc ~/.bashrc
cp -r ctf.sh /usr/local/bin/ctf.sh && chmod +x /usr/local/bin/ctf.sh

cd /exports
git clone https://github.com/bata24/gef.git
