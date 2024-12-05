FROM ubuntu:22.04 AS base

ARG BUILDROOT_RELEASE=2024.02.8

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update

# add apt-get installs for deps here

RUN apt-get install -qy \
    bc \
    bison \
    build-essential \
    bzr \
    chrpath \
    cpio \
    cvs \
    devscripts \
    diffstat \
    dosfstools \
    fakeroot \
    flex \
    gawk \
    git \
    libncurses5-dev \
    libssl-dev \
    locales \
    python3-dev \
    python3-distutils \
    python3-setuptools \
    rsync \
    subversion \
    swig \
    texinfo \
    unzip \
    wget \
    whiptail

WORKDIR /root/buildroot
RUN wget -qO- https://buildroot.org/downloads/buildroot-${BUILDROOT_RELEASE}.tar.gz | tar --strip-components=1 -xz 

FROM base AS toolchain

## todo: find cleaner solution to get the toolchain
WORKDIR /root/rockchip_toolchain
RUN git clone https://github.com/deerpi/arm-rockchip830-linux-uclibcgnueabihf
WORKDIR /root/rockchip_toolchain/arm-rockchip830-linux-uclibcgnueabihf
RUN mkdir /root/rockchip_toolchain/toolchain/
RUN bash ./env_install_toolchain.sh /root/rockchip_toolchain/toolchain/
RUN tar -zcvf /root/rockchip_toolchain/toolchain.tar.gz -C /root/rockchip_toolchain/toolchain .

WORKDIR /root/
RUN git clone https://github.com/rockchip-linux/rkbin
RUN tar -zcvf /root/rkbin.tar.gz -C /root/rkbin/ .

FROM base AS main

WORKDIR /root
COPY --from=toolchain /root/rockchip_toolchain/toolchain.tar.gz /root/
RUN tar -xf /root/toolchain.tar.gz -C . && rm toolchain.tar.gz
# toolchain is now located @ /root/arm-rockchip830-linux-uclibcgnueabihf
COPY --from=toolchain /root/rkbin.tar.gz /root/
RUN tar -xf /root/rkbin.tar.gz -C . && rm rkbin.tar.gz
# rkbin is now located @ /root/rkbin

# copy over the main config
WORKDIR /root/rv1106
COPY board/ board/
COPY configs/ configs/
COPY patches/ patches/
COPY package/ package/
COPY \
    Config.in \
    external.desc \
    external.mk \
    ./

# set up the defconfig
WORKDIR /root/buildroot
RUN BR2_EXTERNAL=/root/rv1106 make rv1106_defconfig

# prepare for builds (broken out separately to cache more granularly, especially Linux source fetch)
#RUN make linux-source
RUN make uboot-source

# run the main build command
RUN make

CMD ["tail", "-f", "/dev/null"]