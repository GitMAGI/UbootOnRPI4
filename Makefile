.PHONY: shell prepare clean all

SHELL:=/bin/bash
CWD=$$(pwd)

DOCKER=docker run -it -v $(CWD):/cwd

UBOOT_URL=ftp://ftp.denx.de/pub/u-boot/
UBOOT_V=2019.10
DOCKER_IMG_NAME=arm64-source-compiler
DOCKER_IMG_V=latest

ARCH=arm64
CROSS_COMPILER=aarch64-linux-gnu-

BOARD_TYPE=rpi4
BOARD_DEFCONFIG=rpi_4_defconfig

FIRMWARE_BIN_URL=https://github.com/raspberrypi/firmware/blob/master/boot/bootcode.bin
FIRMWARE_ELF_URL=https://github.com/raspberrypi/firmware/blob/master/boot/start.elf

shell:
	$(DOCKER) --privileged $(DOCKER_IMG_NAME):$(DOCKER_IMG_V)

init:
	@docker build -t $(DOCKER_IMG_NAME):$(DOCKER_IMG_V) .

prepare:
	@echo "Preparing ..."
	@mkdir -m755 -p ./src/
	@wget $(UBOOT_URL)u-boot-$(UBOOT_V).tar.bz2 -P ./src
	@tar --no-same-owner -C ./src/ -xjf ./src/u-boot-$(UBOOT_V).tar.bz2
	@rm -f ./src/u-boot-$(UBOOT_V).tar.bz2
	@echo "Preparation completed!"

build:
	@echo "Cross-Building for ARCH $(ARCH) with the compiler $(CROSS_COMPILER) starting ..."
	$(DOCKER) --privileged $(DOCKER_IMG_NAME):$(DOCKER_IMG_V) -c	\
	"								\
	cd ./src/u-boot-$(UBOOT_V);					\
	make CROSS_COMPILE=$(CROSS_COMPILER) distclean; 		\
	make CROSS_COMPILE=$(CROSS_COMPILER) $(BOARD_DEFCONFIG);	\
	make CROSS_COMPILE=$(CROSS_COMPILER) u-boot.bin;		
	"
	@echo "Cross-Building for ARCH $(ARCH) with the compiler $(CROSS_COMPILER) completed"

finalize:
ifeq (,$(wildcard ./src/u-boot-$(UBOOT_V)/u-boot.bin))
	$(error "File ./src/u-boot-$(UBOOT_V)/u-boot.bin does not exist. Run make build first")
endif
	@mkdir -m755 -p ./build
	@rm -f ./build/*
	@cp ./src/u-boot-$(UBOOT_V)/u-boot.bin ./build/
	@echo "console=serial0,115200 console=tty1 root=PARTUUID=6c586e13-02" > ./build/cmdline.txt
	@echo "kernel=u-boot.bin" > ./build/config.txt
	@wget $(FIRMWARE_BIN_URL) -P ./build
	@wget $(FIRMWARE_ELF_URL) -P ./build

clean:
	@echo "Cleaning ..."
	@rm -rf ./src
	@echo "Clening completed!"

all: prepare build finalize
