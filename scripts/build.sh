#!/bin/bash

set -e

cd /projects/openwrt/ && make defconfig && make -j$(nproc)

if [ ! -d "output" ]; then
  mkdir -p "output"
fi

cp /projects/openwrt/bin/targets/x86/generic/openwrt-x86-generic-generic-rootfs.tar.gz /projects/openwrt-helloworld/output/openwrt-x86-generic-generic-rootfs.tar.gz