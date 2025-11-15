#!/bin/bash
# Build SwiftyλBox with local proxy support
#
# Usage:
#   ./build-with-proxy.sh              # Build minimal production image
#   ./build-with-proxy.sh production-dev  # Build full dev image

set -e

TARGET="${1:-production}"

echo "Building SwiftyλBox with proxy configuration..."
echo "Target: $TARGET"
echo "Proxy: ${HTTP_PROXY:-not set}"
echo "CA Cert: ${NODE_EXTRA_CA_CERTS:-not set}"

# Ensure proxy cert exists as real file (not symlink)
if [ ! -f proxy-cas.pem ] && [ -n "$NODE_EXTRA_CA_CERTS" ]; then
    echo "Copying proxy CA cert to build context..."
    cp -L "$NODE_EXTRA_CA_CERTS" proxy-cas.pem
fi

# Convert localhost proxy URLs to host.containers.internal for container access
CONTAINER_HTTP_PROXY="${HTTP_PROXY/localhost/host.containers.internal}"
CONTAINER_HTTPS_PROXY="${HTTPS_PROXY/localhost/host.containers.internal}"

echo "Container proxy: $CONTAINER_HTTP_PROXY"

# Build with proxy args
podman build \
    --build-arg HTTP_PROXY="$CONTAINER_HTTP_PROXY" \
    --build-arg HTTPS_PROXY="$CONTAINER_HTTPS_PROXY" \
    --build-arg NO_PROXY="$NO_PROXY" \
    --target "$TARGET" \
    -f Containerfile \
    -t swiftybox:${TARGET} \
    .

echo ""
echo "✅ Build complete!"
echo "Image: swiftybox:${TARGET}"
echo ""
echo "Test it:"
echo "  podman run --rm swiftybox:${TARGET} /bin/echo 'Hello from SwiftyλBox!'"
