# -*- coding: utf-8 -*-
"""上传 + 编译 + 短跑 arm_rs422_sender.c（验证语法与启动）"""
import paramiko, sys

RUN = (len(sys.argv) > 1 and sys.argv[1] == "run")

cli = paramiko.SSHClient()
cli.set_missing_host_key_policy(paramiko.AutoAddPolicy())
cli.connect('172.20.32.60', username='zynq', password='root', timeout=10)

sftp = cli.open_sftp()
sftp.put(r"d:\workspace\trae\day01\0702\acz7015-xdma-linux\linux\arm_apps\arm_rs422_sender.c",
         '/tmp/arm_rs422_sender.c')
sftp.close()

# 编译
cmd = "gcc -O2 -o /tmp/arm_rs422_sender /tmp/arm_rs422_sender.c 2>&1; echo EXIT=$?"
_, out, err = cli.exec_command(cmd, timeout=60)
print(out.read().decode(errors='replace'))

if RUN:
    # 短跑 3 秒验证启动（切 MIO + 映射 DDR + 进入等待）
    cmd = ("echo root | sudo -S sh -c 'systemctl stop serial-getty@ttyPS0.service; "
           "timeout 3 /tmp/arm_rs422_sender' 2>&1")
    _, out, err = cli.exec_command(cmd, timeout=30)
    print("=== 短跑输出 ===")
    print(out.read().decode(errors='replace'))

cli.close()