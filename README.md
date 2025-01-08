# RV1106 buildroot

> [!WARNING]  
> This is still very much work in progress and not suitable for being used in dev or production environments

This repository aims to provide a Buildroot BSP for the Rockchip RV1106 system on chip.

## Project Progress / Milestones

- [x] Run u-boot SPL from rockchip source
- [x] Run u-boot from rockchip source
- [x] Boot linux 6.1 kernel from armbian source
- [x] Automatically build root fs
- [ ] Check device drivers (Ethernet, SPI, I2C, I2C, etc.)
- [ ] Check integrated MCU support + Mailbox system
- [ ] Update u-boot (proper & spl) to mainline version

## Docker Buildsystem

The buildsystem is based on two docker containers. A _base_ image and an _iterating_ image. The _base_ image contains the toolchain and an initial build of the project. The _iterating_ image is built ontop of the _base_ image to speed up the build process by just rebuilding the _iterating_ image.

This repository contains two github actions (`.github/workflows/`) which automatically build the _base_ image on push to main (or by manually triggering it) or the _iterating_ image on push to any other branch.

### Build the base image

```bash
docker build -f Dockerfile -t olel/rv1106-buildroot-base:latest .
```

### Build the iterating image

```bash
docker build -f Dockerfile.dev --output type=tar,dest=- . | tar x -C dist
```

This will output the build images to a directory called `dist/`

## Manual Build

To manually build the project, you have two options:

### 1. Native on a linux machine

This is work in progress, you can use the commands from the `Dockerfile` to build it on any debian-based os.

### 2. Using docker compose

To speed up the dev process you can use the included docker-compose configuration file to setup a running container which actually does nothing (`tail -f /dev/null`), so you can attach to it and use the command-line to build the project. All configuration files and the board directory are directly mounted inside the container, so you can change them quickly.

#### Run the container:

```bash
DOCKER_DEFAULT_PLATFORM=linux/amd64 docker compose up -d
```

(If you're on a amd64 machine, you can omit the `DOCKER_DEFAULT_PLATFORM`)

#### Attach to the container

```bash
# Get container ID using
docker ps
# Exec a bash shell
docker exec -it <container_id> /bin/bash
```

#### Build inside the container

Once you're attached to the bash, you can build the project using the following commands. All commands are executed in the `/root/buildroot/` directory.

```bash
# see all options
make help

# cleanup everything (next build will take a long time)
make clean

# Reload the configuration
make rv1106_defconfig

# build everything
make

# rebuild single package (eg. uboot, linux, etc.)
make uboot

# clean single package (eg. uboot, linux, etc.)
make uboot-dirclean
```

After building the images can be found at `/root/buildroot/output/images`, to boot from an SD-Card you can flash the `sdcard.img` file directly.
