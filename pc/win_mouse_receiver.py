#!/usr/bin/env python3
"""
PC Windows侧：USB/CAN/PS2/RS422 四路数据接收程序（协议标准格式V5）

改动说明（V4→V5）：
  - 新增 CAN 路环形缓冲区读取（0x20001900），完整解析 5 种协议帧
  - CAN帧布局：data[0..3]=29位扩展帧ID(小端), data[4..7]+reserved低16位=数据场

改动说明（V3→V4）：
  - 改读环形缓冲区（每路64槽×32B=2KB，一次DMA整块读）
  - 按槽内seq升序回放历史帧，根治单槽位覆盖丢帧
  - USB环形区0x20000100 PS/2环形区0x20000900 RS422环形区0x20001100

改动说明（V2→V3）：
  - 轮询三路槽位：USB(0x00) + PS2(0x40) + RS422(0x60)，seq各自独立检测
  - PS/2路解析标准PS/2鼠标3字节数据包（按键+XY位移）

改动说明（V1→V2）：
  - 读取32字节统一槽位格式（原24字节）
  - 解析device_id区分USB/CAN/PS2/RS422四路接口
  - USB数据从data字段解析input_event（type+code+value）

协议依据：d:/workspace/trae/day01/0702/protocol_spec.md
  - 统一槽位：{seq,device_id,data_len,reserved,data[8],tv_sec,tv_nsec} 32字节
  - 环形缓冲：板端写ring[seq%64]，PC端整块读2KB后按seq升序回放
  - PS/2数据：标准PS/2鼠标3字节包
    Byte0=[Y溢出][X溢出][Y符号][X符号][1][中键][右键][左键] Byte1=X Byte2=Y(上为正)

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

# 环形缓冲区（V4）：每路64槽×32B=2KB，板端写ring[seq%64]记录历史帧
RING_USB   = 0x100
RING_PS2   = 0x900
RING_RS422 = 0x1100
RING_CAN   = 0x1900   # CAN环形区紧随RS422(0x1100+0x800=0x1900)
RING_SLOTS = 64
RING_BYTES = RING_SLOTS * SLOT_SIZE  # 2048字节，64的倍数满足XDMA读要求

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


def read_ring(handle, ring_offset):
    """从DDR同步读取整块环形缓冲区（2048字节=64槽，一次DMA）

    XDMA驱动用SetFilePointerEx的偏移作为DMA源地址（见dma_engine.c的deviceOffset）
    """
    buf = (ctypes.c_ubyte * RING_BYTES)()
    bytes_read = wintypes.DWORD(0)
    kernel32.SetFilePointerEx(handle, ctypes.c_longlong(DDR_BASE + ring_offset), None, 0)
    if not kernel32.ReadFile(handle, buf, RING_BYTES, ctypes.byref(bytes_read), None):
        return None
    if bytes_read.value < RING_BYTES:
        return None
    return bytes(buf)


def parse_ring_entries(data, expect_dev):
    """解析环形缓冲64槽，返回按seq升序的记录列表（跳过空槽/异设备槽）

    撕裂防护：板端seq最后写（前面有内存屏障），PC见新seq则数据字段已就绪
    """
    entries = []
    if data is None:
        return entries
    for i in range(RING_SLOTS):
        off = i * SLOT_SIZE
        seq, dev_id, dlen, reserved = struct.unpack_from('<IIII', data, off)
        if seq == 0 or dev_id != expect_dev or dlen == 0 or dlen > 8:
            continue
        data_payload = data[off + 0x10:off + 0x18]
        tv_sec, tv_nsec = struct.unpack_from('<II', data, off + 0x18)
        entries.append((seq, dev_id, dlen, reserved, data_payload, tv_sec, tv_nsec))
    entries.sort(key=lambda e: e[0])
    return entries


def parse_usb_event(data_payload):
    """从USB data字段解析input_event: type(2B)+code(2B)+value(4B)"""
    if len(data_payload) < 8:
        return None
    typ, code = struct.unpack_from('<HH', data_payload, 0)
    value = struct.unpack_from('<i', data_payload, 4)[0]
    return typ, code, value


def parse_ps2_packet(data_payload, dlen):
    """解析PS/2鼠标4字节数据包(含滚轮)，返回(x,y,z,左,右,中)

    Byte0: [Y溢出][X溢出][Y符号][X符号][1][中键][右键][左键]
    Byte1: X位移(9位补码低8位，右为正)
    Byte2: Y位移(9位补码低8位，PS/2约定上为正)
    Byte3: Z滚轮(8位补码，上为正)
    """
    if dlen < 3 or len(data_payload) < 3:
        return None
    b0, b1, b2 = data_payload[0], data_payload[1], data_payload[2]
    x = b1 - 256 if (b0 & 0x10) else b1   # X符号位bit4
    y = b2 - 256 if (b0 & 0x20) else b2   # Y符号位bit5
    # 滚轮：第4字节，8位补码
    z = 0
    if dlen >= 4 and len(data_payload) >= 4:
        b3 = data_payload[3]
        z = b3 - 256 if (b3 & 0x80) else b3
    left   = b0 & 0x01
    right  = (b0 >> 1) & 0x01
    middle = (b0 >> 2) & 0x01
    return x, y, z, left, right, middle


# ===== CAN 协议帧 ID（29位扩展帧，A825/ARINC825）=====
CAN_ID_TRACKBALL = 0x01180118   # 轨迹球数据（轨迹球→测试系统，4字节）
CAN_ID_VER_QUERY = 0x01180119   # 软件版本查询（测试系统→轨迹球，4字节）
CAN_ID_VER_REPLY = 0x01180117   # 软件版本回复（轨迹球→测试系统，3字节）
CAN_ID_PBIT      = 0x01180116   # 上电PBIT（轨迹球→测试系统，6字节，连续5帧）
CAN_ID_MODEL     = 0x01180115   # 设备型号（轨迹球→测试系统，6字节，连续3帧）

CAN_FRAME_NAMES = {
    CAN_ID_TRACKBALL: "轨迹球数据",
    CAN_ID_VER_QUERY: "版本查询",
    CAN_ID_VER_REPLY: "版本回复",
    CAN_ID_PBIT:      "上电PBIT",
    CAN_ID_MODEL:     "设备型号",
}


def parse_can_frame(data_payload, dlen, reserved):
    """解析 CAN 槽位数据：data[0..3]=can_id(小端29位), data[4..7]=数据前4字节,
    reserved低16位=数据第5/6字节。返回 (can_id, data_list) 或 None"""
    if len(data_payload) < 4:
        return None
    can_id = struct.unpack_from('<I', data_payload, 0)[0] & 0x1FFFFFFF
    data = list(data_payload[4:8])
    if dlen > 4:
        data.append(reserved & 0xFF)
    if dlen > 5:
        data.append((reserved >> 8) & 0xFF)
    return can_id, data[:dlen]


def format_can_data(can_id, data):
    """按帧 ID 解析并格式化 CAN 数据场"""
    # 轨迹球数据：4字节位域（小端：bit0右/bit1左/bit2-9Y/bit10-17X/bit18-25滚轮）
    if can_id == CAN_ID_TRACKBALL and len(data) >= 4:
        raw = data[0] | (data[1] << 8) | (data[2] << 16) | (data[3] << 24)
        right = raw & 0x01
        left = (raw >> 1) & 0x01
        y = (raw >> 2) & 0xFF
        x = (raw >> 10) & 0xFF
        wheel = (raw >> 18) & 0xFF
        return f"X{x:+#d} Y{y:+#d} 滚轮{wheel:+#d} [左:{left} 右:{right}]"
    # 版本回复：3字节 主.次.修订
    if can_id == CAN_ID_VER_REPLY and len(data) >= 3:
        return f"版本 {data[0]}.{data[1]:02d}.{data[2]:02d}"
    # 设备型号：6字节 ASCII
    if can_id == CAN_ID_MODEL and len(data) >= 1:
        s = bytes(data).decode('ascii', errors='replace').strip('\x00')
        return f"型号 \"{s}\""
    # 版本查询/PBIT/未知：原始 hex
    return " ".join(f"{b:02X}" for b in data)


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


def format_payload(dev_id, data_payload, dlen, reserved=0):
    """根据device_id格式化data字段显示"""
    if dev_id == DEV_USB:
        parsed = parse_usb_event(data_payload)
        if parsed:
            typ, code, val = parsed
            return f"{ev_type_name(typ)} {ev_code_name(typ, code)}={format_value(typ, code, val)}"
    elif dev_id == DEV_CAN:
        # CAN帧：data[0..3]=can_id, data[4..7]+reserved=数据
        parsed = parse_can_frame(data_payload, dlen, reserved)
        if parsed:
            can_id, data = parsed
            name = CAN_FRAME_NAMES.get(can_id, "未知帧")
            return f"{name}(0x{can_id:08X})[{dlen}B]: {format_can_data(can_id, data)}"
        return f"CAN帧[{dlen}B]: " + " ".join(f"{b:02X}" for b in data_payload[:dlen])
    elif dev_id == DEV_PS2:
        # PS2 路统一使用 input_event 格式（与 USB 一致）
        parsed = parse_usb_event(data_payload)
        if parsed:
            typ, code, value = parsed
            return f"{ev_type_name(typ)} {ev_code_name(typ, code)} = {value}"
        return f"PS2[{dlen}B]: " + " ".join(f"{b:02X}" for b in data_payload[:dlen])
    elif dev_id == DEV_RS422:
        # 设备型号D7分片：reserved低位=16标记16字节型号，高位=片序号，data为裸字节
        if (reserved & 0xFFFF) == 16:
            frag = (reserved >> 16) & 0xFFFF
            return f"型号片{frag}: " + " ".join(f"{b:02X}" for b in data_payload[:dlen])
        # 常规报文（data[0]=报文标识，后跟有效数据）
        cmd_names = {0xD1: "位移", 0xD2: "状态", 0xD3: "温度", 0xD4: "电压",
                     0xD5: "版本", 0xD6: "上电PBIT"}
        if dlen >= 1 and data_payload[0] in cmd_names:
            return f"{cmd_names[data_payload[0]]}: " + \
                   " ".join(f"{b:02X}" for b in data_payload[1:dlen])
        return f"RS422[{dlen}B]: " + " ".join(f"{b:02X}" for b in data_payload[:dlen])
    return f"未知[{dlen}B]: " + " ".join(f"{b:02X}" for b in data_payload[:dlen])


def main():
    print("=== PC端四路数据接收程序 V5（USB/CAN/PS2/RS422 环形缓冲零丢帧）===\n")

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

    # 四路环形缓冲轮询配置：(环形区偏移, 接口名, 期望device_id)
    poll_rings = [(RING_USB, "USB", DEV_USB),
                  (RING_CAN, "CAN", DEV_CAN),
                  (RING_PS2, "PS2", DEV_PS2),
                  (RING_RS422, "RS422", DEV_RS422)]

    # 读各路环形缓冲，取最大seq作为基线（板端程序可能已运行）
    last_seqs = {}
    for ring_off, ring_name, expect_dev in poll_rings:
        data = read_ring(h_c2h, ring_off)
        max_seq = 0
        if data:
            for e in parse_ring_entries(data, expect_dev):
                max_seq = max(max_seq, e[0])
        last_seqs[ring_off] = max_seq
        print(f"{ring_name}环形缓冲基线seq: {max_seq}")

    count = 0
    lost_total = 0
    # 时钟偏差校准值（首次收到事件时自动设置基准）
    clock_offset = None

    print("等待事件... (动鼠标/发CAN帧试试，Ctrl+C退出)\n")
    print("序号    | 接口 | 数据内容                    | 延时(us) | 开发板时间戳")
    print("-" * 80)

    # 用独立线程做ReadFile循环（XDMA驱动只支持同步I/O，无法用重叠I/O中断）
    # 主线程捕获Ctrl+C后os._exit()强制退出，OS自动回收XDMA句柄
    stop_flag = threading.Event()

    def worker():
        nonlocal count, clock_offset, lost_total
        try:
            while not stop_flag.is_set():
                # 依次同步轮询三路环形缓冲
                for ring_off, ring_name, expect_dev in poll_rings:
                    data = read_ring(h_c2h, ring_off)
                    if data is None:
                        continue

                    entries = parse_ring_entries(data, expect_dev)
                    last = last_seqs[ring_off]
                    new = [e for e in entries if e[0] > last]
                    if not new:
                        continue

                    # 丢帧检测：期望帧数(最大seq-基线)与实际收到数之差
                    max_seq = new[-1][0]
                    lost = (max_seq - last) - len(new)
                    if last > 0 and lost > 0:
                        lost_total += lost
                        print(f"         [{ring_name} 提示] seq #{last + 1}~#{max_seq} "
                              f"中{lost}帧被环形覆盖丢失（超过64槽历史）")
                    last_seqs[ring_off] = max_seq

                    for seq, dev_id, dlen, reserved, data_payload, tv_sec, tv_nsec in new:
                        count += 1
                        dev_str = DEV_NAMES.get(dev_id, f"?{dev_id}")
                        payload_str = format_payload(dev_id, data_payload, dlen, reserved)

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
        print(f"\n\n[Ctrl+C] 正在退出，共收到 {count} 个事件（丢帧 {lost_total}）")
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
