#!/usr/bin/env python3
#-*-coding:utf-8-*-

from ptrlib import *

def dbg(ss):
  fmt = f"{ss}:"
  try:
    val = eval(ss.encode())
    if type(val) is int:
      fmt += f" {hex(val)}"
    elif type(val) is str or type(val) is bytes:
      fmt += f" {val}"
  except NameError:
    fmt = fmt.rstrip(":")
  logging.debug(cs + fmt + ce)

  
def pQ(a): return struct.pack('<Q', a&0xffffffffffffffff)
def p(a): return struct.pack('<I', a&0xffffffff)
def uQ(a): return struct.unpack('<Q', a.ljust(8, b'\x00'))[0]
def u(a): return struct.unpack('<I', a.ljust(4, b'\x00'))[0]

def rol(x, rotate, bitwidth=64):
  assert rotate < bitwidth
  """
  rotate left in bitwidth 
  ex. 
    0x11223344 -> 0x22334411 (8bit rotate left @32bit)
    0x1122334455667788 -> 0x3344556677881122 (16bit rotate left @64bit) 
  """
  word_mask = (1 << bitwidth) - 1
  right_mask = (1 << (bitwidth - rotate)) - 1
  left = x&(word_mask - right_mask)
  left >>= (bitwidth - rotate)
  return ((x << rotate)&word_mask) | left

def ror(x, rotate, bitwidth=64):
  assert rotate < bitwidth
  """
  rotate right in bitwidth 
  0x11223344 -> 0x44112233 (8bit rotate right @32bit)
  0x1122334455667788 -> 0x7788112233445566 (16bit rotate right @64bit)
  """
  word_mask = (1 << bitwidth) - 1
  right_mask = (1 << rotate) - 1
  right = (x&right_mask)
  shifter = bitwidth - rotate
  return (right << shifter) | ((x >> rotate)&word_mask)

   

##### addrs/offsets of symbols, gadgets and consts #####
is_remote = len(sys.argv) > 1 and sys.argv[1] == 'r'

if is_remote:
  s = Socket("")
else:
  s = Socket('127.0.0.1', 1337)

### exploit from here ###


s.interactive()
