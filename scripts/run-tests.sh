#!/bin/bash
# run-tests.sh - Build and run SwiftyλBox tests

set -e

echo "=== SwiftyλBox Test Runner ==="
echo ""

# Check if we're in the swiftybox directory
if [ ! -f "Package.swift" ]; then
    echo "Error: Must be run from swiftybox directory"
    exit 1
fi

# Build the project
echo "Building swiftybox..."
swift build
echo ""

# Run tests
echo "Running tests..."
if [ -n "$VERBOSE" ]; then
    swift test --verbose
else
    swift test
fi

echo ""
echo "=== Test Summary ==="
if [ $? -eq 0 ]; then
    echo "✅ All tests passed!"
else
    echo "❌ Some tests failed. Run with VERBOSE=1 for details."
    exit 1
fi
