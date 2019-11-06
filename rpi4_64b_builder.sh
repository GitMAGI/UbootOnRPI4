# BUILD UBOOT FOR ARM64 AND THE RPI4 BOARD
make clean
make init
make prepare
make build ARCH=arm64 CROSS_COMPILER=aarch64-linux-gnu- BOARD_DEFCONFIG=rpi_4_defconfig
make finalize BOARD_TYPE=rpi_4 ARCH=arm64 BOARD_DEFCONFIG=rpi_4_defconfig