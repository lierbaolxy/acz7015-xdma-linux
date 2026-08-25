#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
部署 CAN 版 bitstream（MCP2518FD SPI0 EMIO）到 SD 卡 FAT 分区，替换 system.bit

关键前提：
  - CAN 版 bitstream = SYSTEM_can.bit，MD5 = A38418C775CAD335CB06B8F7E061F976
    在方案A(XDMA+UART1, D7BD6FFC) 基础上启用 SPI0 EMIO(C4/D5/G8/C8) + axi_gpio(0x41200000)
  - 当前 system.bit = 方案A(XDMA+UART1)，无 SPI0 EMIO，故 MCP2518FD 读不到
  - 替换后必须重启 PC 才能让新 bitstream 生效（开发板由 PCIe 供电，bitstream 在 BOOT.BIN 时从 SD 加载）

用法：
  python deploy_can_bit.py               # 备份 + 部署 + 校验（默认执行）
  python deploy_can_bit.py --check       # 只读检查当前版本，不替换
  python deploy_can_bit.py --restore     # 从备份恢复部署前的原版 system.bit

安全：部署前自动把当前 system.bit 备份到 /mnt/fat/backup_can/<原MD5>.bak，可无损恢复。
"""
import os
import sys
import hashlib
import paramiko

BOARD_IP = os.environ.get("BOARD_IP", "172.20.32.60")
BOARD_USER = os.environ.get("BOARD_USER", "zynq")
BOARD_PWD = os.environ.get("BOARD_PWD", "root")

# CAN 版 bitstream（本地仓库）与目标 MD5
LOCAL_CAN_BIT = r"d:\workspace\trae\day01\0702\acz7015-xdma-linux\部署\启动文件\SYSTEM_can.bit"
CAN_BIT_MD5 = "A38418C775CAD335CB06B8F7E061F976"

FAT_MOUNT = "/mnt/fat"
FAT_DEV = "/dev/mmcblk0p1"
TARGET = "/mnt/fat/system.bit"
BACKUP_DIR = "/mnt/fat/backup_can"


def local_md5(path):
    h = hashlib.md5()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest().upper()


def sudo(cmd):
    return "echo %s | sudo -S sh -c '%s'" % (BOARD_PWD, cmd.replace("'", "'\\''"))


def main():
    mode = "--restore" in sys.argv or "--check" in sys.argv
    action = "restore" if "--restore" in sys.argv else ("check" if "--check" in sys.argv else "deploy")

    # 部署前先本地校验 CAN 版 bitstream MD5
    if action in ("deploy", "check"):
        lm = local_md5(LOCAL_CAN_BIT)
        print("本地 SYSTEM_can.bit MD5 = %s %s" % (lm, "[OK]" if lm == CAN_BIT_MD5 else "[MISMATCH!]"))
        if lm != CAN_BIT_MD5:
            print("[FAIL] 本地 CAN 版 bitstream MD5 与档案不符，中止")
            sys.exit(1)

    print("连接 %s@%s ..." % (BOARD_USER, BOARD_IP))
    cli = paramiko.SSHClient()
    cli.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    cli.connect(BOARD_IP, username=BOARD_USER, password=BOARD_PWD, timeout=10)

    def run(cmd, t=60):
        _, o, e = cli.exec_command(cmd, timeout=t)
        return o.read().decode(errors="replace"), e.read().decode(errors="replace")

    # 1. 挂载 FAT（读写）。开机默认 ro 挂载，先尝试 remount rw
    o, e = run("mountpoint -q %s && echo MOUNTED || echo NOT" % FAT_MOUNT, 15)
    if "MOUNTED" in (o + e):
        o, e = run(sudo("mount -o remount,rw %s 2>&1" % FAT_MOUNT), 20)
        print("remount rw:", (o + e).strip() or "OK")
    else:
        o, e = run(sudo("mkdir -p %s; mount -t vfat %s %s 2>&1" % (FAT_MOUNT, FAT_DEV, FAT_MOUNT)), 20)
        print("挂载:", (o + e).strip())
    o, e = run("mount | grep %s" % FAT_MOUNT, 15)
    print("挂载状态:", o.strip())

    o, e = run("md5sum %s 2>&1" % TARGET, 30)
    cur_md5 = o.split()[0].upper() if o else ""
    print("当前 system.bit MD5 = %s" % (cur_md5 or "读取失败"))

    if action == "check":
        print("检查完成：当前=%s，CAN版=%s" % (cur_md5, CAN_BIT_MD5))
        cli.close()
        return

    # 2. 备份当前（仅在部署时）
    if action == "deploy":
        if cur_md5 == CAN_BIT_MD5:
            print("当前已是 CAN 版，跳过部署。")
            cli.close()
            return
        run(sudo("mkdir -p %s" % BACKUP_DIR), 20)
        backup = "%s/system.bit.%s.bak" % (BACKUP_DIR, cur_md5)
        o, e = run(sudo("cp %s %s && sync" % (TARGET, backup)), 60)
        o2, e2 = run("md5sum %s 2>&1" % backup, 30)
        print("备份 -> %s (%s)" % (backup, o2.split()[0] if o2 else "校验失败"))

        # 3. SFTP 上传 CAN 版 bitstream 到 /tmp
        sftp = cli.open_sftp()
        sftp.put(LOCAL_CAN_BIT, "/tmp/SYSTEM_can.bit")
        sftp.close()
        print("[OK] 上传 SYSTEM_can.bit 到 /tmp")

        # 4. 替换 + sync + 校验
        o, e = run(sudo("cp /tmp/SYSTEM_can.bit %s && sync" % TARGET), 90)
        o2, e2 = run("md5sum %s 2>&1" % TARGET, 30)
        new_md5 = o2.split()[0].upper() if o2 else ""
        print("部署后 system.bit MD5 = %s %s" % (new_md5, "[OK]" if new_md5 == CAN_BIT_MD5 else "[MISMATCH!]"))
        if new_md5 != CAN_BIT_MD5:
            print("[FAIL] 部署后 MD5 校验失败，请从备份恢复")
            sys.exit(1)
        print("[OK] CAN 版 bitstream 已部署，重启 PC 后生效")
        print("     恢复命令: python deploy_can_bit.py --restore")

    # 5. 恢复（仅 restore）
    if action == "restore":
        o, e = run("ls %s/ 2>&1" % BACKUP_DIR, 15)
        print("可用备份:\n" + o.strip())
        # 找最新备份
        o, e = run("ls -t %s/system.bit.*.bak 2>/dev/null | head -1" % BACKUP_DIR, 15)
        bak = o.strip()
        if not bak:
            print("[FAIL] 未找到备份文件")
            sys.exit(1)
        o, e = run(sudo("cp %s %s && sync" % (bak, TARGET)), 60)
        o2, e2 = run("md5sum %s 2>&1" % TARGET, 30)
        print("恢复后 system.bit MD5 = %s (来自 %s)" % (o2.split()[0] if o2 else "?", bak))

    cli.close()
    print("DONE")


if __name__ == "__main__":
    main()