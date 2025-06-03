IMAGE_NAME=quay.io/theforeman/pulpcore

PROJECT_XY_TAG=3.73
PROJECT_XYZ_TAG=${PROJECT_XY_TAG}.9

FOREMAN_XY_TAG=foreman-3.16
FOREMAN_XYZ_TAG=${FOREMAN_XY_TAG}.0

IMAGE_TAGS=${IMAGE_NAME}:${PROJECT_XY_TAG} ${IMAGE_NAME}:${PROJECT_XYZ_TAG} ${IMAGE_NAME}:${FOREMAN_XY_TAG} ${IMAGE_NAME}:${FOREMAN_XYZ_TAG}

build:
	podman build --file images/pulpcore/Containerfile --tag ${IMAGE_NAME}:${PROJECT_XYZ_TAG}	.
	$(foreach tag,$(IMAGE_TAGS),\
		podman tag ${IMAGE_NAME}:${PROJECT_XYZ_TAG} $(tag); \
	)

push:
	$(foreach tag,$(IMAGE_TAGS),\
		podman push $(tag);\
	)
