import paramiko
import time

SRC = r'd:\workspace\trae\day01\0702\acz7015-xdma-linux\linux\arm_apps\arm_ddr_write_test.c'
BIN = '/tmp/arm_ddr_write_test'

c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect('172.20.32.60', username='zynq', password='root', timeout=8)


def run(cmd):
    _, out, err = c.exec_command(cmd, timeout=40)
    o = out.read().decode(errors='replace').strip()
    e = err.read().decode(errors='replace').strip()
    return o, e


# 1. 上传源码
sftp = c.open_sftp()
sftp.put(SRC, '/tmp/arm_ddr_write_test.c')
sftp.close()
print('[1] 上传完成')

# 2. 清理旧进程
run('echo root | sudo -S pkill -f arm_ddr_write_test 2>/dev/null; true')
time.sleep(0.5)
print('[2] 清理旧进程完成')

# 3. 编译
o, e = run('gcc -O2 -o %s /tmp/arm_ddr_write_test.c' % BIN)
if e:
    print('[3] 编译告警/错误:', e)
else:
    print('[3] 编译成功:', o)

# 4. 后台运行（sudo + nohup，日志到 /tmp/ddr_test.log）
run('echo root | sudo -S sh -c "nohup %s > /tmp/ddr_test.log 2>&1 &"' % BIN)
time.sleep(2)
print('[4] 已启动')

# 5. 确认进程 + 日志
o, _ = run('echo root | sudo -S ps | grep -v grep | grep arm_ddr_write_test')
print('[5] 进程:', o if o else '(未检测到)')
o, _ = run('cat /tmp/ddr_test.log')
print('[5] 日志:', o)

c.close()
print('DONE')