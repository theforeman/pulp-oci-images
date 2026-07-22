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

Development builds give you a Pulp server with all the plugins Foreman/Katello needs,
built from PyPI packages so you can easily test different versions.

### Prerequisites

- `podman` (or `docker`) installed
- Clone this repo:
  ```bash
  git clone https://github.com/theforeman/pulp-oci-images.git
  cd pulp-oci-images
  ```

### How to Build

```bash
PROJECT=pulp-development make build
```

This builds a container image tagged `quay.io/foreman/pulp-development:latest` with the
newest versions of pulpcore and all plugins.

### What's Inside

The image installs these Pulp components from PyPI:

- **pulpcore** — the Pulp platform
- **pulp-ansible**, **pulp-container**, **pulp-deb**, **pulp-ostree**, **pulp-python**,
  **pulp-rpm** — content plugins
- **pulp-smart-proxy** — the Foreman Smart Proxy integration plugin

`pulp-smart-proxy` is modified: during the build it's cloned from GitHub (`develop`
branch) and patched to remove pulpcore version restrictions, so it always works regardless
of which pulpcore version you're running.

### PyPI Requirements

The packages to install are listed in `images/pulp-development/requirements.txt`.
By default pulpcore is unpinned, so pip installs the latest compatible version of
everything.

The Makefile reads `requirements.txt` to determine the base image tag. If there's a
`pulpcore==X.Y.Z` pin it uses that version, otherwise it defaults to `:latest`.

A separate `constraints.txt` file is used to point `pulp-smart-proxy` at a locally
patched copy that has its pulpcore version requirement removed. This allows
pulp-smart-proxy to work with any pulpcore version. You should not need to edit
`constraints.txt`.

### Pinning Versions

If you need a specific pulpcore version,
pin it directly in `images/pulp-development/requirements.txt`:

```
pulpcore==3.105.1
```

Then build normally:

```bash
PROJECT=pulp-development make build
```

pip will resolve the newest plugin versions compatible with the pinned pulpcore. You can
also pin individual plugins if you need a fully locked set. The nightly RPM repo
([yum.theforeman.org](https://yum.theforeman.org/pulpcore/nightly/el9/x86_64/)) is a
useful reference for compatible version combinations:

```
pulpcore==3.105.1
pulp-ansible==0.29.7
pulp-container==2.27.6
pulp-rpm==3.35.2
pulp-ostree==2.6.0
pulp-python==3.27.2
pulp-deb==3.8.1
```

### Quick Reference

| I want... | What to do |
|---|---|
| Latest everything | `PROJECT=pulp-development make build` (no changes needed) |
| Specific pulpcore | Pin `pulpcore==X.Y.Z` in `requirements.txt`, then build |
| Fully locked versions | Pin all packages in `requirements.txt`, then build |
| Push to registry | `PROJECT=pulp-development make push` |

### How to Release

```bash
PROJECT=pulp-development make push
```
