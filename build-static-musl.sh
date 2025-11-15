#!/bin/bash
# build-static-musl.sh - Build SwiftyλBox static musl binary with proxy support
#
# This script automatically configures proxy settings for container builds

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "==================================================================="
echo "SwiftyλBox Static Musl Build"
echo "==================================================================="

# Check if proxy is configured on host
if [ -n "$HTTPS_PROXY" ] || [ -n "$HTTP_PROXY" ]; then
    # Get proxy URL (prefer HTTPS_PROXY, fall back to HTTP_PROXY)
    PROXY_URL="${HTTPS_PROXY:-$HTTP_PROXY}"

    # Convert localhost/127.0.0.1 to container hostname
    CONTAINER_PROXY="${PROXY_URL//localhost/host.containers.internal}"
    CONTAINER_PROXY="${CONTAINER_PROXY//127.0.0.1/host.containers.internal}"

    echo "✓ Proxy detected on host: $PROXY_URL"
    echo "✓ Container proxy: $CONTAINER_PROXY"
    echo "✓ No proxy: ${NO_PROXY:-none}"

    # Build with proxy configuration
    podman build \
        --build-arg HTTP_PROXY="$CONTAINER_PROXY" \
        --build-arg HTTPS_PROXY="$CONTAINER_PROXY" \
        --build-arg NO_PROXY="${NO_PROXY:-127.0.0.1,localhost,::1}" \
        -f Containerfile.static-musl \
        -t swiftybox:static-musl \
        "$@"  # Pass any additional arguments
else
    echo "✓ No proxy detected - building without proxy"

    # Build without proxy
    podman build \
        -f Containerfile.static-musl \
        -t swiftybox:static-musl \
        "$@"
fi

echo ""
echo "==================================================================="
echo "Build complete!"
echo "==================================================================="
echo ""
echo "Next steps:"
echo "  1. Test the binary:"
echo "     podman run --rm swiftybox:static-musl echo 'Hello from static musl!'"
echo ""
echo "  2. Extract the binary:"
echo "     podman create --name test swiftybox:static-musl"
echo "     podman cp test:/bin/swiftybox ./swiftybox-static-musl"
echo "     podman rm test"
echo ""
echo "  3. Verify it's static:"
echo "     ldd swiftybox-static-musl  # Should say 'not a dynamic executable'"
echo "     file swiftybox-static-musl # Should say 'statically linked'"
echo ""
