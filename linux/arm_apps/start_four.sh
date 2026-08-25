#!/bin/sh
# ACZ7015 四路外设采集统一启动脚本（USB / PS2 / CAN / RS422）
# 用法（板端，需 root）：sudo sh /tmp/start_four.sh [usb节点] [ps2节点]
#   默认 usb=/dev/input/event1  ps2=/dev/input/event4
# 说明：
#   - CAN 进程   /tmp/arm_can_sender  （CH343 USB-CANFD 包模式，500kbps 扩展帧，写 0x20000020 + 环形区）
#   - 三路进程   /tmp/arm_multi       （USB/PS2/RS422，写各自槽位 + 环形区）
#   - 两进程均 mmap /dev/mem，故需 root 权限

USB_DEV=${1:-/dev/input/event1}
PS2_DEV=${2:-/dev/input/event4}

# 1. 释放 UART1 console（RS422 复用 ttyPS0，先 stop 再 disable 防 systemd 自动重启）
systemctl stop serial-getty@ttyPS0.service 2>/dev/null
systemctl disable serial-getty@ttyPS0.service 2>/dev/null

# 2. 清理旧进程（按命令行匹配，二进制名唯一）
pkill -9 -f arm_can_sender 2>/dev/null
pkill -9 -f arm_multi 2>/dev/null
pkill -9 -f arm_usb_ps2_rs422 2>/dev/null
pkill -9 -f arm_rs422 2>/dev/null
pkill -9 -f hexdump 2>/dev/null
sleep 1

# 3. 启动 CAN（默认 normal 模式持续收帧；依赖 /dev/ttyCH343USB0 即 ch343.ko 已加载）
nohup /tmp/arm_can_sender > /tmp/can_sender.log 2>&1 &

# 4. 启动 USB/PS2/RS422 三路（默认 stream 模式被动接收）
nohup /tmp/arm_multi "$USB_DEV" "$PS2_DEV" > /tmp/multi.log 2>&1 &

sleep 2
echo "=== 四路外设采集已启动 ==="
ps | grep -v grep | grep -E "arm_can_sender|arm_multi"
echo "日志: /tmp/can_sender.log  /tmp/multi.log"