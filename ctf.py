#!/usr/bin/python3
#-*-coding:utf-8-*-

import socket, telnetlib, struct, sys, logging, signal, functools

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

def timeout(func):
  def handler(signum, frame):
    raise TimeoutError

  @functools.wraps(func)
  def wrapper(*args, **kwargs):
    __TIMEOUT__ = 3
    try:
      signal.signal(signal.SIGALRM, handler) 
      signal.alarm(__TIMEOUT__)
      ret = func(*args, **kwargs)
      signal.alarm(0) 
      return ret
    except TimeoutError:
      print(f"[!] Timeout-ed in {func.__name__}({args}, {kwargs})")
      sys.exit(1)
  return wrapper

def sock(host, port):
  s = socket.create_connection((host, port))
  return s, s.makefile('rwb', buffering=None)

def sendline(f, line, taillf=True):
  if type(line) is str: 
    line = line.encode()
  if taillf:
    line = line + b'\n'
  
  f.write(line) 
  f.flush()

@timeout
def readuntil(f, delim=b'\n', strip_delim=False, textwrap=False):
  if type(delim) is str: 
    delim = delim.encode()
  dat = b''
  while not dat.endswith(delim): 
    dat += f.read(1)
  dat = dat.rstrip(delim) if strip_delim else dat
  dat = dat.decode() if textwrap else dat
  return dat

@timeout
def readline_after(f, skip_until, delim=b'\n', strip_delim=True, textwrap=False):
  _ = readuntil(f, skip_until)
  if type(delim) is str: 
    delim = delim.encode()
  return readuntil(f, delim, strip_delim, textwrap)

@timeout
def sendline_after(f, waitfor, line):
  readuntil(f, waitfor)
  sendline(f, line)

@timeout
def skips(f, nr):
  for i in range(nr): 
    readuntil(f) 
   
def pQ(a): return struct.pack('<Q', a&0xffffffffffffffff)
def p(a): return struct.pack('<I', a&0xffffffff)
def uQ(a): return struct.unpack('<Q', a.ljust(8, b'\x00'))[0]
def u(a): return struct.pack('<I', a.ljust(4, b'\x00'))[0]

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
