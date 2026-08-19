# -*- coding: utf-8 -*-
"""RS422 采集程序端到端验证：后台跑 sender + 发帧 + 读日志"""
import paramiko, time

cli = paramiko.SSHClient()
cli.set_missing_host_key_policy(paramiko.AutoAddPolicy())
cli.connect('172.20.32.60', username='zynq', password='root', timeout=10)

def run(cmd, t=60):
    _, o, e = cli.exec_command(cmd, timeout=t)
    return o.read().decode(errors='replace'), e.read().decode(errors='replace')

# 1. 上传源码与发帧脚本
sftp = cli.open_sftp()
sftp.put(r"d:\workspace\trae\day01\0702\acz7015-xdma-linux\linux\arm_apps\arm_rs422_sender.c", '/tmp/sender_test.c')
sftp.put(r"d:\workspace\trae\day01\0702\acz7015-xdma-linux\fpga\can_integration\send_frame.py", '/tmp/send_frame.py')
sftp.close()

# 2. 编译
o, _ = run("gcc -O2 -o /tmp/sender_test /tmp/sender_test.c 2>&1; echo COMPILE_DONE")
print(o.strip().split('\n')[-1])

# 3. 清理旧进程 + 停 getty
run("echo root | sudo -S sh -c 'pkill -f sender_test; pkill -f a.out; pkill -f arm_rs422_sender; systemctl stop serial-getty@ttyPS0.service; rm -f /tmp/sender.log'")

# 4. 后台启动 sender，日志重定向
run("echo root | sudo -S sh -c 'nohup /tmp/sender_test > /tmp/sender.log 2>&1 &'")
time.sleep(2)

# 5. 发帧
o, _ = run("echo root | sudo -S python3 /tmp/send_frame.py")
print(o.strip())
time.sleep(1)

# 6. 读日志
o, _ = run("cat /tmp/sender.log")
print("=== sender 日志 ===")
print(o)

# 7. 杀掉 sender
run("echo root | sudo -S sh -c 'pkill -f sender_test'")
cli.close()