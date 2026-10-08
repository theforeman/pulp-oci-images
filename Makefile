# Production builds (default)
PROJECT?=pulp
IMAGE_NAME=quay.io/foreman/${PROJECT}

PROJECT_XY_TAG=${VERSION}
PROJECT_XYZ_TAG=${PROJECT_XY_TAG} #.8

FOREMAN_XY_TAG=foreman-nightly
FOREMAN_XYZ_TAG=${FOREMAN_XY_TAG} #.0

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

# Source builds
ifeq ($(PROJECT),pulp-source)
SOURCE_REQUIREMENTS=images/pulp-source/pulpcore-packaging/automation/requirements.txt
_SOURCE_PULPCORE_VERSION=$(shell sed -n 's/^pulpcore==//p' $(SOURCE_REQUIREMENTS) 2>/dev/null)
WHEELS_IMAGE_TAG?=$(if $(_SOURCE_PULPCORE_VERSION),$(_SOURCE_PULPCORE_VERSION),latest)-wheels
WHEELS_IMAGE_NAME=quay.io/foreman/pulp

build:
	cd images/pulp-source && podman build --file Containerfile \
		--tag ${WHEELS_IMAGE_NAME}:${WHEELS_IMAGE_TAG} .

push:
	podman push ${WHEELS_IMAGE_NAME}:${WHEELS_IMAGE_TAG}
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
