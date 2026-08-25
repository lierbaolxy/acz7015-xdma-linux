# -*- coding: utf-8 -*-
"""确认 SD 卡当前部署的 bitstream 版本（只读，不写）"""
import os
import paramiko

IP = os.environ.get("BOARD_IP", "172.20.32.60")
USER = os.environ.get("BOARD_USER", "zynq")
PWD = os.environ.get("BOARD_PWD", "root")

c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect(IP, username=USER, password=PWD, timeout=10)


def run(cmd, t=30):
    _, o, e = c.exec_command(cmd, timeout=t)
    return o.read().decode(errors="replace"), e.read().decode(errors="replace")


def sudo_sh(cmd):
    return "echo %s | sudo -S sh -c '%s'" % (PWD, cmd.replace("'", "'\\''"))


# 1. 挂载 FAT 分区（只读）
o, e = run("mountpoint -q /mnt/fat && echo MOUNTED || echo NOT", 15)
print("=== FAT挂载状态 ===")
print(o.strip() or e.strip())

if "MOUNTED" not in (o + e):
    o, e = run(sudo_sh("mkdir -p /mnt/fat; mount -t vfat -o ro /dev/mmcblk0p1 /mnt/fat 2>&1"), 20)
    print("挂载尝试:", (o + e).strip())

# 2. FAT 分区 system.bit 及关键文件
o, e = run("ls -la /mnt/fat/ 2>&1", 15)
print("=== /mnt/fat 内容 ===")
print(o.strip() or e.strip())

# 3. system.bit MD5
o, e = run("md5sum /mnt/fat/system.bit 2>&1", 20)
print("=== system.bit MD5 ===")
print(o.strip() or e.strip())

# 4. 备份目录里的已知版本
o, e = run("ls -la /mnt/fat/backup_pre_rs422/ 2>/dev/null; echo ---; ls -la /home/zynq/*.bit* 2>/dev/null | head -20", 15)
print("=== 备份文件 ===")
print(o.strip())

c.close()
print("DONE")