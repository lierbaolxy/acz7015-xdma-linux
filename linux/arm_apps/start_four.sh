#!/bin/sh
# ACZ7015 四路外设采集统一启动脚本（USB / PS2 / CAN / RS422，单进程）
# 用法（板端，需 root）：sudo sh /tmp/start_four.sh [usb节点] [ps2节点]
#   不传参时自动识别鼠标 event 节点（按 Name 匹配 + 有 REL= 的鼠标数据接口）
#   识别失败回退缺省值 usb=/dev/input/event1  ps2=/dev/input/event4
# 说明：
#   - 单进程 /tmp/arm_all_four 同时采集 USB/PS2/RS422/CAN 四路，写各自槽位 + 环形区
#   - CAN 依赖 /dev/ttyCH343USB0（ch343.ko 已加载）；RS422 依赖 UART1 console 已释放
#   - 进程 mmap /dev/mem，故需 root 权限

USB_DEV=${1:-/dev/input/event1}
PS2_DEV=${2:-/dev/input/event4}
AUTO_USB=""
AUTO_PS2=""

# 0. 无传参时自动识别鼠标 event 节点（按设备名匹配，有 REL= 的才是鼠标数据接口）
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "[识别] 检测鼠标 event 节点..."
    # awk 输出每个鼠标设备的 Name + Handlers（仅有 REL= 的才打印）
    DEV_LIST=$(cat /proc/bus/input/devices | awk '/Name/{name=$0} /Handlers/{h=$0} /REL=/{print name"\n"h}')

    if [ -z "$1" ]; then
        # USB 鼠标: 匹配 "HP USB MOUSE"，取其后 Handlers 行的 eventN
        AUTO_USB=$(echo "$DEV_LIST" | awk '/HP USB MOUSE/{getline h; print h}' | grep -oE 'event[0-9]+' | head -1)
        [ -n "$AUTO_USB" ] && USB_DEV=/dev/input/$AUTO_USB
    fi

    if [ -z "$2" ]; then
        # PS2 转 USB 鼠标: 匹配 "Barcode Reader"，取其后 Handlers 行的 eventN
        AUTO_PS2=$(echo "$DEV_LIST" | awk '/Barcode Reader/{getline h; print h}' | grep -oE 'event[0-9]+' | head -1)
        [ -n "$AUTO_PS2" ] && PS2_DEV=/dev/input/$AUTO_PS2
    fi
fi

echo "  USB 鼠标: $USB_DEV $([ -n "$AUTO_USB" ] && echo '(自动识别)' || echo '(缺省/传参)')"
echo "  PS2 鼠标: $PS2_DEV $([ -n "$AUTO_PS2" ] && echo '(自动识别)' || echo '(缺省/传参)')"

# 1. 释放 UART1 console（RS422 复用 ttyPS0，先 stop 再 disable 防 systemd 自动重启）
systemctl stop serial-getty@ttyPS0.service 2>/dev/null
systemctl disable serial-getty@ttyPS0.service 2>/dev/null

# 2. 清理旧进程（含旧两进程方案残留 + 单进程自身，按命令行匹配，二进制名唯一）
pkill -9 -f arm_all_four 2>/dev/null
pkill -9 -f arm_can_sender 2>/dev/null
pkill -9 -f arm_multi 2>/dev/null
pkill -9 -f arm_usb_ps2_rs422 2>/dev/null
pkill -9 -f arm_rs422 2>/dev/null
pkill -9 -f hexdump 2>/dev/null
sleep 1

# 3. 启动四路单进程（可执行文件在 ~/0829 持久化目录；日志写 /tmp tmpfs）
nohup /home/zynq/0829/arm_all_four "$USB_DEV" "$PS2_DEV" > /tmp/all_four.log 2>&1 &

sleep 2
echo "=== 四路外设采集已启动（单进程）==="
ps | grep -v grep | grep -E "arm_all_four"
echo "日志: /tmp/all_four.log"