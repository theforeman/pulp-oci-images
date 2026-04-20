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

# Development builds
ifeq ($(PROJECT),pulp-development)
_REQUIREMENTS_FILE=$(if $(PULP_SMART_PROXY_ALLOW_UNSUPPORTED_VERSIONS),requirements-custom-pulp-smart-proxy.txt,requirements.txt)
_PINNED_VERSION=$(shell grep '^pulpcore==' images/pulp-development/$(_REQUIREMENTS_FILE) | cut -d= -f3)
PULPCORE_VERSION=$(if $(_PINNED_VERSION),$(_PINNED_VERSION),latest)
DEV_IMAGE_NAME=quay.io/foreman/pulp-development

build:
	cd images/pulp-development && podman build --file Containerfile \
		--build-arg PULPCORE_VERSION=${PULPCORE_VERSION} \
		$(if ${PULP_SMART_PROXY_ALLOW_UNSUPPORTED_VERSIONS},--build-arg PULP_SMART_PROXY_ALLOW_UNSUPPORTED_VERSIONS=${PULP_SMART_PROXY_ALLOW_UNSUPPORTED_VERSIONS}) \
		--tag ${DEV_IMAGE_NAME}:${PULPCORE_VERSION} .

push:
	podman push ${DEV_IMAGE_NAME}:${PULPCORE_VERSION}
endif
