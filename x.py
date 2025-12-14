#!/usr/bin/env python3
#-*-coding:utf-8-*-

import sys
from ptrlib import *

def dbg(ss):
  cs, ce = '\x1b[93;41m', '\x1b[0m' # white
  fmt = f"[+] {ss}:"
  try:
    val = eval(ss.encode())
    if type(val) is int:
      fmt += f" {hex(val)}"
    elif type(val) is str or type(val) is bytes:
      fmt += f" {val}"
  except NameError:
    fmt = fmt.rstrip(":")
  print(cs + fmt + ce)

def pQ(x): return p64(x)
def p(x): return p32(x)
def uQ(x): return u64(x)
def u(x): return u32(x)

def mkasm(code):
  # apt install -y nasm
  open('/tmp/asm.s','w').write(code)
  cmd =  '   nasm -fbin /tmp/asm.s -l/tmp/asm.lst -o /tmp/asm.bin'
  cmd += ' && rm -f /tmp/asm.s /tmp/asm.lst'
  p = subprocess.run([cmd], shell=True)
  if p.returncode != 0: 
    print(f"Aborted!: assemble error {p.returncode}, {p.stderr}")
    sys.exit(1)
  buf = open('/tmp/asm.bin','rb').read()
  return buf
 
##### addrs/offsets of symbols, gadgets and consts #####
is_remote = len(sys.argv) > 1 and sys.argv[1] == 'r'

if is_remote:
  s = Socket("nc challenge.server.com 1337")
else:
  s = Socket('127.0.0.1', 1337)

### exploit from here ###


s.interactive()
