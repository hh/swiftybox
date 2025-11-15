#!/bin/bash
# build-base-image.sh - Build and optionally push the SwiftyλBox base image
#
# This image contains Swift SDK + BusyBox and should be rebuilt when:
# - Swift version changes
# - BusyBox version changes
# - ASH integration patch changes

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Configuration
IMAGE_NAME="${IMAGE_NAME:-swiftybox-base}"
IMAGE_TAG="${IMAGE_TAG:-musl}"
REGISTRY="${REGISTRY:-ghcr.io/hh}"
PUSH="${PUSH:-false}"

echo "=========================================="
echo "Building SwiftyλBox Base Image"
echo "=========================================="
echo "Image: $IMAGE_NAME:$IMAGE_TAG"
echo "Registry: $REGISTRY"
echo "Push: $PUSH"
echo "=========================================="

# Build the base image
podman build \
    -f Containerfile.base-musl \
    -t "$IMAGE_NAME:$IMAGE_TAG" \
    -t "$REGISTRY/$IMAGE_NAME:$IMAGE_TAG" \
    .

echo ""
echo "✓ Base image built successfully!"
echo ""
echo "Local tag: $IMAGE_NAME:$IMAGE_TAG"
echo "Registry tag: $REGISTRY/$IMAGE_NAME:$IMAGE_TAG"
echo ""

# Push if requested
if [ "$PUSH" = "true" ]; then
    echo "Pushing to registry..."
    podman push "$REGISTRY/$IMAGE_NAME:$IMAGE_TAG"
    echo "✓ Image pushed to $REGISTRY/$IMAGE_NAME:$IMAGE_TAG"
fi

echo ""
echo "=========================================="
echo "Next steps:"
echo "=========================================="
echo ""
echo "1. To push to registry:"
echo "   PUSH=true ./build-base-image.sh"
echo ""
echo "2. To build SwiftyλBox using this base:"
echo "   podman build -f Containerfile.musl-production -t swiftybox:musl ."
echo ""
echo "3. For development (interactive):"
echo "   podman run -it --rm -v \$(pwd):/workspace $IMAGE_NAME:$IMAGE_TAG"
echo ""
