# -*- coding: utf-8 -*-
"""PC 端 RS422 协议帧发送脚本（模拟轨迹球发送端，无需编译环境）

用途：通过 PC 串口（USB 转 RS422 / USB 转 TTL+422 模块）按 115200 8N1
      发送标准 RS422 协议帧，验证开发板 PS 端 arm_rs422_sender 接收程序
      的协议解析正确性与物理通路。

协议帧格式: 帧头(0x55) | 报文标识(0xD1~0xD5) | 有效数据 | 校验和
校验和 = (帧头 + 标识 + 有效数据各字节) 累加取低 8 位

依赖: pip install pyserial

用法: python rs422_pc_send.py COM5 [轮数] [帧间隔ms]
      python rs422_pc_send.py COM5 10 200
"""
import sys
import time

try:
    import serial
except ImportError:
    print("[错误] 缺少 pyserial，请先安装: pip install pyserial")
    sys.exit(1)

FRAME_HEAD = 0x55

# 报文标识 -> (名称, 有效数据长度)
CMD_MAP = {
    0xD1: ("位移", 3),
    0xD2: ("状态", 3),
    0xD3: ("温度", 1),
    0xD4: ("电压", 2),
    0xD5: ("版本", 3),
}


def build_frame(cmd, data):
    """组装一帧：[帧头, 标识, 数据..., 校验和]，校验和=累加取低8位"""
    f = [FRAME_HEAD, cmd] + list(data)
    f.append(sum(f) & 0xFF)
    return bytes(f)


def main():
    port = sys.argv[1] if len(sys.argv) > 1 else "COM5"
    rounds = int(sys.argv[2]) if len(sys.argv) > 2 else 10
    interval_ms = int(sys.argv[3]) if len(sys.argv) > 3 else 200
    if rounds < 1:
        rounds = 1

    ser = serial.Serial(port, 115200, timeout=1)  # 115200 8N1
    print("=== RS422 协议帧发送(PC) ===")
    print("端口: %s  115200 8N1  轮数: %d  帧间隔: %dms\n" % (port, rounds, interval_ms))

    for r in range(rounds):
        # 位移 D1(3B): 左键交替 + X/Y（int8 补码，&0xFF 转字节）
        x = ((r % 30) - 15) & 0xFF
        y = (((r * 3) % 20) - 10) & 0xFF
        frames = [
            ("位移", build_frame(0xD1, [0x01 if (r & 1) else 0x00, x, y])),
            ("状态", build_frame(0xD2, [0x40, 0x02, 0x01])),          # Remote/分辨率2/采样率1
            ("温度", build_frame(0xD3, [0x25])),                      # 37℃（0x25）
            ("电压", build_frame(0xD4, [0x40, 0x01])),                # 0x0140=320 => 3.2V
            ("版本", build_frame(0xD5, [0x02, 0x00, 0x01])),          # 版本 2.01
        ]

        for name, f in frames:
            ser.write(f)
            print("[#%2d] %s  %s" % (r + 1, name, " ".join("%02X" % b for b in f)))
            time.sleep(interval_ms / 1000.0)

    ser.close()
    print("\n=== 发送完成: %d 帧（%d 轮 x 5）===" % (rounds * 5, rounds))


if __name__ == "__main__":
    main()