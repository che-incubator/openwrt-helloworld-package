#!/bin/bash

set -e

cd /projects/openwrt/ && make defconfig && make -j$(nproc)

if [ ! -d "/projects/openwrt-helloworld/output" ]; then
  mkdir -p "/projects/openwrt-helloworld/output"
fi

if [ - f "/projects/openwrt-helloworld/output/image.raw" ]; then
  rm -f "/projects/openwrt-helloworld/output/image.raw"
fi

cp -r /projects/openwrt/bin/targets/*/*/openwrt-*.gz /projects/openwrt-helloworld/output/