#!/usr/bin/env python3
"""
修改 SYSTEM_xdma.dtb：
1. aliases.spi0 → "/amba/spi@e0006000" (PS SPI0)
2. aliases.spi1 → "/amba/spi@e000d000" (QSPI)
3. usb@e0002000.dr_mode → "host"

用法：python patch_dtb.py
"""
import fdt
import sys
import os

SRC_DTB = r"D:\workspace\trae\day01\0702\acz7015-xdma-linux\部署\启动文件\SYSTEM_xdma.dtb"
DST_DTB = SRC_DTB  # 覆盖原文件（备份在外部）

def main():
    # 备份
    bak = SRC_DTB + ".bak"
    if not os.path.exists(bak):
        with open(SRC_DTB, "rb") as f, open(bak, "wb") as g:
            g.write(f.read())
        print(f"备份: {bak}")

    with open(SRC_DTB, "rb") as f:
        data = f.read()
    print(f"原dtb大小: {len(data)} 字节")

    dt = fdt.parse_dtb(data)
    print(f"解析成功，根节点: {dt.root.name if dt.root else 'NONE'}")

    # 1. 修改 aliases
    aliases = dt.get_node("/aliases")
    if aliases is None:
        print("ERROR: /aliases 节点不存在"); sys.exit(1)

    # 当前 spi0
    spi0 = aliases.get_property("spi0")
    if spi0:
        print(f"原 aliases.spi0 = {spi0.value}")
    aliases.set_property("spi0", "/amba/spi@e0006000")
    print("新 aliases.spi0 = /amba/spi@e0006000")

    # 检查是否已有 spi1
    spi1 = aliases.get_property("spi1")
    if spi1:
        print(f"原 aliases.spi1 = {spi1.value}")
    aliases.set_property("spi1", "/amba/spi@e000d000")
    print("新 aliases.spi1 = /amba/spi@e000d000")

    # 2. 修改 usb@e0002000 的 dr_mode
    usb_node = dt.get_node("/amba/usb@e0002000")
    if usb_node is None:
        print("WARNING: /amba/usb@e0002000 节点不存在，跳过 dr_mode 修改")
    else:
        dr_mode = usb_node.get_property("dr_mode")
        if dr_mode:
            print(f"原 usb@e0002000.dr_mode = {dr_mode.value}")
        usb_node.set_property("dr_mode", "host")
        print("新 usb@e0002000.dr_mode = host")

    # 3. 序列化回 dtb
    new_data = dt.to_dtb()
    print(f"新dtb大小: {len(new_data)} 字节")

    with open(DST_DTB, "wb") as f:
        f.write(new_data)
    print(f"已写入: {DST_DTB}")

    # 4. 验证：重新读回检查
    with open(DST_DTB, "rb") as f:
        verify_data = f.read()
    verify_dt = fdt.parse_dtb(verify_data)
    v_aliases = verify_dt.get_node("/aliases")
    v_spi0 = v_aliases.get_property("spi0")
    v_spi1 = v_aliases.get_property("spi1")
    v_usb = verify_dt.get_node("/amba/usb@e0002000")
    v_dr = v_usb.get_property("dr_mode") if v_usb else None
    print("\n=== 验证结果 ===")
    print(f"aliases.spi0 = {v_spi0.value if v_spi0 else 'MISSING'}")
    print(f"aliases.spi1 = {v_spi1.value if v_spi1 else 'MISSING'}")
    print(f"usb@e0002000.dr_mode = {v_dr.value if v_dr else 'MISSING'}")
    if (v_spi0 and v_spi0.value == "/amba/spi@e0006000" and
        v_spi1 and v_spi1.value == "/amba/spi@e000d000" and
        v_dr and v_dr.value == "host"):
        print("\n✅ 全部修改成功！dtb 可用于 SD 卡烧录")
    else:
        print("\n❌ 修改失败，请检查")

if __name__ == "__main__":
    main()
