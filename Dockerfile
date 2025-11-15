# SwiftyλBox Container - Single Binary with Symlinks
# Multi-stage build for minimal final image

# Stage 1: Build SwiftyλBox
FROM swift:6.2 AS builder

WORKDIR /build

# Copy source
COPY . .

# Build release binary
RUN swift build -c release

# Strip binary for smaller size
RUN strip .build/release/swiftybox

# Stage 2: Minimal runtime image
FROM alpine:latest

# Copy only the binary
COPY --from=builder /build/.build/release/swiftybox /bin/swiftybox

# Install symlinks for all commands
RUN cd /bin && /bin/swiftybox --install

# Set swiftybox as default shell for interactive use
CMD ["/bin/swiftybox"]

# Labels
LABEL org.opencontainers.image.title="SwiftyλBox"
LABEL org.opencontainers.image.description="Where λ replaces fork+exec - BusyBox reimagined in Swift"
LABEL org.opencontainers.image.version="0.2.0"
LABEL org.opencontainers.image.authors="SwiftyλBox Project"
