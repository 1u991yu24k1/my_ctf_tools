#!/bin/bash


SRC=$1;
if [ "x$1" == "x" ]; then
  SRC="./x.c";
fi

## figure compile option
echo "[+] building : $SRC";
GCCARGS="-static -o x";
fgrep '<pthread.h>' $SRC
if [ $? == 1 ]; then
  $GCCARGS="$GCCARGS $SRC -lpthread";
else
  $GCCARGS="$GCCARGS $SRC";
fi
echo "gcc $GCCARGS";
gcc $GCCARGS;


## place exploit
RAMFSD="./initramfs";
if [ -d $RAMFSD ]; then
  echo "[*] initramfs was found. compiler output 'x' in initramfs dir.";
  cp -p ./x $RAMFSD/
  pushd $RAMFSD;
  find . | cpio -o --format=newc > ../initramfs.cpio
  popd 
else
  echo "[*] initramfs was not found."
fi
