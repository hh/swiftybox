# SwiftyλBox - Production Container
# Builds everything from source with caching
# Single 164KB binary + 85 symlinks = Complete Linux system!

# ============================================
# Stage 1: Build BusyBox Library
# ============================================
FROM ubuntu:24.04 AS busybox-builder

RUN apt-get update && apt-get install -y \
    build-essential wget bzip2 patch \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Download and extract BusyBox (cached)
ARG BUSYBOX_VERSION=1.36.1
RUN --mount=type=cache,target=/var/cache/busybox \
    if [ ! -f /var/cache/busybox/busybox-${BUSYBOX_VERSION}.tar.bz2 ]; then \
        wget -O /var/cache/busybox/busybox-${BUSYBOX_VERSION}.tar.bz2 \
        https://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2; \
    fi && \
    cp /var/cache/busybox/busybox-${BUSYBOX_VERSION}.tar.bz2 . && \
    tar xjf busybox-${BUSYBOX_VERSION}.tar.bz2 && \
    mv busybox-${BUSYBOX_VERSION} busybox

WORKDIR /build/busybox

# Configure for library build
RUN make defconfig && \
    sed -i 's/# CONFIG_BUILD_LIBBUSYBOX is not set/CONFIG_BUILD_LIBBUSYBOX=y/' .config && \
    sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config

# Build library (cached)
RUN --mount=type=cache,target=/build/busybox/.cache \
    make -j$(nproc) libbusybox.a

RUN ls -lh libbusybox.a

# ============================================
# Stage 2: Build SwiftyλBox
# ============================================
FROM swift:latest AS builder

WORKDIR /build

# Copy BusyBox artifacts
COPY --from=busybox-builder /build/busybox/libbusybox.a ./busybox/
COPY --from=busybox-builder /build/busybox/include/ ./busybox/include/

# Copy SwiftyλBox source
COPY swiftybox/ ./swiftybox/

# Build in release mode (cached)
WORKDIR /build/swiftybox
RUN --mount=type=cache,target=/build/swiftybox/.build \
    swift build -c release && \
    cp .build/release/swiftybox /tmp/swiftybox

RUN ls -lh /tmp/swiftybox

# ============================================
# Stage 2: Install all symlinks
# ============================================
FROM ubuntu:24.04 AS installer

# Copy binary from builder
COPY --from=builder /build/swiftybox/.build/release/swiftybox /tmp/swiftybox

# Create directory for our complete system
RUN mkdir -p /rootfs/bin

# Install all 85 symlinks
WORKDIR /rootfs/bin
RUN /tmp/swiftybox --install && \
    mv swiftybox swiftybox.real

# Verify installation
RUN echo "Symlinks created:" && \
    ls -1 | wc -l && \
    ls -1 | head -10 && \
    echo "..."

# ============================================
# Stage 3: Final minimal image
# ============================================
FROM ubuntu:24.04

# Copy the complete /bin directory (binary + 85 symlinks)
COPY --from=installer /rootfs/bin/ /bin/

# Create minimal filesystem structure
RUN mkdir -p /tmp /home /root /etc

# Set up /bin/swiftybox symlink
RUN cd /bin && ln -sf swiftybox.real swiftybox

# Verify the system works
RUN /bin/echo "SwiftyλBox system ready!" && \
    /bin/pwd && \
    /bin/sh -c 'echo "Shell works!" && pwd'

# Set default shell to SwiftyλBox
CMD ["/bin/sh"]

# ============================================
# Build instructions:
#
# Using Podman (recommended):
#   podman build -t swiftybox:latest .
#   podman run -it swiftybox:latest
#
# Using Buildah:
#   buildah bud -t swiftybox:latest .
#   podman run -it swiftybox:latest
#
# Inside container:
#   $ echo "Hello from SwiftyλBox!"  # Swift NOFORK (0.28μs)
#   $ pwd                             # Swift NOFORK
#   $ ls -la                          # BusyBox/external
#   $ sh -c 'for i in 1 2 3; do echo $i; done'  # NOFORK loop!
# ============================================
