
import os, mmap, stat

class CountMap:

  def __init__(self, fn):
    self.file_len=os.stat(fn)[stat.ST_SIZE]
    self.fp=open(fn, 'rb')
    self.map=mmap.mmap(self.fp.fileno(), self.file_len, prot=mmap.PROT_READ)

  def cnt(self, pos):
    self.map.seek(pos)
    v=self.map.read_byte()
    v=ord(v)
    return v

