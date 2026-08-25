#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
编译 + 上传 arm_can_sender.c 到开发板（板上本机 gcc 编译）
用法：
    python deploy_can_sender.py              # 仅上传 + 编译
    python deploy_can_sender.py --run        # 上传 + 编译 + 运行 normal 模式（8s 短跑）
    python deploy_can_sender.py --probe      # 上传 + 编译 + 读 DEVID 验证 SPI 链路/模块接线
    python deploy_can_sender.py --loopback   # 上传 + 编译 + 内部回环自检（不驱动总线，零硬件风险）
板卡信息经环境变量读取（BOARD_IP/BOARD_USER/BOARD_PWD），默认 172.20.32.60/zynq/root
"""
import os
import sys
import paramiko

BOARD_IP = os.environ.get("BOARD_IP", "172.20.32.60")
BOARD_USER = os.environ.get("BOARD_USER", "zynq")
BOARD_PWD = os.environ.get("BOARD_PWD", "root")

SRC = os.path.join(os.path.dirname(os.path.abspath(__file__)), "arm_can_sender.c")
REMOTE_SRC = "/tmp/arm_can_sender.c"
REMOTE_BIN = "/tmp/arm_can_sender"


def main():
    args = sys.argv[1:]
    mode = ""
    if "--probe" in args:
        mode = "--probe"
    elif "--loopback" in args:
        mode = "--loopback"
    do_run = ("--run" in args) or bool(mode)

    print("连接 %s@%s ..." % (BOARD_USER, BOARD_IP))

    cli = paramiko.SSHClient()
    cli.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    cli.connect(BOARD_IP, username=BOARD_USER, password=BOARD_PWD, timeout=10)

    # 1. 上传源码（base64 + stdin 管道，绕开 SFTP 因 rootfs 只读而失败）
    import base64 as _b64
    with open(SRC, 'rb') as f:
        src_b64 = _b64.b64encode(f.read()).decode()
    stdin, out, err = cli.exec_command("base64 -d > %s" % REMOTE_SRC, timeout=60)
    stdin.write(src_b64)
    stdin.channel.shutdown_write()
    out.read()
    err.read()
    print("[1] 上传完成 -> %s (%d bytes b64)" % (REMOTE_SRC, len(src_b64)))

    # 2. 板上 gcc 编译（cd /tmp 让临时文件落在 tmpfs，避开只读 rootfs）
    _, out, err = cli.exec_command(
        "cd /tmp && gcc -O2 -o %s %s 2>&1; echo EXIT=$?" % (REMOTE_BIN, REMOTE_SRC),
        timeout=60)
    o = out.read().decode(errors="replace")
    print(o)
    if "EXIT=0" not in o:
        print("[FAIL] 编译失败，已终止")
        cli.close()
        sys.exit(1)
    print("[2] 编译成功 -> %s" % REMOTE_BIN)

    # 3. 可选运行验证
    if not do_run:
        print("完成。加 --probe/--loopback/--run 参数可运行验证。")
        cli.close()
        return

    # loopback 需 FRESET + 回环 + 200ms 轮询，超时放宽；probe 读 DEVID 很快
    timeout_s = "20" if mode == "--loopback" else "15"
    cmd = "echo %s | sudo -S sh -c 'timeout %s %s %s'" % (BOARD_PWD, timeout_s, REMOTE_BIN, mode)
    _, out, _ = cli.exec_command(cmd, timeout=70)
    print("[3] 运行输出(mode=%s):\n" % (mode or "normal") + out.read().decode(errors="replace"))
    cli.close()
    print("DONE")


if __name__ == "__main__":
    main()