#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
RS422 PC命令发送器（H2C命令信箱方式）

功能：PC经XDMA H2C通道写命令到板端DDR命令信箱(0x20000080)，ARM轮询后转发到UART1 TX
      符合协议"测试系统(PC)→轨迹球"的命令下发方向（protocol_spec.md 命令集）

命令信箱格式（复用share_slot_t 32字节，小端）：
  seq(u32)       命令序号，PC每次发送递增，ARM检测变化后转发
  device_id(u32) 固定0xCC命令信箱标识（ARM校验用）
  data_len(u32)  命令码（0xEA/0xF0/0xEB/0xE9/0xE4/0xE3/0xE2/0xF3/0xE8）
  reserved(u32)  参数长度（仅配置类命令需参数）
  data[8]        参数字节（最多6字节）
  tv_sec/tv_nsec 保留

用法：
  交互式：python rs422_pc_cmd.py
  命令行：python rs422_pc_cmd.py stream        # 切Stream模式
          python rs422_pc_cmd.py remote        # 切Remote模式
          python rs422_pc_cmd.py status        # 查询状态
          python rs422_pc_cmd.py temp          # 查询温度
          python rs422_pc_cmd.py voltage       # 查询电压
          python rs422_pc_cmd.py version       # 查询版本
          python rs422_pc_cmd.py cpi 5         # 分辨率CPI=5(625)
          python rs422_pc_cmd.py rate 20      # 采样率=200Hz
"""
import ctypes
import struct
import sys
from ctypes import wintypes

# ============ 常量 ============
DDR_BASE   = 0x20000000
MAILBOX    = 0x80             # 0x20000080 命令信箱（空闲区，单槽区之后环形区之前）
MBOX_BYTES = 32               # share_slot_t 大小

# 命令码（protocol_spec.md 命令集，测试系统→轨迹球）
CMD_STREAM    = 0xEA
CMD_REMOTE    = 0xF0
CMD_Q_DISPL   = 0xEB  # Remote模式位移查询（协议约定2字节）
CMD_Q_STATUS  = 0xE9
CMD_Q_TEMP    = 0xE4
CMD_Q_VOLTAGE = 0xE3
CMD_Q_VERSION = 0xE2
CMD_CFG_RATE  = 0xF3  # 采样率配置（带1字节参数，字节值×10=Hz）
CMD_CFG_CPI   = 0xE8  # 分辨率配置（带1字节参数，0-10档）

# 无参数命令字典
CMD_PLAIN = {
    "stream": CMD_STREAM, "remote": CMD_REMOTE,
    "status": CMD_Q_STATUS, "temp": CMD_Q_TEMP,
    "voltage": CMD_Q_VOLTAGE, "version": CMD_Q_VERSION,
    "displacement": CMD_Q_DISPL,
}

# ============ Windows API ============
kernel32 = ctypes.windll.kernel32
GENERIC_READ  = 0x80000000
GENERIC_WRITE = 0x40000000
OPEN_EXISTING = 3
FILE_ATTRIBUTE_NORMAL = 0x80
INVALID_HANDLE_VALUE = ctypes.c_void_p(-1).value

kernel32.CreateFileA.restype = wintypes.HANDLE
kernel32.CreateFileA.argtypes = [ctypes.c_char_p, wintypes.DWORD, wintypes.DWORD,
                                 ctypes.c_void_p, wintypes.DWORD, wintypes.DWORD, wintypes.HANDLE]
kernel32.WriteFile.restype = wintypes.BOOL
kernel32.WriteFile.argtypes = [wintypes.HANDLE, ctypes.c_void_p, wintypes.DWORD,
                               ctypes.POINTER(wintypes.DWORD), ctypes.c_void_p]
kernel32.SetFilePointerEx.restype = wintypes.BOOL
kernel32.SetFilePointerEx.argtypes = [wintypes.HANDLE, ctypes.c_longlong,
                                      ctypes.POINTER(ctypes.c_longlong), wintypes.DWORD]
kernel32.CloseHandle.restype = wintypes.BOOL
kernel32.CloseHandle.argtypes = [wintypes.HANDLE]

# ============ SetupAPI（枚举XDMA设备接口路径，同win_mouse_receiver.py）============
setupapi = ctypes.windll.setupapi


class GUID(ctypes.Structure):
    _fields_ = [("Data1", wintypes.DWORD), ("Data2", wintypes.WORD),
                ("Data3", wintypes.WORD), ("Data4", ctypes.c_ubyte * 8)]


XDMA_GUID = GUID(0x74c7e4a9, 0x6d5d, 0x4a70,
                 (ctypes.c_ubyte * 8)(0xbc, 0x0d, 0x20, 0x69, 0x1d, 0xff, 0x9e, 0x9d))


class SP_DEVICE_INTERFACE_DATA(ctypes.Structure):
    _fields_ = [("cbSize", wintypes.DWORD), ("InterfaceClassGuid", GUID),
                ("Flags", wintypes.DWORD), ("Reserved", ctypes.c_void_p)]


class SP_DEVICE_INTERFACE_DETAIL_DATA_A(ctypes.Structure):
    _fields_ = [("cbSize", wintypes.DWORD), ("DevicePath", ctypes.c_char * 1)]


DIGCF_PRESENT = 0x02
DIGCF_DEVICEINTERFACE = 0x10

setupapi.SetupDiGetClassDevsA.restype = ctypes.c_void_p
setupapi.SetupDiGetClassDevsA.argtypes = [ctypes.POINTER(GUID), ctypes.c_char_p, ctypes.c_void_p, wintypes.DWORD]
setupapi.SetupDiEnumDeviceInterfaces.restype = wintypes.BOOL
setupapi.SetupDiEnumDeviceInterfaces.argtypes = [ctypes.c_void_p, ctypes.c_void_p,
                                                 ctypes.POINTER(GUID), wintypes.DWORD,
                                                 ctypes.POINTER(SP_DEVICE_INTERFACE_DATA)]
setupapi.SetupDiGetDeviceInterfaceDetailA.restype = wintypes.BOOL
setupapi.SetupDiGetDeviceInterfaceDetailA.argtypes = [ctypes.c_void_p,
                                                      ctypes.POINTER(SP_DEVICE_INTERFACE_DATA),
                                                      ctypes.c_void_p, wintypes.DWORD,
                                                      ctypes.POINTER(wintypes.DWORD), ctypes.c_void_p]
setupapi.SetupDiDestroyDeviceInfoList.restype = wintypes.BOOL
setupapi.SetupDiDestroyDeviceInfoList.argtypes = [ctypes.c_void_p]


def find_xdma_device_path():
    """枚举XDMA设备接口路径（复用win_mouse_receiver.py逻辑）"""
    h = setupapi.SetupDiGetClassDevsA(ctypes.byref(XDMA_GUID), None, None,
                                      DIGCF_PRESENT | DIGCF_DEVICEINTERFACE)
    if not h or h == INVALID_HANDLE_VALUE:
        return None
    did = SP_DEVICE_INTERFACE_DATA()
    did.cbSize = ctypes.sizeof(SP_DEVICE_INTERFACE_DATA)
    if not setupapi.SetupDiEnumDeviceInterfaces(h, None, ctypes.byref(XDMA_GUID),
                                                0, ctypes.byref(did)):
        setupapi.SetupDiDestroyDeviceInfoList(h)
        return None
    ptr_size = ctypes.sizeof(ctypes.c_void_p)
    detail_cb_size = (5 + ptr_size - 1) & ~(ptr_size - 1)
    detail_buf = (ctypes.c_ubyte * 512)()
    detail = ctypes.cast(detail_buf, ctypes.POINTER(SP_DEVICE_INTERFACE_DETAIL_DATA_A))
    detail[0].cbSize = detail_cb_size
    if not setupapi.SetupDiGetDeviceInterfaceDetailA(h, ctypes.byref(did), detail,
                                                     512, None, None):
        setupapi.SetupDiDestroyDeviceInfoList(h)
        return None
    path_offset = ctypes.sizeof(wintypes.DWORD)
    raw_bytes = bytes(detail_buf[path_offset:path_offset + 255])
    path = raw_bytes.split(b'\x00')[0].decode('ascii', errors='replace')
    setupapi.SetupDiDestroyDeviceInfoList(h)
    return path


def open_xdma_h2c(base_path):
    """打开XDMA H2C设备（Host→Card写方向，必须GENERIC_WRITE）"""
    full_path = f"{base_path}\\h2c_0"
    handle = kernel32.CreateFileA(full_path.encode('ascii'),
                                  GENERIC_WRITE, 0, None, OPEN_EXISTING,
                                  FILE_ATTRIBUTE_NORMAL, None)
    return handle if handle != INVALID_HANDLE_VALUE else None


def write_mailbox(handle, seq, cmd, param=b''):
    """写命令到DDR命令信箱(0x20000080)，32字节share_slot_t小端格式"""
    param = param[:8].ljust(8, b'\x00')
    # seq(u32) device_id(u32)=0xCC data_len(u32)=cmd reserved(u32)=参数长度 data[8] tv_sec tv_nsec
    buf = struct.pack('<IIII8sII', seq, 0xCC, cmd, len(param), param, 0, 0)
    cbuf = (ctypes.c_ubyte * MBOX_BYTES).from_buffer_copy(buf)
    written = wintypes.DWORD(0)
    kernel32.SetFilePointerEx(handle, ctypes.c_longlong(DDR_BASE + MAILBOX), None, 0)
    ok = kernel32.WriteFile(handle, cbuf, MBOX_BYTES, ctypes.byref(written), None)
    return ok and written.value == MBOX_BYTES


def send_cmd(handle, seq_holder, cmd, param=b''):
    """发命令并递增seq（seq从1开始，0是空槽）"""
    ok = write_mailbox(handle, seq_holder[0], cmd, param)
    if ok:
        p = param.hex() if param else '无'
        print(f"[发送] seq={seq_holder[0]} cmd=0x{cmd:02X} param={p}")
        seq_holder[0] = (seq_holder[0] + 1) & 0xFFFFFFFF
    else:
        print("[错误] 写命令信箱失败")
    return ok


def interactive(handle, seq_holder):
    """交互式命令输入"""
    print("\n可用命令：")
    print("  stream / remote        切换工作模式")
    print("  status / temp / voltage / version  查询")
    print("  displacement           Remote位移查询(0xEB)")
    print("  cpi<N>                 分辨率档位0-10(125/250/.../1375)")
    print("  rate<N>                采样率Hz= N×10 (0-40)")
    print("  q                      退出")
    while True:
        try:
            s = input("\n> ").strip().lower()
            if not s:
                continue
            if s in ('q', 'quit', 'exit'):
                break
            if s in CMD_PLAIN:
                send_cmd(handle, seq_holder, CMD_PLAIN[s])
            elif s.startswith('cpi'):
                v = int(s[3:])
                if 0 <= v <= 10:
                    send_cmd(handle, seq_holder, CMD_CFG_CPI, bytes([v]))
                else:
                    print("cpi范围0-10")
            elif s.startswith('rate'):
                v = int(s[4:])
                if 0 <= v <= 40:
                    send_cmd(handle, seq_holder, CMD_CFG_RATE, bytes([v]))
                else:
                    print("rate范围0-40")
            else:
                print(f"未知命令: {s}（输入q退出）")
        except ValueError:
            print("参数错误")
        except KeyboardInterrupt:
            break


def main():
    print("=== RS422 PC命令发送器（H2C命令信箱方式）===")
    print("查找XDMA设备...")
    base_path = find_xdma_device_path()
    if not base_path:
        print("未找到XDMA设备！请确认驱动已安装")
        return 1
    print(f"XDMA设备: {base_path}")
    h2c = open_xdma_h2c(base_path)
    if h2c is None or h2c == INVALID_HANDLE_VALUE:
        print("打开 h2c_0 失败！")
        return 1
    print(f"H2C设备打开成功 命令信箱:0x{DDR_BASE + MAILBOX:08X}\n")

    seq_holder = [1]  # 从1开始，0是空槽避免与初始清零冲突
    try:
        if len(sys.argv) > 1:
            # 命令行模式：一次性发命令后退出
            arg = sys.argv[1].lower()
            if arg in CMD_PLAIN:
                send_cmd(h2c, seq_holder, CMD_PLAIN[arg])
            elif arg == 'query' and len(sys.argv) > 2:
                q = sys.argv[2].lower()
                if q in CMD_PLAIN and q not in ('stream', 'remote'):
                    send_cmd(h2c, seq_holder, CMD_PLAIN[q])
                else:
                    print(f"未知查询: {q}")
            elif arg == 'cpi' and len(sys.argv) > 2:
                send_cmd(h2c, seq_holder, CMD_CFG_CPI, bytes([int(sys.argv[2])]))
            elif arg == 'rate' and len(sys.argv) > 2:
                send_cmd(h2c, seq_holder, CMD_CFG_RATE, bytes([int(sys.argv[2])]))
            else:
                print("用法: python rs422_pc_cmd.py [stream|remote|status|temp|voltage|version|displacement|cpi N|rate N]")
        else:
            interactive(h2c, seq_holder)
    finally:
        kernel32.CloseHandle(h2c)
    return 0


if __name__ == '__main__':
    sys.exit(main())
