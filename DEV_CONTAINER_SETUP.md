# SwiftyλBox Development Container Setup

## ✅ Build SUCCESS - Dynamic Linking Working!

The build now works with dynamic linking! Key fixes applied:
1. Enable `CONFIG_FEATURE_INDIVIDUAL=y` in BusyBox config
2. Override `-fvisibility=hidden` → `-fvisibility=default` in Makefile.flags
3. Simplified busybox-bridge.h to avoid hidden symbol conflicts
4. Added `-fPIC` flag to Swift compilation

## Quick Development Workflow

### Option 1: Use the Helper Script (RECOMMENDED) 🚀

The easiest way with automatic proxy/certificate handling:

```bash
# Start development container (auto-detects proxy)
./dev-container.sh start

# Enter the container
./dev-container.sh enter

# Build SwiftyλBox (takes ~3 seconds!)
./dev-container.sh build

# Run quick tests
./dev-container.sh test

# Check status
./dev-container.sh status

# Stop when done
./dev-container.sh stop
```

**Features:**
- ✅ Automatic proxy detection and configuration
- ✅ SSL certificate mounting (if `~/.config/proxy-cas.pem` exists)
- ✅ Uses `host.containers.internal` (rootless, no sudo needed)
- ✅ Fast builds (~3 seconds vs 5+ minutes for full container)

### Option 2: Manual Interactive Container

For custom setups or understanding what the script does:

```bash
# 1. Start container with proxy support (if needed)
podman run -it --rm \
  --name swiftybox-dev \
  -e HTTPS_PROXY="http://host.containers.internal:4128" \
  -e https_proxy="http://host.containers.internal:4128" \
  -e SSL_CERT_FILE="/certs/proxy-cas.pem" \
  -e GIT_SSL_CAINFO="/certs/proxy-cas.pem" \
  -v /var/home/hh/w/swift/swiftybox:/workspace:Z \
  -v /var/home/hh/.config/proxy-cas.pem:/certs/proxy-cas.pem:ro,Z \
  -w /workspace \
  swift:latest \
  bash

# 2. Inside the container, build and test quickly:
swift build -c release \
  -Xswiftc -I/workspace/BusyBox \
  -Xcc -fPIC \
  -Xlinker -L/workspace/BusyBox/lib \
  -Xlinker -lbusybox \
  -Xlinker -rpath -Xlinker /usr/lib

# 3. Test your changes
.build/release/swiftybox echo "Hello!"
.build/release/swiftybox ls -la
.build/release/swiftybox whoami
```

### Option 2: Persistent Development Container

Create a long-running development environment:

```bash
# Create persistent container
podman run -d \
  --name swiftybox-dev \
  -v /var/home/hh/w/swift/swiftybox:/workspace:Z \
  -v /var/home/hh/w/swift/swiftybox/libbusybox.so.1.36.1:/usr/lib/libbusybox.so.1.36.1:Z \
  -w /workspace \
  swift:latest \
  tail -f /dev/null

# Enter for development
podman exec -it swiftybox-dev bash

# When done
podman stop swiftybox-dev
podman rm swiftybox-dev
```

### Option 3: Setup Script for Development Container

```bash
#!/bin/bash
# save as: dev-container.sh

CONTAINER_NAME="swiftybox-dev"
WORKSPACE="/var/home/hh/w/swift/swiftybox"

case "$1" in
  start)
    echo "Starting development container..."
    podman run -d \
      --name $CONTAINER_NAME \
      -v $WORKSPACE:/workspace:Z \
      -v $WORKSPACE/libbusybox.so.1.36.1:/usr/lib/libbusybox.so.1.36.1:Z \
      -w /workspace \
      swift:latest \
      tail -f /dev/null
    echo "Container started. Use './dev-container.sh enter' to access it."
    ;;

  enter)
    podman exec -it $CONTAINER_NAME bash
    ;;

  build)
    echo "Building SwiftyλBox..."
    podman exec -it $CONTAINER_NAME bash -c '
      swift build -c release \
        -Xswiftc -I/workspace/BusyBox \
        -Xcc -fPIC \
        -Xlinker -L/workspace/BusyBox/lib \
        -Xlinker -lbusybox \
        -Xlinker -rpath -Xlinker /usr/lib
    '
    ;;

  test)
    echo "Running quick tests..."
    podman exec -it $CONTAINER_NAME bash -c '
      .build/release/swiftybox echo "✓ Echo works"
      .build/release/swiftybox pwd
      .build/release/swiftybox sh -c "echo Shell integration works"
    '
    ;;

  stop)
    podman stop $CONTAINER_NAME
    podman rm $CONTAINER_NAME
    ;;

  rebuild-busybox)
    echo "Rebuilding BusyBox library..."
    # Add commands to rebuild just the BusyBox portion if needed
    ;;

  *)
    echo "Usage: $0 {start|enter|build|test|stop|rebuild-busybox}"
    echo ""
    echo "  start  - Start the development container"
    echo "  enter  - Enter the development container shell"
    echo "  build  - Build SwiftyλBox inside the container"
    echo "  test   - Run quick functionality tests"
    echo "  stop   - Stop and remove the development container"
    exit 1
    ;;
esac
```

Make it executable:
```bash
chmod +x dev-container.sh
```

Usage:
```bash
./dev-container.sh start
./dev-container.sh enter
# ... make changes ...
./dev-container.sh build
./dev-container.sh test
./dev-container.sh stop
```

## Iterating on BusyBox Library

If you need to rebuild the BusyBox library with different options:

```bash
# 1. Start a BusyBox builder container
podman run -it --rm \
  -v /var/home/hh/w/swift:/work:Z \
  -w /work \
  ubuntu:24.04 \
  bash

# 2. Inside container:
apt-get update && apt-get install -y build-essential wget bzip2

# 3. Download and configure BusyBox
cd /work
wget https://busybox.net/downloads/busybox-1.36.1.tar.bz2
tar xjf busybox-1.36.1.tar.bz2
cd busybox-1.36.1

# 4. Configure for shared library with exported symbols
make defconfig
sed -i 's/# CONFIG_BUILD_LIBBUSYBOX is not set/CONFIG_BUILD_LIBBUSYBOX=y/' .config
sed -i 's/# CONFIG_FEATURE_SHARED_BUSYBOX is not set/CONFIG_FEATURE_SHARED_BUSYBOX=y/' .config
sed -i 's/# CONFIG_FEATURE_INDIVIDUAL is not set/CONFIG_FEATURE_INDIVIDUAL=y/' .config
sed -i 's/^CONFIG_TC=y/# CONFIG_TC is not set/' .config

# 5. Override visibility flag
sed -i 's/-fvisibility=hidden/-fvisibility=default/g' Makefile.flags

# 6. Build
make -j$(nproc) SKIP_STRIP=y

# 7. Copy library to Swift project
cp 0_lib/libbusybox.so.1.36.1 /work/swift/swiftybox/
cp 0_lib/libbusybox.so.1.36.1 /work/swift/swiftybox/BusyBox/lib/
cd /work/swift/swiftybox/BusyBox/lib/
ln -sf libbusybox.so.1.36.1 libbusybox.so

# 8. Verify symbols are exported
nm -D libbusybox.so | grep -E "(echo_main|pwd_main|ash_main|lbb_prepare)"
```

## Key Files to Watch

When developing, these files are most commonly edited:

### Swift Source Files
- `Sources/swiftybox/*.swift` - Swift implementations
- `Sources/swiftybox/CommandRegistry.swift` - Command dispatch logic
- `BusyBox/include/busybox-bridge.h` - C bridge header

### Configuration Files
- `Package.swift` - Swift package configuration
- `BusyBox/module.modulemap` - Module mapping for C interop
- `Containerfile` - Production build configuration

### Build Artifacts
- `.build/release/swiftybox` - Built binary
- `BusyBox/lib/libbusybox.so.1.36.1` - BusyBox shared library

## Testing Workflow

### Unit Tests
```bash
# Inside dev container
swift test
```

### Integration Tests
```bash
# Inside dev container
swift build -c release <flags>

# Test Swift commands (NOFORK - ultra fast)
.build/release/swiftybox echo "test"
.build/release/swiftybox pwd
.build/release/swiftybox true && echo "success"

# Test BusyBox integration (shell, etc.)
.build/release/swiftybox sh -c 'echo "Shell test" && pwd'
.build/release/swiftybox ash -c 'for i in 1 2 3; do echo $i; done'
```

### Performance Testing
```bash
# Compare Swift NOFORK vs BusyBox/fork+exec
time for i in {1..1000}; do .build/release/swiftybox echo test >/dev/null; done
time for i in {1..1000}; do /bin/echo test >/dev/null; done
```

## Debugging Tips

### Check Symbol Export
```bash
# Verify BusyBox exports symbols correctly
nm -D BusyBox/lib/libbusybox.so | grep " T " | grep -E "(echo_main|ash_main)"

# Expected output (uppercase T = exported):
# 00000000000795ad T ash_main
# 00000000000ad347 T echo_main
```

### Check Library Linkage
```bash
# Verify Swift binary links correctly
ldd .build/release/swiftybox | grep busybox

# Expected output:
# libbusybox.so.1.36.1 => /usr/lib/libbusybox.so.1.36.1
```

### Visibility Issues
If you get "hidden symbol" errors:
1. Check `busybox-bridge.h` uses `__attribute__((visibility("default")))`
2. Verify Makefile.flags has `-fvisibility=default` not `-fvisibility=hidden`
3. Ensure `-fPIC` flag is passed to Swift compiler

## Proxy and Certificate Configuration

### Automatic Detection (dev-container.sh)

The helper script automatically handles:
- Detects `$HTTPS_PROXY` environment variable
- Uses `host.containers.internal` for rootless containers
- Mounts SSL certificates from `~/.config/proxy-cas.pem`
- Configures Git, curl, and Swift Package Manager

### Manual Configuration

If not using the helper script:

```bash
# Environment variables needed
-e HTTPS_PROXY="http://host.containers.internal:4128"
-e https_proxy="http://host.containers.internal:4128"
-e HTTP_PROXY="http://host.containers.internal:4128"
-e http_proxy="http://host.containers.internal:4128"
-e SSL_CERT_FILE="/certs/proxy-cas.pem"
-e GIT_SSL_CAINFO="/certs/proxy-cas.pem"
-e CURL_CA_BUNDLE="/certs/proxy-cas.pem"

# Mount certificates
-v /var/home/hh/.config/proxy-cas.pem:/certs/proxy-cas.pem:ro,Z
```

### For Containerfile Builds

When building the production container, you need to pass build args:

```bash
podman build \
  --build-arg HTTPS_PROXY="http://host.containers.internal:4128" \
  --build-arg https_proxy="http://host.containers.internal:4128" \
  -v /var/home/hh/.config/proxy-cas.pem:/certs/proxy-cas.pem:ro \
  -t swiftybox:test \
  -f Containerfile .
```

**Note**: The Containerfile will need updates to use certificates during build. See "TODO: Containerfile Proxy Support" below.

## Advantages of Dev Container Approach

1. **Speed**: Rebuild Swift code in ~3 seconds vs 5+ minutes for full container
2. **Iteration**: Change code → build → test loop is much faster
3. **Debugging**: Can use lldb and other tools interactively
4. **Flexibility**: Easy to experiment with different build flags
5. **State**: Keep build cache between sessions
6. **Rootless**: Works without sudo/root privileges

## Production Build

When ready for production:
```bash
# Full clean build
cd /var/home/hh/w/swift/swiftybox
podman rmi swiftybox:test
unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY
podman build -t swiftybox:test -f Containerfile .
```

## Next Steps

1. **Implement Missing Commands**: Add ls, ps implementations
2. **Performance Tuning**: Profile and optimize hot paths
3. **Testing**: Add comprehensive test suite
4. **Documentation**: Document each command implementation

---

**Status**: ✅ Dynamic linking working! Ready for rapid development!
