#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ACZ7015 CAN 数据接收程序（PC 端）

功能：通过 XDMA 从 DDR 共享内存读取 CAN 槽位（device_id=1，槽位 0x20000020），
      解析 A825/ARINC825 29 位扩展帧并显示。
协议依据：fpga_project/docs/can_protocol_spec.md
  - 500kbps，29 位扩展帧（ID 0x01180115 ~ 0x01180119）
  - 接收 4 种帧，发送 1 种帧

CAN 槽位编码（与 arm_can_sender.c 的 write_can_to_ddr 严格对应）：
  data[0..3] = CAN ID（uint32 小端，29 位）
  data[4..7] = CAN 数据 data[0..3]
  reserved[0..1] = CAN 数据 data[4..5]（仅 data_len > 4 时）
  data_len    = CAN DLC

复用 win_mouse_receiver 的成熟 XDMA 层（SetupAPI 枚举 + 同步 I/O）。

用法：python -u win_can_receiver.py
""" 
import ctypes
import struct
import time
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import win_mouse_receiver as wm   # 复用 XDMA 层

# ===== CAN 槽位配置 =====
SLOT_CAN = 0x20          # 0x20000020
DEV_CAN  = 1

# ===== 协议帧 ID（29 位扩展帧）=====
CAN_ID_TRACKBALL = 0x01180118  # 轨迹球数据（4B）
CAN_ID_VER_QUERY = 0x01180119  # 版本查询（发送，通常本侧不主动收）
CAN_ID_VER_REPLY = 0x01180117  # 版本回复（3B）
CAN_ID_PBIT      = 0x01180116  # 上电 PBIT（6B ×5）
CAN_ID_MODEL     = 0x01180115  # 设备型号（6B ×3）

CAN_ID_NAMES = {
    CAN_ID_TRACKBALL: "轨迹球数据",
    CAN_ID_VER_QUERY: "版本查询",
    CAN_ID_VER_REPLY: "版本回复",
    CAN_ID_PBIT:      "上电PBIT",
    CAN_ID_MODEL:     "设备型号",
}


def parse_can_slot(data):
    """解析 32 字节 CAN 槽位，返回 (seq, can_id, dlc, can_data_bytes)。"""
    if data is None or len(data) < 32:
        return None
    seq, dev_id, dlc, reserved = struct.unpack_from('<IIII', data, 0)
    if dev_id != DEV_CAN:
        return None
    payload = data[0x10:0x18]   # 8 字节 data

    # 29 位扩展帧 ID（4 字节小端）
    can_id = payload[0] | (payload[1] << 8) | (payload[2] << 16) | (payload[3] << 24)
    can_id &= 0x1FFFFFFF

    # CAN 数据：data[4..7] + reserved 低 2 字节（DLC>4 时补齐）
    can_data = list(payload[4:8])
    if dlc > 4:
        can_data += [reserved & 0xFF, (reserved >> 8) & 0xFF]
    can_data = can_data[:dlc if dlc > 0 else 0]

    return seq, can_id, dlc, can_data


def format_trackball_data(b):
    """解析轨迹球数据帧（0x01180118，4 字节位域）。"""
    if len(b) < 4:
        return "数据不足"
    raw = b[0] | (b[1] << 8) | (b[2] << 16) | (b[3] << 24)
    right = (raw >> 0) & 0x1
    left  = (raw >> 1) & 0x1
    y = (raw >> 2) & 0xFF
    x = (raw >> 10) & 0xFF
    wheel = (raw >> 18) & 0xFF
    # 有符号 8 位位移
    if x & 0x80: x -= 256
    if y & 0x80: y -= 256
    if wheel & 0x80: wheel -= 256
    return f"X={x:>3} Y={y:>3} Wheel={wheel:>3} 左键={left} 右键={right}"


def format_can_payload(can_id, dlc, can_data):
    """格式化 CAN 帧内容。"""
    name = CAN_ID_NAMES.get(can_id, "未知")
    hex_data = ' '.join(f'{b:02X}' for b in can_data)
    if can_id == CAN_ID_TRACKBALL and len(can_data) >= 4:
        tb = format_trackball_data(can_data)
        return f"{name} [{tb}]"
    elif can_id == CAN_ID_MODEL:
        try:
            s = bytes(can_data).decode('ascii', errors='replace')
            return f"{name} 型号={s}"
        except Exception:
            pass
    return f"{name} DLC={dlc} Data=[{hex_data}]"


def main():
    print("=== PC端 CAN 数据接收程序（A825 扩展帧）===")

    # 复用成熟 XDMA 层
    print("查找 XDMA 设备...")
    base = wm.find_xdma_device_path()
    if not base:
        print("未找到 XDMA 设备")
        return 1
    print(f"设备路径: {base}")

    handle = wm.open_xdma_c2h(base)
    if not handle:
        print("C2H 设备打开失败")
        return 1
    print("C2H 设备打开成功\n")

    # 初始序号
    data = wm.read_slot(handle, SLOT_CAN)
    data32 = bytes(data[:32]) if data else None
    last_seq = 0
    if data32:
        r = parse_can_slot(data32)
        if r:
            last_seq = r[0]
            print(f"CAN 槽位初始序号: {last_seq}")

    print("等待 CAN 数据... (发 CAN 帧试试，Ctrl+C 退出)\n")
    print(f"{'序号':<8}| {'接口':<5}| {'数据内容':<55}")
    print("-" * 90)

    clock_offset = None
    try:
        while True:
            data = wm.read_slot(handle, SLOT_CAN)
            if not data:
                continue
            data32 = bytes(data[:32])
            r = parse_can_slot(data32)
            if not r:
                continue
            seq, can_id, dlc, can_data = r

            if seq != last_seq:
                last_seq = seq
                content = format_can_payload(can_id, dlc, can_data)
                print(f"#{seq:<7}| {'CAN':<5}| {content}")

    except KeyboardInterrupt:
        print("\n退出")
    finally:
        wm.kernel32.CloseHandle(handle)


if __name__ == "__main__":
    sys.exit(main())