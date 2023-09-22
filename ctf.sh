#!/bin/bash -eu
# . ctf.sh

WSDIR="/tmp/now"
if [ -d $WSDIR ]; then
  BAK="/tmp/ctf_bak_`date '%Y%m%d'`";
  mv -pr $WSDIR $BAK;
fi
mkdir -p $WSDIR
cp -p /exports/my_ctf_tools/ctf.py /tmp/now/x.py && chmod u+x /tmp/now/x.py
cd $WSDIR
