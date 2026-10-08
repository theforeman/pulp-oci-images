# Repository agent notes

This repository builds Pulp OCI images used by Foreman.

## RPM build modes

- `master` builds the nightly RPM image using ordinary DNF repository resolution; it is
  not a hermetic RPM build.
- `foreman-5.0` uses Hermeto-prefetched RPMs in Konflux with `USE_HERMETO_REPOS=true`.
  Package and repository inputs are in `images/pulp/rpms.in.yaml`; resolved RPMs are
  pinned in `images/pulp/rpms.lock.yaml`.
- `make build` invokes Podman directly and does not run Hermeto. On `foreman-5.0`, use
  `VERSION=3.105 make build` for a local build, not as validation of Konflux prefetching.

## Refreshing the RPM lockfile

The Makefile target is present on `master` for future stable branches, but current
`master` has no lock inputs. Run `make refresh-rpm-lockfiles` on `foreman-5.0` or another
branch containing `images/pulp/rpms.in.yaml`.

The target builds the official `rpm-lockfile-prototype` helper image locally with Podman
when needed, defaults to upstream release `v0.30.1`, and does not publish the helper. It
mounts the repository with `:z` for SELinux relabeling. Keep it separate from `build`,
GHA, and image publishing.

The explicit `packages` list in `rpms.in.yaml` takes precedence over Containerfile
package scanning. Update the input when changing RPM packages; refresh and review the
lockfile after package or repository changes.

## Publishing and troubleshooting

Konflux publishes images through branch push pipelines after merge; local Makefile `push`
targets are not the release workflow. For hermetic failures, inspect `prefetch-dependencies`
logs first and then `build-container`. Check the versioned `.tekton/pulp-5-0-*` pipeline
parameters and the lockfile inputs.

## References

- [shared hermetic RPM guide](https://github.com/theforeman/theforeman-rel-eng-konflux/blob/develop/docs/hermetic-rpm-builds.md)
- [Konflux dependency prefetching](https://konflux-ci.dev/docs/building/prefetching-dependencies/)
- [Hermeto RPM dependencies](https://hermetoproject.github.io/hermeto/rpm/)
- [rpm-lockfile-prototype container instructions](https://github.com/konflux-ci/rpm-lockfile-prototype#running-in-a-container)
- [rpm-lockfile-prototype package precedence](https://github.com/konflux-ci/rpm-lockfile-prototype#containerfile-package-scanning-and-packages-precedence)
- [MintMaker RPM lockfiles](https://konflux-ci.dev/docs/mintmaker/rpm-lockfile/)
- [MintMaker support](https://konflux-ci.dev/docs/mintmaker/support/)
- [MintMaker user guide](https://konflux-ci.dev/docs/mintmaker/user/)
- [Renovate documentation](https://docs.renovatebot.com/)
- [Foreman OCI images README](https://github.com/theforeman/foreman-oci-images/blob/master/README.md)
- [Pulp OCI images README](https://github.com/theforeman/pulp-oci-images/blob/master/README.md)
- [Candlepin OCI images README](https://github.com/theforeman/candlepin-oci-images/blob/master/README.md)
