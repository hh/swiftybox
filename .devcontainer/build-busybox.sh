#!/bin/bash
# Build BusyBox with proper symbol visibility for Swift integration

set -e

BUSYBOX_VERSION="${BUSYBOX_VERSION:-1.36.1}"
BUSYBOX_SRC="${BUSYBOX_SRC:-/workspace/busybox-src}"
OUTPUT_DIR="${OUTPUT_DIR:-/workspace/BusyBox/lib}"

echo "🔨 Building BusyBox ${BUSYBOX_VERSION} for SwiftyλBox"
echo ""

# Create source directory if it doesn't exist
mkdir -p "$BUSYBOX_SRC"
cd "$BUSYBOX_SRC"

# Download BusyBox if not already present
if [ ! -d "busybox-${BUSYBOX_VERSION}" ]; then
    echo "📦 Downloading BusyBox ${BUSYBOX_VERSION}..."
    if [ ! -f "busybox-${BUSYBOX_VERSION}.tar.bz2" ]; then
        wget https://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2
    fi
    echo "📂 Extracting..."
    tar xjf busybox-${BUSYBOX_VERSION}.tar.bz2
fi

cd "busybox-${BUSYBOX_VERSION}"

# Configure for shared library with exported symbols
echo "⚙️  Configuring BusyBox..."
make defconfig

# Enable shared library build
sed -i 's/# CONFIG_BUILD_LIBBUSYBOX is not set/CONFIG_BUILD_LIBBUSYBOX=y/' .config
sed -i 's/# CONFIG_FEATURE_SHARED_BUSYBOX is not set/CONFIG_FEATURE_SHARED_BUSYBOX=y/' .config
sed -i 's/# CONFIG_FEATURE_INDIVIDUAL is not set/CONFIG_FEATURE_INDIVIDUAL=y/' .config

# Disable problematic applets
sed -i 's/^CONFIG_TC=y/# CONFIG_TC is not set/' .config

# Show configuration
echo "📋 Configuration:"
grep "CONFIG_BUILD_LIBBUSYBOX\|CONFIG_FEATURE_SHARED_BUSYBOX\|CONFIG_FEATURE_INDIVIDUAL" .config

# Override visibility flag to export symbols
echo "🔧 Fixing symbol visibility..."
sed -i 's/-fvisibility=hidden/-fvisibility=default/g' Makefile.flags

echo "🏗️  Building (this may take a few minutes)..."
make -j$(nproc) SKIP_STRIP=y

# Verify symbols are exported
echo ""
echo "✅ Verifying exported symbols..."
SYMBOL_COUNT=$(nm -D 0_lib/libbusybox.so.1.36.1 | grep " T " | wc -l)
echo "   Exported symbols: $SYMBOL_COUNT"

# Check for critical symbols
echo "   Checking critical symbols:"
for sym in echo_main pwd_main ash_main lbb_prepare; do
    if nm -D 0_lib/libbusybox.so.1.36.1 | grep -q " T $sym"; then
        echo "   ✓ $sym"
    else
        echo "   ✗ $sym (MISSING!)"
    fi
done

# Copy to output directory
echo ""
echo "📋 Installing library..."
mkdir -p "$OUTPUT_DIR"
cp 0_lib/libbusybox.so.1.36.1 "$OUTPUT_DIR/"
cd "$OUTPUT_DIR"
ln -sf libbusybox.so.1.36.1 libbusybox.so

# Also install system-wide for runtime
cp libbusybox.so.1.36.1 /usr/lib/
cd /usr/lib
ln -sf libbusybox.so.1.36.1 libbusybox.so

echo ""
echo "✅ BusyBox library built successfully!"
echo "   Library: $OUTPUT_DIR/libbusybox.so.1.36.1"
echo "   System:  /usr/lib/libbusybox.so.1.36.1"
echo ""
echo "💡 Now run: build-swift"
