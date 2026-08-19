# -*- coding: utf-8 -*-
"""读取双路采集程序的运行日志，统计 USB/RS422 事件并结束进程"""
import paramiko

cli = paramiko.SSHClient()
cli.set_missing_host_key_policy(paramiko.AutoAddPolicy())
cli.connect('172.20.32.60', username='zynq', password='root', timeout=10)

_, out, _ = cli.exec_command(
    "echo '=== USB 事件条数 ==='; grep -c '\\[USB' /tmp/usb_test.log 2>/dev/null; "
    "echo '=== USB 事件明细(最近40条) ==='; grep '\\[USB' /tmp/usb_test.log 2>/dev/null | tail -40; "
    "echo '=== RS422 事件 ==='; grep '\\[RS422' /tmp/usb_test.log 2>/dev/null; "
    "echo '=== 结束进程 ==='; echo root | sudo -S pkill -f arm_usb_rs422_sender 2>/dev/null; "
    "sleep 1; ps aux | grep arm_usb_rs422 | grep -v grep || echo '(已无残留进程)'",
    timeout=20)
print(out.read().decode(errors='replace'))

cli.close()