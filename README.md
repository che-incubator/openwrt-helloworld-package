# OpenWrt HelloWorld package

## Description

This is the simple C++ OpenWrt package to print the phrase "Hello, World!" to the console.

## Usage

If the HelloWorld package is placed in openwrt/package, the following is used to compile it:
```bash
make package/helloworld/compile V=s
```

## Remote development with Eclipse Che
- Create and start a workspace from this repository(This repository contains the necessary files to create a workspace in Eclipse Che to develop the OpenWrt HelloWorld package.).
- Open the terminal in the workspace.
- Login into your Kubernetes cluster via `oc login https://<IP>:<PORT> --certificate-authority=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt` command.
- Deploy the remote-gdb service via `kubectl apply -f ./kubernetes-manifests/remote-gdb.service.yaml` command.

## License

See [LICENSE](LICENSE) file.