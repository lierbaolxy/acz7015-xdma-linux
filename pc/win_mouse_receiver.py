#!/usr/bin/env python3
"""
PC Windows侧：USB鼠标数据接收程序
功能：通过XDMA轮询读取DDR共享内存，检测鼠标事件并显示
运行：python win_mouse_receiver.py

依赖：Xilinx XDMA Windows驱动已安装
"""
import ctypes
from ctypes import wintypes
import struct
import sys
import time

# DDR共享内存物理地址
DDR_BASE = 0x20000000

# 共享内存结构偏移（和arm_mouse_sender.c一致）
# OFF_SEQ=0x00, OFF_TYPE=0x04, OFF_CODE=0x08, OFF_VALUE=0x0C, OFF_TV_SEC=0x10, OFF_TV_NSEC=0x14
DMA_BUF_SIZE = 24  # 6个32位字段

# Linux input事件类型
EV_SYN = 0x00
EV_KEY = 0x01
EV_REL = 0x02

# 按键代码
BTN_LEFT   = 0x110
BTN_RIGHT  = 0x111
BTN_MIDDLE = 0x112

# 相对位移代码
REL_X      = 0x00
REL_Y      = 0x01
REL_WHEEL  = 0x08

# Windows API
kernel32 = ctypes.windll.kernel32

GENERIC_READ  = 0x80000000
OPEN_EXISTING = 3
FILE_ATTRIBUTE_NORMAL = 0x80
INVALID_HANDLE_VALUE = ctypes.c_void_p(-1).value

# 函数原型
kernel32.CreateFileA.restype = wintypes.HANDLE
kernel32.CreateFileA.argtypes = [ctypes.c_char_p, wintypes.DWORD, wintypes.DWORD, ctypes.c_void_p, wintypes.DWORD, wintypes.DWORD, wintypes.HANDLE]
kernel32.ReadFile.restype = wintypes.BOOL
kernel32.ReadFile.argtypes = [wintypes.HANDLE, ctypes.c_void_p, wintypes.DWORD, ctypes.POINTER(wintypes.DWORD), ctypes.c_void_p]
kernel32.SetFilePointerEx.restype = wintypes.BOOL
kernel32.SetFilePointerEx.argtypes = [wintypes.HANDLE, ctypes.c_longlong, ctypes.POINTER(ctypes.c_longlong), wintypes.DWORD]
kernel32.CloseHandle.restype = wintypes.BOOL
kernel32.CloseHandle.argtypes = [wintypes.HANDLE]


def find_xdma_device_path():
    """从xdma_info.exe输出解析设备路径"""
    import subprocess
    xdma_info = r"G:\fpga\0708\111\盘C_基于Verilog的FPGA逻辑设计与验证视频课程\04_高速收发器原理与应用教程\06_基于XDMA的PCIE应用系统\工程\XDMA\xdma_driver_win_bin_x64_2017_4\x64\bin\xdma_info.exe"
    try:
        result = subprocess.run([xdma_info], capture_output=True, text=True, timeout=5)
        for line in result.stdout.split('\n'):
            if 'device path' in line.lower():
                path = line.split(':', 1)[1].strip()
                return path
    except Exception as e:
        print(f"运行xdma_info.exe失败: {e}")
    return None


def open_xdma_c2h(base_path):
    """打开XDMA C2H设备（Card to Host，PC读取DDR）"""
    full_path = f"{base_path}\\c2h_0"
    handle = kernel32.CreateFileA(full_path.encode('ascii'), GENERIC_READ, 0, None, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, None)
    return handle if handle != INVALID_HANDLE_VALUE else None


def read_ddr(handle):
    """从DDR读取24字节共享内存数据"""
    buf = (ctypes.c_ubyte * DMA_BUF_SIZE)()
    bytes_read = wintypes.DWORD(0)
    kernel32.SetFilePointerEx(handle, DDR_BASE, None, 0)
    if not kernel32.ReadFile(handle, buf, DMA_BUF_SIZE, ctypes.byref(bytes_read), None):
        return None
    return bytes(buf[:bytes_read.value])


def parse_data(data):
    """解析DDR数据，返回(seq, type, code, value, tv_sec, tv_nsec)"""
    if data is None or len(data) < 24:
        return None
    # value用有符号int32（鼠标位移可为负），其余无符号
    return struct.unpack_from('<IIIiII', data, 0)


def ev_type_name(typ):
    names = {EV_SYN: "SYN", EV_KEY: "KEY", EV_REL: "REL"}
    return names.get(typ, f"0x{typ:X}")


def ev_code_name(typ, code):
    if typ == EV_KEY:
        names = {BTN_LEFT: "左键", BTN_RIGHT: "右键", BTN_MIDDLE: "中键"}
        return names.get(code, f"键0x{code:X}")
    if typ == EV_REL:
        names = {REL_X: "X轴", REL_Y: "Y轴", REL_WHEEL: "滚轮"}
        return names.get(code, f"轴0x{code:X}")
    return "-"


def format_value(typ, code, val):
    if typ == EV_KEY:
        return "按下" if val == 1 else "松开"
    if typ == EV_REL:
        if code == REL_WHEEL:
            return f"{'上' if val > 0 else '下'}({val})"
        return str(val)
    return str(val)


def main():
    print("=== PC端鼠标数据接收程序 ===\n")

    # 查找XDMA设备
    print("查找XDMA设备...")
    base_path = find_xdma_device_path()
    if base_path is None:
        print("未找到XDMA设备！请确认驱动已安装")
        input("按回车退出...")
        return 1
    print(f"设备路径: {base_path}")

    # 打开C2H设备
    h_c2h = open_xdma_c2h(base_path)
    if h_c2h is None:
        print("打开 c2h_0 失败！")
        input("按回车退出...")
        return 1
    print("C2H设备打开成功\n")

    # 读初始序号
    last_seq = 0
    data = read_ddr(h_c2h)
    if data:
        parsed = parse_data(data)
        if parsed:
            last_seq = parsed[0]
            print(f"初始序号: {last_seq}")

    count = 0
    # 时钟偏差校准值（首次收到事件时自动设置基准）
    clock_offset = None

    print("等待鼠标事件... (动鼠标试试，Ctrl+C退出)\n")
    print("序号    | 类型 | 代码  | 值   | 延时(us) | 开发板时间戳")
    print("-" * 70)

    try:
        while True:
            data = read_ddr(h_c2h)
            if data is None:
                continue

            parsed = parse_data(data)
            if parsed is None:
                continue

            seq, typ, code, val, tv_sec, tv_nsec = parsed

            # 检测序号变化
            if seq != last_seq:
                last_seq = seq
                if seq > 0:
                    count += 1
                    type_str = ev_type_name(typ)
                    code_str = ev_code_name(typ, code)
                    val_str = format_value(typ, code, val)

                    # PC收到时间（Unix时间戳，秒）
                    pc_time = time.time()
                    # 开发板事件时间戳（秒）
                    arm_time = tv_sec + tv_nsec / 1e9

                    # 首次校准时钟偏差（假设首次延时为0，后续测量相对延时）
                    if clock_offset is None:
                        clock_offset = pc_time - arm_time

                    # 相对延时 = (PC收到时间 - 开发板发送时间) - 时钟偏差
                    latency_us = (pc_time - arm_time - clock_offset) * 1e6

                    ts_str = f"{tv_sec}.{tv_nsec // 1000000:03d}"
                    print(f"#{seq:<6d}| {type_str:<4s} | {code_str:<5s} | {val_str:<5s} | {latency_us:8.0f} | {ts_str}")

    except KeyboardInterrupt:
        print(f"\n\n退出，共收到 {count} 个鼠标事件")

    kernel32.CloseHandle(h_c2h)
    return 0


if __name__ == "__main__":
    sys.exit(main())
