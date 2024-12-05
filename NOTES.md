# LuckFox Pico - mainline linux boot effort

Chip: Rockchip RV1106g3

### Todo:

- [ ] Load and start rockchips uboot version from SD card
- [ ] Build a running kernel
- [ ] Run the kernel

### SD card layout of known booting image

| addr         |  offset | sector 512b | image        | content?                         |
| ------------ | ------: | ----------: | ------------ | -------------------------------- |
| `0x00000000` |       0 |        0x00 | env.img      |                                  |
| `0x00008000` |     32k |        0x40 | idblock.img  | DDR init + uboot spl - see below |
| `0x00088000` |    544k |       0x440 | uboot.img    |                                  |
| `0x000c8000` |    800k |             | boot.img     |                                  |
| `0x020c8000` |  33568k |             | oem.img      |                                  |
| `0x220c8000` | 557856k |             | userdata.img |                                  |
| `0x320c8000` | 820000k |             | rootfs.img   |                                  |

### How does the RV1106 boot?

1. Chip loads binary boot code and uboot spl from 0x8000
   - dram init is done here
   - uboot spl works from rockchip/uboot source
2. uboot spl jumps to uboot, which is located at

## idblock generation

`./mkimage -n rk3588 -T rksd -d ../bin/rv11/rv1106_ddr_924MHz_v1.15.bin:../../buildroot/output/images/u-boot-spl.bin idtest.img`
-> generates a booting idblock

- ddr binary files ranges from 0x800 to 0x67ff

sys_text_base rv1106:0x00200000

## stock image boot output (until it starts linux :D)

```
DDR 306b9977f5 wesley.yao 23/12/21-09:28:37,fwver: v1.15
S5P1
4x
f967
rgef1
DDRConf2
DDR3, BW=16 Col=10 Bk=8 CS0 Row=14 CS=1 Size=256MB
924MHz
DDR bin out

U-Boot SPL board init
U-Boot SPL 2017.09 (Nov 21 2024 - 10:38:46)
unknown raw ID 0 0 0
Trying to boot from MMC2
ENVF: Primary 0x00000000 - 0x00008000
ENVF: Primary 0x00000000 - 0x00008000
No misc partition
Trying fit image at 0x440 sector
## Verified-boot: 0
## Checking uboot 0x00200000 (lzma @0x00400000) ... sha256(17038ce860...) + sha256(aad0bf6774...) + OK
## Checking fdt 0x00260998 ... sha256(9f596c5683...) + OK
Total: 538.164/593.19 ms

Jumping to U-Boot(0x00200000)


U-Boot 2017.09 (Nov 21 2024 - 10:38:46 +0800)

Model: Rockchip RV1106 EVB Board
MPIDR: 0xf00
PreSerial: 2, raw, 0xff4c0000
DRAM:  256 MiB
Sysmem: init
Relocation Offset: 0fd81000
Relocation fdt: 0edfa778 - 0edfede0
CR: M/C/I
Using default environment

no mmc device at slot 1
ENVF: Primary 0x00000000 - 0x00008000
ENVF: Primary 0x00000000 - 0x00008000
mmc@ffa90000: 0, mmc@ffaa0000: 1 (SD)
Bootdev(atags): mmc 1
MMC1: Legacy, 52Mhz
PartType: ENV
DM: v2
No misc partition
boot mode: None
RESC: 'boot', blk@0x00001d9e
resource: sha256+
FIT: no signed, no conf required
DTB: rk-kernel.dtb
HASH(c): OK
Model: Luckfox Pico Mini
## retrieving sd_update.txt ...
bad MBR sector signature 0x0000
** Invalid partition 1 **
CLK: (uboot. arm: enter 816000 KHz, init 816000 KHz, kernel 0N/A)
  apll 816000 KHz
  dpll 924000 KHz
  gpll 1188000 KHz
  cpll 1000000 KHz
  aclk_peri_root 400000 KHz
  hclK_peri_root 200000 KHz
  pclk_peri_root 100000 KHz
  aclk_bus_root 300000 KHz
  pclk_top_root 100000 KHz
  pclk_pmu_root 100000 KHz
  hclk_pmu_root 200000 KHz
No misc partition
Net:   eth0: ethernet@ffa80000
Hit key to stop autoboot('CTRL+C'):  0
## Booting FIT Image

```

### stock image SD Card layout

| Addr in hex-bytes | Content        | Notes?                   |
| ----------------- | -------------- | ------------------------ |
| 0x00              | Environment    |                          |
| 0x8000            | RKNS Signature | RKNS 4x00 80 01 02 00 01 |
| 0x8600            | Unknown block  |                          |
| 0x8800            | uboot-spl      | Ends 0x35F70             |
| 0x88000           | FIT image      | uboot + android kernel   |

## working boot output --> uboot loading, failing to boot

| Log                                                      | Comment |
| -------------------------------------------------------- | ------- |
| DDR 306b9977f5 wesley.yao 23/12/21-09:28:37,fwver: v1.15 |         |
| S5P1                                                     |         |
| 4x                                                       |         |
| f967                                                     |         |
| rgef1                                                    |         |
| DDRConf2                                                 |         |
| DDR3, BW=16 Col=10 Bk=8 CS0 Row=14 CS=1 Size=256MB       |         |
| 924MHz                                                   |         |
| DDR bin out                                              |         |
|                                                          |         |
| U-Boot SPL board init                                    |         |
| U-Boot SPL 2017.09 (Dec 03 2024 - 22:05:13)              |         |
| sfc cmd=9fH(6BH-x4)                                      |         |
| unknown raw ID 0 0 0                                     |         |
| Trying to boot from MMC2                                 |         |
| ENVF: Primary 0x00006000 - 0x00008000                    |         |
| ENVF: Primary 0x00006000 - 0x00008000                    |         |
| Trying to boot from MMC1                                 |         |
| Card did not respond to voltage select!                  |         |
| mmc_init: -95, time 16                                   |         |
| spl: mmc init failed with error: -95                     |         |
| SPL: failed to boot from all boot devices                |         |
| ### ERROR ### Please RESET the board ###                 |         |
