#!/bin/bash -e

echo "=== Running post-build script ==="

BOARD_DIR="${BR2_EXTERNAL_RV1106_PATH}/board/RV1106"
IMAGES_DIR="/root/buildroot/output/images"
UBOOT_BUILD_DIR="/root/buildroot/output/build/uboot-next-dev"
UBOOT_TOOLS_DIR="${UBOOT_BUILD_DIR}/tools/"
ENV_FILE="${BOARD_DIR}/uboot/rv1106.env"
RKBIN_PATH="/root/rkbin/"

#
# Build env image
#
cd ${UBOOT_TOOLS_DIR}
./mkenvimage \
    -p 0x0 \
    -s 0x2000 \
    -o "${IMAGES_DIR}/env.img" \
    "${ENV_FILE}"

#
# Build idblock
#  idblock contains the binary DDR init code and
#  the u-boot SPL binary
#

# Note: image name (-n) is "rk3588", which seems to be compatible to RV1106
#       using "rv1106" as image name doesnt work...

cd ${UBOOT_TOOLS_DIR}
./mkimage \
    -n rk3588 \
    -T rksd \
    -d "${RKBIN_PATH}/bin/rv11/rv1106_ddr_924MHz_v1.15.bin:${IMAGES_DIR}/u-boot-spl.bin" \
    "${IMAGES_DIR}/idblock.img"

exit $?