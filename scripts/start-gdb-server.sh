#!/bin/bash

set -e

env_name=`echo "$DEVWORKSPACE_ID" | tr '[:lower:]' '[:upper:]'`_SERVICE_PORT_30022_TCP

eval "host=\"\$$env_name\"" && host=`echo $host | sed 's/tcp:\/\///' | sed 's/:.*//'`

echo "Connecting to $host"

sshpass -p pass1234 ssh -L 39000:localhost:9000 -o StrictHostKeyChecking=no "root@$host" -p 30022 "cd /bin/ && gdbserver localhost:9000 ./helloworld"