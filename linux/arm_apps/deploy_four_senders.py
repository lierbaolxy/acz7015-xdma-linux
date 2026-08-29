#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
编译 + 上传 + 启动 四路外设采集（USB/PS2/CAN/RS422，单进程）到开发板（板上 gcc 编译）

产物：
  /home/zynq/0829/arm_all_four    <- arm_all_four.c（USB/PS2/RS422/CAN 四路单进程）
  /home/zynq/0829/start_four.sh   <- 统一启动脚本
  /tmp/all_four.log               <- 运行日志（tmpfs）

用法：
  python deploy_four_senders.py           # 仅上传 + 编译 + 上传启动脚本
  python deploy_four_senders.py --start   # 额外启动四路单进程
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
SRC_MAIN = os.path.join(HERE, "arm_all_four.c")
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

    # 1. 上传单进程源码 + 启动脚本到 ~/0829（SD卡rootfs持久化,重启不丢）
    REMOTE_DIR = "/home/zynq/0829"
    cli.exec_command("mkdir -p %s" % REMOTE_DIR, timeout=10)[1].read()
    n1 = upload(cli, SRC_MAIN, "%s/arm_all_four.c" % REMOTE_DIR)
    n3 = upload(cli, SRC_START, "%s/start_four.sh" % REMOTE_DIR)
    print("[1] 上传完成 (src=%d start=%d bytes b64) -> %s" % (n1, n3, REMOTE_DIR))

    # 2. 板上编译单进程（在 ~/0829 持久化目录编译）
    cmds = [
        "cd %s && gcc -O2 -o arm_all_four arm_all_four.c 2>&1; echo EXIT=$?" % REMOTE_DIR,
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
    print("[2] 编译成功 -> %s/arm_all_four" % REMOTE_DIR)

    # 2.5 部署 CH343 驱动（ ~/0829 持久化，重启不丢；lsmod 已加载则跳过）
    if os.path.exists(KO_LOCAL):
        upload(cli, KO_LOCAL, "%s/ch343.ko" % REMOTE_DIR)
        cmd_ko = (
            "lsmod | grep -q ch343 || "
            "(echo %s | sudo -S insmod %s/ch343.ko 2>&1); "
            "ls -l /dev/ttyCH343USB0 2>&1" % (BOARD_PWD, REMOTE_DIR)
        )
        _, out, _ = cli.exec_command(cmd_ko, timeout=30)
        print("[2.5] CH343 驱动: " + out.read().decode(errors="replace").strip())
    else:
        print("[2.5] 未找到 ch343.ko，跳过驱动部署（请确保 /dev/ttyCH343USB0 已存在）")

    # 3. 可选：CAN AT 查询（验证 CH343 串口链路，不启动常驻进程）
    if do_probe:
        cmd = "echo %s | sudo -S timeout 15 %s/arm_all_four --probe 2>&1" % (BOARD_PWD, REMOTE_DIR)
        _, out, _ = cli.exec_command(cmd, timeout=60)
        print("[3] CAN 探测输出:\n" + out.read().decode(errors="replace"))
        cli.close()
        print("DONE")
        return

    # 4. 可选：启动四路单进程
    if do_start:
        cmd = "echo %s | sudo -S sh %s/start_four.sh 2>&1" % (BOARD_PWD, REMOTE_DIR)
        _, out, _ = cli.exec_command(cmd, timeout=30)
        print("[3] 启动输出:\n" + out.read().decode(errors="replace"))
        print("日志查看: sudo tail -f /tmp/all_four.log")
    else:
        print("完成。加 --start 启动，加 --probe 做 CAN AT 查询。")

    cli.close()
    print("DONE")


if __name__ == "__main__":
    main()