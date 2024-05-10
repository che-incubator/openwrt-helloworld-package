#!/bin/bash

set -e

cp  /tmp/pre-install/openwrt/.config -d /projects/openwrt/.config
unzip  /tmp/pre-install/openwrt/feeds.zip -d /projects/openwrt
unzip  /tmp/pre-install/openwrt/bin.zip -d /projects/openwrt

if [ -d /projects/openwrt-helloworld/output ]; then
  rm -r /projects/openwrt-helloworld/output
fi

mkdir -p /projects/openwrt-helloworld/output

cp -r /projects/openwrt/bin/targets/*/*/openwrt-*combined.img.gz /projects/openwrt-helloworld/output/