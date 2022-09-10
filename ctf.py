#!/usr/bin/python3
#-*-coding:utf-8-*-

import socket, telnetlib, struct, sys, logging 

logging.basicConfig(level=logging.DEBUG, format="[*] %(message)s")
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
  logging.info("%s"%ss)

def sock(host, port):
  s = socket.create_connection((host, port))
  return s, s.makefile('rwb', buffering=None)

def readuntil(f, delim=b'\n',textwrap=False):
  if type(delim) is str: 
    delim = delim.encode()
  dat = b''
  while not dat.endswith(delim): 
    dat += f.read(1)
  return dat if not textwrap else dat.decode()

def readline_after(f, skip_until, delim=b'\n'):
  _ = readuntil(f, skip_until)
  if type(delim) is str: 
    delim = delim.encode()
  return readuntil(f, delim).strip(delim)

def sendline(f, line, nolf=False):
  if type(line) is str: 
    line = line.encode()
  if not nolf:
    line = line + b'\n'
  f.write(line) 
  f.flush()

def sendline_after(f, waitfor, line):
  readuntil(f, waitfor)
  sendline(f, line)

def skips(f, nr):
  for i in range(nr): 
    readuntil(f) 
   
def pQ(a): return struct.pack('<Q', a&0xffffffffffffffff)
def uQ(a): return struct.unpack('<Q', a.ljust(8, b'\x00'))[0]

def shell(s):
  t = telnetlib.Telnet()
  t.sock = s
  t.interact()
    

##### addrs/offsets of symbols, gadgets and consts #####
HOST, PORT = '127.0.0.1', 1337 
banner = 'local-> %s %d'%(HOST, PORT) 
if len(sys.argv) == 2 and sys.argv[1] == 'r':
  HOST, PORT = '<remote-host>', 1337
  banner = 'remote-> %s %d'%(HOST, PORT)

inf(banner)
s, f = sock(HOST, PORT)
### exploit from here ###


shell(s)
