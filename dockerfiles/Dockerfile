FROM scratch
ADD output/openwrt-x86-generic-generic-rootfs.tar.gz /

EXPOSE 80

RUN mkdir /var/lock && \
    opkg update && \
    opkg install uhttpd-mod-lua && \
    uci set uhttpd.main.interpreter='.lua=/usr/bin/lua' && \
    uci commit uhttpd && \
    /etc/init.d/uhttpd enable && \
    /etc/init.d/uhttpd start && \
    echo "Hello, World!" > /www/index.html

USER root

# using exec format so that /sbin/init is proc 1 (see procd docs)
CMD ["/sbin/init"]