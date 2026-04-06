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
VERSION?=3.85.15
DEV_IMAGE_NAME=quay.io/foreman/pulp-development

build:
	cd images/pulp-development && podman build --file Containerfile \
		--build-arg VERSION=${VERSION} \
		$(if ${PULP_ANSIBLE_VERSION},--build-arg PULP_ANSIBLE_VERSION=${PULP_ANSIBLE_VERSION}) \
		$(if ${PULP_CONTAINER_VERSION},--build-arg PULP_CONTAINER_VERSION=${PULP_CONTAINER_VERSION}) \
		$(if ${PULP_RPM_VERSION},--build-arg PULP_RPM_VERSION=${PULP_RPM_VERSION}) \
		$(if ${PULP_OSTREE_VERSION},--build-arg PULP_OSTREE_VERSION=${PULP_OSTREE_VERSION}) \
		$(if ${PULP_PYTHON_VERSION},--build-arg PULP_PYTHON_VERSION=${PULP_PYTHON_VERSION}) \
		$(if ${PULP_DEB_VERSION},--build-arg PULP_DEB_VERSION=${PULP_DEB_VERSION}) \
		$(if ${PULP_SMART_PROXY_ALLOW_UNSUPPORTED_VERSIONS},--build-arg PULP_SMART_PROXY_ALLOW_UNSUPPORTED_VERSIONS=${PULP_SMART_PROXY_ALLOW_UNSUPPORTED_VERSIONS}) \
		--tag ${DEV_IMAGE_NAME}:${VERSION} .

push:
	podman push ${DEV_IMAGE_NAME}:${VERSION}
endif
