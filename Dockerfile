FROM debian:stretch

RUN apt-get update                              \
    && apt-get -y upgrade                       \
    && apt-get install -y                       \
        bc										\
        build-essential                        	\
        curl                                   	\
        device-tree-compiler                   	\
        dosfstools                             	\
        binutils-aarch64-linux-gnu				\
        gcc-aarch64-linux-gnu                  	\
		gcc-arm-linux-gnueabi					\
        gcc-arm-linux-gnueabihf                 \
		device-tree-compiler					\
        bison                                  	\
        flex                                   	\
        libssl-dev                             	\
        git                                    	\
        man                                    	\
        u-boot-tools

VOLUME ["/cwd"]
WORKDIR /cwd

ENTRYPOINT ["bash"]
