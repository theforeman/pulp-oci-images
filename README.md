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

Development builds install pulpcore and plugins from PyPI using `requirements.txt`.
Only `pulpcore` is pinned by default — pip resolves compatible plugin versions automatically.

The image tag is derived automatically from the `pulpcore` version in `requirements.txt`,
or `:latest` if unpinned.

### How to Build

```bash
PROJECT=pulp-development make build
```

### Pinning Versions

To target a specific pulpcore version, edit the `pulpcore` line in
`images/pulp-development/requirements.txt`:

```
pulpcore==3.105.1
pulp-ansible
pulp-container
pulp-rpm
pulp-ostree
pulp-python
pulp-deb
pulp-smart-proxy
```

pip will resolve the newest plugin versions compatible with the pinned pulpcore. You can
also pin individual plugins explicitly if you need a specific known-good set — the nightly
RPM repo ([yum.theforeman.org](https://yum.theforeman.org/pulpcore/nightly/el9/x86_64/))
is a useful reference for compatible version combinations:

```
pulpcore==3.105.1
pulp-ansible==0.29.7
pulp-container==2.27.6
pulp-rpm==3.35.2
pulp-ostree==2.6.0
pulp-python==3.27.2
pulp-deb==3.8.1
pulp-smart-proxy==0.4.0
```

### How to Release

```bash
PROJECT=pulp-development make push
```

### Newer pulpcore Versions (pulp-smart-proxy compatibility)

If you need a pulpcore version that `pulp-smart-proxy` doesn't yet officially support,
edit `images/pulp-development/requirements-custom-pulp-smart-proxy.txt` with the versions
you want (it mirrors `requirements.txt` but without `pulp-smart-proxy`), then build with:

```bash
PROJECT=pulp-development PULP_SMART_PROXY_ALLOW_UNSUPPORTED_VERSIONS=true make build
```

This clones `pulp-smart-proxy` from the `develop` branch, removes the pulpcore upper
version bound from its dependency constraints, and installs that patched version alongside
the plugins from `requirements-custom-pulp-smart-proxy.txt`.
