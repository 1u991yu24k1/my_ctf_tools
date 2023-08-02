#!/bin/bash -eu


WSDIR="/tmp/now"
mkdir -p $WSDIR
cp -p /exports/my_ctf_tools/ctf.py /tmp/now/x.py && chmod u+x /tmp/now/x.py
cd $WSDIR
