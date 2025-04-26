#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Try: sudo $0"
    exit 1
fi

CONFIG_FILE="/home/mdlw/.config/scripts/mount_disk.config"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file $CONFIG_FILE not found!"
    echo "Please create a file with the following format:"
    echo "  First line: disk path (e.g., /dev/nvme0n1p1)"
    echo "  Second line: mount point (e.g., /mnt/ssd)"
    exit 1
fi

DISK_PATH=$(head -n 1 "$CONFIG_FILE" | tr -d '[:space:]')
MOUNT_POINT=$(tail -n 1 "$CONFIG_FILE" | tr -d '[:space:]')

if [ -z "$DISK_PATH" ] || [ -z "$MOUNT_POINT" ]; then
    echo "Error: Disk path or mount point is empty in config file"
    exit 1
fi

if [ ! -e "$DISK_PATH" ]; then
    echo "Error: Disk $DISK_PATH does not exist"
    exit 1
fi

if [ ! -d "$MOUNT_POINT" ]; then
    echo "Creating mount point directory $MOUNT_POINT"
    mkdir -p "$MOUNT_POINT" || {
        echo "Error: Failed to create mount point directory"
        exit 1
    }
fi

echo "Mounting $DISK_PATH to $MOUNT_POINT"
mount "$DISK_PATH" "$MOUNT_POINT" || {
    echo "Error: Failed to mount $DISK_PATH to $MOUNT_POINT"
    exit 1
}

echo "Successfully mounted $DISK_PATH to $MOUNT_POINT"

df -h "$MOUNT_POINT"
