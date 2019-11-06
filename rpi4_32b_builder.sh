# BUILD UBOOT FOR ARM AND THE RPI4 BOARD
make clean
make init
make prepare
make build ARCH=arm CROSS_COMPILER=arm-linux-gnueabihf- BOARD_DEFCONFIG=rpi_4_32b_defconfig
make finalize BOARD_TYPE=rpi_4 ARCH=arm BOARD_DEFCONFIG=rpi_4_32b_defconfig