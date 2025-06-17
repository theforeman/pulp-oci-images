IMAGE_NAME=quay.io/theforeman/pulpcore
IMAGE_TAG=3.73.8

build:
	cd images/pulpcore && podman build --file Containerfile --tag ${IMAGE_NAME}:${IMAGE_TAG} .

push:
	podman push ${IMAGE_NAME}:${IMAGE_TAG}
