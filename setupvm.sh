#!/bin/bash -eux

### RUN THIS SCRIPT WITH ROOT USER!!!!
#  Stop and disable unused service
function disable_unused_service() {
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
}


function install_via_apt() {
  # remove libreoffice
  apt remove --purge libreoffice*
  apt remove --purge thunderbird
  apt clean

  # use japanese repository 
  sed -i".bak" -e 's/\/\/us.archive.ubuntu.com/\/\/ftp.jaist.ac.jp/g' /etc/apt/sources.list
  # disable ipv6 in apt(for performace)
  echo 'Acquire::ForceIPv4 "true";' >> /etc/apt/apt.conf.d/99force-ipv4

  dpkg --add-architecture i386
  apt update -y 
  
  ## development tooling
  apt install -y open-vm-tools, aptitude
  apt install -y vim git flex bison manpages nkf libncurses5 patch expect screen lsof lshw mlocate tree util-linux
  apt install -y zip unzip rar unrar cpio p7zip-full lzip zstd
  apt install -y gcc g++ clang make automake autogen autoconf cmake ninja-build llvm llvm-dev llvm-tools lld libclang-dev
  apt install -y clang-13 llvm-13 llvm-13-dev llvm-13-tools
  apt install -y binutils strace ltrace gdb gdbserver elfutils dwarves nasm rr dwarfdump patchelf silversearcher-ag
  apt install -y gcc-multilib g++-multilib binutils-multiarch gdb-multiarch  
  apt install -y libc6-dbg libmpc-dev libmpfr-dev libelf-dev libc6:i386 libncurses5:i386 libstdc++6:i386 libc6-dbg:i386 
  apt install -y pkg-config libtool protobuf-compiler libprotobuf-dev 
  apt install -y libcapstone-dev libseccomp-dev libssl-dev libelf-dev 
  apt install -y libmpfr-dev libslirp-dev fuse libfuse-dev liburing2 liburing-dev 
  apt install -y libnl-3-dev libnl-route-3-dev libmicrohttpd12
  apt install -y debuginfod

  ## scripting 
  apt install -y perl php 

  ## forensic
  apt install -y imagemagick libsixel-bin
  apt install -y binwalk foremost scalpel zbar-tools ffmpeg sox qpdf testdisk sleuthkit kpartx pciutils squashfs-tools 

  ## networking 
  apt install -y iproute2 wget curl tcpdump tshark netcat socat tcpick tcpflow ngrep telnet

  ## ssl/crypto
  apt install -y aespipe john hashcash openssl

  
  apt install -y libcap-dev libgoogle-perftools-dev libncurses5-dev libsqlite3-dev libtcmalloc-minimal4 graphviz doxygen 
  apt install -y exiftool zipinfo 

  ## server infra 
  apt install -y openssh-server dnsutils cifs-utils smbclient

  ## emulator/vmm
  apt install -y busybox-static qemu-user-static qemu-utils fakeroot u-boot-tools 

}

## setup git
function setup_git() {
  echo "[+] Setup Git";
  git config --global user.name "1u991yu24k1"
  git config --global user.email mycd9427@gmail.com
  git config --global core.editor /usr/bin/vim
  git config --global diff.indentHeuristic true
  git config --global core.longpaths true
  git config --global core.compression 0 
}

function setup_python() {
  echo "[+] Setup Python Environment"
  apt install -yq python3 python3-dev python3-pip 
  apt install -yq python3-tabulate
  python3 -m pip install --upgrade pip
  python3 -m pip install hexdump pwntools z3-solver angr pycryptodome requests lit wllvm keystone-engine
}

function setup_ruby() {
  echo "[+] Setup Ruby Environment";
  apt install -yq ruby ruby-dev
  gem install one_gadget
  gem install seccomp-tools
  gem install zsteg
}


## install pkcrack
function setup_pkcrack() {
  echo "[+] Setup pkcrack"
  pushd ~/
  git clone https://github.com/keyunluo/pkcrack
  cd pkcrack
  mkdir build
  cd build
  cmake ..
  make 
  cp -p ../bin/{extract,findkey,makekey,pkcrack,zipdecrypt} /usr/local/bin/ 
}

## setup john
function setup_john() {
  pushd /exports
  git clone https://github.com/openwall/john -b bleeding-jumbo john
  cd john/src/
  ./configure
  make -s clean && make -sj4
  make install
  popd 
}

# docker/docker-compose
DOCKER_COMPOSE_VER="v2.24.5"
curl -fsSL https://get.docker.com/ | sh
curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VER}/docker-compose-$(uname -s)-$(uname -m)"  -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose


## yq (yaml)
wget -O /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
chmod +x /usr/local/bin/yq

### checksec
wget -O /usr/local/bin/checksec https://raw.githubusercontent.com/slimm609/checksec.sh/master/checksec
chmod +x /usr/loca/bin/checksec

### gef
wget -q https://raw.githubusercontent.com/bata24/gef/dev/install.sh -O- | bash

### add debug symbols
function install_dbg_symbol_for_libc() {
  echo "[+] Install Debug symbol for libc"
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
}


mkdir -p /exports

## Rust(rustc, cargo)
echo "[+] Setup Rust Environment";
curl https://sh.rustup.rs -sSf | sh 
  
echo "[+] Install attractive tools by Rust";
cargo install rustfilt
cargo install ropr
cargo install --git https://github.com/Aplet123/kctf-pow.git


setup_rust

# setup uv
echo "[*] Install uv"
curl -LsSf https://astral.sh/uv/install.sh | sh

## Golang
## Version 1.22.1(latest at 2024/03/31)
GOLANG_VERSION="1.22.1"

echo "[+] Install Golang (Version: ${GOLANG_VERSION})";
wget "https://go.dev/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz" -O "/tmp/go${GOLANG_VERSION}.tar.gz"
tar -C /usr/local -xzf /tmp/go${GOLANG_VERSION}.tar.gz
echo 'PATH="$PATH:/usr/local/go/bin"' >> ~/.bashrc
unset GOLANG_VERSION;



## Klee
function setup_klee() {
  echo "[+] Install Klee";
  pushd /exports
  git clone --depth 1 https://github.com/klee/klee.git
  cd klee
  mkdir -p ./build
  cd ./build
  ### <asm/XXX.h>系のファイルが無い場合の対策.
  pushd /usr/include
  ln -s asm-generic asm
  cmake -DLLVMCC=/usr/bin/clang -DLLVMCXX=/usr/bin/clang++ -DCMAKE_BUILD_TYPE=Release  ..
  make check && make install 
  popd
}

## Xbyak
function install_xbyak() {
  echo "[+] Install Xbyak";
  pushd /exports 
  git clone --depth 1 https://github.com/herumi/xbyak.git
  pushd xbyak
  make install 
  popd
}


## nsjail
function install_nsjail() {
  echo "[+] Install nsjail"
  pushd /exports
  git clone https://github.com/google/nsjail.git
  cd nsjail 
  make -j && cp ./nsjail /usr/local/bin/nsjail
  make clean 
  popd
}

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
git clone github:1u991yu24k1/my_ctf_tools
cd my_ctf_tools

### build lsenum command 
make && make install && make clean
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
