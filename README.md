# Pulp Container Images

The [pulpcore-oci-images](https://github.com/theforeman/pulpcore-oci-images) repository is used to provide a Pulp container image configured for the Foreman project's use case.

Note that OCI stands for "Open Container Initiative", see [here](https://opencontainers.org/).

## How to Build

To build the container image locally:

```
make build
```

## How to Release

To push a new version of the container:

```
make push
```
