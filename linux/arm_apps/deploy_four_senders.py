#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
编译 + 上传 + 启动 四路外设采集（USB/PS2/CAN/RS422）到开发板（板上 gcc 编译）

产物：
  /tmp/arm_can_sender   <- arm_can_sender.c（CH343 USB-CANFD 包模式，CAN）
  /tmp/arm_multi        <- arm_usb_ps2_rs422_sender.c（USB/PS2/RS422 三路）
  /tmp/start_four.sh    <- 统一启动脚本

用法：
  python deploy_four_senders.py           # 仅上传 + 编译 + 上传启动脚本
  python deploy_four_senders.py --start   # 额外启动四路进程
  python deploy_four_senders.py --probe   # 上传编译后仅跑 CAN 的 AT 查询（串口链路验证，不启动常驻进程）

板卡信息经环境变量读取（BOARD_IP/BOARD_USER/BOARD_PWD），默认 172.20.32.60/zynq/root
"""
import os
import sys
import base64
import paramiko

BOARD_IP = os.environ.get("BOARD_IP", "172.20.32.60")
BOARD_USER = os.environ.get("BOARD_USER", "zynq")
BOARD_PWD = os.environ.get("BOARD_PWD", "root")

HERE = os.path.dirname(os.path.abspath(__file__))
SRC_CAN = os.path.join(HERE, "arm_can_sender.c")
SRC_MULTI = os.path.join(HERE, "arm_usb_ps2_rs422_sender.c")
SRC_START = os.path.join(HERE, "start_four.sh")
KO_LOCAL = os.path.join(HERE, "ch343.ko")


def upload(cli, local_path, remote_path):
    with open(local_path, "rb") as f:
        b64 = base64.b64encode(f.read()).decode()
    stdin, out, err = cli.exec_command("base64 -d > %s" % remote_path, timeout=60)
    stdin.write(b64)
    stdin.channel.shutdown_write()
    out.read()
    err.read()
    return len(b64)


def main():
    do_start = "--start" in sys.argv
    do_probe = "--probe" in sys.argv

    print("连接 %s@%s ..." % (BOARD_USER, BOARD_IP))
    cli = paramiko.SSHClient()
    cli.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    cli.connect(BOARD_IP, username=BOARD_USER, password=BOARD_PWD, timeout=10)

    # 1. 上传两个源码 + 启动脚本（base64，绕开 rootfs 只读）
    n1 = upload(cli, SRC_CAN, "/tmp/arm_can_sender.c")
    n2 = upload(cli, SRC_MULTI, "/tmp/arm_usb_ps2_rs422_sender.c")
    n3 = upload(cli, SRC_START, "/tmp/start_four.sh")
    print("[1] 上传完成 (can=%d multi=%d start=%d bytes b64)" % (n1, n2, n3))

    # 2. 板上编译两个（cd /tmp 落 tmpfs）
    cmds = [
        "cd /tmp && gcc -O2 -o arm_can_sender arm_can_sender.c 2>&1; echo EXIT=$?",
        "cd /tmp && gcc -O2 -o arm_multi arm_usb_ps2_rs422_sender.c 2>&1; echo EXIT=$?",
    ]
    ok = True
    for idx, cmd in enumerate(cmds, 1):
        _, out, err = cli.exec_command(cmd, timeout=60)
        o = out.read().decode(errors="replace")
        print("[2.%d] %s" % (idx, o.strip()))
        if "EXIT=0" not in o:
            ok = False
    if not ok:
        print("[FAIL] 编译失败，已终止")
        cli.close()
        sys.exit(1)
    print("[2] 编译成功 -> /tmp/arm_can_sender + /tmp/arm_multi")

    # 2.5 部署 CH343 驱动（板子重启后 /tmp 丢失，需重新上传 insmod）
    if os.path.exists(KO_LOCAL):
        upload(cli, KO_LOCAL, "/tmp/ch343.ko")
        cmd_ko = (
            "lsmod | grep -q ch343 || "
            "(echo %s | sudo -S insmod /tmp/ch343.ko 2>&1); "
            "ls -l /dev/ttyCH343USB0 2>&1" % BOARD_PWD
        )
        _, out, _ = cli.exec_command(cmd_ko, timeout=30)
        print("[2.5] CH343 驱动: " + out.read().decode(errors="replace").strip())
    else:
        print("[2.5] 未找到 ch343.ko，跳过驱动部署（请确保 /dev/ttyCH343USB0 已存在）")

    # 3. 可选：CAN AT 查询（验证 CH343 串口链路，不启动常驻进程）
    if do_probe:
        cmd = "echo %s | sudo -S timeout 15 /tmp/arm_can_sender --probe 2>&1" % BOARD_PWD
        _, out, _ = cli.exec_command(cmd, timeout=60)
        print("[3] CAN 探测输出:\n" + out.read().decode(errors="replace"))
        cli.close()
        print("DONE")
        return

    # 4. 可选：启动四路
    if do_start:
        cmd = "echo %s | sudo -S sh /tmp/start_four.sh 2>&1" % BOARD_PWD
        _, out, _ = cli.exec_command(cmd, timeout=30)
        print("[3] 启动输出:\n" + out.read().decode(errors="replace"))
        print("日志查看: sudo tail -f /tmp/can_sender.log /tmp/multi.log")
    else:
        print("完成。加 --start 启动，加 --probe 做 CAN AT 查询。")

    cli.close()
    print("DONE")


if __name__ == "__main__":
    main()