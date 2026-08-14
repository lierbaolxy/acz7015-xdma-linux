#!/usr/bin/env python3
"""PS端开发板自动部署：传输arm_mouse_sender.c + 编译 + 后台运行"""
import paramiko
import sys
import time

HOST = "172.20.33.225"
USER = "zynq"
PASS = "root"
LOCAL_C = r"d:\workspace\trae\day01\0702\latency_test\arm_mouse_sender.c"
REMOTE_C = "/home/zynq/arm_mouse_sender.c"
REMOTE_BIN = "/home/zynq/arm_mouse_sender"

def run(cmd, sudo=False, timeout=30):
    """执行命令，返回(stdout, stderr, exit_code)"""
    if sudo:
        cmd = f"echo '{PASS}' | sudo -S {cmd}"
    stdin, stdout, stderr = client.exec_command(cmd, timeout=timeout)
    out = stdout.read().decode('utf-8', errors='replace').strip()
    err = stderr.read().decode('utf-8', errors='replace').strip()
    code = stdout.channel.recv_exit_status()
    return out, err, code

print(f"=== PS端部署开始 ===")
print(f"连接 {USER}@{HOST}...")

client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
try:
    client.connect(HOST, username=USER, password=PASS, timeout=10)
except Exception as e:
    print(f"SSH连接失败: {e}")
    sys.exit(1)
print("SSH连接成功")

# 1. 先杀掉旧进程
print("\n[1/5] 清理旧进程...")
out, err, code = run("pkill -f arm_mouse_sender", sudo=True)
print(f"  清理完成（exit={code}）")

# 2. SFTP传输文件
print("\n[2/5] 传输arm_mouse_sender.c...")
sftp = client.open_sftp()
sftp.put(LOCAL_C, REMOTE_C)
stat = sftp.stat(REMOTE_C)
print(f"  传输成功，大小={stat.st_size}字节")
sftp.close()

# 3. 编译
print("\n[3/5] 编译...")
out, err, code = run(f"gcc -O2 -o {REMOTE_BIN} {REMOTE_C}", timeout=30)
if code != 0:
    print(f"  编译失败！exit={code}")
    print(f"  stderr: {err}")
    client.close()
    sys.exit(1)
print(f"  编译成功")

# 4. 验证二进制
print("\n[4/5] 验证二进制...")
out, err, code = run(f"ls -la {REMOTE_BIN}")
print(f"  {out}")

# 5. 后台运行（sudo + nohup，输出重定向到日志，用event0鼠标设备）
print("\n[5/5] 后台启动arm_mouse_sender...")
# 先清空日志
run("rm -f /tmp/sender.log", sudo=True)
# nohup后台运行，参数指定鼠标设备/dev/input/event0（SIGMACHIP Usb Mouse）
run(f"nohup {REMOTE_BIN} /dev/input/event0 > /tmp/sender.log 2>&1 &", sudo=True)
time.sleep(2)

# 检查进程是否在运行
out, err, code = run("pgrep -f arm_mouse_sender", sudo=True)
if out:
    pid = out.split('\n')[0]
    print(f"  进程运行中，PID={pid}")
    # 读日志
    out2, _, _ = run("cat /tmp/sender.log", sudo=True)
    print(f"\n  === 启动日志 ===")
    for line in out2.split('\n')[:10]:
        if line.strip():
            print(f"  {line}")
else:
    print("  警告：进程未检测到，查看日志：")
    out2, _, _ = run("cat /tmp/sender.log", sudo=True)
    print(out2)

client.close()
print("\n=== PS端部署完成，等待PC端接收 ===")
