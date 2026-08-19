# -*- coding: utf-8 -*-
"""后台启动双路采集程序，用于配合用户动鼠标做 USB 端到端验证（日志落 /tmp/usb_test.log）"""
import paramiko, time

cli = paramiko.SSHClient()
cli.set_missing_host_key_policy(paramiko.AutoAddPolicy())
cli.connect('172.20.32.60', username='zynq', password='root', timeout=10)

cmd = ("echo root | sudo -S sh -c 'systemctl stop serial-getty@ttyPS0.service; "
       "nohup /tmp/arm_usb_rs422_sender /dev/input/event1 > /tmp/usb_test.log 2>&1 "
       "< /dev/null & echo PID=$!'")
_, out, err = cli.exec_command(cmd, timeout=15)
print(out.read().decode(errors='replace'))

time.sleep(3)

_, out2, _ = cli.exec_command("ps aux | grep arm_usb_rs422 | grep -v grep", timeout=10)
print("=== 进程确认 ===")
print(out2.read().decode(errors='replace'))

_, out3, _ = cli.exec_command("cat /tmp/usb_test.log", timeout=10)
print("=== 初始日志 ===")
print(out3.read().decode(errors='replace'))

cli.close()