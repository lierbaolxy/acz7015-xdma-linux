# -*- coding: utf-8 -*-
"""
win_rs422_receiver.py - PC端RS422数据接收程序（协议标准格式V2）

功能：通过XDMA读取开发板DDR中RS422槽位数据，解析并显示RS422协议帧

RS422槽位地址: 0x20000060 (device_id=3)
数据格式: slot_t {seq, device_id, data_len, reserved, data[8], tv_sec, tv_nsec}
  - data[0] = 报文标识(0xD1-0xD5)
  - data[1..data_len] = 有效数据

协议依据: d:/workspace/trae/day01/0702/protocol_spec.md
运行: python -u win_rs422_receiver.py
"""
import ctypes
import struct
import time
import sys
import os
import threading

# ===== 配置 =====
DDR_BASE     = 0x20000000
SLOT_RS422   = 0x60         # RS422槽位偏移
SLOT_SIZE    = 32           # 槽位大小
READ_SIZE    = 64           # XDMA读取长度(对齐)
DEV_ID_RS422 = 3

# RS422报文标识
CMD_DISPLACEMENT = 0xD1
CMD_STATUS       = 0xD2
CMD_TEMP         = 0xD3
CMD_VOLTAGE      = 0xD4
CMD_VERSION      = 0xD5

CMD_NAMES = {
    CMD_DISPLACEMENT: "位移",
    CMD_STATUS:       "状态",
    CMD_TEMP:         "温度",
    CMD_VOLTAGE:      "电压",
    CMD_VERSION:      "版本",
}

# ===== Windows API =====
kernel32 = ctypes.WinDLL('kernel32', use_last_error=True)
setupapi = ctypes.WinDLL('setupapi', use_last_error=True)

# GUID: {74c7e4a9-6d5d-4a70-bc0d-20691dff9e9d}
class GUID(ctypes.Structure):
    _fields_ = [
        ("Data1", ctypes.c_ulong),
        ("Data2", ctypes.c_ushort),
        ("Data3", ctypes.c_ushort),
        ("Data4", ctypes.c_ubyte * 8),
    ]

XDMA_GUID = GUID(0x74c7e4a9, 0x6d5d, 0x4a70,
                 (ctypes.c_ubyte * 8)(0xbc, 0x0d, 0x20, 0x69, 0x1d, 0xff, 0x9e, 0x9d))

# Windows API 类型声明
kernel32.CreateFileA.restype = ctypes.c_void_p
kernel32.CreateFileA.argtypes = [ctypes.c_char_p, ctypes.c_uint32, ctypes.c_uint32,
                                  ctypes.c_void_p, ctypes.c_uint32, ctypes.c_uint32, ctypes.c_void_p]
kernel32.ReadFile.restype = ctypes.c_int
kernel32.ReadFile.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_uint32,
                               ctypes.POINTER(ctypes.c_uint32), ctypes.c_void_p]
kernel32.SetFilePointerEx.restype = ctypes.c_int
kernel32.SetFilePointerEx.argtypes = [ctypes.c_void_p, ctypes.c_longlong,
                                       ctypes.POINTER(ctypes.c_longlong), ctypes.c_uint32]
kernel32.CloseHandle.restype = ctypes.c_int
kernel32.CloseHandle.argtypes = [ctypes.c_void_p]

INVALID_HANDLE_VALUE = ctypes.c_void_p(-1)
GENERIC_READ    = 0x80000000
GENERIC_WRITE   = 0x40000000
OPEN_EXISTING   = 3
FILE_ATTRIBUTE_NORMAL = 0x80
FILE_BEGIN      = 0

# SetupAPI 类型声明
class SP_DEVICE_INTERFACE_DATA(ctypes.Structure):
    _fields_ = [
        ("cbSize", ctypes.c_uint32),
        ("InterfaceClassGuid", GUID),
        ("Flags", ctypes.c_uint32),
        ("Reserved", ctypes.c_void_p),
    ]

class SP_DEVICE_INTERFACE_DETAIL_DATA_A(ctypes.Structure):
    _fields_ = [
        ("cbSize", ctypes.c_uint32),
        ("DevicePath", ctypes.c_char * 1),  # ANYSIZE_ARRAY, 实际缓冲区在外部分配
    ]

DIGCF_PRESENT          = 0x02
DIGCF_DEVICEINTERFACE  = 0x10

# SetupAPI函数声明（统一使用A版本，避免W/A混用）
setupapi.SetupDiGetClassDevsA.restype = ctypes.c_void_p
setupapi.SetupDiGetClassDevsA.argtypes = [ctypes.POINTER(GUID), ctypes.c_char_p,
                                           ctypes.c_void_p, ctypes.c_uint32]
setupapi.SetupDiEnumDeviceInterfaces.restype = ctypes.c_int
setupapi.SetupDiEnumDeviceInterfaces.argtypes = [ctypes.c_void_p, ctypes.c_void_p,
                                                  ctypes.POINTER(GUID), ctypes.c_uint32,
                                                  ctypes.POINTER(SP_DEVICE_INTERFACE_DATA)]
setupapi.SetupDiGetDeviceInterfaceDetailA.restype = ctypes.c_int
setupapi.SetupDiGetDeviceInterfaceDetailA.argtypes = [ctypes.c_void_p,
                                                       ctypes.POINTER(SP_DEVICE_INTERFACE_DATA),
                                                       ctypes.c_void_p, ctypes.c_uint32,
                                                       ctypes.POINTER(ctypes.c_uint32),
                                                       ctypes.c_void_p]
setupapi.SetupDiDestroyDeviceInfoList.restype = ctypes.c_int
setupapi.SetupDiDestroyDeviceInfoList.argtypes = [ctypes.c_void_p]


def find_xdma_device():
    """通过SetupAPI查找XDMA设备路径（统一使用A版本API）"""
    h = setupapi.SetupDiGetClassDevsA(ctypes.byref(XDMA_GUID), None, None,
                                       DIGCF_PRESENT | DIGCF_DEVICEINTERFACE)
    if not h or h == ctypes.c_void_p(-1).value:
        return None

    did = SP_DEVICE_INTERFACE_DATA()
    did.cbSize = ctypes.sizeof(SP_DEVICE_INTERFACE_DATA)

    if not setupapi.SetupDiEnumDeviceInterfaces(h, None, ctypes.byref(XDMA_GUID),
                                                  0, ctypes.byref(did)):
        setupapi.SetupDiDestroyDeviceInfoList(h)
        return None

    # 计算正确的cbSize：cbSize(4) + 1字节路径 = 5，对齐到指针大小
    # 32位Python: (5+3)&~3 = 8; 64位Python: (5+7)&~7 = 8
    ptr_size = ctypes.sizeof(ctypes.c_void_p)
    detail_cb_size = (5 + ptr_size - 1) & ~(ptr_size - 1)

    # 分配足够大的缓冲区（DevicePath实际长度由系统填充）
    detail_buf = (ctypes.c_ubyte * 256)()
    detail_struct = ctypes.cast(detail_buf, ctypes.POINTER(SP_DEVICE_INTERFACE_DETAIL_DATA_A))
    detail_struct[0].cbSize = detail_cb_size

    if not setupapi.SetupDiGetDeviceInterfaceDetailA(h, ctypes.byref(did),
                                                       detail_struct, 256, None, None):
        setupapi.SetupDiDestroyDeviceInfoList(h)
        return None

    # DevicePath是c_char*1，实际字符串紧随其后，从原始缓冲区读取
    # 路径起始偏移 = cbSize字段大小(4) 对齐到指针大小
    path_offset = ptr_size  # 32位=4, 64位=8
    raw_bytes = bytes(detail_buf[path_offset:path_offset+255])
    path = raw_bytes.split(b'\x00')[0].decode('ascii')

    setupapi.SetupDiDestroyDeviceInfoList(h)
    return path


def read_slot(handle, addr, buf):
    """从DDR指定地址读取槽位数据"""
    offset = ctypes.c_longlong(addr)
    if not kernel32.SetFilePointerEx(handle, offset, None, FILE_BEGIN):
        return False
    got = ctypes.c_uint32(0)
    if not kernel32.ReadFile(handle, buf, READ_SIZE, ctypes.byref(got), None):
        return False
    return got.value >= SLOT_SIZE


def parse_rs422(data, data_len):
    """解析RS422报文并返回描述字符串"""
    if data_len < 1:
        return "空数据"

    cmd = data[0]
    payload = data[1:1+data_len]
    name = CMD_NAMES.get(cmd, f"未知(0x{cmd:02X})")

    if cmd == CMD_DISPLACEMENT and data_len >= 4:
        b1 = payload[0]
        x = ctypes.c_int8(payload[1]).value
        y = ctypes.c_int8(payload[2]).value
        left  = b1 & 0x01
        right = (b1 >> 1) & 0x01
        return f"{name}: X={x} Y={y} 左键={left} 右键={right}"

    elif cmd == CMD_STATUS and data_len >= 4:
        mode = (payload[0] >> 6) & 0x01
        res  = payload[1]
        rate = payload[2]
        return f"{name}: 模式={'Remote' if mode else 'Stream'} 分辨率={res} 采样率={rate}"

    elif cmd == CMD_TEMP and data_len >= 2:
        temp = ctypes.c_int8(payload[0]).value
        return f"{name}: {temp}℃"

    elif cmd == CMD_VOLTAGE and data_len >= 3:
        vol = payload[0] | (payload[1] << 8)
        return f"{name}: {vol/100:.1f}V"

    elif cmd == CMD_VERSION and data_len >= 4:
        return f"{name}: {payload[0]}.{payload[1]:02d}.{payload[2]:02d}"

    else:
        hex_str = ' '.join(f'{b:02X}' for b in payload[:data_len])
        return f"{name}: {hex_str}"


# Ctrl+C 退出控制
g_stop = False

def main():
    global g_stop

    print("=== PC端RS422数据接收程序 V2（协议标准格式）===")
    print()

    # 查找XDMA设备
    print("查找XDMA设备...")
    device_path = find_xdma_device()
    if not device_path:
        print("错误: 未找到XDMA设备，请确认驱动已安装")
        return

    # 拼接c2h_0路径
    c2h_path = device_path.rstrip('\\') + '\\c2h_0'
    print(f"设备路径: {c2h_path}")

    # 打开设备
    handle = kernel32.CreateFileA(c2h_path.encode('ascii'),
                                   GENERIC_READ | GENERIC_WRITE,
                                   0, None, OPEN_EXISTING,
                                   FILE_ATTRIBUTE_NORMAL, None)
    if handle == INVALID_HANDLE_VALUE:
        print(f"错误: 打开设备失败 (错误码={ctypes.get_last_error()})")
        return
    print("C2H设备打开成功")
    print()
    print("等待RS422数据... (动轨迹球试试，Ctrl+C退出)")
    print()
    print("序号    | 报文 | 数据内容                         | 延时(us) | 开发板时间戳")
    print("-" * 80)

    buf = (ctypes.c_ubyte * READ_SIZE)()
    last_seq = 0
    count = 0
    clock_offset = None
    rs422_addr = DDR_BASE + SLOT_RS422

    try:
        while not g_stop:
            if not read_slot(handle, rs422_addr, buf):
                continue

            # 解析前32字节
            raw = bytes(buf[:SLOT_SIZE])
            seq, dev_id, data_len, reserved = struct.unpack('<IIII', raw[:16])
            data = struct.unpack('8B', raw[16:24])
            tv_sec, tv_nsec = struct.unpack('<II', raw[24:32])

            if seq == 0 or seq == last_seq:
                time.sleep(0.01)  # 10ms轮询
                continue

            last_seq = seq
            count += 1

            # 时间戳和延时
            arm_time = tv_sec + tv_nsec / 1e9
            pc_time = time.time()
            if clock_offset is None:
                clock_offset = pc_time - arm_time
            delay_us = (pc_time - arm_time - clock_offset) * 1e6

            # 解析RS422报文
            desc = parse_rs422(data, data_len)
            ts_str = f"{tv_sec}.{tv_nsec // 1000000:03d}"

            print(f"#{seq:<6} | {desc:<40} | {delay_us:8.0f} | {ts_str}")

    except KeyboardInterrupt:
        pass
    finally:
        kernel32.CloseHandle(handle)
        print(f"\n[退出] 共收到 {count} 个RS422数据包")


def ctrl_handler(ctrl_type):
    global g_stop
    if ctrl_type == 0:  # CTRL_C_EVENT
        g_stop = True
        return True
    return False

if __name__ == '__main__':
    # 注册Ctrl+C处理
    HANDLER_ROUTINE = ctypes.WINFUNCTYPE(ctypes.c_int, ctypes.c_uint)
    handler = HANDLER_ROUTINE(ctrl_handler)
    kernel32.SetConsoleCtrlHandler(handler, True)

    # 用线程跑main，主线程等待Ctrl+C
    t = threading.Thread(target=main, daemon=True)
    t.start()

    while t.is_alive():
        t.join(0.5)

    os._exit(0)
