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

Edit `images/pulp-development/Containerfile` to specify the plugin versions you need:

```dockerfile
# Install specific plugin versions
# Edit these versions as needed for your environment
RUN pip install --upgrade pip && \
    pip install \
        pulpcore==3.105.1 \
        pulp-ansible==0.29.6 \
        pulp-container==2.27.3 \
        pulp-rpm==3.35.2 \
        pulp-ostree==2.6.0 \
        pulp-python==3.27.0 \
        pulp-deb==3.8.1 \
        pulp-smart-proxy
```

The containerfile also contains commented lines for increaseing the maximum Pulpcore version.
This is helpful for when pulp_smart_proxy isn't yet tested with a newer version of Pulpcore.

### How to Build

To build the container image locally:

```
PROJECT=pulp-development VERSION=3.105 make build
```

### How to Release

To push a new version of the container:

```
PROJECT=pulp-development VERSION=3.105 make push
```

