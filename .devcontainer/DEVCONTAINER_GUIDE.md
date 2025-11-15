# SwiftyλBox Devcontainer Guide

## What is a Devcontainer?

A devcontainer is a standardized development environment that runs in a container. It provides:
- **Reproducibility** - Same environment for all developers
- **Isolation** - No conflicts with host system
- **Portability** - Works on any machine with container support
- **Completeness** - All tools and dependencies included

## Specification Compliance

This devcontainer follows the [Dev Containers Specification](https://containers.dev/) and is compatible with:
- ✅ VS Code Dev Containers extension
- ✅ GitHub Codespaces
- ✅ DevPod
- ✅ Devcontainer CLI
- ✅ Podman (rootless)
- ✅ Docker

## Files in .devcontainer/

```
.devcontainer/
├── Containerfile          # Container image definition
├── devcontainer.json      # Devcontainer configuration
├── build-busybox.sh       # Helper script to build BusyBox
├── build-swift.sh         # Helper script to build SwiftyBox
├── README.md              # Quick reference
└── DEVCONTAINER_GUIDE.md  # This file
```

## Usage Methods

### 1. VS Code (Easiest)

**Prerequisites:**
- VS Code with "Dev Containers" extension
- Podman or Docker installed

**Steps:**
1. Open folder in VS Code: `code /var/home/hh/w/swift/swiftybox`
2. Click "Reopen in Container" when prompted
3. Wait for image to build (~5 minutes first time)
4. Start coding!

**First Build:**
```bash
# Inside VS Code terminal
build-busybox    # One-time BusyBox build (~2-3 min)
build-swift      # Build SwiftyBox (~3 sec)
```

### 2. Devcontainer CLI (Standard)

**Prerequisites:**
```bash
npm install -g @devcontainers/cli
```

**Usage:**
```bash
# From project root
cd /var/home/hh/w/swift/swiftybox

# Start devcontainer
devcontainer up --workspace-folder .

# Execute commands
devcontainer exec --workspace-folder . build-busybox
devcontainer exec --workspace-folder . build-swift
devcontainer exec --workspace-folder . bash

# Stop
devcontainer down --workspace-folder .
```

### 3. Podman CLI (Our Custom Wrapper)

**Prerequisites:**
- Podman installed

**Usage:**
```bash
# Use our CLI wrapper
./devcontainer-cli.sh start          # Build & start
./devcontainer-cli.sh build-busybox  # Build BusyBox
./devcontainer-cli.sh build-swift    # Build SwiftyBox
./devcontainer-cli.sh shell          # Enter shell
./devcontainer-cli.sh test           # Run tests
./devcontainer-cli.sh stop           # Stop container
```

This is our custom wrapper that:
- Auto-detects proxy settings
- Handles SSL certificates
- Works with Podman rootless
- Follows devcontainer spec

### 4. Manual Podman (Advanced)

```bash
# Build image
cd .devcontainer
podman build -t swiftybox-dev:latest -f Containerfile .

# Run container
podman run -d --name swiftybox-devcontainer \
  -e HTTPS_PROXY="http://host.containers.internal:4128" \
  -e SSL_CERT_FILE="/certs/proxy-cas.pem" \
  -v ~/.config/proxy-cas.pem:/certs/proxy-cas.pem:ro,Z \
  -v /var/home/hh/w/swift/swiftybox:/workspace:Z \
  -w /workspace \
  swiftybox-dev:latest

# Enter container
podman exec -it swiftybox-devcontainer bash
```

## Proxy Configuration

The devcontainer automatically handles HTTPS proxy and SSL certificates:

### Automatic (Recommended)

Set environment variables on host:
```bash
export HTTPS_PROXY="http://localhost:4128"
export https_proxy="http://localhost:4128"
```

The devcontainer will:
1. Detect proxy from host environment
2. Convert `localhost` → `host.containers.internal` (rootless compatible)
3. Mount SSL certs from `~/.config/proxy-cas.pem`
4. Configure Git, curl, and Swift Package Manager

### Manual Override

Edit `.devcontainer/devcontainer.json`:
```json
"containerEnv": {
  "HTTPS_PROXY": "http://your-proxy:port",
  "SSL_CERT_FILE": "/certs/your-cert.pem"
}
```

## Building BusyBox and Swift

### Initial Setup (One Time)

```bash
# Build BusyBox library with exported symbols
build-busybox
```

This will:
1. Download BusyBox 1.36.1 (cached)
2. Configure with:
   - `CONFIG_FEATURE_SHARED_BUSYBOX=y`
   - `CONFIG_FEATURE_INDIVIDUAL=y`
3. Override `-fvisibility=hidden` → `-fvisibility=default`
4. Build `libbusybox.so.1.36.1`
5. Install to `/workspace/BusyBox/lib/` and `/usr/lib/`
6. Verify exported symbols

**Time:** 2-3 minutes (one-time)

### Swift Development (Frequent)

```bash
# Build SwiftyBox
build-swift              # Release build
build-swift debug        # Debug build

# Test
.build/release/swiftybox echo "Hello!"
.build/release/swiftybox ls -la

# Run tests
swift test
```

**Time:** ~3 seconds (incremental)

## Development Workflow

### Typical Session

```bash
# 1. Start devcontainer (if not already running)
./devcontainer-cli.sh start

# 2. Enter shell
./devcontainer-cli.sh shell

# 3. Make changes to code (on host or in container)
# Edit Sources/swiftybox/*.swift

# 4. Build (very fast!)
build-swift

# 5. Test
.build/release/swiftybox echo "test"
swift test

# 6. Repeat steps 3-5 as needed

# 7. Stop when done
exit
./devcontainer-cli.sh stop
```

### Performance

| Task | Time | Notes |
|------|------|-------|
| Image build (first time) | ~5 min | Cached after first build |
| BusyBox build | ~2-3 min | Only needed once or when config changes |
| Swift build (clean) | ~30 sec | First build in fresh container |
| Swift build (incremental) | ~3 sec | After making small changes |
| Container start | ~2 sec | Using existing image |

## Features

### Included Tools

**Swift Development:**
- Swift 6.2+ toolchain
- LLDB debugger
- Swift Package Manager
- Source code completion (VS Code)

**C Development (BusyBox):**
- GCC compiler
- Make build system
- GDB debugger
- Binutils (nm, objdump, etc.)

**Analysis:**
- strace (system call tracing)
- ltrace (library call tracing)
- lsof (open files)
- file (file type detection)

**Editors:**
- vim
- nano
- VS Code (when using Dev Containers extension)

### Helper Scripts

**build-busybox:**
- Downloads BusyBox source (cached)
- Configures for shared library build
- Fixes symbol visibility
- Verifies exports
- Installs library

**build-swift:**
- Checks BusyBox library exists
- Builds with proper linking flags
- Shows binary info
- Suggests test commands

## Troubleshooting

### Container won't start
```bash
# Check if image exists
podman images | grep swiftybox-dev

# Rebuild image
./devcontainer-cli.sh build-image

# Check for port conflicts
podman ps -a
```

### Proxy not working
```bash
# Verify environment
./devcontainer-cli.sh exec env | grep -i proxy

# Check certificates
./devcontainer-cli.sh exec ls -la /certs/

# Test manually
./devcontainer-cli.sh exec curl -I https://github.com
```

### BusyBox symbols not exported
```bash
# Verify symbols
./devcontainer-cli.sh exec nm -D /workspace/BusyBox/lib/libbusybox.so | grep " T "

# Rebuild BusyBox
./devcontainer-cli.sh exec build-busybox
```

### Permission issues
```bash
# Container runs as root (normal for devcontainers)
# Files created in container are owned by root

# Fix ownership on host:
sudo chown -R $USER:$USER .build
```

### VS Code can't find Swift
```bash
# Check settings in devcontainer.json
# Should have:
"customizations": {
  "vscode": {
    "settings": {
      "swift.path": "/usr/bin/swift"
    }
  }
}
```

## Comparison: Old vs New

### Old Approach (dev-container.sh)
- ✅ Simple script
- ✅ Fast to start
- ❌ No BusyBox build capability
- ❌ Not standard compliant
- ❌ No VS Code integration
- ❌ Manual library setup

### New Approach (.devcontainer/)
- ✅ Standard specification
- ✅ VS Code integration
- ✅ Builds both BusyBox and Swift
- ✅ Reproducible environment
- ✅ Helper scripts included
- ✅ Proxy auto-configuration
- ⚠️ Slightly larger image (~500MB)

## Migration from dev-container.sh

If you were using the old `dev-container.sh`:

```bash
# Stop old container
./dev-container.sh stop

# Start new devcontainer
./devcontainer-cli.sh start

# Build BusyBox (one time)
./devcontainer-cli.sh build-busybox

# Build Swift (as before)
./devcontainer-cli.sh build-swift
```

**Benefits:**
- Can now rebuild BusyBox when needed
- Standard devcontainer format
- Works with VS Code
- Better documented

## Additional Resources

- [Dev Containers Specification](https://containers.dev/)
- [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)
- [Devcontainer CLI](https://github.com/devcontainers/cli)
- [GitHub Codespaces](https://github.com/features/codespaces)

## Quick Reference Card

```bash
# Start
./devcontainer-cli.sh start

# Build BusyBox (first time only)
./devcontainer-cli.sh build-busybox

# Build Swift (every change)
./devcontainer-cli.sh build-swift

# Test
./devcontainer-cli.sh test

# Shell
./devcontainer-cli.sh shell

# Stop
./devcontainer-cli.sh stop

# Status
./devcontainer-cli.sh status
```

---

**Ready to develop!** 🚀
