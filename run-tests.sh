#!/bin/bash
# Run SwiftyBox tests in distrobox container
# Usage: ./run-tests.sh [test-filter]

set -e

CONTAINER_NAME="swiftybox-dev"
PROJECT_DIR="/var/home/hh/w/swift/swiftybox"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== SwiftyBox Test Runner ===${NC}"
echo ""

# Check if container exists
if ! distrobox list | grep -q "$CONTAINER_NAME"; then
    echo -e "${RED}Error: Container '$CONTAINER_NAME' not found${NC}"
    echo "Create it with:"
    echo "  distrobox create --name swiftybox-dev --image swift:latest"
    exit 1
fi

# Check if we're already in the container
if [ -f /.dockerenv ] || [ -f /run/.containerenv ]; then
    echo -e "${GREEN}Running inside container${NC}"
    cd "$PROJECT_DIR"

    if [ -n "$1" ]; then
        echo -e "${YELLOW}Running filtered tests: $1${NC}"
        swift test --filter "$1" 2>&1 | tee "test-results-$(date +%Y%m%d-%H%M%S).log"
    else
        echo -e "${YELLOW}Running ALL tests${NC}"
        swift test 2>&1 | tee "test-results-$(date +%Y%m%d-%H%M%S).log"
    fi

    echo ""
    echo -e "${BLUE}=== Test Summary ===${NC}"
    echo "Results saved to test-results-*.log"

else
    echo -e "${YELLOW}Entering container: $CONTAINER_NAME${NC}"

    if [ -n "$1" ]; then
        distrobox enter "$CONTAINER_NAME" -- bash -c "cd $PROJECT_DIR && ./run-tests.sh '$1'"
    else
        distrobox enter "$CONTAINER_NAME" -- bash -c "cd $PROJECT_DIR && ./run-tests.sh"
    fi
fi
