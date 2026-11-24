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
