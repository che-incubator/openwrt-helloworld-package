FROM quay.io/devfile/universal-developer-image:ubi8-6eb0041

# Switching to root user (setting UID to 0) because next
# commands require root privileges. Universal Developer
# Image default user has UID set to 10001.
USER 0

RUN dnf -y update && dnf -y install \
    gcc gcc-c++ make ncurses-devel patch rsync tar unzip bzip2 wget which diffutils python2 python3 perl &&\
    dnf -y clean all --enablerepo='*'

RUN npm install -g http-server
# Switch back to default user
USER 10001

ARG OPENWRT_BASE_URL='https://github.com/openwrt/openwrt'
ARG OPENWRT_VERSION='23.05.0-rc1'

COPY ${PWD}/package/helloworld /tmp/helloworld
COPY ${PWD}/configs/.x86-generic.config /tmp/.config

RUN mkdir -p /tmp/pre-install /tmp/pre-install/openwrt /tmp/pre-install/openwrt/${OPENWRT_VERSION} \
    && curl "${OPENWRT_BASE_URL}/archive/refs/tags/v${OPENWRT_VERSION}.zip" -L -o "/tmp/pre-install/openwrt-${OPENWRT_VERSION}.zip" \
    && unzip "/tmp/pre-install/openwrt-${OPENWRT_VERSION}.zip" -d /tmp/pre-install \
    && rm -rf /tmp/pre-install/openwrt-${OPENWRT_VERSION}.zip \
    && cd /tmp/pre-install/openwrt-${OPENWRT_VERSION} \
    && scripts/feeds update -a -f \
    && scripts/feeds install -a -f \
    && cp /tmp/.config /tmp/pre-install/openwrt-${OPENWRT_VERSION}/.config \
    && cp -r /tmp/helloworld /tmp/pre-install/openwrt-${OPENWRT_VERSION}/package/helloworld \
    && cd /tmp/pre-install/openwrt-${OPENWRT_VERSION} \
    && make defconfig \
    && make -j1 \
    && mv bin /tmp/pre-install/openwrt/${OPENWRT_VERSION}/bin \
    && mv build_dir /tmp/pre-install/openwrt/${OPENWRT_VERSION}/build_dir \
    && mv dl /tmp/pre-install/openwrt/${OPENWRT_VERSION}/dl \
    && mv feeds /tmp/pre-install/openwrt/${OPENWRT_VERSION}/feeds \
    && mv staging_dir /tmp/pre-install/openwrt/${OPENWRT_VERSION}/staging_dir \
    && mv tmp /tmp/pre-install/openwrt/${OPENWRT_VERSION}/tmp \
    && rm -rf /tmp/pre-install/openwrt-${OPENWRT_VERSION}
