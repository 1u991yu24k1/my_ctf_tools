#!/usr/bin/python3
#-*-coding:utf-8-*-

import socket, telnetlib, struct, hexdump, subprocess, sys, logging, time

logging.basicConfig(level=logging.DEBUG, format="%(message)s")
cs, ce = '\x1b[93;41m', '\x1b[0m' # white

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

def inf(ss):
  logging.info("[*] %s"%ss)

def sock(host, port):
  s = socket.create_connection((host, port))
  return s, s.makefile('rwb', buffering=None)

def read_until(f, delim=b'\n',textwrap=False):
  if type(delim) is str: delim = delim.encode()
  dat = b''
  while not dat.endswith(delim): dat += f.read(1)
  return dat if not textwrap else dat.decode()

def readline_after(f, skip_until, delim=b'\n'):
  _ = read_until(f, skip_until)
  if type(delim) is str: delim = delim.encode()
  return read_until(f, delim).strip(delim)

def sendline(f, line):
  if type(line) is str: line = (line + '\n').encode()
  f.write(line) # no tailing LF in bytes
  f.flush()

def sendline_after(f, waitfor, line):
  read_until(f, waitfor)
  sendline(f, line)

def skips(f, nr):
  for i in range(nr): read_until(f) 
   
def pQ(a): return struct.pack('<Q', a&0xffffffffffffffff)
def uQ(a): return struct.unpack('<Q', a.ljust(8, b'\x00'))[0]

def shell(s):
  t = telnetlib.Telnet()
  t.sock = s
  t.interact()
    

##### addrs/offsets of symbols, gadgets and consts #####
       
banner, HOST, PORT = 'test', '127.0.0.1', 1337 
if len(sys.argv) == 2 and sys.argv[1] == 'r':
  banner = 'remote'
  HOST, PORT = '<remote-host>', 1337

logging.info(banner)
s, f = sock(HOST, PORT)
### exploit from here ###


### end of exploit ###
shell(s)
