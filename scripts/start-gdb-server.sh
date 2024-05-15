#!/bin/bash

set -e

cd /bin/ && gdbserver localhost:9000 ./helloworld