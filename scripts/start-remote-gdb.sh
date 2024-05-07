#!/bin/bash

set -e

cd /projects/openwrt/ && ./scripts/remote-gdb localhost:39000 ./build_dir/target-*/helloworld-*/helloworld