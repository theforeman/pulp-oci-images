# Production builds (default)
PROJECT?=pulp
IMAGE_NAME=quay.io/foreman/${PROJECT}

PROJECT_XY_TAG=3.118
PROJECT_XYZ_TAG=3.118

FOREMAN_XY_TAG=foreman-5.1
FOREMAN_XYZ_TAG=foreman-5.1.0-rc1

IMAGE_TAGS=${IMAGE_NAME}:${PROJECT_XY_TAG} ${IMAGE_NAME}:${PROJECT_XYZ_TAG} ${IMAGE_NAME}:${FOREMAN_XY_TAG} ${IMAGE_NAME}:${FOREMAN_XYZ_TAG}

# Production build target
ifeq ($(PROJECT),pulp)
VERSION?=nightly

build:
	cd images/${PROJECT} && podman build --file Containerfile --build-arg VERSION=${VERSION} --tag ${IMAGE_NAME}:${PROJECT_XYZ_TAG} .
	$(foreach tag,$(IMAGE_TAGS),\
		podman tag ${IMAGE_NAME}:${PROJECT_XYZ_TAG} $(tag); \
	)

push:
	$(foreach tag,$(IMAGE_TAGS),\
		podman push $(tag);\
	)
endif

# RPM lockfile maintenance. Keep this target on master for future version branches.
RPM_LOCKFILE_INPUTS := images/pulp/rpms.in.yaml
RPM_LOCKFILE_VERSION ?= v0.30.1
RPM_LOCKFILE_IMAGE ?= localhost/rpm-lockfile-prototype:$(RPM_LOCKFILE_VERSION)
RPM_LOCKFILE_CONTAINERFILE_URL ?= https://raw.githubusercontent.com/konflux-ci/rpm-lockfile-prototype/refs/heads/main/Containerfile

.PHONY: check-rpm-lockfile-inputs refresh-rpm-lockfiles refresh-rpm-lockfile rpm-lockfile-prototype-image
check-rpm-lockfile-inputs:
	@for input in $(RPM_LOCKFILE_INPUTS); do \
		if [ ! -f "$$input" ]; then \
			echo "Missing $$input; run this target from a branch with hermetic RPM inputs." >&2; \
			exit 1; \
		fi; \
	done

refresh-rpm-lockfiles: refresh-rpm-lockfile

refresh-rpm-lockfile: rpm-lockfile-prototype-image
	podman run --rm --volume "$(CURDIR):/work:z" \
		--workdir /work/images/pulp \
		$(RPM_LOCKFILE_IMAGE) --outfile=rpms.lock.yaml rpms.in.yaml

rpm-lockfile-prototype-image: check-rpm-lockfile-inputs
	@if ! podman image exists "$(RPM_LOCKFILE_IMAGE)"; then \
		curl --fail --location "$(RPM_LOCKFILE_CONTAINERFILE_URL)" | \
			podman build --build-arg GIT_REF=tags/$(RPM_LOCKFILE_VERSION) \
				--tag "$(RPM_LOCKFILE_IMAGE)" -; \
	fi
