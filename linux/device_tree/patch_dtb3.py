import fdt

src = r"d:\workspace\trae\day01\0702\img_files\SYSTEM.DTB"
dst = r"d:\workspace\trae\day01\0702\img_files\SYSTEM_xdma.dtb"
with open(src, "rb") as f:
    data = f.read()
dt = fdt.parse_dtb(data)

# 1. USB 改 Host
usb = "/amba/usb@e0002000"
dt.set_property("dr_mode", "host", usb)
print("USB dr_mode:", dt.get_property("dr_mode", usb))

# 2. 禁用所有 PL 侧节点 (XDMA bitstream 里没有这些硬件, 访问会 AXI 总线挂死)
# 注意: 这些节点在 /amba_pl/ 下, 不是 /amba/
DISABLE = [
    "/amba_pl/Check_GPIO@43c70000",
    "/amba_pl/DVP_Capture2DDR@43c00000",
    "/amba_pl/Measure_Camera_Parametar@43c60000",
    "/amba_pl/audio_formatter@43c10000",
    "/amba_pl/i2c@41600000",
    "/amba_pl/dma@43000000",
    "/amba_pl/clk_wiz@43c20000",
    "/amba_pl/i2s_receiver@43c30000",
    "/amba_pl/i2s_transmitter@43c40000",
    "/amba_pl/v_tc@43c50000",
    "/amba_pl/xlnx_vdma_lcd",
    "/amba/i2c@e0004000/hdmi@39",
]
print("\n=== 禁用 PL 节点 ===")
ok = 0
for path in DISABLE:
    try:
        node = dt.get_node(path)  # 确认节点存在(路径正确)
        dt.set_property("status", "disabled", path)
        v = dt.get_property("status", path)
        print(f"  [OK] {path:50s} -> {v}")
        ok += 1
    except Exception as e:
        print(f"  [失败] {path:50s} -> {e}")

print(f"\n成功禁用: {ok}/{len(DISABLE)}")

# 3. 写出新 dtb
new_dtb = dt.to_dtb()
with open(dst, "wb") as f:
    f.write(new_dtb)
print(f"写出: 原{len(data)} 新{len(new_dtb)} bytes -> {dst}")
