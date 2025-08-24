#!/usr/bin/env python3
#-*-coding:utf-8-*-
import sys
from ptrlib import *

def dbg(ss):
  cs, ce = '\x1b[93;41m', '\x1b[0m' # white
  fmt = f"{ss}:"
  try:
    val = eval(ss.encode())
    if type(val) is int:
      fmt += f" {hex(val)}"
    elif type(val) is str or type(val) is bytes:
      fmt += f" {val}"
  except NameError:
    fmt = fmt.rstrip(":")
  print(cs + fmt + ce)

##### addrs/offsets of symbols, gadgets and consts #####
is_remote = len(sys.argv) > 1 and sys.argv[1] == 'r'

if is_remote:
  s = Socket("")
else:
  s = Socket('127.0.0.1', 1337)

### exploit from here ###


s.interactive()
