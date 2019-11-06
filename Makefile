.SILENT: build finalize help prepare clean
SHELL:=/bin/bash
CWD=$$(pwd)

DOCKER=docker run -it -v $(CWD):/cwd

DOCKER_IMG_NAME=arm-source-compiler
DOCKER_IMG_V=latest

UBOOT_GIT=https://gitlab.denx.de/u-boot/u-boot.git

#ARCH=arm64
#CROSS_COMPILER=aarch64-linux-gnu-

#ARCH=arm
#CROSS_COMPILER=arm-linux-gnueabihf-

#BOARD_TYPE=rpi_4
#BOARD_DEFCONFIG=rpi_4_defconfig
#BOARD_DEFCONFIG=rpi_4_32b_defconfig

help:
	@echo USAGE: make ACTION CONFIGURATIONS
	@echo "ACTIONS: init|prepare|build|finalize"
	@echo "CONFIGURATIONS: ARCH=(arm|arm64) CROSS_COMPILER=(arm-linux-gnueabihf-|aarch64-linux-gnu-) BOARD_TYPE=(rpi_4) BOARD_DEFCONFIG=(rpi_4_defconfig|rpi_4_32b_defconfig)"

shell:
	$(DOCKER) --privileged $(DOCKER_IMG_NAME):$(DOCKER_IMG_V)

init:
	@docker build -t $(DOCKER_IMG_NAME):$(DOCKER_IMG_V) .

prepare:
	@echo "Preparing ..."
ifeq (,$(wildcard ./src/u-boot/))
	@mkdir -m755 -p ./src/
	@git clone $(UBOOT_GIT) ./src/u-boot
endif
	@echo "Preparation completed!"

build:
	@echo "Cross-Building for ARCH $(ARCH) with the compiler $(CROSS_COMPILER) starting ..."
	$(DOCKER) --privileged $(DOCKER_IMG_NAME):$(DOCKER_IMG_V) -c	\
	"																\
	cd ./src/u-boot;												\
	make CROSS_COMPILE=$(CROSS_COMPILER) $(BOARD_DEFCONFIG);		\
	make CROSS_COMPILE=$(CROSS_COMPILER) -j8						\
	"
	@echo "Cross-Building for ARCH $(ARCH) with the compiler $(CROSS_COMPILER) completed"

finalize:
ifeq (,$(wildcard ./src/u-boot/u-boot.bin))
	$(error "File ./src/u-boot/u-boot.bin does not exist. Run make build first")
endif
	@echo "Finalizing ..."
	@mkdir -m755 -p ./build
	@rm -f ./build/*
	@cp ./src/u-boot/u-boot.bin ./build/u-boot-$(BOARD_DEFCONFIG:_defconfig=).bin
	@cp ./asset/$(BOARD_TYPE)_$(ARCH)_config.txt ./build/config.txt
	@echo "kernel=u-boot-$(BOARD_DEFCONFIG:_defconfig=).bin" >> ./build/config.txt
	@echo "enable_uart=1" >> ./build/config.txt
	@echo "Finalization complteted!"

clean:
	@echo "Cleaning ..."
	@rm -rf ./build
	$(DOCKER) --privileged $(DOCKER_IMG_NAME):$(DOCKER_IMG_V) -c	\
	"                                                             	\
	cd ./src/u-boot;												\
	make clean              										\
	"
	@echo "Clening completed!"