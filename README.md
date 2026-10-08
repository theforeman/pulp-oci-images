# Pulp Container Images

This repository provides Pulp container images for the Foreman project's use case.
It follows [foremanctl's container builds structure](https://github.com/theforeman/foremanctl/blob/master/docs/developer/container-image-builds.md).

Note that OCI stands for "Open Container Initiative", see [here](https://opencontainers.org/).

## RPM build modes by branch

| Branch | RPM build mode |
| --- | --- |
| `master` (nightly) | Non-hermetic; DNF resolves RPMs during the build. |
| `foreman-5.0` | Hermetic in Konflux; `USE_HERMETO_REPOS=true` enables [Hermeto prefetching](https://konflux-ci.dev/docs/building/prefetching-dependencies/). |

On `foreman-5.0`, `images/pulp/rpms.in.yaml` lists the requested packages and repository
files; `images/pulp/rpms.lock.yaml` pins the resolved RPM transaction. `make build` runs
Podman directly and does not run Hermeto, so it does not validate Konflux prefetching.

### Refresh the RPM lockfile

The `make refresh-rpm-lockfiles` target is also present on `master` for future stable
branches. Current `master` has no hermetic RPM inputs; run it on `foreman-5.0` or another
branch that has the corresponding input file:

```bash
git switch foreman-5.0
make refresh-rpm-lockfiles
git diff -- images/pulp/rpms.lock.yaml
```

The target builds the official [rpm-lockfile-prototype container workflow](https://github.com/konflux-ci/rpm-lockfile-prototype#running-in-a-container) locally with Podman when needed, then regenerates the lockfile from `images/pulp/rpms.in.yaml` and its referenced repository files. It mounts with `:z` for SELinux relabeling. The helper image is not published, and `make build` is unaffected. The tool defaults to `v0.30.1`; set `RPM_LOCKFILE_VERSION` only when intentionally testing or adopting another upstream release.

The input has an explicit `packages` list, which takes precedence over [Containerfile package scanning](https://github.com/konflux-ci/rpm-lockfile-prototype#containerfile-package-scanning-and-packages-precedence). Update `images/pulp/rpms.in.yaml` when changing the RPM package set, then refresh and review the lockfile.

See the [shared hermetic RPM guide](https://github.com/theforeman/theforeman-rel-eng-konflux/blob/develop/docs/hermetic-rpm-builds.md) for the shared branch matrix and troubleshooting guidance.

Related OCI image repositories:

- [Foreman OCI images](https://github.com/theforeman/foreman-oci-images/blob/master/README.md)
- [Pulp OCI images](https://github.com/theforeman/pulp-oci-images/blob/master/README.md)
- [Candlepin OCI images](https://github.com/theforeman/candlepin-oci-images/blob/master/README.md)

## Production

Production builds install from RPM packages and use multiple tags.

### How to Build

```bash
# Build latest/nightly version
make build

# Build specific RPM repo version
VERSION=3.105 make build
```

## Publishing

After a change is merged, Konflux builds and publishes the image through the branch's
push pipeline. Check that Konflux pipeline to confirm publication; `make push` is not
the release workflow for these images.

## Source

The source image installs the versions pinned by the `pulpcore-packaging`
submodule's `automation/requirements.txt` using pip. Build it with:

```bash
PROJECT=pulp-source make build
```

The image is tagged as `quay.io/foreman/pulp:<pulpcore-version>-wheels`.

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
