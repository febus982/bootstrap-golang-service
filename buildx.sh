#!/usr/bin/env sh
# `buildx` uses named _builder_ instances configured for specific platforms.
# This script creates a `skaffold-builder` as required.
if ! docker buildx inspect skaffold-k3s-builder >/dev/null 2>&1; then
  docker buildx create --name skaffold-k3s-builder \
  --driver kubernetes \
  --platform linux/amd64 \
  --node skaffold-buildx-amd64 \
  --driver-opt namespace=default,nodeselector=kubernetes.io/arch=amd64
  docker buildx create --append --name skaffold-k3s-builder \
  --driver kubernetes \
  --platform linux/arm64 \
  --node skaffold-buildx-amd64 \
  --driver-opt namespace=default,nodeselector=kubernetes.io/arch=arm64
fi

# Building for multiple platforms requires pushing to a registry
# as the Docker Daemon cannot load multi-platform images.
if [ "$PUSH_IMAGE" = true ]; then
  args="--platform linux/amd64,linux/arm64 --push"
else
  args="--load"
fi

set -x      # show the command-line
docker buildx build --builder skaffold-k3s-builder --tag $IMAGE $args "$BUILD_CONTEXT"
