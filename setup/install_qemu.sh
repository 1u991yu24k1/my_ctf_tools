#!/bin/bash -eu

## build qemu-system from source code

QEMU_VERSION="7.0.0"
QM_VER="70"


# uncomment deb-src(for apt build-dep)
sed -i -e 's/^# \(deb-src\)/\1/g' /etc/apt/sources.list
apt build-dep qemu ninja-build

wget https://download.qemu.org/qemu-$(QEMU_VERSION).tar.xz
tar xvJf qemu-$(QEMU_VERSION).tar.xz
cd qemu-$(QEMU_VERSION)
cp -r pc-bios /usr/local/share/qemu

make clean

## do build 
for ARCH in "i386 x86_64 arm aarch64 microblazeel riscv32 riscv64"; 
do
  # 7.2.0以上はslirp環境を使う場合は, --enable-slirp option が必要.
  ./configure --target-list=${ARCH}-softmmu --enable-slirp
  make -j
  mv build/qemu-system-${ARCH} /usr/local/bin/qemu"$QM_VER"-system-${ARCH}
  ln -s /usr/local/bin/qemu"$QM_VER"-system-${ARCH} /usr/local/bin/qemu-system-${ARCH}
  make clean
done
