#!/bin/bash

set -e

cp -f /projects/openwrt-helloworld/configs/.x86-generic.config /projects/openwrt/.config

if [ ! -d /projects/openwrt/package/helloworld ]; then
  ln -sr /projects/openwrt-helloworld/package/helloworld /projects/openwrt/package/
fi

cd /projects/openwrt && make defconfig