FROM ubuntu:22.04 AS base

ARG BUILDROOT_RELEASE=2024.02.9

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
    whiptail \
    python-is-python3

WORKDIR /root/buildroot
RUN wget -qO- https://buildroot.org/downloads/buildroot-${BUILDROOT_RELEASE}.tar.gz | tar --strip-components=1 -xz 

FROM base AS toolchain

# configure a skeleton setup for `make sdk` only at first
# (we take special care to not include other unrelated config files)
WORKDIR /root/rv1106-sdk
RUN echo 'name: RV1106_SDK' >> external.desc
RUN echo 'desc: RV1106 SDK only' >> external.desc
RUN touch external.mk Config.in
COPY configs/rv1106_sdk_defconfig configs/

# compile the SDK (this takes a while!)
WORKDIR /root/buildroot
RUN BR2_EXTERNAL=/root/rv1106-sdk make rv1106_sdk_defconfig

RUN make sdk
RUN ls -la /root/buildroot/output/images

FROM base AS rkbin

WORKDIR /root/
RUN git clone https://github.com/rockchip-linux/rkbin
RUN tar -zcvf /root/rkbin.tar.gz -C /root/rkbin/ .

FROM base AS main

WORKDIR /root

COPY --from=toolchain /root/buildroot/output/images/arm-buildroot-linux-gnueabihf_sdk-buildroot.tar.gz /root/
RUN ls -l /root/

COPY --from=rkbin /root/rkbin.tar.gz /root/
RUN mkdir -p /root/rkbin
RUN tar -xf /root/rkbin.tar.gz -C /root/rkbin && rm rkbin.tar.gz
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
