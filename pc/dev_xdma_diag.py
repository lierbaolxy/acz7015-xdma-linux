#!/usr/bin/env python3
# 诊断：XDMA c2h_0 读 DDR 槽位是否阻塞/返回
import ctypes
from ctypes import wintypes
import struct
import time
import threading
import sys

sys.path.insert(0, r'd:\workspace\trae\day01\0702\acz7015-xdma-linux\pc')
import win_mouse_receiver as w

DDR_BASE = 0x20000000

def open_c2h():
    p = w.find_xdma_device_path()
    print(f"device path: {p}")
    h = w.open_xdma_c2h(p)
    print(f"handle: {h} (valid={h is not None and h != ctypes.c_void_p(-1).value})")
    return h

def read_with_timeout(h, addr, timeout_s=5):
    buf = (ctypes.c_ubyte * 64)()
    got = wintypes.DWORD(0)
    result = {}

    def worker():
        t0 = time.time()
        ok = w.kernel32.SetFilePointerEx(h, ctypes.c_longlong(addr), None, 0)
        ok2 = w.kernel32.ReadFile(h, buf, 64, ctypes.byref(got), None)
        result['setptr'] = bool(ok)
        result['read'] = bool(ok2)
        result['bytes'] = got.value
        result['elapsed'] = time.time() - t0
        result['data'] = bytes(buf)

    t = threading.Thread(target=worker, daemon=True)
    t.start()
    t.join(timeout_s)
    if t.is_alive():
        return {'timeout': True}
    return result

h = open_c2h()

print("\n=== 读 USB 槽位 0x20000000 ===")
r = read_with_timeout(h, DDR_BASE + 0x00)
print("result:", r)
if not r.get('timeout') and r.get('data') is not None:
    seq, dev, dlen, res = struct.unpack_from('<IIII', r['data'], 0)
    print(f"  seq={seq} device_id={dev} data_len={dlen} reserved={res}")
    print(f"  data={r['data'][0x10:0x18].hex()}")

print("\n=== 读 RS422 槽位 0x20000060 ===")
r2 = read_with_timeout(h, DDR_BASE + 0x60)
print("result:", r2)
if not r2.get('timeout') and r2.get('data') is not None:
    seq, dev, dlen, res = struct.unpack_from('<IIII', r2['data'], 0)
    print(f"  seq={seq} device_id={dev} data_len={dlen} reserved={res}")

w.kernel32.CloseHandle(h)
print("\nDONE")