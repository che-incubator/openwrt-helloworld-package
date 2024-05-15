#!/bin/bash

set -e

cp  /tmp/pre-install/openwrt/.config -d /projects/openwrt/.config
unzip  /tmp/pre-install/openwrt/feeds.zip -d /projects/openwrt
unzip  /tmp/pre-install/openwrt/bin.zip -d /projects/openwrt

if [ -f /tmp/pre-install/openwrt/helloworld.zip ]; then
  unzip  /tmp/pre-install/openwrt/helloworld.zip -d /projects/openwrt
fi

if [ -f /tmp/pre-install/openwrt/x86_64-openwrt-linux-gdb.zip ]; then
  unzip  /tmp/pre-install/openwrt/x86_64-openwrt-linux-gdb.zip -d /projects/openwrt
fi

if [ -f /tmp/pre-install/openwrt/root-x86.zip ]; then
  unzip  /tmp/pre-install/openwrt/root-x86.zip -d /projects/openwrt
fi

mkdir -p /projects/openwrt-helloworld/output

cp -r /projects/openwrt/bin/targets/*/*/openwrt-*combined.img.gz /projects/openwrt-helloworld/output/

if [ ! -d /projects/openwrt/package/helloworld ]; then
  ln -sr /projects/openwrt-helloworld/package/helloworld /projects/openwrt/package/
fi