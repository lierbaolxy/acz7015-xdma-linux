#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
一键重启开发板，重启后自动检查 CH343 驱动与四路采集程序是否正常运行。

用法：
  python reboot_and_check.py           # 重启 + 等待恢复 + 检查
  python reboot_and_check.py --check   # 不重启，仅检查当前状态

板卡信息经环境变量读取（BOARD_IP/BOARD_USER/BOARD_PWD），默认 172.20.32.60/zynq/root
"""
import os
import sys
import time
import paramiko

BOARD_IP = os.environ.get("BOARD_IP", "172.20.32.60")
BOARD_USER = os.environ.get("BOARD_USER", "zynq")
BOARD_PWD = os.environ.get("BOARD_PWD", "root")

# 重启后等待 SSH 恢复的最长时间与轮询间隔
WAIT_TIMEOUT = 150
POLL_INTERVAL = 5


def connect(timeout=10):
    cli = paramiko.SSHClient()
    cli.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    cli.connect(BOARD_IP, username=BOARD_USER, password=BOARD_PWD, timeout=timeout)
    return cli


def run(cli, cmd, timeout=30):
    _, o, e = cli.exec_command(cmd, timeout=timeout)
    return (o.read().decode(errors="replace") + e.read().decode(errors="replace")).strip()


def do_reboot():
    """后台触发软重启，避免 SSH 会话被卡死"""
    cli = connect(10)
    cmd = "echo %s | sudo -S sh -c '(sleep 2 && reboot) &'" % BOARD_PWD
    try:
        run(cli, cmd, timeout=8)
    except Exception:
        pass  # 重启会导致连接中断，属正常
    finally:
        cli.close()
    print("[1] 已发送重启命令，等待板卡重启...")


def wait_recover():
    """轮询等待 SSH 恢复：连接成功不算数，须先探测 echo OK 确认通道真正可用"""
    start = time.time()
    while time.time() - start < WAIT_TIMEOUT:
        try:
            cli = connect(6)
            alive = run(cli, "echo OK", timeout=8)
            if alive.strip() == "OK":
                return cli
            cli.close()
        except Exception:
            pass
        el = int(time.time() - start)
        print("    等待恢复中... (%ds)" % el)
        time.sleep(POLL_INTERVAL)
    print("[FAIL] %ds 内未恢复 SSH，请检查板卡供电/网络" % WAIT_TIMEOUT)
    return None


def do_check(cli):
    print("\n[2] 检查结果")
    # 1. CH343 驱动 + 设备节点
    drv = run(cli, "lsmod | grep -q '^ch343 ' && echo LOADED || echo NOT_LOADED")
    node = run(cli, "ls -l /dev/ttyCH343USB0 2>&1")
    print("  CH343 驱动: %s" % drv)
    print("  设备节点  : %s" % node)

    # 2. 采集进程
    can = run(cli, "ps -eo comm | grep -q arm_can_sender && echo RUNNING || echo NOT_RUNNING")
    multi = run(cli, "ps -eo comm | grep -q arm_multi && echo RUNNING || echo NOT_RUNNING")
    print("  CAN 进程  : %s" % can)
    print("  三路进程  : %s" % multi)
    print("  进程明细  :")
    ps = run(cli, "ps -eo pid,comm | grep -E 'arm_can_sender|arm_multi' | grep -v grep")
    print("    " + (ps if ps else "(无)"))

    # 3. 采集日志末尾
    can_log = run(cli, "tail -5 /home/zynq/can_sender.log 2>&1")
    multi_log = run(cli, "tail -5 /home/zynq/multi.log 2>&1")
    print("  can_sender.log 尾部:\n" + "\n".join("    " + l for l in can_log.splitlines()))
    print("  multi.log 尾部:\n" + "\n".join("    " + l for l in multi_log.splitlines()))

    # 4. 结论
    ok = drv == "LOADED" and can == "RUNNING" and multi == "RUNNING"
    print("\n[3] 结论: %s" % ("全部正常" if ok else "存在异常，请排查"))
    if not ok:
        print("  建议: 检查 /home/zynq/ 下二进制与 start_four.sh 是否齐全、rc.local 是否含自启行")
    return ok


def main():
    only_check = "--check" in sys.argv
    if not only_check:
        do_reboot()
        cli = wait_recover()
        if cli is None:
            sys.exit(1)
    else:
        print("[0] 跳过重启，仅检查当前状态")
        cli = connect(10)

    ok = do_check(cli)
    cli.close()
    print("\n[DONE]")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()