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
# Build with default versions (pulpcore 3.85.x - latest patch)
PROJECT=pulp-development make build

# Build with custom versions (example: Katello 4.20 compatible) 
PROJECT=pulp-development \
VERSION=3.85 \
PULP_ANSIBLE_VERSION=0.28 \
PULP_CONTAINER_VERSION=2.26 \
PULP_RPM_VERSION=3.32 \
PULP_OSTREE_VERSION=2.5 \
PULP_PYTHON_VERSION=3.19 \
PULP_DEB_VERSION=3.8 \
make build
```

### Version Compatibility

For newer pulpcore versions that pulp-smart-proxy doesn't officially support yet:
```bash
PROJECT=pulp-development \
VERSION=3.105 \
PULP_SMART_PROXY_ALLOW_UNSUPPORTED_VERSIONS=true \
make build
```

This installs pulp-smart-proxy from source with version constraints relaxed.

### Notes

- `VERSION` specifies the pulpcore major.minor version (e.g., `3.85`)
- Automatically installs the latest patch version (e.g., `3.85.x`)
- Plugin versions use major.minor format and auto-update to latest patch
- Images are tagged as `quay.io/foreman/pulp-development:VERSION`
- Base image is automatically selected to match the pulpcore version

### How to Release

```bash
PROJECT=pulp-development VERSION=3.85 make push
```

