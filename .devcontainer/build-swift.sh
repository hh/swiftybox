#!/bin/bash
# Build SwiftyλBox with dynamic linking to BusyBox

set -e

WORKSPACE="${WORKSPACE:-/workspace}"
BUILD_TYPE="${1:-release}"

echo "🚀 Building SwiftyλBox (${BUILD_TYPE} mode)"
echo ""

cd "$WORKSPACE"

# Check if BusyBox library exists
if [ ! -f "BusyBox/lib/libbusybox.so" ]; then
    echo "❌ BusyBox library not found!"
    echo "   Run 'build-busybox' first to build the BusyBox library"
    exit 1
fi

# Verify symbols
echo "✓ BusyBox library found"
SYMBOL_COUNT=$(nm -D BusyBox/lib/libbusybox.so | grep " T " | wc -l)
echo "✓ Exported symbols: $SYMBOL_COUNT"

echo ""
echo "🔨 Building Swift code..."

# Build with proper flags
swift build -c "$BUILD_TYPE" \
    -Xswiftc -I/workspace/BusyBox \
    -Xcc -fPIC \
    -Xlinker -L/workspace/BusyBox/lib \
    -Xlinker -lbusybox \
    -Xlinker -rpath -Xlinker /usr/lib

echo ""
echo "✅ Build complete!"
echo "   Binary: .build/${BUILD_TYPE}/swiftybox"
echo ""

# Show binary info
echo "📊 Binary info:"
ls -lh ".build/${BUILD_TYPE}/swiftybox"
echo ""
ldd ".build/${BUILD_TYPE}/swiftybox" | grep -E "libbusybox|libswift" || true

echo ""
echo "💡 Test with:"
echo "   .build/${BUILD_TYPE}/swiftybox echo 'Hello!'"
echo "   .build/${BUILD_TYPE}/swiftybox pwd"
echo "   .build/${BUILD_TYPE}/swiftybox ls -la"
