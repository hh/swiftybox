#!/bin/bash
# CLI wrapper for .devcontainer development environment
# Works with Podman (rootless) and standard devcontainer specification

set -e

CONTAINER_NAME="swiftybox-devcontainer"
IMAGE_NAME="swiftybox-dev:latest"
WORKSPACE="$(cd "$(dirname "$0")" && pwd)"
DEVCONTAINER_DIR="$WORKSPACE/.devcontainer"
PROXY_CERTS="${HOME}/.config/proxy-cas.pem"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detect proxy settings
if [ -n "$HTTPS_PROXY" ] || [ -n "$https_proxy" ]; then
    PROXY_HOST="host.containers.internal:4128"
    PROXY_URL="http://${PROXY_HOST}"
    USE_PROXY=true
else
    USE_PROXY=false
fi

build_image() {
    echo -e "${BLUE}🏗️  Building devcontainer image (development target)...${NC}"
    echo ""

    # Build from project root using development target
    cd "$WORKSPACE"

    # Build with proxy args if needed
    BUILD_ARGS=""
    if [ "$USE_PROXY" = true ]; then
        echo -e "${YELLOW}📡 Proxy detected: $PROXY_URL${NC}"
        BUILD_ARGS="--build-arg HTTPS_PROXY=$PROXY_URL \
                    --build-arg https_proxy=$PROXY_URL \
                    --build-arg HTTP_PROXY=$PROXY_URL \
                    --build-arg http_proxy=$PROXY_URL"
    fi

    # Build using development target from main Containerfile
    podman build $BUILD_ARGS --target development -t "$IMAGE_NAME" -f Containerfile .

    echo ""
    echo -e "${GREEN}✅ Image built: $IMAGE_NAME (development target)${NC}"
}

start_container() {
    # Check if image exists
    if ! podman image exists "$IMAGE_NAME"; then
        echo -e "${YELLOW}⚠️  Image not found, building...${NC}"
        build_image
    fi

    echo -e "${BLUE}🚀 Starting devcontainer...${NC}"

    # Stop existing container if running
    podman stop "$CONTAINER_NAME" 2>/dev/null || true
    podman rm "$CONTAINER_NAME" 2>/dev/null || true

    # Build podman run command
    CMD="podman run -d --name $CONTAINER_NAME"

    # Add proxy configuration if needed
    if [ "$USE_PROXY" = true ]; then
        echo -e "${YELLOW}📡 Configuring proxy: $PROXY_URL${NC}"
        CMD="$CMD \
            -e HTTP_PROXY=$PROXY_URL \
            -e HTTPS_PROXY=$PROXY_URL \
            -e http_proxy=$PROXY_URL \
            -e https_proxy=$PROXY_URL \
            -e NO_PROXY=127.0.0.1,localhost,::1 \
            -e no_proxy=127.0.0.1,localhost,::1"

        # Add SSL certs if they exist
        if [ -f "$PROXY_CERTS" ]; then
            echo -e "${YELLOW}🔒 Mounting SSL certificates${NC}"
            CMD="$CMD \
                -e SSL_CERT_FILE=/certs/proxy-cas.pem \
                -e CURL_CA_BUNDLE=/certs/proxy-cas.pem \
                -e GIT_SSL_CAINFO=/certs/proxy-cas.pem \
                -v $PROXY_CERTS:/certs/proxy-cas.pem:ro,Z"
        fi
    fi

    # Add workspace mount
    CMD="$CMD \
        -v $WORKSPACE:/workspace:Z \
        -w /workspace \
        $IMAGE_NAME"

    # Run the command
    eval $CMD

    echo ""
    echo -e "${GREEN}✅ Devcontainer started!${NC}"
    echo ""
    echo -e "${BLUE}Quick commands:${NC}"
    echo "  $0 exec bash           - Enter container shell"
    echo "  $0 build-busybox       - Build BusyBox library"
    echo "  $0 build-swift         - Build SwiftyBox"
    echo "  $0 test                - Run tests"
}

exec_command() {
    if ! podman ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
        echo -e "${RED}❌ Container not running${NC}"
        echo "Run: $0 start"
        exit 1
    fi

    podman exec -it "$CONTAINER_NAME" "$@"
}

stop_container() {
    echo -e "${YELLOW}🛑 Stopping devcontainer...${NC}"
    podman stop "$CONTAINER_NAME" 2>/dev/null || true
    podman rm "$CONTAINER_NAME" 2>/dev/null || true
    echo -e "${GREEN}✅ Container stopped${NC}"
}

status_container() {
    if podman ps -a --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
        if podman ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
            echo -e "${GREEN}✅ Container is running${NC}"
            echo ""
            podman exec "$CONTAINER_NAME" bash -c '
                echo "Image: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2)"
                echo "Swift: $(swift --version | head -1)"
                echo "Workspace: /workspace"
                echo "BusyBox lib: $(ls -lh /usr/lib/libbusybox.so 2>/dev/null || echo not found)"
                if [ -n "$HTTPS_PROXY" ]; then
                    echo "Proxy: $HTTPS_PROXY"
                fi
            '
        else
            echo -e "${YELLOW}⚠️  Container exists but is not running${NC}"
            echo "Run: $0 start"
        fi
    else
        echo -e "${RED}❌ Container does not exist${NC}"
        echo "Run: $0 start"
    fi
}

case "$1" in
    build-image|rebuild)
        build_image
        ;;

    start|up)
        start_container
        ;;

    stop|down)
        stop_container
        ;;

    restart)
        stop_container
        start_container
        ;;

    exec)
        shift
        if [ $# -eq 0 ]; then
            exec_command bash
        else
            exec_command "$@"
        fi
        ;;

    shell|bash)
        exec_command bash
        ;;

    build-busybox)
        exec_command build-busybox
        ;;

    build-swift|build)
        shift
        exec_command build-swift "$@"
        ;;

    test)
        exec_command bash -c 'cd /workspace && swift test'
        ;;

    status)
        status_container
        ;;

    logs)
        podman logs "$CONTAINER_NAME"
        ;;

    *)
        echo -e "${BLUE}SwiftyλBox Devcontainer CLI${NC}"
        echo ""
        echo "Usage: $0 {command} [args]"
        echo ""
        echo -e "${YELLOW}Container Management:${NC}"
        echo "  build-image     - Build the devcontainer image"
        echo "  start           - Start the devcontainer"
        echo "  stop            - Stop the devcontainer"
        echo "  restart         - Restart the devcontainer"
        echo "  status          - Show container status"
        echo "  logs            - Show container logs"
        echo ""
        echo -e "${YELLOW}Development:${NC}"
        echo "  exec {cmd}      - Execute command in container"
        echo "  shell           - Enter container shell"
        echo "  build-busybox   - Build BusyBox library"
        echo "  build-swift     - Build SwiftyBox (release)"
        echo "  test            - Run Swift tests"
        echo ""
        echo -e "${YELLOW}Examples:${NC}"
        echo "  $0 start                  # Start container"
        echo "  $0 shell                  # Enter shell"
        echo "  $0 build-busybox          # Build BusyBox"
        echo "  $0 build-swift            # Build SwiftyBox"
        echo "  $0 exec ls -la            # Run command"
        echo ""
        echo -e "${BLUE}Follows .devcontainer specification${NC}"
        echo "Compatible with VS Code Dev Containers and devcontainer CLI"
        exit 1
        ;;
esac
