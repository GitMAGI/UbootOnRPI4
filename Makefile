SHELL:=/bin/bash
CWD=$$(pwd)

DOCKER=docker run -it -v $(CWD):/cwd

DOCKER_IMG_NAME=arm-source-compiler
DOCKER_IMG_V=latest

UBOOT_GIT=https://gitlab.denx.de/u-boot/u-boot.git

#ARCH=arm64
#CROSS_COMPILER=aarch64-linux-gnu-

ARCH=arm
CROSS_COMPILER=arm-linux-gnueabihf-

BOARD_TYPE=rpi4
#BOARD_DEFCONFIG=rpi_4_defconfig
BOARD_DEFCONFIG=rpi_4_32b_defconfig

shell:
	$(DOCKER) --privileged $(DOCKER_IMG_NAME):$(DOCKER_IMG_V)

init:
	@docker build -t $(DOCKER_IMG_NAME):$(DOCKER_IMG_V) .

prepare:
	@echo "Preparing ..."
	@mkdir -m755 -p ./src/
	@git clone $(UBOOT_GIT) ./src/u-boot
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
	@cp ./src/u-boot/u-boot.bin ./build/
	@cp ./asset/$(BOARD_TYPE)/config.txt ./build/
	@echo "kernel=u-boot.bin" >> ./build/config.txt
	@echo "enable_uart=1" >> ./build/config.txt	
	@echo "Finalization complteted!"

clean:
	@echo "Cleaning ..."
	@rm -rf ./build
	$(DOCKER) --privileged $(DOCKER_IMG_NAME):$(DOCKER_IMG_V) -c	\
	"                                                             	\
	cd ./src/u-boot;												\
	make CROSS_COMPILE=$(CROSS_COMPILER) clean              		\
	"
	@echo "Clening completed!"
