env set bootargs "console=ttyFIQ0,115200 panic=5 rootwait root=/dev/mmcblk1p6 rw"
env set sys_bootargs "console=ttyFIQ0,115200 panic=5 rootwait root=/dev/mmcblk1p6 rw"
fatload mmc 1:5 0x8C00000 rv1106-custom.dtb
fatload mmc 1:5 0x8000800 zImage
bootz 0x8000800 - 0x8C00000
