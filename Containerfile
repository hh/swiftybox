# SwiftyλBox - Unified Multi-Target Containerfile
# Serves both development (devcontainer) and production builds
#
# Targets:
#   development    - Full dev environment with helper scripts (for devcontainers)
#   production     - Minimal production image (default)
#
# Usage:
#   Development:  podman build --target development -t swiftybox-dev .
#   Production:   podman build -t swiftybox:latest .

# ============================================
# Stage: Base Build Environment
# ============================================
FROM docker.io/library/swift:latest AS build-base

# Install build tools (shared by both dev and production)
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    make \
    wget \
    bzip2 \
    patch \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# ============================================
# Stage: Development Environment (devcontainer target)
# ============================================
FROM build-base AS development

# Install additional development tools
RUN apt-get update && apt-get install -y \
    vim \
    nano \
    less \
    gdb \
    lldb \
    strace \
    ltrace \
    binutils \
    file \
    lsof \
    tree \
    && rm -rf /var/lib/apt/lists/*

# Copy helper scripts
COPY .devcontainer/build-busybox.sh /usr/local/bin/build-busybox
COPY .devcontainer/build-swift.sh /usr/local/bin/build-swift
RUN chmod +x /usr/local/bin/build-*

# Configure git to trust workspace
RUN git config --system --add safe.directory /workspace

# Environment variables for development
ENV BUSYBOX_VERSION=1.36.1
ENV BUSYBOX_SRC=/workspace/busybox-src
ENV SWIFTYBOX_SRC=/workspace

# Keep container running for development
CMD ["bash"]

# ============================================
# Stage: Build BusyBox Library
# ============================================
FROM build-base AS busybox-builder

ARG BUSYBOX_VERSION=1.36.1

# Copy SwiftyλBox ASH integration patch
COPY swiftybox-ash-integration-v2.patch /tmp/

# Download and extract BusyBox (cached)
RUN --mount=type=cache,target=/var/cache/busybox \
    if [ ! -f /var/cache/busybox/busybox-${BUSYBOX_VERSION}.tar.bz2 ]; then \
        wget -O /var/cache/busybox/busybox-${BUSYBOX_VERSION}.tar.bz2 \
        https://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2; \
    fi && \
    cp /var/cache/busybox/busybox-${BUSYBOX_VERSION}.tar.bz2 . && \
    tar xjf busybox-${BUSYBOX_VERSION}.tar.bz2 && \
    cd busybox-${BUSYBOX_VERSION} && \
    # Note: ASH integration patch temporarily disabled due to patch format issues
    # Will be re-enabled once patch is regenerated from correct BusyBox version
    # patch -p1 < /tmp/swiftybox-ash-integration-v2.patch && \
    # echo "✅ SwiftyλBox ASH integration patch applied" && \
    # Configure for shared library build with individual applets
    make defconfig && \
    sed -i 's/# CONFIG_BUILD_LIBBUSYBOX is not set/CONFIG_BUILD_LIBBUSYBOX=y/' .config && \
    sed -i 's/# CONFIG_FEATURE_SHARED_BUSYBOX is not set/CONFIG_FEATURE_SHARED_BUSYBOX=y/' .config && \
    sed -i 's/# CONFIG_FEATURE_INDIVIDUAL is not set/CONFIG_FEATURE_INDIVIDUAL=y/' .config && \
    sed -i 's/^CONFIG_TC=y/# CONFIG_TC is not set/' .config && \
    # Override visibility to export symbols
    sed -i 's/-fvisibility=hidden/-fvisibility=default/g' Makefile.flags && \
    # Build with all symbols exported
    make -j$(nproc) SKIP_STRIP=y && \
    # Verify symbols are exported
    echo "Verifying exported symbols..." && \
    nm -D 0_lib/libbusybox.so.1.36.1 | grep " T " | grep -E "(echo_main|pwd_main|ash_main|lbb_prepare)" && \
    echo "✅ BusyBox library built with exported symbols"

# ============================================
# Stage: Build SwiftyλBox
# ============================================
FROM build-base AS swift-builder

# Copy BusyBox shared library and headers
COPY --from=busybox-builder /workspace/busybox-*/0_lib/libbusybox.so.1.36.1 /usr/lib/
COPY --from=busybox-builder /workspace/busybox-*/include/ /tmp/busybox-include/

# Copy SwiftyλBox source
COPY . /workspace/

# Set up BusyBox module for Swift
RUN cd /workspace/BusyBox && \
    mkdir -p lib && \
    cp /usr/lib/libbusybox.so.1.36.1 lib/ && \
    cd lib && ln -sf libbusybox.so.1.36.1 libbusybox.so && \
    cd /workspace/BusyBox && \
    cp -r /tmp/busybox-include include/

# Build SwiftyλBox in release mode with dynamic linking
RUN --mount=type=cache,target=/workspace/.build \
    cd /workspace && \
    swift build -c release \
        -Xswiftc -I/workspace/BusyBox \
        -Xcc -fPIC \
        -Xlinker -L/workspace/BusyBox/lib \
        -Xlinker -lbusybox \
        -Xlinker -rpath -Xlinker /usr/lib && \
    echo "✅ SwiftyλBox built successfully" && \
    ls -lh .build/release/swiftybox && \
    ldd .build/release/swiftybox | grep libbusybox

# ============================================
# Stage: Install Symlinks
# ============================================
FROM docker.io/library/swift:latest AS installer

# Copy binary and library from builder
COPY --from=swift-builder /workspace/.build/release/swiftybox /tmp/swiftybox
COPY --from=swift-builder /usr/lib/libbusybox.so.1.36.1 /tmp/

# Create directory for our complete system
RUN mkdir -p /rootfs/bin /rootfs/lib

# Set up library path for installation
ENV LD_LIBRARY_PATH=/tmp:$LD_LIBRARY_PATH

# Install all symlinks
WORKDIR /rootfs/bin
RUN /tmp/swiftybox --install && \
    mv /tmp/swiftybox swiftybox.real && \
    echo "✅ Installed $(ls -1 | wc -l) commands"

# Copy shared library to rootfs
RUN cp /tmp/libbusybox.so.1.36.1 /rootfs/lib/ && \
    cd /rootfs/lib && ln -sf libbusybox.so.1.36.1 libbusybox.so

# ============================================
# Stage: Production (default target)
# ============================================
FROM docker.io/library/swift:latest AS production

# Copy the complete /bin directory (binary + symlinks)
COPY --from=installer /rootfs/bin/ /bin/

# Copy BusyBox shared library to system location
COPY --from=installer /rootfs/lib/ /usr/lib/

# Set library path for runtime
ENV LD_LIBRARY_PATH=/usr/lib:$LD_LIBRARY_PATH

# Create minimal filesystem structure
RUN mkdir -p /tmp /home /root /etc

# Set up /bin/swiftybox symlink
RUN cd /bin && ln -sf swiftybox.real swiftybox

# Verify the system works
RUN echo "Verifying shared library linkage:" && \
    ldd /bin/swiftybox.real | grep libbusybox && \
    echo "SwiftyλBox system ready!" && \
    /bin/echo "✓ Echo test (Swift NOFORK)" && \
    /bin/pwd && \
    /bin/sh -c 'echo "✓ Shell works!" && pwd'

# Set default shell to SwiftyλBox
CMD ["/bin/sh"]

# ============================================
# Build Instructions:
#
# Development (devcontainer):
#   podman build --target development -t swiftybox-dev .
#   podman run -it -v $(pwd):/workspace:Z swiftybox-dev
#   # Inside: build-busybox, build-swift
#
# Production (default):
#   podman build -t swiftybox:latest .
#   podman run -it swiftybox:latest
#
# Test production image:
#   podman run --rm swiftybox:latest /bin/echo "Hello!"
#   podman run --rm swiftybox:latest /bin/ls -la
#   podman run -it --rm swiftybox:latest /bin/sh
# ============================================
