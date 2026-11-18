#!/bin/sh
# RS422 轨迹球采集程序启动脚本（由 systemd 服务 rs422-collector 以 root 调用）
PROG=/home/zynq/0915-lxy/arm_all_four_udp
LOG=/home/zynq/0915-lxy/arm_all_four_udp.log
CONF=/home/zynq/0915-lxy/rs422.conf
PC_IP=192.168.1.58
PC_PORT=9060

# 配置文件不存在则生成默认（VERBOSE=0：关闭逐帧调试日志）
if [ ! -f "$CONF" ]; then
    cat > "$CONF" <<'EOF'
# RS422 采集服务配置（修改后执行 sudo systemctl restart rs422-collector 生效）
# VERBOSE=1: 打开逐帧调试日志（[UDP↑]/[RS422←球]/[RS422→球]），日志量大
# VERBOSE=0: 关闭，只保留事件级日志
VERBOSE=0
EOF
fi

# 读取配置（默认关闭 verbose）
VERBOSE=0
. "$CONF"
EXTRA=""
[ "$VERBOSE" = "1" ] && EXTRA="-v"

# CH340 拔插后节点索引会变（ttyCH341USB0/USB1/...），这里逐个查找
find_dev() {
    if [ -e /dev/rs422 ]; then echo /dev/rs422; return 0; fi
    for d in /dev/ttyCH341USB0 /dev/ttyCH341USB1 /dev/ttyCH341USB2 /dev/ttyCH341USB3 \
             /dev/ttyUSB0 /dev/ttyUSB1 /dev/ttyUSB2; do
        if [ -e "$d" ]; then echo "$d"; return 0; fi
    done
    return 1
}

# 等待设备节点就绪（最长 15 秒）
i=0
DEV=""
while [ $i -lt 30 ]; do
    DEV="$(find_dev)"
    [ -n "$DEV" ] && break
    sleep 0.5
    i=$((i + 1))
done

if [ -z "$DEV" ]; then
    echo "[start_rs422] 未找到 USB转RS422 设备节点，启动取消（$(date)）" >> "$LOG"
    exit 1
fi

# 日志轮转由采集程序内部完成（超过 100MB -> arm_all_four_udp.log.bak），
# 脚本只负责把日志路径传进去，保证程序写的是当前文件而不是旧 inode。
export RS422_LOG="$LOG"

echo "[start_rs422] 启动: --dev $DEV --pc $PC_IP --pcport $PC_PORT stream $EXTRA （$(date)）" >> "$LOG"
exec "$PROG" --dev "$DEV" --pc "$PC_IP" --pcport "$PC_PORT" stream $EXTRA >> "$LOG" 2>&1
