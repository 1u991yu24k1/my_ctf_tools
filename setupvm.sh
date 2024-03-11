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
apt install -y vim git flex bison manpages nkf libncurses5 patch expect screen lsof lshw mlocate tree util-linux
apt install -y zip unzip rar unrar cpio p7zip-full lzip zstd
apt install -y gcc g++ clang make automake autogen autoconf cmake ninja-build llvm lld libclang-dev
apt install -y clang-13 llvm-13 llvm-13-dev llvm-13-tools
apt install -y binutils strace ltrace gdb gdbserver elfutils dwarves nasm rr dwarfdump patchelf silversearcher-ag
apt install -y gcc-multilib g++-multilib binutils-multiarch gdb-multiarch  
apt install -y libc6-dbg libmpc-dev libmpfr-dev libelf-dev libc6:i386 libncurses5:i386 libstdc++6:i386 libc6-dbg:i386
apt install -y pkg-config libtool protobuf-compiler libprotobuf-dev 
apt install -y libcapstone-dev libseccomp-dev libssl-dev libelf-dev libmpfr-dev libslirp-dev fuse libfuse-dev liburing2 liburing-dev libnl-3-dev libnl-route-3-dev

## scripting 
apt install -y perl python3 python3-dev ruby ruby-dev php 

## forensic
apt install -y binwalk foremost scalpel zbar-tools ffmpeg sox qpdf testdisk sleuthkit kpartx pciutils squashfs-tools 

## networking 
apt install -y iproute2 wget curl tcpdump tshark netcat socat tcpick tcpflow ngrep telnet

## ssl/crypto
apt install -y aespipe john hashcash openssl

## setup git
git config --global user.name "1u991yu24k1"
git config --global user.email mycd9427@gmail.com
git config --global core.editor /usr/bin/vim
git config --global diff.indentHeuristic true


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
apt install -y openssh-server dnsutils cifs-utils smbclient

## emulator/vmm
apt install -y busybox-static qemu-user-static qemu-utils fakeroot u-boot-tools 

## install non-apt tools
python3 -m pip install --upgrade pip 
python3 -m pip install hexdump pwntools z3-solver angr pycryptodome requests lit wllvm keystone-engine
gem install one_gadget
gem install seccomp-tools
gem install zsteg

# docker/docker-compose
DOCKER_COMPOSE_VER="v2.24.5"
curl -fsSL https://get.docker.com/ | sh
curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VER}/docker-compose-$(uname -s)-$(uname -m)"  -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose


### checksec
wget https://raw.githubusercontent.com/slimm609/checksec.sh/master/checksec -O /usr/local/bin/checksec && chmod +x /usr/local/bin/checksec

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
curl https://sh.rustup.rs -sSf | sh 
cargo install rustfilt
cargo install ropr


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
cd ../.. # /exports

## Xbyak
git clone --depth 1 https://github.com/herumi/xbyak.git
pushd xbyak
make install 
popd

## nsjail
pushd /exports
git clone https://github.com/google/nsjail.git
cd nsjail 
make -j && cp ./nsjail /usr/local/bin/nsjail
make clean 
popd

## Linux kernel source code
pushd /exports
git clone --depth 1 git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
cd linux/
make mrproper
popd 

### utilitiy tools for kernel 
wget -O /usr/local/bin/extract-vmlinux https://raw.githubusercontent.com/torvalds/linux/master/scripts/extract-vmlinux
chmod +x /usr/local/bin/extract-vmlinux
wget -O /usr/local/bin/decodecode https://raw.githubusercontent.com/torvalds/linux/master/scripts/decodecode
chmod +x /usr/local/bin/decodecode

## bata24/gef
pushd /exports
git clone https://github.com/bata24/gef.git
popd

## mytools
pushd /exports
git clone ctftools:1u991yu24k1/my_ctf_tools.git 
cd my_ctf_tools

### build lsenum command 
make && make install && male clean
cat gdb_init.txt >> ~/.gdbinit
cp vimrc ~/.vimrc
cp ctf.sh /usr/local/bin/ctf.sh && chmod +x /usr/local/bin/ctf.sh
cp bashrc ~/.bashrc 
popd


## depot_tools (for v8)
pushd /exports
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
echo "export PATH=$(pwd)/depot_tools:\$PATH" >> ~/.bashrc
popd


## done 
source ~/.bashrc
