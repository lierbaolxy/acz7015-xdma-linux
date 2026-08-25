#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""上传 ch343.ko 到板端并 insmod，验证 CH343 USB-CANFD 驱动绑定。
用法: python deploy_ch343_ko.py [host] [user] [pwd]
默认: 172.20.32.60 zynq root
"""
import os
import sys
import hashlib
import paramiko

HOST = sys.argv[1] if len(sys.argv) > 1 else os.environ.get("BOARD_IP", "172.20.32.60")
USER = sys.argv[2] if len(sys.argv) > 2 else os.environ.get("BOARD_USER", "zynq")
PWD  = sys.argv[3] if len(sys.argv) > 3 else os.environ.get("BOARD_PWD", "root")

HERE = os.path.dirname(os.path.abspath(__file__))
LOCAL_KO = os.path.join(HERE, "ch343.ko")
REMOTE_KO = "/tmp/ch343.ko"


def run(cli, cmd, timeout=40):
    _, o, e = cli.exec_command(cmd, timeout=timeout)
    out = o.read().decode(errors="replace")
    err = e.read().decode(errors="replace")
    return (out + err).strip()


def main():
    cli = paramiko.SSHClient()
    cli.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    cli.connect(HOST, username=USER, password=PWD, timeout=10)
    print("[1] 连接成功 %s@%s" % (USER, HOST))

    sftp = cli.open_sftp()
    sftp.put(LOCAL_KO, REMOTE_KO)
    sftp.close()
    local_md5 = hashlib.md5(open(LOCAL_KO, "rb").read()).hexdigest()
    remote_md5 = run(cli, "md5sum %s" % REMOTE_KO)
    print("[2] 上传完成  本地MD5=%s  远端=%s" % (local_md5, remote_md5))

    r = run(cli, "echo %s | sudo -S insmod %s 2>&1; echo EXIT=$?" % (PWD, REMOTE_KO))
    print("[3] insmod 结果:\n%s" % r)
    if "EXIT=0" not in r:
        print("[3] insmod 失败，见上")

    r = run(cli, "lsmod | grep -i ch343; echo ---TTY---; ls -l /dev/ttyCH343* 2>&1; echo ---DMESG---; dmesg | tail -15")
    print("[4] 绑定验证:\n%s" % r)

    cli.close()
    print("[DONE]")


if __name__ == "__main__":
    main()