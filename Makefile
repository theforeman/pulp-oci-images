# Production builds (default)
PROJECT?=pulp
IMAGE_NAME=quay.io/foreman/${PROJECT}

PROJECT_XY_TAG=3.105
PROJECT_XYZ_TAG=3.105

FOREMAN_XY_TAG=foreman-5.0
FOREMAN_XYZ_TAG=foreman-5.0.1

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

# Development builds
ifeq ($(PROJECT),pulp-development)
_PINNED_VERSION=$(shell grep '^pulpcore==' images/pulp-development/requirements.txt 2>/dev/null | cut -d= -f3)
PULPCORE_VERSION=$(if $(_PINNED_VERSION),$(_PINNED_VERSION),latest)
DEV_IMAGE_NAME=quay.io/foreman/pulp-development

build:
	cd images/pulp-development && podman build --file Containerfile \
		--build-arg PULPCORE_VERSION=${PULPCORE_VERSION} \
		--tag ${DEV_IMAGE_NAME}:${PULPCORE_VERSION} .

push:
	podman push ${DEV_IMAGE_NAME}:${PULPCORE_VERSION}
endif

# RPM lockfile maintenance (foreman-5.0 hermetic inputs)
RPM_LOCKFILE_VERSION ?= v0.30.1
RPM_LOCKFILE_IMAGE ?= localhost/rpm-lockfile-prototype:$(RPM_LOCKFILE_VERSION)
RPM_LOCKFILE_CONTAINERFILE_URL ?= https://raw.githubusercontent.com/konflux-ci/rpm-lockfile-prototype/refs/heads/main/Containerfile

.PHONY: refresh-rpm-lockfiles refresh-rpm-lockfile rpm-lockfile-prototype-image
refresh-rpm-lockfiles: refresh-rpm-lockfile

refresh-rpm-lockfile: rpm-lockfile-prototype-image
	podman run --rm --volume "$(CURDIR):/work:z" \
		--workdir /work/images/pulp \
		$(RPM_LOCKFILE_IMAGE) --outfile=rpms.lock.yaml rpms.in.yaml

rpm-lockfile-prototype-image:
	@if ! podman image exists "$(RPM_LOCKFILE_IMAGE)"; then \
		curl --fail --location "$(RPM_LOCKFILE_CONTAINERFILE_URL)" | \
			podman build --build-arg GIT_REF=tags/$(RPM_LOCKFILE_VERSION) \
				--tag "$(RPM_LOCKFILE_IMAGE)" -; \
	fi
