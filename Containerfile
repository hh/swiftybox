# SwiftyλBox - Unified Multi-Target Containerfile
# Serves both development (devcontainer) and production builds
#
# Targets:
#   development    - Full dev environment with helper scripts (for devcontainers)
#   production     - Minimal scratch-based image with CA certs, timezone data (default, ~70 MB)
#   production-dev - Full Swift image for debugging (3.85GB)
#
# Usage:
#   Development:  podman build --target development -t swiftybox-dev .
#   Production:   podman build -t swiftybox:latest .
#   With Proxy:   podman build --build-arg HTTP_PROXY=$HTTP_PROXY \
#                               --build-arg HTTPS_PROXY=$HTTPS_PROXY \
#                               --build-arg CA_CERT_FILE=/path/to/cert.pem \
#                               -t swiftybox:latest .

# Proxy configuration (can be overridden with --build-arg)
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY
ARG CA_CERT_FILE

# ============================================
# Stage: Base Build Environment
# ============================================
FROM docker.io/library/swift:latest AS build-base

# Configure proxy if provided
ENV HTTP_PROXY=${HTTP_PROXY} \
    HTTPS_PROXY=${HTTPS_PROXY} \
    NO_PROXY=${NO_PROXY} \
    http_proxy=${HTTP_PROXY} \
    https_proxy=${HTTPS_PROXY} \
    no_proxy=${NO_PROXY}

# Install build tools first (needed for CA cert handling)
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

# Copy proxy CA certificate if it exists (optional - for corporate proxies)
# Using glob pattern makes this optional - if file doesn't exist in build context, step succeeds with no files copied
COPY --chmod=644 proxy-cas.pe[m] /tmp/proxy-ca.pem*
RUN if [ -f /tmp/proxy-cas.pem ]; then \
        mkdir -p /usr/local/share/ca-certificates && \
        cp /tmp/proxy-cas.pem /usr/local/share/ca-certificates/proxy-ca.crt && \
        update-ca-certificates && \
        echo "✅ Installed proxy CA certificate"; \
    else \
        echo "ℹ️  No proxy CA certificate found (optional - continuing without it)"; \
    fi

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
    ca-certificates \
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

# Clone BusyBox from GitHub mirror (much faster than wget)
# Note: GitHub mirror uses underscores in tags (1_36_1 not 1.36.1)
RUN git clone --depth 1 --branch 1_36_1 \
        https://github.com/mirror/busybox.git busybox-${BUSYBOX_VERSION} && \
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
    swift build -c release -j $(nproc) \
        -Xswiftc -I/workspace/BusyBox \
        -Xcc -fPIC \
        -Xlinker -L/workspace/BusyBox/lib \
        -Xlinker -lbusybox \
        -Xlinker -rpath -Xlinker /usr/lib && \
    echo "✅ SwiftyλBox built successfully (using $(nproc) cores)" && \
    ls -lh .build/release/swiftybox && \
    ldd .build/release/swiftybox | grep libbusybox && \
    # Copy binary out of cache mount before it's unmounted
    cp .build/release/swiftybox /workspace/swiftybox

# ============================================
# Stage: Install Symlinks
# ============================================
FROM docker.io/library/swift:latest AS installer

# Copy binary and library from builder
COPY --from=swift-builder /workspace/swiftybox /tmp/swiftybox
COPY --from=swift-builder /usr/lib/libbusybox.so.1.36.1 /tmp/

# Create directory for our complete system
RUN mkdir -p /rootfs/bin /rootfs/lib

# Copy shared library to rootfs first
RUN mkdir -p /rootfs/lib && \
    cp /tmp/libbusybox.so.1.36.1 /rootfs/lib/ && \
    cd /rootfs/lib && ln -sf libbusybox.so.1.36.1 libbusybox.so

# Set up library path for installation
ENV LD_LIBRARY_PATH=/tmp:/rootfs/lib:$LD_LIBRARY_PATH

# Install all symlinks
WORKDIR /rootfs/bin
RUN mv /tmp/swiftybox swiftybox && \
    ./swiftybox --install && \
    echo "✅ Installed $(ls -1 | wc -l) commands"

# Copy Swift runtime libraries AND dynamic linker needed for execution
RUN mkdir -p /rootfs/usr/lib /rootfs/lib64 && \
    ldd /rootfs/bin/swiftybox | grep "=> /" | awk '{print $3}' | while read lib; do \
        if [ -f "$lib" ]; then \
            cp -L "$lib" /rootfs/usr/lib/ || true; \
        fi \
    done && \
    # Copy dynamic linker (required for scratch images)
    cp /lib64/ld-linux-x86-64.so.2 /rootfs/lib64/ && \
    echo "✅ Copied Swift runtime libraries and dynamic linker"

# Copy CA certificates for HTTPS support
RUN mkdir -p /rootfs/etc/ssl/certs && \
    cp -r /etc/ssl/certs/* /rootfs/etc/ssl/certs/ && \
    echo "✅ Copied CA certificates"

# Copy timezone data for date/time commands
RUN mkdir -p /rootfs/usr/share/zoneinfo && \
    cp -r /usr/share/zoneinfo/* /rootfs/usr/share/zoneinfo/ && \
    echo "✅ Copied timezone data"

# Create minimal /etc/passwd and /etc/group for user/group lookups
RUN mkdir -p /rootfs/etc && \
    echo "root:x:0:0:root:/root:/bin/sh" > /rootfs/etc/passwd && \
    echo "nobody:x:65534:65534:nobody:/:/bin/false" >> /rootfs/etc/passwd && \
    echo "root:x:0:" > /rootfs/etc/group && \
    echo "nobody:x:65534:" >> /rootfs/etc/group && \
    echo "✅ Created /etc/passwd and /etc/group"

# Create minimal filesystem structure in rootfs
RUN mkdir -p /rootfs/tmp /rootfs/home /rootfs/root /rootfs/dev /rootfs/proc /rootfs/sys

# ============================================
# Stage: Production-Dev (full Swift image for debugging)
# ============================================
FROM docker.io/library/swift:latest AS production-dev

# Copy the complete /bin directory (binary + symlinks)
COPY --from=installer /rootfs/bin/ /bin/

# Copy BusyBox shared library to system location
COPY --from=installer /rootfs/lib/ /usr/lib/

# Set library path for runtime
ENV LD_LIBRARY_PATH=/usr/lib:$LD_LIBRARY_PATH

# Create minimal filesystem structure
RUN mkdir -p /tmp /home /root /etc

# Verify the system works
RUN echo "Verifying shared library linkage:" && \
    ldd /bin/swiftybox | grep libbusybox && \
    echo "SwiftyλBox system ready!" && \
    /bin/echo "✓ Echo test (Swift NOFORK)" && \
    /bin/pwd && \
    /bin/sh -c 'echo "✓ Shell works!" && pwd'

# Set default shell to SwiftyλBox
CMD ["/bin/sh"]

# ============================================
# Stage: Production (default target) - Minimal scratch-based image
# ============================================
FROM scratch AS production

# Copy the complete rootfs with binary, symlinks, libraries, and filesystem structure
COPY --from=installer /rootfs/ /

# Set library path for runtime
ENV LD_LIBRARY_PATH=/usr/lib:/lib

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
# Production (default - scratch base with system essentials):
#   podman build -t swiftybox:latest .
#   podman run -it swiftybox:latest
#
# Test production image:
#   podman run --rm swiftybox:latest /bin/echo "Hello!"
#   podman run --rm swiftybox:latest /bin/date
#   podman run --rm swiftybox:latest /bin/ls -la
#   podman run -it --rm swiftybox:latest /bin/sh
#
# Production image includes:
# - SwiftyλBox binary + 74 command symlinks
# - Swift runtime libraries + BusyBox library
# - CA certificates (/etc/ssl/certs) - for HTTPS support
# - Timezone data (/usr/share/zoneinfo) - for date/time commands
# - User/group database (/etc/passwd, /etc/group) - for user lookups
# - Total size: ~70 MB
# ============================================
