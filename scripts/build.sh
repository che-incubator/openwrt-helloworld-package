#!/bin/bash

set -e

cd /projects/openwrt/ && make defconfig && make -j$(nproc)

cp /projects/openwrt/bin/targets/x86/64/*/*-rootfs.tar.gz /output/