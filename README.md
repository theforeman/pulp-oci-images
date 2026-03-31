# Pulp Container Images

This repository provides Pulp container images for the Foreman project's use case.
It follows [foremanctl's container builds structure](https://github.com/theforeman/foremanctl/blob/master/docs/developer/container-image-builds.md).

Note that OCI stands for "Open Container Initiative", see [here](https://opencontainers.org/).

## Production

### How to Build

To build the container image locally:

```
make build
```

### How to Release

To push a new version of the container:

```
make push
```

## Development

### How to Build

Build with default versions (pulpcore 3.105.1):
```bash
PROJECT=pulp-development make build
```

Build with custom plugin versions:
```bash
PROJECT=pulp-development \
VERSION=3.85 \
PULPCORE_VERSION=3.85.13 \
PULP_ANSIBLE_VERSION=0.28.5 \
PULP_CONTAINER_VERSION=2.26.7 \
PULP_RPM_VERSION=3.32.9 \
PULP_OSTREE_VERSION=2.5.3 \
PULP_PYTHON_VERSION=3.19.1 \
PULP_DEB_VERSION=3.8.1 \
make build
```

### Version Compatibility

For newer pulpcore versions that pulp-smart-proxy doesn't officially support yet:
```bash
PROJECT=pulp-development \
PULPCORE_VERSION=3.105.1 \
PULP_SMART_PROXY_ALLOW_UNSUPPORTED_VERSIONS=true \
make build
```

This installs pulp-smart-proxy from source with version constraints relaxed.

### How to Release

```bash
PROJECT=pulp-development VERSION=3.105 make push
```

