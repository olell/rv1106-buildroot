setenv bootargs console=tty0 console=ttyS0,115200 panic=5 rootwait g_acm_ms.removable=1 root=/dev/mmcblk0p2 rw resume=/dev/mmcblk0p4 resumewait
load mmc 0:1 0x80C00000 suniv-f1c100s-pocketpill-custom.dtb
load mmc 0:1 0x80008000 zImage
bootz 0x80008000 - 0x80C00000
