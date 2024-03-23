FROM scratch
ADD output/openwrt-x86-generic-generic-rootfs.tar.gz /

EXPOSE 80

#RUN mkdir /var/lock && \
#    opkg update && \
#    opkg install uhttpd-mod-lua && \
#    uci set uhttpd.main.interpreter='.lua=/usr/bin/lua' && \
#    uci commit uhttpd && \
#    /etc/init.d/uhttpd enable && \
#    /etc/init.d/uhttpd start && \
#    echo 'Hello, World!' > /www/index.html

USER 0

RUN mkdir /var/lock && \
    opkg update && \
    uci commit uhttpd && \
    /etc/init.d/uhttpd enable && \
    /etc/init.d/uhttpd start

RUN chmod 777 /sbin/init

#USER root
#
#CMD [ "/sbin/init" ]