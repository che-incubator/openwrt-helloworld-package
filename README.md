[![Contribute (sandbox)](https://img.shields.io/static/v1?label=Dev%20Spaces%20sandbox&message=for%20maintainers&logo=redhat&color=FDB940&labelColor=525C86)](https://workspaces.openshift.com#https://github.com/che-incubator/openwrt-helloworld-package)
[![Contribute (nightly)](https://img.shields.io/static/v1?label=nightly%20Che&message=for%20maintainers&logo=eclipseche&color=FDB940&labelColor=525C86)](https://che-dogfooding.apps.che-dev.x6e0.p1.openshiftapps.com#https://github.com/che-incubator/openwrt-helloworld-package)

# About OpenWrt HelloWorld package

OpenWrt is a highly extensible GNU/Linux distribution for embedded devices (typically wireless routers). Unlike many other distributions for routers, OpenWrt is built from the ground up to be a full-featured, easily modifiable operating system for embedded devices. In practice, this means you can have all the features you need with no bloat, powered by a modern Linux kernel. It provides convenient tools to integrate pre-built packages into a custom firmware image. This repo includes a sample of the HelloWorld package for OpenWrt.

## Description

This is the simple C++ OpenWrt package to print the phrase "Hello, World!" to the console.

## Usage

If the HelloWorld package is placed in openwrt/package, the following is used to compile it:
```bash
make package/helloworld/compile V=s
```

## Development with Eclipse Che

- Create and start a workspace from this repository.
- Open the target workspace. Link HelloWorld package, configs and install all the necessary packages to build OpenWRT. We can do this by running the following tasks from the devfile.yaml file: `Link helloworld package`, `Copy diff-config to OpenWRT`, `Install all package definitions`.
- Build OpenWRT by running the following task from the devfile.yaml file: `Build all packages and the kernel`.


## Builds
This repo contains several [actions](https://github.com/che-incubator/openwrt-helloworld-package/actions), including:
* [![Build of the CDE container image](https://github.com/che-incubator/openwrt-helloworld-package/actions/workflows/cde-image-build.yaml/badge.svg)](https://github.com/che-incubator/openwrt-helloworld-package/actions/workflows/cde-image-build.yaml)
* [![Build of the QEMU container image](https://github.com/che-incubator/openwrt-helloworld-package/actions/workflows/qemu-image-build.yaml/badge.svg)](https://github.com/che-incubator/openwrt-helloworld-package/actions/workflows/qemu-image-build.yaml)

## License

See [LICENSE](LICENSE) file.
