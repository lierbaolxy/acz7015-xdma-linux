#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""通用：上传单个 C 源文件到板端编译运行（sudo）。
用法: python board_run.py <c文件名> [运行参数...]
"""
import os
import sys
import paramiko

HOST = os.environ.get("BOARD_IP", "172.20.32.60")
USER = os.environ.get("BOARD_USER", "zynq")
PWD = os.environ.get("BOARD_PWD", "root")
ARM_DIR = r"d:\workspace\trae\day01\0702\acz7015-xdma-linux\linux\arm_apps"


def run(cli, cmd, timeout=90):
    _, o, e = cli.exec_command(cmd, timeout=timeout)
    return (o.read().decode(errors="replace") + e.read().decode(errors="replace")).strip()


def main():
    if len(sys.argv) < 2:
        print("用法: board_run.py <c文件名> [参数...]")
        return
    src = sys.argv[1]
    args = " ".join(sys.argv[2:])
    name = os.path.splitext(src)[0]
    local = os.path.join(ARM_DIR, src)

    cli = paramiko.SSHClient()
    cli.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    cli.connect(HOST, username=USER, password=PWD, timeout=10)

    sftp = cli.open_sftp()
    sftp.put(local, "/tmp/" + src)
    sftp.close()
    print("[1] 上传 %s 完成" % src)

    r = run(cli, "cd /tmp && gcc -O2 -o %s %s 2>&1; echo EXIT=$?" % (name, src))
    print("[2] 编译:\n%s" % r)

    r = run(cli, "echo %s | sudo -S /tmp/%s %s 2>&1" % (PWD, name, args), timeout=60)
    print("[3] 运行:\n%s" % r)

    cli.close()
    print("[DONE]")


if __name__ == "__main__":
    main()