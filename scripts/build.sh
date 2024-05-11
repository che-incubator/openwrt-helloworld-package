#!/bin/bash

set -e

cd /projects/openwrt/ && make defconfig && make -j$(nproc)

if [ -d /projects/openwrt-helloworld/output ]; then
  rm -r /projects/openwrt-helloworld/output
fi

mkdir -p /projects/openwrt-helloworld/output

cp -r /projects/openwrt/bin/targets/*/*/openwrt-*combined.img.gz /projects/openwrt-helloworld/output/