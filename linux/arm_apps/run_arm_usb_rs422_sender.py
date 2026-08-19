# -*- coding: utf-8 -*-
"""上传 + 编译 + 短跑 arm_usb_rs422_sender.c（验证语法、启动、双路就绪）"""
import paramiko

cli = paramiko.SSHClient()
cli.set_missing_host_key_policy(paramiko.AutoAddPolicy())
cli.connect('172.20.32.60', username='zynq', password='root', timeout=10)

sftp = cli.open_sftp()
sftp.put(r"d:\workspace\trae\day01\0702\acz7015-xdma-linux\linux\arm_apps\arm_usb_rs422_sender.c",
         '/tmp/arm_usb_rs422_sender.c')
sftp.close()

# 1. 编译
cmd = "gcc -O2 -o /tmp/arm_usb_rs422_sender /tmp/arm_usb_rs422_sender.c 2>&1; echo EXIT=$?"
_, out, err = cli.exec_command(cmd, timeout=60)
print(out.read().decode(errors='replace'))

# 2. 查 input 设备节点
cmd = "ls -l /dev/input/ 2>&1; echo '--- NAME/HANDLERS ---'; cat /proc/bus/input/devices 2>/dev/null | grep -Ei 'Name|Handlers' | head -40"
_, out, err = cli.exec_command(cmd, timeout=20)
print("=== input 设备 ===")
print(out.read().decode(errors='replace'))

# 3. 短跑 5 秒验证双路启动（切 MIO + 映射 DDR + 进入主循环）
cmd = ("echo root | sudo -S sh -c 'systemctl stop serial-getty@ttyPS0.service; "
       "timeout 5 /tmp/arm_usb_rs422_sender /dev/input/event1' 2>&1")
_, out, err = cli.exec_command(cmd, timeout=30)
print("=== 短跑输出(5s) ===")
print(out.read().decode(errors='replace'))

cli.close()