# -*- coding: utf-8 -*-
"""核查板卡 CAN 部署前置状态（只读，无副作用）"""
import os
import paramiko

IP = os.environ.get("BOARD_IP", "172.20.32.60")
USER = os.environ.get("BOARD_USER", "zynq")
PWD = os.environ.get("BOARD_PWD", "root")

c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect(IP, username=USER, password=PWD, timeout=10)


def run(cmd):
    _, o, e = c.exec_command(cmd, timeout=25)
    return o.read().decode(errors="replace"), e.read().decode(errors="replace")


def sudo(cmd):
    return "echo %s | sudo -S %s" % (PWD, cmd)


checks = [
    ("系统", "uname -srm"),
    ("根分区挂载", "mount | grep 'on / '"),
    ("磁盘占用", "df -h / 2>&1"),
    ("SPI0时钟(APER_CLK_CTRL)", sudo("busybox devmem 0xF800012C 32 2>&1")),
    ("SPI0时钟(SPI_CLK_CTRL)", sudo("busybox devmem 0xF8000158 32 2>&1")),
    ("SPI0复位(SPI_RST_CTRL)", sudo("busybox devmem 0xF800021C 32 2>&1")),
    ("SPI0 CR寄存器(0xE0006000)", sudo("busybox devmem 0xE0006000 32 2>&1")),
    ("SPI0 SR寄存器(0xE0006004)", sudo("busybox devmem 0xE0006004 32 2>&1")),
    ("排针UART1控制(0xF8000154)", sudo("busybox devmem 0xF8000154 32 2>&1")),
]

for name, cmd in checks:
    o, e = run(cmd)
    print("=== %s ===" % name)
    if o.strip():
        print(o.strip())
    if e.strip():
        print("[err]", e.strip())
    print()

c.close()
print("DONE")