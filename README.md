# Pulp Container Images

This repository provides Pulp container images for the Foreman project's use case.
It follows [foremanctl's container builds structure](https://github.com/theforeman/foremanctl/blob/master/docs/developer/container-image-builds.md).

Note that OCI stands for "Open Container Initiative", see [here](https://opencontainers.org/).

## Production

Production builds install from RPM packages and use multiple tags.

### How to Build

```bash
# Build latest/nightly version
make build

# Build specific RPM repo version
VERSION=3.85 make build
```

### How to Release

```bash
make push
```

## Development

Development builds install from PyPI and use single version tags.

### How to Build

```bash
# Build with default pulpcore version (3.105.1)
PROJECT=pulp-development make build

# Build with Katello 4.20 compatible versions
PROJECT=pulp-development \
VERSION=3.85.13 \
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
VERSION=3.105.1 \
PULP_SMART_PROXY_ALLOW_UNSUPPORTED_VERSIONS=true \
make build
```

This installs pulp-smart-proxy from source with version constraints relaxed.

### Notes

- `VERSION` specifies the pulpcore version to install via pip
- Images are tagged as `quay.io/foreman/pulp-development:VERSION`
- Base image is automatically selected to match the pulpcore version

### How to Release

```bash
PROJECT=pulp-development VERSION=3.85.13 make push
```

