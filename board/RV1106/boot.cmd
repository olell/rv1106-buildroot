env set bootargs "console=ttyS0,115200 panic=5 rootwait root=/dev/mmcblk1p6 rw"
env set sys_bootargs "console=ttyFIQ0,115200 panic=5 rootwait root=/dev/mmcblk1p6 rw"
fatload mmc 1:5 0x808000 rv1106-custom.dtb
fatload mmc 1:5 0x828000 zImage
bootz 0x828000 - 0x808000
