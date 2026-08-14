#!/usr/bin/env python3
"""
PC Windows侧：USB鼠标延时测试程序（直接CreateFile访问XDMA设备）
功能：通过XDMA DMA读写DDR共享内存，乒乓法测延时
运行：python win_xdma_latency_v3.py [测试次数]

依赖：Xilinx XDMA Windows驱动已安装
"""
import ctypes
from ctypes import wintypes
import struct
import time
import sys

# DDR共享内存物理地址
DDR_BASE = 0x20000000

# 共享内存寄存器偏移
OFF_REQ_SEQ    = 0x00
OFF_RSP_SEQ    = 0x04
OFF_MOUSE_DATA = 0x08
OFF_TS_LO      = 0x0C
OFF_TS_HI      = 0x10

# DMA传输缓冲区大小
DMA_BUF_SIZE = 64

# Windows API
kernel32 = ctypes.windll.kernel32
setupapi = ctypes.windll.setupapi

GENERIC_READ  = 0x80000000
GENERIC_WRITE = 0x40000000
OPEN_EXISTING = 3
FILE_ATTRIBUTE_NORMAL = 0x80
INVALID_HANDLE_VALUE = ctypes.c_void_p(-1).value

DIGCF_PRESENT = 2
DIGCF_DEVICEINTERFACE = 16

# XDMA设备接口GUID（从xdma_info.exe输出获取）
GUID_DEVINTERFACE_XDMA = "{74c7e4a9-6d5d-4a70-bc0d-20691dff9e9d}"

# 定义结构体
class GUID(ctypes.Structure):
    _fields_ = [("Data1", ctypes.c_ulong),
                ("Data2", ctypes.c_ushort),
                ("Data3", ctypes.c_ushort),
                ("Data4", ctypes.c_ubyte * 8)]

class SP_DEVICE_INTERFACE_DATA(ctypes.Structure):
    _fields_ = [("cbSize", ctypes.c_ulong),
                ("InterfaceClassGuid", GUID),
                ("Flags", ctypes.c_ulong),
                ("Reserved", ctypes.c_void_p)]

class SP_DEVICE_INTERFACE_DETAIL_DATA_A(ctypes.Structure):
    _fields_ = [("cbSize", ctypes.c_ulong),
                ("DevicePath", ctypes.c_char * 512)]

# 函数原型
kernel32.CreateFileA.restype = wintypes.HANDLE
kernel32.CreateFileA.argtypes = [ctypes.c_char_p, wintypes.DWORD, wintypes.DWORD, ctypes.c_void_p, wintypes.DWORD, wintypes.DWORD, wintypes.HANDLE]
kernel32.ReadFile.restype = wintypes.BOOL
kernel32.ReadFile.argtypes = [wintypes.HANDLE, ctypes.c_void_p, wintypes.DWORD, ctypes.POINTER(wintypes.DWORD), ctypes.c_void_p]
kernel32.WriteFile.restype = wintypes.BOOL
kernel32.WriteFile.argtypes = [wintypes.HANDLE, ctypes.c_void_p, wintypes.DWORD, ctypes.POINTER(wintypes.DWORD), ctypes.c_void_p]
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
                # 格式: "device path:    \\?\pci#ven_10ee..."
                path = line.split(':', 1)[1].strip()
                return path
    except Exception as e:
        print(f"运行xdma_info.exe失败: {e}")
    return None

def open_xdma_subdev(base_path, subdev, access):
    """打开XDMA子设备"""
    full_path = f"{base_path}\\{subdev}"
    handle = kernel32.CreateFileA(full_path.encode('ascii'), access, 0, None, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, None)
    return handle if handle != INVALID_HANDLE_VALUE else None

def read_ddr(h_c2h, offset, size=DMA_BUF_SIZE):
    """从DDR读取数据"""
    buf = (ctypes.c_ubyte * size)()
    bytes_read = wintypes.DWORD(0)
    kernel32.SetFilePointerEx(h_c2h, DDR_BASE, None, 0)
    if not kernel32.ReadFile(h_c2h, buf, size, ctypes.byref(bytes_read), None):
        return None
    return bytes(buf[:bytes_read.value])

def write_ddr(h_h2c, h_c2h, offset, value):
    """写DDR指定偏移的32位数据"""
    # 先读当前数据
    data = read_ddr(h_c2h, offset)
    if data is None:
        return False
    buf = bytearray(data)
    struct.pack_into('<I', buf, offset, value)
    write_buf = (ctypes.c_ubyte * DMA_BUF_SIZE)(*buf)
    bytes_written = wintypes.DWORD(0)
    kernel32.SetFilePointerEx(h_h2c, DDR_BASE, None, 0)
    return kernel32.WriteFile(h_h2c, write_buf, DMA_BUF_SIZE, ctypes.byref(bytes_written), None)

def read_reg(h_c2h, offset):
    """读32位寄存器"""
    data = read_ddr(h_c2h, offset)
    if data is None or len(data) < offset + 4:
        return None
    return struct.unpack_from('<I', data, offset)[0]

def get_time_us():
    """高精度时间戳（微秒）"""
    freq = ctypes.c_longlong(0)
    count = ctypes.c_longlong(0)
    kernel32.QueryPerformanceFrequency(ctypes.byref(freq))
    kernel32.QueryPerformanceCounter(ctypes.byref(count))
    return count.value / freq.value * 1000000.0

def main():
    test_count = 100
    if len(sys.argv) > 1:
        test_count = int(sys.argv[1])
        if test_count <= 0 or test_count > 10000:
            test_count = 100

    print("=== PC端XDMA延时测试程序 (直接CreateFile版) ===\n")

    # 查找XDMA设备路径
    print("查找XDMA设备...")
    base_path = find_xdma_device_path()
    if base_path is None:
        print("未找到XDMA设备！请确认驱动已安装")
        return 1
    print(f"设备路径: {base_path}")

    # 打开C2H和H2C设备
    h_c2h = open_xdma_subdev(base_path, "c2h_0", GENERIC_READ)
    if h_c2h is None:
        print("打开 c2h_0 失败")
        return 1
    h_h2c = open_xdma_subdev(base_path, "h2c_0", GENERIC_WRITE)
    if h_h2c is None:
        print("打开 h2c_0 失败")
        kernel32.CloseHandle(h_c2h)
        return 1
    print("C2H/H2C设备打开成功\n")

    # 测试读取
    print("测试读取DDR...")
    data = read_ddr(h_c2h, 0)
    if data is None:
        print("读取DDR失败！")
        kernel32.CloseHandle(h_c2h)
        kernel32.CloseHandle(h_h2c)
        return 1
    print(f"读取成功，{len(data)}字节")
    req = read_reg(h_c2h, OFF_REQ_SEQ)
    rsp = read_reg(h_c2h, OFF_RSP_SEQ)
    print(f"  REQ_SEQ={req}, RSP_SEQ={rsp}\n")

    # 初始化共享内存
    write_ddr(h_h2c, h_c2h, OFF_REQ_SEQ, 0)
    write_ddr(h_h2c, h_c2h, OFF_RSP_SEQ, 0)
    time.sleep(0.1)

    print(f"开始乒乓法延时测试（{test_count}次）...")
    print("每次：PC写请求 → 开发板响应 → PC读到响应\n")

    latencies = []
    req_seq = 0

    for i in range(test_count):
        req_seq += 1
        t1 = get_time_us()
        write_ddr(h_h2c, h_c2h, OFF_REQ_SEQ, req_seq)

        # 轮询等待响应
        retry = 0
        read_rsp = 0
        while read_rsp != req_seq:
            read_rsp = read_reg(h_c2h, OFF_RSP_SEQ)
            if read_rsp is None:
                read_rsp = 0
            retry += 1
            if retry > 100000:
                print(f"[第{i+1}次] 超时！开发板未响应（请确认开发板程序正在运行）")
                break

        t2 = get_time_us()
        latency = t2 - t1

        if retry <= 100000:
            latencies.append(latency)
            if (i + 1) % 10 == 0 or i < 5:
                print(f"[第{i+1}次] 往返={latency:.1f}us 单程={latency/2:.1f}us (轮询{retry}次)")

    # 统计结果
    if latencies:
        print("\n========== 延时统计结果 ==========")
        print(f"测试次数: {len(latencies)}")
        avg = sum(latencies) / len(latencies)
        print(f"平均往返延时: {avg:.1f} us ({avg/1000:.2f} ms)")
        print(f"平均单程延时: {avg/2:.1f} us ({avg/2000:.2f} ms)")
        print(f"最小单程延时: {min(latencies)/2:.1f} us")
        print(f"最大单程延时: {max(latencies)/2:.1f} us")
        print("===================================")

        # 读当前鼠标数据
        mouse_data = read_reg(h_c2h, OFF_MOUSE_DATA)
        ts_lo = read_reg(h_c2h, OFF_TS_LO)
        ts_hi = read_reg(h_c2h, OFF_TS_HI)
        print(f"\n当前DDR共享内存状态:")
        if mouse_data is not None:
            print(f"  鼠标数据: 0x{mouse_data:08X} (type={(mouse_data>>16)&0xFFFF} code={mouse_data&0xFFFF})")
        if ts_hi is not None and ts_lo is not None:
            print(f"  开发板时间戳: {ts_hi}.{ts_lo}")
    else:
        print("\n所有测试超时，请确认开发板程序正在运行")
        print("开发板上运行: sudo ./arm_mouse_latency")

    kernel32.CloseHandle(h_c2h)
    kernel32.CloseHandle(h_h2c)
    print("\n按回车退出...")
    input()
    return 0

if __name__ == "__main__":
    sys.exit(main())
