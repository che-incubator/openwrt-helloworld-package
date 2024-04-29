FROM scratch
ADD output/openwrt-x86-generic-generic-rootfs.tar.gz /

EXPOSE 80

RUN mkdir /var/lock && \
    opkg update && \
    opkg install uhttpd-mod-lua && \
    uci set uhttpd.main.interpreter='.lua=/usr/bin/lua' && \
    uci set uhttpd.main.redirect_https=1 && \
    uci commit uhttpd

USER root

CMD ["/sbin/init"]