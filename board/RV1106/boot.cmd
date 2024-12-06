env set bootcmd "fatload mmc 1:4 0x8C00000 rv1106-custom.dtb;fatload mmc 1:4 0x8000800 zImage;bootz 0x8000800 - 0x8C00000"
