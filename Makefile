IMAGE_NAME=quay.io/theforeman/pulpcore
IMAGE_TAG=3.73.8

build:
	podman build -f images/pulpcore/Containerfile -t ${IMAGE_NAME}:${IMAGE_TAG} .

push:
	podman push ${IMAGE_NAME}:${IMAGE_TAG}