#!/usr/bin/env python3
"""
pc_can_peer.py - PC端 CAN 对等测试工具（模拟"轨迹球"对端，双模块验证用）

用途：第二根 USB-CANFD-V1（CH343, VID 1a86:55d3）插 Windows 本机，枚举为 COM 口。
     通过 AT 指令把模块配成 500kbps + 包模式(MODE2) + 正常收发，然后：
       - 模拟轨迹球上电时序（PBIT×5 + 型号×3）
       - 持续发送轨迹球数据帧 0x01180118
       - 收到板端发来的版本查询 0x01180119 时自动回复版本 0x01180117

协议依据：泥人科技《CAN转换器系列使用手册V2.7》6.3 包模式 + 项目A825协议
包模式 17 字节帧（与板端 arm_can_sender.c 完全一致）：
  [0]   0xAA       包头
  [1]   0x00/0x01  扩展帧标识(0标准 1扩展)
  [2]   0x00/0x01  远程帧标识(0数据 1远程)
  [3]   DLC        有效数据长度 0~8
  [4..7] 帧ID(4B大端, 扩展帧低29bit有效)
  [8..15] 帧数据(8B)
  [16]  0x7A       包尾

验证拓扑（同一台 Windows PC 两个窗口）：
  窗口1: pc_can_peer.py     <- COM口 -> CH343#2 --CAN总线-- CH343#1(板端) -> DDR -> XDMA
  窗口2: win_mouse_receiver.py <- XDMA <- 板端 DDR（验证板端收包并转发）

依赖：pyserial（若未安装: pip install pyserial）
用法：
  python pc_can_peer.py --port COM13 --probe       # 探测波特率并回环自检
  python pc_can_peer.py --port COM13 --handshake   # 发 PBIT×5 + 型号×3（上电时序）
  python pc_can_peer.py --port COM13 --stream      # 持续发轨迹球数据帧 + 自动监听查询
  python pc_can_peer.py --port COM13 --stream --loop 5  # 发5帧后退出
"""
import sys
import time
import struct
import argparse

try:
    import serial
except ImportError:
    print("[ERROR] 缺少 pyserial，请先安装：  pip install pyserial")
    sys.exit(1)

# ===== 包模式常量（与板端 arm_can_sender.c 一致）=====
PKT_HDR = 0xAA
PKT_TAIL = 0x7A
PKT_LEN = 17

# ===== 项目协议帧 ID（29位扩展帧）=====
CAN_ID_TRACKBALL = 0x01180118   # 轨迹球数据（轨迹球→测试系统，4字节）
CAN_ID_VER_QUERY = 0x01180119   # 软件版本查询（测试系统→轨迹球，4字节）
CAN_ID_VER_REPLY = 0x01180117   # 软件版本回复（轨迹球→测试系统，3字节）
CAN_ID_PBIT      = 0x01180116   # 上电PBIT（轨迹球→测试系统，6字节）
CAN_ID_MODEL     = 0x01180115   # 设备型号（轨迹球→测试系统，6字节）

CAN_FRAME_NAMES = {
    CAN_ID_TRACKBALL: "轨迹球数据",
    CAN_ID_VER_QUERY: "版本查询",
    CAN_ID_VER_REPLY: "版本回复",
    CAN_ID_PBIT:      "上电PBIT",
    CAN_ID_MODEL:     "设备型号",
}

# 探测波特率顺序（CH343 模块串口常见速率，逐档试 AT 回 OK）
PROBE_BAUDS = [9600, 115200, 38400, 57600, 19200, 4800, 230400]


def open_port(port, baud):
    """打开串口，8N1 raw 模式"""
    sp = serial.Serial()
    sp.port = port
    sp.baudrate = baud
    sp.bytesize = serial.EIGHTBITS
    sp.parity = serial.PARITY_NONE
    sp.stopbits = serial.STOPBITS_ONE
    sp.timeout = 0.3
    sp.write_timeout = 1.0
    sp.open()
    return sp


def at_cmd(sp, cmd, is_plus=False, wait=0.3):
    """下发 AT 指令并读回复，返回回复字符串"""
    time.sleep(0.02)
    sp.reset_input_buffer()
    if is_plus:
        sp.write(cmd.encode())          # +++ 不带回车、前后需空闲
    else:
        sp.write((cmd + "\r\n").encode())
    sp.flush()
    time.sleep(wait)
    out = b""
    while sp.in_waiting:
        out += sp.read(sp.in_waiting)
    return out.decode(errors="replace")


def config_normal(sp):
    """配置：500kbps + 包模式 + 正常收发 + 允许所有帧（与板端 configure_normal 一致）"""
    print("[配置] " + at_cmd(sp, "+++", True).strip())
    print("[配置] " + at_cmd(sp, "AT+CAN_BAUD=500000").strip())
    print("[配置] " + at_cmd(sp, "AT+CANFD_EN=0").strip())
    print("[配置] " + at_cmd(sp, "AT+CAN_MODE=0").strip())
    print("[配置] " + at_cmd(sp, "AT+MODE=2").strip())
    print("[配置] " + at_cmd(sp, "AT+MODE2=1,122").strip())
    print("[配置] " + at_cmd(sp, "AT+CAN_FILTER0=1,0,4,0,0").strip())
    print("[配置] " + at_cmd(sp, "ATO").strip())


def config_loopback(sp):
    """配置回环模式（自检，不驱动 CAN 总线）"""
    print("[配置] " + at_cmd(sp, "+++", True).strip())
    print("[配置] " + at_cmd(sp, "AT+CAN_BAUD=500000").strip())
    print("[配置] " + at_cmd(sp, "AT+CANFD_EN=0").strip())
    print("[配置] " + at_cmd(sp, "AT+CAN_MODE=1").strip())  # 回环
    print("[配置] " + at_cmd(sp, "AT+MODE=2").strip())
    print("[配置] " + at_cmd(sp, "AT+MODE2=1,122").strip())
    print("[配置] " + at_cmd(sp, "AT+CAN_FILTER0=1,0,4,0,0").strip())
    print("[配置] " + at_cmd(sp, "ATO").strip())


def pkt_build(can_id, dlc, data, is_ext=True):
    """构造 17 字节包模式帧"""
    if dlc > 8:
        dlc = 8
    tx = bytearray(PKT_LEN)
    tx[0] = PKT_HDR
    tx[1] = 0x01 if is_ext else 0x00
    tx[2] = 0x00
    tx[3] = dlc
    tx[4] = (can_id >> 24) & 0xFF
    tx[5] = (can_id >> 16) & 0xFF
    tx[6] = (can_id >> 8) & 0xFF
    tx[7] = can_id & 0xFF
    for i in range(dlc):
        tx[8 + i] = data[i]
    tx[16] = PKT_TAIL
    return bytes(tx)


def pkt_send(sp, can_id, dlc, data):
    """发送一个 17 字节包（对应一帧 CAN）"""
    sp.write(pkt_build(can_id, dlc, data))
    sp.flush()


def parse_packet(buf):
    """从字节流提取一帧 17 字节包，返回 (can_id, dlc, data, is_ext) 或 None"""
    while len(buf) >= PKT_LEN:
        for i in range(len(buf) - PKT_LEN + 1):
            if buf[i] == PKT_HDR and buf[i + 16] == PKT_TAIL:
                is_ext = buf[i + 1] & 0x01
                dlc = buf[i + 3]
                if dlc > 8:
                    dlc = 8
                can_id = (buf[i + 4] << 24) | (buf[i + 5] << 16) | \
                         (buf[i + 6] << 8) | buf[i + 7]
                data = list(buf[i + 8:i + 8 + dlc])
                del buf[:i + PKT_LEN]
                return can_id, dlc, data, is_ext
        # 未找到完整帧，保留末尾可能的不完整帧头
        keep = buf[-(PKT_LEN - 1):]
        buf.clear()
        buf.extend(keep)
        break
    return None


def probe(sp):
    """查询模块参数，验证链路"""
    for b in [at_cmd(sp, "AT"), at_cmd(sp, "AT+VER=?"), at_cmd(sp, "AT+CAN_BAUD=?"),
              at_cmd(sp, "AT+CAN_MODE=?"), at_cmd(sp, "AT+MODE=?")]:
        print("  >> " + b.strip())


def self_test_loopback(sp):
    """回环自检：发一帧扩展帧 → 回环自收 → 校验"""
    print("\n===== PC端 CH343 包模式回环自检 =====")
    config_loopback(sp)
    time.sleep(0.3)
    sp.reset_input_buffer()

    test_id = 0x01180118
    test_data = [0x11, 0x22, 0x33, 0x44]
    print(f"[发送] 回环帧 ID=0x{test_id:08X} DLC=4")
    pkt_send(sp, test_id, 4, test_data)

    buf = bytearray()
    deadline = time.time() + 2.0
    while time.time() < deadline:
        while sp.in_waiting:
            buf.extend(sp.read(sp.in_waiting))
        r = parse_packet(buf)
        if r:
            can_id, dlc, data, is_ext = r
            print(f"[解析] 扩展={is_ext} ID=0x{can_id:08X} DLC={dlc} 数据=" +
                  " ".join(f"{b:02X}" for b in data))
            if can_id != test_id or dlc != 4 or data != test_data:
                print("[FAIL] 回环校验不匹配")
                return False
            print("[PASS] PC端回环自检通过")
            return True
        time.sleep(0.02)
    print("[FAIL] 2s 内未收到回环帧")
    return False


def send_handshake(sp, stream_once=False):
    """上电时序：PBIT×5 + 型号×3"""
    print("\n===== 模拟轨迹球上电时序 =====")
    pbit = [0x08, 0x02, 0x05, 0x08, 0x02, 0x05]
    model = list(b"20-427")  # 6字节 ASCII

    for i in range(5):
        pkt_send(sp, CAN_ID_PBIT, 6, pbit)
        print(f"  [PBIT  #{i + 1}/5] 0x{CAN_ID_PBIT:08X} {pbit}")
        time.sleep(0.05)
    for i in range(3):
        pkt_send(sp, CAN_ID_MODEL, 6, model)
        print(f"  [型号  #{i + 1}/3] 0x{CAN_ID_MODEL:08X} {model}")
        time.sleep(0.05)
    if stream_once:
        send_trackball_frame(sp, 10, 5, 0, 1, 0)  # 发一帧示例数据
    print("  [OK] 上电时序发送完成")


def send_trackball_frame(sp, x, y, wheel, left, right):
    """构造 4 字节轨迹球数据帧（小端位域：bit0右/bit1左/bit2-9Y/bit10-17X/bit18-25滚轮）"""
    y8 = y & 0xFF
    x8 = x & 0xFF
    w8 = wheel & 0xFF
    raw = (right & 1) | ((left & 1) << 1) | (y8 << 2) | (x8 << 10) | (w8 << 18)
    data = [raw & 0xFF, (raw >> 8) & 0xFF, (raw >> 16) & 0xFF, (raw >> 24) & 0xFF]
    pkt_send(sp, CAN_ID_TRACKBALL, 4, data)
    return raw


def stream(sp, loop):
    """持续发轨迹球数据 + 后台监听版本查询自动回复"""
    print("\n===== 持续发送轨迹球数据帧 =====")
    print("  [监听] 收到 0x01180119 版本查询将自动回复 0x01180117\n"
          "  (Ctrl+C 退出)\n")

    buf = bytearray()
    x, y, wheel, left, right = 10, 5, 0, 1, 0
    count = 0
    try:
        while loop <= 0 or count < loop:
            send_trackball_frame(sp, x, y, wheel, left, right)
            count += 1
            print(f"  #{count:>4d} 轨迹球数据 X={x:+d} Y={y:+d} 滚轮={wheel:+d} "
                  f"左:{left} 右:{right}", end="\r")

            # 交替改变位移模拟移动
            x = -x if count % 4 == 0 else x
            y = (y + 1) % 30

            # 读取并解析收到的帧（版本查询）
            while sp.in_waiting:
                buf.extend(sp.read(sp.in_waiting))
            r = parse_packet(buf)
            if r:
                can_id, dlc, data, is_ext = r
                name = CAN_FRAME_NAMES.get(can_id, "未知帧")
                print(f"\n  [收到] {name}(0x{can_id:08X})[{dlc}B]: " +
                      " ".join(f"{b:02X}" for b in data))
                if can_id == CAN_ID_VER_QUERY:
                    reply = [0x02, 0x00, 0x01]
                    pkt_send(sp, CAN_ID_VER_REPLY, 3, reply)
                    print(f"  [回复] 版本 2.01 -> 0x{CAN_ID_VER_REPLY:08X} {reply}")

            time.sleep(0.05)
    except KeyboardInterrupt:
        print(f"\n  [停止] 共发 {count} 帧")


def main():
    ap = argparse.ArgumentParser(description="PC端 CAN 对等测试工具（模拟轨迹球对端）")
    ap.add_argument("--port", required=True, help="CH343 对应的 COM 口，如 COM13")
    ap.add_argument("--baud", type=int, default=0,
                    help="模块串口波特率，0=自动探测（默认）")
    ap.add_argument("--probe", action="store_true", help="查询参数并回环自检")
    ap.add_argument("--handshake", action="store_true", help="发上电时序 PBIT×5+型号×3")
    ap.add_argument("--stream", action="store_true", help="持续发轨迹球数据帧")
    ap.add_argument("--loop", type=int, default=0, help="stream 模式发 N 帧后退出（0=无限）")
    args = ap.parse_args()

    print("=== PC端 CAN 对等测试工具（CH343 包模式，500kbps 扩展帧）===\n")

    # 自动探测波特率
    if args.baud > 0:
        sp = open_port(args.port, args.baud)
        print(f"[OK] 打开 {args.port} @ {args.baud}")
    else:
        sp = None
        for b in PROBE_BAUDS:
            try:
                tmp = open_port(args.port, b)
            except Exception:
                continue
            out = at_cmd(tmp, "+++", True) + at_cmd(tmp, "AT")
            if "OK" in out:
                sp = tmp
                print(f"[OK] 探测到 {args.port} @ {b} (AT 回复 OK)")
                break
            tmp.close()
        if sp is None:
            print(f"[FAIL] 在 {args.port} 上未能探测到 CH343 模块")
            print("  请检查：①驱动已装 ②设备管理器确认 COM 号 ③线材供电正常")
            sys.exit(1)

    try:
        if args.probe:
            at_cmd(sp, "+++", True)
            probe(sp)
            at_cmd(sp, "ATO")
            if not self_test_loopback(sp):
                sys.exit(1)
            print("\n[PASS] PC端模块探测+回环自检全部通过")
            return 0

        if args.handshake:
            config_normal(sp)
            send_handshake(sp)

        if args.stream:
            config_normal(sp)
            # stream 前先发一次上电时序，模拟真实轨迹球上电
            if not args.handshake:
                send_handshake(sp, stream_once=True)
            stream(sp, args.loop)
            return 0

        if not args.probe and not args.handshake and not args.stream:
            config_normal(sp)
            print("[OK] 已配置为 500kbps + 包模式 + 正常收发，" +
                  "进入纯监听（收到查询自动回复）")
            stream(sp, 0)  # 默认仅监听并自动回复
            return 0

    except serial.SerialException as e:
        print(f"[ERROR] 串口异常: {e}")
        return 1
    finally:
        if sp is not None:
            sp.close()
    return 0


if __name__ == "__main__":
    sys.exit(main())