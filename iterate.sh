#!/bin/bash

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <container> <disk> [command]"
    exit 1
fi

container="$1"
disk="$2"

if [ -n "$3" ]; then
    cmd="make $3 && make"
else
    cmd="make"
fi

echo "Container ID: $container"
echo "Disk path: $disk"
echo "Executing cmd: $cmd"

mount_point=$(mount | grep $disk | sed -n 's/.* on \(.*\) (.*/\1/p')

echo "Mounted at $mount_point"

echo "Running command in docker container"
docker exec -it $container bash -c "$cmd"

echo "Copying image to local disk"
docker cp $container:/root/buildroot/output/images/sdcard.img .

echo "Unmounting disk"
diskutil unmount "$mount_point"

echo ""
echo "Please check if this is the correct disk"
diskutil list | grep -A10 $disk 

echo "Press Return to continue or Ctrl+C to abort."
read -r

sudo dd bs=4M if=sdcard.img of=$disk status=progress
sync
rm sdcard.img