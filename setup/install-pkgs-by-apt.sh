#!/bin/bash 

if [ $(whoami) != "root" ]; then
  echo "[!] Execute by root user"
  exit 1;
fi

## disable ipv6 in apt 
echo 'Acquire::ForceIPv4 "true";' >> /etc/apt/apt.conf.d/99force-ipv4

# Tools Source 
mkdir -p /exports 

apt update -y


## VMWare 
apt install -y open-vm-tools open-vm-tools-desktop manpages

## network
apt install -y wget curl nfs-common cifs-utils openssh-server dnsutils

## editor / archiver / unarchiver
apt install -y vim zip unzip rar unrar cpio p7zip-full lzip zstd


# setup git
echo "[+] Setup Git";
apt install -y git && \
  git config --global user.name "1u991yu24k1" && \
  git config --global user.email mycd9427@gmail.com && \
  git config --global core.editor /usr/bin/vim && \
  git config --global diff.indentHeuristic true && \
  git config --global core.longpaths true && \
  git config --global core.compression 0  && \

