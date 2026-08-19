import paramiko
import time

SRC = r'd:\workspace\trae\day01\0702\acz7015-xdma-linux\linux\arm_apps\arm_usb_rs422_sender.c'
BIN = '/tmp/arm_usb_rs422_sender'

c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect('172.20.32.60', username='zynq', password='root', timeout=8)


def run(cmd):
    _, out, err = c.exec_command(cmd, timeout=40)
    return out.read().decode(errors='replace').strip(), err.read().decode(errors='replace').strip()


# 1. 上传源码
sftp = c.open_sftp()
sftp.put(SRC, '/tmp/arm_usb_rs422_sender.c')
sftp.close()
print('[1] 上传完成')

# 2. 清理旧进程 + 停 console
run('echo root | sudo -S pkill -f arm_usb_rs422_sender 2>/dev/null; true')
run('echo root | sudo -S systemctl stop serial-getty@ttyPS0.service 2>/dev/null; true')
time.sleep(0.5)
print('[2] 已停旧进程 + serial-getty@ttyPS0')

# 3. 编译
o, e = run('gcc -O2 -o %s /tmp/arm_usb_rs422_sender.c' % BIN)
print('[3] 编译:', e if e else 'OK')

# 4. 后台运行（默认 /dev/input/event1）
run('echo root | sudo -S sh -c "nohup %s /dev/input/event1 > /tmp/usb_rs422.log 2>&1 &"' % BIN)
time.sleep(2)
print('[4] 已启动')

# 5. 确认进程 + 日志
o, _ = run('echo root | sudo -S ps | grep -v grep | grep arm_usb_rs422')
print('[5] 进程:', o if o else '(未检测到，可能名被截断)')
o, _ = run('head -20 /tmp/usb_rs422.log')
print('[5] 日志:\n' + o)

c.close()
print('DONE')