#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ACZ7015 CAN数据接收程序（PC端）
功能：通过XDMA从DDR共享内存读取CAN数据（device_id=1，槽位0x20000020）
协议依据：d:/workspace/trae/day01/0702/protocol_spec.md
依赖：pywin32（ctypes调用Win32 API）
用法：python -u win_can_receiver.py
"""

import ctypes
import struct
import time
import sys
import os

# ========== 协议规范定义 ==========
DDR_BASE = 0x20000000
SLOT_SIZE = 32
SLOT_CAN = 0x20          # CAN槽位偏移
DEV_CAN = 1              # CAN的device_id

# ========== XDMA设备GUID ==========
XDMA_GUID = "{74c7e4a9-6d5d-4a70-bc0d-20691dff9e9d}"
GENERIC_READ = 0x80000000
GENERIC_WRITE = 0x40000000
OPEN_EXISTING = 0x3
FILE_ATTRIBUTE_NORMAL = 0x80
INVALID_HANDLE_VALUE = ctypes.c_void_p(-1).value

# ========== Win32 API ==========
kernel32 = ctypes.windll.kernel32
CreateFileA = kernel32.CreateFileA
ReadFile = kernel32.ReadFile
WriteFile = kernel32.WriteFile
CloseHandle = kernel32.CloseHandle
SetFilePointerEx = kernel32.SetFilePointerEx
DeviceIoControl = kernel32.DeviceIoControl

# ========== 槽位解析 ==========
def parse_slot(data):
    """解析32字节槽位，返回(seq, device_id, data_len, reserved, data_payload, tv_sec, tv_nsec)"""
    if len(data) < SLOT_SIZE:
        return None
    seq, device_id, data_len, reserved = struct.unpack_from('<IIII', data, 0)
    data_payload = data[0x10:0x18]  # 8字节data
    tv_sec, tv_nsec = struct.unpack_from('<II', data, 0x18)
    return seq, device_id, data_len, reserved, data_payload, tv_sec, tv_nsec

def format_can_payload(data, data_len):
    """格式化CAN数据内容"""
    if data_len < 3:
        return f"无效(data_len={data_len})"

    can_id = data[0] | (data[1] << 8)
    dlc = data[2]
    can_data = data[3:3+min(dlc, 5)]

    hex_data = ' '.join(f'{b:02X}' for b in can_data)
    return f"CAN ID=0x{can_id:04X} DLC={dlc} Data=[{hex_data}]"

# ========== XDMA设备查找 ==========
def find_xdma_device():
    """查找XDMA设备路径"""
    import win32com.client
    try:
        wmi = win32com.client.GetObject("winmgmts:")
        devices = wmi.InstancesOf("Win32_PnPEntity")
        for dev in devices:
            if dev.DeviceID and "VEN_10EE" in str(dev.DeviceID).upper():
                guid_path = str(dev.DeviceID)
                if "{" in guid_path:
                    return f"\\\\?\\{guid_path.lower()}"
    except:
        pass

    # 备用：硬编码路径
    base = r"\\?\pci#ven_10ee&dev_7021&subsys_000710ee&rev_00#4&3d70c87&0&00e0"
    return f"{base}#{XDMA_GUID}"

# ========== DDR读取 ==========
def read_can_slot(handle):
    """从DDR读取CAN槽位（读64字节对齐，取前32字节）"""
    buf = (ctypes.c_ubyte * 64)()
    bytes_read = ctypes.c_ulong(0)

    # 设置偏移到CAN槽位
    offset = DDR_BASE + SLOT_CAN
    pos = ctypes.c_longlong(offset)
    if not SetFilePointerEx(handle, pos, None, 0):  # FILE_BEGIN
        return None

    # 读64字节
    if not ReadFile(handle, buf, 64, ctypes.byref(bytes_read), None):
        return None
    if bytes_read.value < SLOT_SIZE:
        return None

    return bytes(buf[:SLOT_SIZE])

# ========== 主函数 ==========
def main():
    print("=== PC端CAN数据接收程序 V2（协议标准格式）===")
    print(f"协议依据：d:/workspace/trae/day01/0702/protocol_spec.md\n")

    # 查找XDMA设备
    print("查找XDMA设备...")
    device_path = find_xdma_device()
    c2h_path = f"{device_path}\\c2h_0"
    print(f"C2H设备路径: {c2h_path}")

    # 打开C2H设备
    handle = CreateFileA(
        c2h_path.encode('ascii'),
        GENERIC_READ,
        0, None,
        OPEN_EXISTING,
        FILE_ATTRIBUTE_NORMAL, None
    )
    if handle == INVALID_HANDLE_VALUE:
        print("C2H设备打开失败")
        return 1
    print("C2H设备打开成功\n")

    # 读取初始序号
    data = read_can_slot(handle)
    if data:
        slot = parse_slot(data)
        if slot:
            print(f"CAN槽位初始序号: {slot[0]}")

    print("等待CAN数据... (发CAN帧试试，Ctrl+C退出)\n")
    print(f"{'序号':<8}| {'接口':<5}| {'数据内容':<45}| {'延时(us)':<10}| 开发板时间戳")
    print("-" * 100)

    last_seq = 0
    if data:
        slot = parse_slot(data)
        if slot:
            last_seq = slot[0]

    clock_offset = None
    try:
        while True:
            data = read_can_slot(handle)
            if not data:
                continue

            slot = parse_slot(data)
            if not slot:
                continue

            seq, device_id, data_len, reserved, data_payload, tv_sec, tv_nsec = slot

            if seq != last_seq:
                last_seq = seq

                # 计算延时
                pc_time = time.time()
                arm_time = tv_sec + tv_nsec / 1e9
                if clock_offset is None:
                    clock_offset = pc_time - arm_time
                latency_us = (pc_time - arm_time - clock_offset) * 1e6

                # 格式化显示
                dev_name = "CAN" if device_id == DEV_CAN else f"DEV{device_id}"
                content = format_can_payload(data_payload, data_len)
                ts_str = f"{tv_sec}.{tv_nsec // 1000000:03d}"

                print(f"#{seq:<7}| {dev_name:<5}| {content:<45}| {latency_us:>8.0f} | {ts_str}")

    except KeyboardInterrupt:
        print("\n退出")
    finally:
        CloseHandle(handle)

if __name__ == "__main__":
    sys.exit(main())
