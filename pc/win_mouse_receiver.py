#!/usr/bin/env python3
"""
PC Windows侧：USB鼠标数据接收程序（协议标准格式V2）

改动说明（V1→V2）：
  - 读取32字节统一槽位格式（原24字节）
  - 解析device_id区分USB/CAN/PS2/RS422四路接口
  - USB数据从data字段解析input_event（type+code+value）
  - 兼容后续CAN/PS2/RS422接口扩展

协议依据：d:/workspace/trae/day01/0702/protocol_spec.md
  - 统一槽位：{seq,device_id,data_len,reserved,data[8],tv_sec,tv_nsec} 32字节
  - USB槽位地址：0x20000000

依赖：Xilinx XDMA Windows驱动已安装

Ctrl+C退出说明：
  - 用独立线程做同步ReadFile（XDMA驱动不支持重叠I/O）
  - 主线程捕获Ctrl+C后os._exit()强制退出，OS自动回收句柄
"""
import ctypes
from ctypes import wintypes
import struct
import sys
import time
import threading
import os

# ===== DDR共享内存配置（和arm_mouse_sender.c V2一致）=====
DDR_BASE = 0x20000000

# 统一槽位格式：32字节（对齐cache line）
# OFF_SEQ=0x00, OFF_DEV=0x04, OFF_LEN=0x08, OFF_RES=0x0C, OFF_DATA=0x10, OFF_SEC=0x18, OFF_NSEC=0x1C
SLOT_SIZE = 32

# 四路接口槽位偏移（每路32字节）
SLOT_USB   = 0x00
SLOT_CAN   = 0x20
SLOT_PS2   = 0x40
SLOT_RS422 = 0x60

# 接口类型标识
DEV_USB    = 0
DEV_CAN    = 1
DEV_PS2    = 2
DEV_RS422  = 3
DEV_NAMES = {DEV_USB: "USB", DEV_CAN: "CAN", DEV_PS2: "PS2", DEV_RS422: "RS422"}

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
GENERIC_WRITE = 0x40000000
OPEN_EXISTING = 3
FILE_ATTRIBUTE_NORMAL = 0x80
INVALID_HANDLE_VALUE = ctypes.c_void_p(-1).value

# 函数原型（和小梅哥simple_dma.c一致：同步I/O）
kernel32.CreateFileA.restype = wintypes.HANDLE
kernel32.CreateFileA.argtypes = [ctypes.c_char_p, wintypes.DWORD, wintypes.DWORD, ctypes.c_void_p, wintypes.DWORD, wintypes.DWORD, wintypes.HANDLE]
kernel32.ReadFile.restype = wintypes.BOOL
kernel32.ReadFile.argtypes = [wintypes.HANDLE, ctypes.c_void_p, wintypes.DWORD, ctypes.POINTER(wintypes.DWORD), ctypes.c_void_p]
kernel32.SetFilePointerEx.restype = wintypes.BOOL
kernel32.SetFilePointerEx.argtypes = [wintypes.HANDLE, ctypes.c_longlong, ctypes.POINTER(ctypes.c_longlong), wintypes.DWORD]
kernel32.CloseHandle.restype = wintypes.BOOL
kernel32.CloseHandle.argtypes = [wintypes.HANDLE]

# SetupAPI（枚举 XDMA 设备接口路径，替代 xdma_info.exe 硬编码）
setupapi = ctypes.windll.setupapi


class GUID(ctypes.Structure):
    _fields_ = [("Data1", wintypes.DWORD),
                ("Data2", wintypes.WORD),
                ("Data3", wintypes.WORD),
                ("Data4", ctypes.c_ubyte * 8)]


XDMA_GUID = GUID(0x74c7e4a9, 0x6d5d, 0x4a70,
                 (ctypes.c_ubyte * 8)(0xbc, 0x0d, 0x20, 0x69, 0x1d, 0xff, 0x9e, 0x9d))


class SP_DEVICE_INTERFACE_DATA(ctypes.Structure):
    _fields_ = [("cbSize", wintypes.DWORD),
                ("InterfaceClassGuid", GUID),
                ("Flags", wintypes.DWORD),
                ("Reserved", ctypes.c_void_p)]


class SP_DEVICE_INTERFACE_DETAIL_DATA_A(ctypes.Structure):
    _fields_ = [("cbSize", wintypes.DWORD),
                ("DevicePath", ctypes.c_char * 1)]


DIGCF_PRESENT = 0x02
DIGCF_DEVICEINTERFACE = 0x10

setupapi.SetupDiGetClassDevsA.restype = ctypes.c_void_p
setupapi.SetupDiGetClassDevsA.argtypes = [ctypes.POINTER(GUID), ctypes.c_char_p,
                                          ctypes.c_void_p, wintypes.DWORD]
setupapi.SetupDiEnumDeviceInterfaces.restype = wintypes.BOOL
setupapi.SetupDiEnumDeviceInterfaces.argtypes = [ctypes.c_void_p, ctypes.c_void_p,
                                                 ctypes.POINTER(GUID), wintypes.DWORD,
                                                 ctypes.POINTER(SP_DEVICE_INTERFACE_DATA)]
setupapi.SetupDiGetDeviceInterfaceDetailA.restype = wintypes.BOOL
setupapi.SetupDiGetDeviceInterfaceDetailA.argtypes = [ctypes.c_void_p,
                                                       ctypes.POINTER(SP_DEVICE_INTERFACE_DATA),
                                                       ctypes.c_void_p, wintypes.DWORD,
                                                       ctypes.POINTER(wintypes.DWORD),
                                                       ctypes.c_void_p]
setupapi.SetupDiDestroyDeviceInfoList.restype = wintypes.BOOL
setupapi.SetupDiDestroyDeviceInfoList.argtypes = [ctypes.c_void_p]


def find_xdma_device_path():
    """SetupAPI 枚举 XDMA 设备接口路径（同 xdma_demo.c / win_rs422_receiver.py）"""
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

    # DevicePath 紧跟 cbSize(DWORD=4字节) 之后
    path_offset = ctypes.sizeof(wintypes.DWORD)
    raw_bytes = bytes(detail_buf[path_offset:path_offset + 255])
    path = raw_bytes.split(b'\x00')[0].decode('ascii', errors='replace')
    setupapi.SetupDiDestroyDeviceInfoList(h)
    return path


def open_xdma_c2h(base_path):
    """打开XDMA C2H设备（和小梅哥simple_dma.c一致：同步I/O + 读写权限）"""
    full_path = f"{base_path}\\c2h_0"
    # 关键：用GENERIC_READ|GENERIC_WRITE + FILE_ATTRIBUTE_NORMAL（同步）
    handle = kernel32.CreateFileA(full_path.encode('ascii'), GENERIC_READ | GENERIC_WRITE, 0, None, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, None)
    return handle if handle != INVALID_HANDLE_VALUE else None


def read_slot(handle, slot_offset):
    """从DDR同步读取指定槽位数据（读64字节满足XDMA对齐，解析前32字节）

    XDMA驱动用SetFilePointerEx的偏移作为DMA源地址（见dma_engine.c的deviceOffset）
    """
    buf = (ctypes.c_ubyte * 64)()
    bytes_read = wintypes.DWORD(0)
    # SetFilePointerEx设置DMA源地址偏移（0x20000000 + slot_offset）
    kernel32.SetFilePointerEx(handle, ctypes.c_longlong(DDR_BASE + slot_offset), None, 0)
    if not kernel32.ReadFile(handle, buf, 64, ctypes.byref(bytes_read), None):
        return None
    if bytes_read.value < SLOT_SIZE:
        return None
    return bytes(buf[:SLOT_SIZE])  # 只返回前32字节供解析


def parse_slot(data):
    """解析32字节槽位，返回(seq,device_id,data_len,data,sec,nsec)"""
    if data is None or len(data) < SLOT_SIZE:
        return None
    seq, dev_id, dlen, _res = struct.unpack_from('<IIII', data, 0)
    data_payload = data[0x10:0x18]  # 8字节
    tv_sec, tv_nsec = struct.unpack_from('<II', data, 0x18)
    return seq, dev_id, dlen, data_payload, tv_sec, tv_nsec


def parse_usb_event(data_payload):
    """从USB data字段解析input_event: type(2B)+code(2B)+value(4B)"""
    if len(data_payload) < 8:
        return None
    typ, code = struct.unpack_from('<HH', data_payload, 0)
    value = struct.unpack_from('<i', data_payload, 4)[0]
    return typ, code, value


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


def format_payload(dev_id, data_payload, dlen):
    """根据device_id格式化data字段显示"""
    if dev_id == DEV_USB:
        parsed = parse_usb_event(data_payload)
        if parsed:
            typ, code, val = parsed
            return f"{ev_type_name(typ)} {ev_code_name(typ, code)}={format_value(typ, code, val)}"
    elif dev_id == DEV_CAN:
        # CAN帧数据（原始字节）
        return f"CAN帧[{dlen}B]: " + " ".join(f"{b:02X}" for b in data_payload[:dlen])
    elif dev_id == DEV_PS2:
        # PS2扫描码
        return f"PS2[{dlen}B]: " + " ".join(f"{b:02X}" for b in data_payload[:dlen])
    elif dev_id == DEV_RS422:
        # RS422报文
        return f"RS422[{dlen}B]: " + " ".join(f"{b:02X}" for b in data_payload[:dlen])
    return f"未知[{dlen}B]: " + " ".join(f"{b:02X}" for b in data_payload[:dlen])


def main():
    print("=== PC端数据接收程序 V2（协议标准格式）===\n")

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

    # 读USB槽位初始序号
    last_seq = 0
    data = read_slot(h_c2h, SLOT_USB)
    if data:
        parsed = parse_slot(data)
        if parsed:
            last_seq = parsed[0]
            print(f"USB槽位初始序号: {last_seq}")

    count = 0
    # 时钟偏差校准值（首次收到事件时自动设置基准）
    clock_offset = None

    print("等待事件... (动鼠标试试，Ctrl+C退出)\n")
    print("序号    | 接口 | 数据内容                    | 延时(us) | 开发板时间戳")
    print("-" * 80)

    # 用独立线程做ReadFile循环（XDMA驱动只支持同步I/O，无法用重叠I/O中断）
    # 主线程捕获Ctrl+C后os._exit()强制退出，OS自动回收XDMA句柄
    stop_flag = threading.Event()

    def worker():
        nonlocal count, clock_offset, last_seq
        try:
            while not stop_flag.is_set():
                # 同步轮询USB槽位
                data = read_slot(h_c2h, SLOT_USB)
                if data is None:
                    continue

                parsed = parse_slot(data)
                if parsed is None:
                    continue

                seq, dev_id, dlen, data_payload, tv_sec, tv_nsec = parsed

                # 检测序号变化
                if seq != last_seq:
                    last_seq = seq
                    if seq > 0:
                        count += 1
                        dev_str = DEV_NAMES.get(dev_id, f"?{dev_id}")
                        payload_str = format_payload(dev_id, data_payload, dlen)

                        pc_time = time.time()
                        arm_time = tv_sec + tv_nsec / 1e9
                        if clock_offset is None:
                            clock_offset = pc_time - arm_time
                        latency_us = (pc_time - arm_time - clock_offset) * 1e6

                        ts_str = f"{tv_sec}.{tv_nsec // 1000000:03d}"
                        print(f"#{seq:<6d}| {dev_str:<4s} | {payload_str:<27s} | {latency_us:8.0f} | {ts_str}")
        except Exception as e:
            print(f"\n[worker异常] {e}")

    t = threading.Thread(target=worker, daemon=True)
    t.start()

    try:
        # 主线程等待Ctrl+C
        while t.is_alive():
            t.join(0.5)
    except KeyboardInterrupt:
        print(f"\n\n[Ctrl+C] 正在退出，共收到 {count} 个事件")
        stop_flag.set()
        # 给线程一点时间退出，然后强制退出（OS自动回收XDMA句柄）
        t.join(1.0)
        try:
            kernel32.CloseHandle(h_c2h)
        except Exception:
            pass
        os._exit(0)
    return 0


if __name__ == "__main__":
    sys.exit(main())
