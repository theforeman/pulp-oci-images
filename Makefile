PROJECT=pulp
IMAGE_NAME=quay.io/foreman/${PROJECT}

PROJECT_XY_TAG=nightly
PROJECT_XYZ_TAG=${PROJECT_XY_TAG} #.8

FOREMAN_XY_TAG=foreman-nightly
FOREMAN_XYZ_TAG=${FOREMAN_XY_TAG} #.0

IMAGE_TAGS=${IMAGE_NAME}:${PROJECT_XY_TAG} ${IMAGE_NAME}:${PROJECT_XYZ_TAG} ${IMAGE_NAME}:${FOREMAN_XY_TAG} ${IMAGE_NAME}:${FOREMAN_XYZ_TAG}

build:
	cd images/${PROJECT} && podman build --file Containerfile --build-arg VERSION=${PROJECT_XY_TAG} --tag ${IMAGE_NAME}:${PROJECT_XYZ_TAG}	.
	$(foreach tag,$(IMAGE_TAGS),\
		podman tag ${IMAGE_NAME}:${PROJECT_XYZ_TAG} $(tag); \
	)

push:
	$(foreach tag,$(IMAGE_TAGS),\
		podman push $(tag);\
	)
