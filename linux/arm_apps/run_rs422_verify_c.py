# -*- coding: utf-8 -*-
"""上传 + 编译 + 运行 rs422_verify.c（板端 gcc）"""
import paramiko, sys

ROUNDS = sys.argv[1] if len(sys.argv) > 1 else "20"

cli = paramiko.SSHClient()
cli.set_missing_host_key_policy(paramiko.AutoAddPolicy())
cli.connect('172.20.32.60', username='zynq', password='root', timeout=10)

sftp = cli.open_sftp()
sftp.put(r"d:\workspace\trae\day01\0702\acz7015-xdma-linux\linux\arm_apps\rs422_verify.c", '/tmp/rs422_verify.c')
sftp.close()

# 编译 + 停 getty + 运行（sudo 密码 root）
cmd = ("echo root | sudo -S sh -c '"
       "gcc -O2 -o /tmp/rs422_verify /tmp/rs422_verify.c && "
       "systemctl stop serial-getty@ttyPS0.service; "
       "/tmp/rs422_verify %s'" % ROUNDS)

_, out, err = cli.exec_command(cmd, timeout=90)
print(out.read().decode(errors='replace'))
e = err.read().decode(errors='replace')
if e.strip():
    print('--- stderr ---')
    print(e)
cli.close()