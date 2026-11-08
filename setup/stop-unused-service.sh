#!/bin/bash 

if [ $(whoami) != "root" ]; then
  echo "[!] Execute by root user"
  exit 1;
fi

 
## cups, cups-browsed
systemctl stop cups && \
  systemctl disable cups

systemctl stop cups-browsed && \
  systemctl disable cups-browsed


## Avahi
systemctl mask avahi-daemon && \
  systemctl stop avahi-daemon && \
  systemctl disable avahi-daemon

systemctl stop avahi-daemon.socket && \
  systemctl disable avahi-daemon.socket


## WPA Supplicant
systemctl stop wpa_supplicant && \
  systemctl disable wpa_supplicant 

## Geoclue (>26.10)
systemctl stop geoclue.service && \
  systemctl mask geoclue.service 
  
