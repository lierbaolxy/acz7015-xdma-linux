import sys
import time

sys.path.insert(0, r'd:\workspace\trae\day01\0702\acz7015-xdma-linux\pc')
import win_mouse_receiver as wr

base = wr.find_xdma_device_path()
print('XDMA 设备路径:', base)
if not base:
    print('!! 未找到 XDMA 设备')
    sys.exit(1)

h = wr.open_xdma_c2h(base)
if h in (None, wr.INVALID_HANDLE_VALUE):
    print('!! 打开 c2h_0 失败')
    sys.exit(1)
print('c2h_0 打开成功\n')

print('读取 20 次（300ms 间隔），观察 seq 是否递增：')
last = None
for i in range(20):
    data = wr.read_slot(h, wr.SLOT_USB)
    if data is None:
        print(f'[{i:02d}] read 返回 None')
    else:
        seq, dev, dlen, payload, sec, nsec = wr.parse_slot(data)
        hexstr = ' '.join(f'{b:02X}' for b in data)
        delta = ('-' if last is None else str(seq - last))
        print(f'[{i:02d}] seq={seq:8d} (Δ{delta:>3}) dev={dev} len={dlen} | {hexstr}')
        last = seq
    time.sleep(0.3)

wr.kernel32.CloseHandle(h)
print('\nDONE')