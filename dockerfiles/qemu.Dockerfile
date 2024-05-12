FROM docker.io/library/alpine:3.19.1

# Install QEMU, remove large unnecessary files
RUN apk add --no-cache \
        make \
        curl \
        make \
        qemu-chardev-spice \
        qemu-hw-display-virtio-vga \
        qemu-img \
        qemu-system-x86_64 \
        qemu-ui-spice-core \
        socat \
        perl \
        && \
    rm -f /usr/share/qemu/edk2-*

# Support Arbitrary User IDs in container
RUN echo -e '#!/bin/sh\n\
set -ex \n\
if ! whoami &> /dev/null; then \n\
  if [ -w /etc/passwd ]; then \n\
    echo "container:x:$(id -u):0:Container User:/tmp:/sbin/nologin" >> /etc/passwd \n\
    echo "container:x:$(id -u):$(id -u)" >> /etc/group \n\
  fi \n\
fi \n\
\n' > /usr/local/bin/create-container-user.sh && \
    chmod +x /usr/local/bin/create-container-user.sh && \
    chmod g=u /etc/passwd && \
    chmod g=u /etc/group

# Provision VM disk image
RUN echo -e '#!/bin/sh\n\
set -ex \n\
if [ ! -f /projects/openwrt-helloworld/output/openwrt-*combined.img.gz ]; then \n\
    echo "No /projects/openwrt-helloworld/output/openwrt-*combined.img.gz file." \n\
    exit 1 \n\
fi \n\
if [ -f /var/lib/qemu/image.raw ]; then \n\
    rm /var/lib/qemu/image.raw \n\
fi \n\
if [ -f /var/lib/qemu/image.qcow2 ]; then \n\
    rm /var/lib/qemu/image.qcow2 \n\
fi \n\
gunzip --stdout /projects/openwrt-helloworld/output/openwrt-*combined.img.gz > /var/lib/qemu/image.raw || true \n\
qemu-img convert -f raw -O qcow2 /var/lib/qemu/image.raw /var/lib/qemu/image.qcow2 \n\
rm /var/lib/qemu/image.raw \n\
if [ -n "${QEMU_STORAGE}" ]; then \n\
    qemu-img resize /var/lib/qemu/image.qcow2 "${QEMU_STORAGE}" \n\
fi \n\
\n' > /usr/local/bin/provision-image.sh && \
    chmod +x /usr/local/bin/provision-image.sh

# Create default VM configuration scripts
RUN mkdir -p /usr/local/share/vmconfig/container.d /usr/local/share/vmconfig/vm.d

RUN echo -e '#!/bin/sh\n\
set -e \n\
cat > vm.d/20-hostname.sh <<EOF\n\
#!/bin/sh \n\
set -e \n\
uci set system.@system[0].hostname="$QEMU_HOSTNAME" \n\
uci commit system \n\
EOF\n\
chmod +x vm.d/20-hostname.sh \n\
\n\' > /usr/local/share/vmconfig/container.d/20-hostname.sh && \
    chmod +x /usr/local/share/vmconfig/container.d/20-hostname.sh

RUN echo -e '#!/bin/sh\n\
set -e \n\
cat > vm.d/20-password.sh <<EOF\n\
#!/bin/sh \n\
set -e \n\
echo -e "$QEMU_PASSWORD\\n$QEMU_PASSWORD" | passwd \n\
EOF\n\
chmod +x vm.d/20-password.sh \n\
\n\' > /usr/local/share/vmconfig/container.d/20-password.sh && \
    chmod +x /usr/local/share/vmconfig/container.d/20-password.sh

RUN echo -e '#!/bin/sh\n\
set -ex \n\
uci add firewall rule \n\
uci set firewall.@rule[-1].name="Allow-Admin" \n\
uci set firewall.@rule[-1].enabled="true" \n\
uci set firewall.@rule[-1].src="wan" \n\
uci set firewall.@rule[-1].proto="tcp" \n\
uci set firewall.@rule[-1].dest_port="22 80 443 9000" \n\
uci set firewall.@rule[-1].target="ACCEPT" \n\
uci commit firewall \n\
\n\' > /usr/local/share/vmconfig/vm.d/20-firewall.sh && \
    chmod +x /usr/local/share/vmconfig/vm.d/20-firewall.sh

RUN echo -e '#!/bin/sh\n\
set -ex \n\
ubus wait_for network.interface.wan \n\
sleep 3 \n\
opkg update \n\
\n\' > /usr/local/share/vmconfig/vm.d/30-wait-for-network.sh && \
chmod +x /usr/local/share/vmconfig/vm.d/30-wait-for-network.sh

RUN echo -e '#!/bin/sh\n\
set -ex \n\
opkg install partx-utils resize2fs sfdisk tune2fs \n\
echo "- +" | sfdisk --force -N 2 /dev/vda \n\
partx -u /dev/vda \n\
mount -o remount,ro / \n\
tune2fs -O^resize_inode /dev/vda2 \n\
e2fsck -y -f /dev/vda2 || true \n\
mount -o remount,rw / \n\
resize2fs /dev/vda2 \n\
\n\' > /usr/local/share/vmconfig/vm.d/40-resize-disk.sh && \
chmod +x /usr/local/share/vmconfig/vm.d/40-resize-disk.sh

# Write VM configuration archive as serial console commands to STDOUT
RUN echo -e '#!/bin/sh\n\
set -e \n\
cat <<EOF\n\
\n\
echo "require \\"nixio\\"; io.stdin:setvbuf \\"no\\"; io.write(nixio.bin.b64decode(io.read()));" > /tmp/base64_decode.lua \n\
lua /tmp/base64_decode.lua > /tmp/vmconfig.tgz \n\
EOF\n\
tar -zcv -C "$1" . | base64 -w0 \n\
cat <<EOF\n\
\n\
mkdir /tmp/vmconfig \n\
tar -zxvf /tmp/vmconfig.tgz -C /tmp/vmconfig \n\
sleep 5 \n\
(cd /tmp/vmconfig && (for f in \$(ls vm.d); do echo "Executing ./vm.d/\$f"; "./vm.d/\$f" || exit 1; done)) && echo -e "\\nVM configuration result: successful." || echo -e "\\nVM configuration result: failed." \n\
poweroff \n\
EOF\n\
\n' > /usr/local/bin/serialize-vm-config.sh && \
    chmod +x /usr/local/bin/serialize-vm-config.sh

# Send configuration archive to VM using serial console
RUN echo -e '#!/bin/sh\n\
set -ex \n\
echo "Discovered vmconfig:" \n\
find /var/lib/vmconfig \n\
sleep 5 \n\
rm -rf /tmp/vmconfig \n\
cp -rv /var/lib/vmconfig /tmp/vmconfig \n\
mkdir -p /tmp/vmconfig/container.d /tmp/vmconfig/vm.d \n\
if [ -z "$QEMU_CONFIG_NO_DEFAULTS" ]; then \n\
    cp /usr/local/share/vmconfig/container.d/* /tmp/vmconfig/container.d \n\
    cp /usr/local/share/vmconfig/vm.d/* /tmp/vmconfig/vm.d \n\
fi \n\
(cd /tmp/vmconfig && (for f in $(ls container.d); do "./container.d/$f"; done)) \n\
run-vm.sh & \n\
QEMU_PID="$!" \n\
sleep 5 \n\
socat STDOUT unix-connect:/tmp/qemu-console.sock | grep -q "Please press Enter to activate this console." \n\
serialize-vm-config.sh /tmp/vmconfig | socat STDIN unix-connect:/tmp/qemu-console.sock \n\
VM_CONFIG_RESULT="$(socat STDOUT unix-connect:/tmp/qemu-console.sock | grep -m1 "^VM configuration result:")" \n\
if test "${VM_CONFIG_RESULT#*failed}" != "$VM_CONFIG_RESULT"; then \n\
    exit 1 \n\
fi \n\
wait "$QEMU_PID" \n\
\n' > /usr/local/bin/send-config-to-vm.sh && \
    chmod +x /usr/local/bin/send-config-to-vm.sh

# Start VM in QEMU
RUN echo -e '#!/bin/sh\n\
set -e \n\
printf "$QEMU_PASSWORD" > /tmp/qemu-password.txt \n\
set -x \n\
exec /usr/bin/qemu-system-x86_64 \\\n\
    -nodefaults \\\n\
    -smp ""${QEMU_SMP}"" \\\n\
    -m "${QEMU_MEMORY}" \\\n\
    -drive file=/var/lib/qemu/image.qcow2,if=virtio \\\n\
    -chardev socket,id=chr0,path=/tmp/qemu-console.sock,mux=on,logfile=/dev/stdout,signal=off,server=on,wait=off \\\n\
    -serial chardev:chr0 \\\n\
    -monitor unix:/tmp/qemu-monitor.sock,server,nowait \\\n\
    -nic "user,model=virtio,restrict=on,ipv6=off,net=192.168.1.0/24,host=192.168.1.2,${QEMU_LAN_OPTIONS}" \\\n\
    -nic "user,model=virtio,net=${QEMU_WAN_NETWORK},${QEMU_WAN_OPTIONS}" \\\n\
    -object secret,id=secvnc0,format=raw,file=/tmp/qemu-password.txt \\\n\
    -display none \\\n\
    -device virtio-vga \\\n\
    -spice port=5900,password-secret=secvnc0 \\\n\
    -device intel-hda \\\n\
    -device hda-duplex \\\n\
    $QEMU_ARGS \\\n\
\n' > /usr/local/bin/run-vm.sh && \
    chmod +x /usr/local/bin/run-vm.sh

# Healthcheck
RUN echo -e '#!/bin/sh\n\
set -ex \n\
[ -e /tmp/qemu-console.sock -a -f /var/lib/qemu/initialized ] \n\
curl -sSf -m 5 http://127.0.0.1:30080 > /dev/null \n\
\n' > /usr/local/bin/healthcheck-vm.sh && \
    chmod +x /usr/local/bin/healthcheck-vm.sh

# Prepare and run the VM
RUN echo -e '#!/bin/sh\n\
set -ex \n\
create-container-user.sh \n\
provision-image.sh \n\
timeout -s SIGINT "$QEMU_CONFIG_TIMEOUT" send-config-to-vm.sh || (echo "VM config error or time out."; exit 1) \n\
touch /var/lib/qemu/initialized \n\
chmod g+rw /var/lib/qemu/* \n\
exec run-vm.sh \n\
\n' > /usr/local/bin/prepare-and-run-vm.sh && \
    chmod +x /usr/local/bin/prepare-and-run-vm.sh

# Runtime configuration
ENV QEMU_MEMORY="256M"
ENV QEMU_STORAGE="1G"
ENV QEMU_SMP="2"
ENV QEMU_LAN_OPTIONS=""
ENV QEMU_WAN_NETWORK="172.16.0.0/24"
ENV QEMU_WAN_OPTIONS="hostfwd=tcp::30022-:22,hostfwd=tcp::30080-:80,hostfwd=tcp::30443-:443,hostfwd=udp::51820-:51820"
ENV QEMU_PASSWORD="pass1234"
ENV QEMU_CONFIG_TIMEOUT="300"
ENV QEMU_CONFIG_NO_DEFAULTS=""
ENV QEMU_HOSTNAME="OpenWrtVM"
ENV QEMU_ARGS=""

EXPOSE 5900/tcp
EXPOSE 30022/tcp
EXPOSE 30080/tcp
EXPOSE 30443/tcp
EXPOSE 51820/udp

HEALTHCHECK --interval=30s --timeout=30s --start-period=120s --retries=3 CMD [ "/usr/local/bin/healthcheck-vm.sh" ]
VOLUME /var/lib/vmconfig
VOLUME /var/lib/qemu
WORKDIR /projects
USER 1001
CMD ["tail", "-f", "/dev/null"]