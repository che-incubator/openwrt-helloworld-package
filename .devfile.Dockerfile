FROM docker.io/debian:buster

USER root
# Install openwrt build dependencies
RUN apt-get update &&\
    apt-get install -y \
        sudo ccache time git-core build-essential g++ bash make \
        libssl-dev patch libncurses5 libncurses5-dev zlib1g-dev gawk \
        flex gettext wget zip unzip xz-utils python python-distutils-extra \
        python3 python3-distutils-extra rsync curl libsnmp-dev liblzma-dev \
        libpam0g-dev cpio rsync re2c && \
    wget https://github.com/cli/cli/releases/download/v2.39.2/gh_2.39.2_linux_amd64.deb && \
    apt-get install -f ./gh_2.39.2_linux_amd64.deb && \
    rm -f ./gh_2.39.2_linux_amd64.deb && \
    apt-get clean && \
    useradd -m user && \
    echo 'user ALL=NOPASSWD: ALL' > /etc/sudoers.d/user

# Install Node.js for che-code editor
ARG NODE_VERSION=v20.12.2
ARG NODE_DISTRO=linux-x64
ARG NODE_BASE_URL=https://nodejs.org/dist/${NODE_VERSION}

RUN curl -fsSL ${NODE_BASE_URL}/node-${NODE_VERSION}-${NODE_DISTRO}.tar.gz -o node-${NODE_VERSION}-${NODE_DISTRO}.tar.gz \
  && mkdir -p /usr/local/lib/nodejs \
  && tar -xzf node-${NODE_VERSION}-${NODE_DISTRO}.tar.gz -C /usr/local/lib/nodejs \
  && rm node-${NODE_VERSION}-${NODE_DISTRO}.tar.gz

ENV VSCODE_NODEJS_RUNTIME_DIR=/usr/local/lib/nodejs/node-${NODE_VERSION}-${NODE_DISTRO}/bin
ENV PATH=${VSCODE_NODEJS_RUNTIME_DIR}:$PATH

RUN apt-get install -y npm \
    && npm install -g http-server

USER user

# Install OpenWRT build dependencies
ARG OPENWRT_BASE_URL='https://github.com/openwrt/openwrt'
ARG OPENWRT_VERSION='21.02.3'

RUN mkdir -p /tmp/pre-install /tmp/pre-install/openwrt /tmp/pre-install/openwrt/package

COPY ${PWD}/package/helloworld /tmp/pre-install/openwrt/package/helloworld
COPY ${PWD}/configs/.x86-generic.config /tmp/pre-install/openwrt/.config

RUN cd /tmp/pre-install \
    && curl "${OPENWRT_BASE_URL}/archive/refs/tags/v${OPENWRT_VERSION}.zip" -L -o "/tmp/pre-install/openwrt-${OPENWRT_VERSION}.zip" \
    && unzip "/tmp/pre-install/openwrt-${OPENWRT_VERSION}.zip" -d /tmp/pre-install \
    && rm -rf /tmp/pre-install/openwrt-${OPENWRT_VERSION}.zip \
    && cd /tmp/pre-install/openwrt-${OPENWRT_VERSION} \
    && cp /tmp/pre-install/openwrt/.config /tmp/pre-install/openwrt-${OPENWRT_VERSION}/.config \
    && cp -r /tmp/pre-install/openwrt/package /tmp/pre-install/openwrt-${OPENWRT_VERSION}/package \
    && cd /tmp/pre-install/openwrt-${OPENWRT_VERSION} \
    && scripts/feeds update -a -f \
    && scripts/feeds install -a -f \
    && cp /tmp/pre-install/openwrt/.config /tmp/pre-install/openwrt-${OPENWRT_VERSION}/.config \
    && make defconfig \
    && make -j$(nproc) \
    && mv bin ../openwrt \
    && rm -r bin \
    && mv build_dir ../openwrt \
    && rm -r build_dir \
    && mv dl ../openwrt \
    && rm -r dl \
    && mv feeds ../openwrt \
    && rm -r feeds \
    && mv staging_dir ../openwrt \
    && rm -r staging_dir \
    && mv tmp ../openwrt \
    && rm -r tmp \
    && cd /tmp/pre-install \
    && rm -rf /tmp/pre-install/openwrt-${OPENWRT_VERSION}

CMD ["tail", "-f", "/dev/null"]
