#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""上传 arm_can_tty.c 到板端，编译并运行，验证 CH343 串口 AT 通信。"""
import os
import sys
import paramiko

HOST = os.environ.get("BOARD_IP", "172.20.32.60")
USER = os.environ.get("BOARD_USER", "zynq")
PWD = os.environ.get("BOARD_PWD", "root")
LOCAL = r"d:\workspace\trae\day01\0702\acz7015-xdma-linux\linux\arm_apps\arm_can_tty.c"
REMOTE = "/tmp/arm_can_tty.c"

BAUD = sys.argv[1] if len(sys.argv) > 1 else "9600"


def run(cli, cmd, timeout=60):
    _, o, e = cli.exec_command(cmd, timeout=timeout)
    return (o.read().decode(errors="replace") + e.read().decode(errors="replace")).strip()


def main():
    cli = paramiko.SSHClient()
    cli.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    cli.connect(HOST, username=USER, password=PWD, timeout=10)

    sftp = cli.open_sftp()
    sftp.put(LOCAL, REMOTE)
    sftp.close()
    print("[1] 上传完成")

    r = run(cli, "cd /tmp && gcc -O2 -o arm_can_tty arm_can_tty.c 2>&1; echo EXIT=$?")
    print("[2] 编译:\n%s" % r)

    r = run(cli, "echo %s | sudo -S /tmp/arm_can_tty %s 2>&1" % (PWD, BAUD), timeout=40)
    print("[3] 运行结果:\n%s" % r)

    cli.close()
    print("[DONE]")


if __name__ == "__main__":
    main()