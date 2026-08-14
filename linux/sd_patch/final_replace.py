"""
最终替换脚本: 直接操作 E盘(SD卡) 的三个文件
1. 备份原 system.bit / system.dtb / uEnv.txt
2. 替换 system.bit (XDMA bitstream)
3. 替换 system.dtb (USB Host 改造版)
4. 修改 uEnv.txt: bitstream_size 0x300000 -> 0x400000 (XDMA bitstream 3.35MB > 3MB)
"""
import os, shutil

SD = "E:\\"   # SD卡FAT分区当前盘符
SRC = r"d:\workspace\trae\day01\0702\img_files"
BAK = os.path.join(SD, "_orig_backup")
os.makedirs(BAK, exist_ok=True)

# ===== 1. 备份原文件 =====
print("=== 1. 备份原文件 ===")
for f in ["system.bit", "system.dtb", "uEnv.txt"]:
    src = os.path.join(SD, f)
    if os.path.isfile(src):
        shutil.copy2(src, os.path.join(BAK, f))
        print(f"  备份 {f} ({os.path.getsize(src)} bytes)")

# ===== 2. 替换 system.bit (XDMA bitstream) =====
print("\n=== 2. 替换 system.bit ===")
old_bit = os.path.getsize(os.path.join(SD, "system.bit"))
shutil.copy2(os.path.join(SRC, "SYSTEM_xdma.bit"), os.path.join(SD, "system.bit"))
new_bit = os.path.getsize(os.path.join(SD, "system.bit"))
print(f"  原厂: {old_bit} bytes -> XDMA: {new_bit} bytes")

# ===== 3. 替换 system.dtb (USB Host 改造版) =====
print("\n=== 3. 替换 system.dtb ===")
old_dtb = os.path.getsize(os.path.join(SD, "system.dtb"))
shutil.copy2(os.path.join(SRC, "SYSTEM_xdma.dtb"), os.path.join(SD, "system.dtb"))
new_dtb = os.path.getsize(os.path.join(SD, "system.dtb"))
print(f"  原厂: {old_dtb} bytes -> 改造: {new_dtb} bytes")

# ===== 4. 修改 uEnv.txt: bitstream_size =====
print("\n=== 4. 修改 uEnv.txt ===")
uenv = os.path.join(SD, "uEnv.txt")
with open(uenv, "r") as f:
    content = f.read()

print("  改前 bitstream_size 行:")
for line in content.splitlines():
    if "bitstream_size" in line:
        print(f"    {line}")

# 0x300000(3MB) -> 0x400000(4MB), XDMA bitstream 3.35MB 需要更大空间
content = content.replace("bitstream_size=0x300000", "bitstream_size=0x400000")

with open(uenv, "w") as f:
    f.write(content)

print("  改后 bitstream_size 行:")
for line in content.splitlines():
    if "bitstream_size" in line:
        print(f"    {line}")

# ===== 5. 验证 =====
print("\n=== 5. 验证 ===")
print(f"  system.bit  : {os.path.getsize(os.path.join(SD, 'system.bit'))} bytes")
print(f"  system.dtb  : {os.path.getsize(os.path.join(SD, 'system.dtb'))} bytes")
with open(uenv, "r") as f:
    for line in f:
        if "bitstream_image" in line or "devicetree_image" in line or "bitstream_size" in line:
            print(f"  uEnv.txt    : {line.strip()}")

print("\n=== 全部完成! ===")
print(f"备份目录: {BAK}")
print("\n下一步: 拔下SD卡, 插到开发板, 设SD启动(MIO5=1,MIO4=0), 上电")
