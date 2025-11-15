# SwiftyλBox Development Guide

## ✨ One Containerfile, Two Purposes

We use a **single unified Containerfile** with multiple build targets:

```
Containerfile
├── development  ← For development (with helper scripts)
└── production   ← For releases (minimal, optimized)
```

This eliminates duplication and ensures dev and production use the same base environment.

## 🚀 Quick Start - Development

### Option 1: Using the CLI Wrapper (Easiest)

```bash
# Build dev image (first time or after Containerfile changes)
./devcontainer-cli.sh build-image

# Start dev container
./devcontainer-cli.sh start

# Build BusyBox library (one-time)
./devcontainer-cli.sh build-busybox

# Build SwiftyBox (frequent, ~3 seconds)
./devcontainer-cli.sh build-swift

# Enter shell for development
./devcontainer-cli.sh shell

# Stop when done
./devcontainer-cli.sh stop
```

### Option 2: Using VS Code

1. Install "Dev Containers" extension
2. Open folder in VS Code
3. Click "Reopen in Container"
4. Inside container: `build-busybox` then `build-swift`

### Option 3: Manual Podman Commands

```bash
# Build dev image using development target
podman build --target development -t swiftybox-dev .

# Run container
podman run -d --name swiftybox-dev \
  -e HTTPS_PROXY="http://host.containers.internal:4128" \
  -e SSL_CERT_FILE="/certs/proxy-cas.pem" \
  -v ~/.config/proxy-cas.pem:/certs/proxy-cas.pem:ro,Z \
  -v $(pwd):/workspace:Z \
  -w /workspace \
  swiftybox-dev

# Enter container
podman exec -it swiftybox-dev bash

# Build inside
build-busybox  # One time
build-swift    # Every change
```

## 🏭 Production Build

```bash
# Build production image (default target)
podman build -t swiftybox:latest .

# Or explicitly specify production target
podman build --target production -t swiftybox:latest .

# Test it
podman run -it --rm swiftybox:latest /bin/sh
```

## 📊 Comparison

| Feature | Development Target | Production Target |
|---------|-------------------|-------------------|
| **Purpose** | Development & iteration | Deployable release |
| **Size** | ~500MB | ~300MB |
| **Contains** | Build tools, debuggers, helpers | Minimal runtime only |
| **Build time** | ~5 min (first time) | ~8 min (full build) |
| **Rebuild time** | Cached (~1 min) | Cached (~3 min) |
| **Use case** | Daily development | CI/CD, releases |

## 🔄 Development Workflow

### Typical Session

```bash
# 1. Start container (uses cached image)
./devcontainer-cli.sh start              # ~2 seconds

# 2. First time only: Build BusyBox
./devcontainer-cli.sh build-busybox      # ~2-3 minutes

# 3. Enter development environment
./devcontainer-cli.sh shell

# 4. Make changes to Swift code
vim Sources/swiftybox/MyCommand.swift

# 5. Build (very fast!)
build-swift                              # ~3 seconds

# 6. Test
.build/release/swiftybox mycommand

# 7. Iterate (repeat 4-6)

# 8. Run tests
swift test

# 9. Exit when done
exit
./devcontainer-cli.sh stop
```

### When to Rebuild BusyBox

Only rebuild BusyBox when:
- ✅ First time setup
- ✅ Changing BusyBox configuration
- ✅ Updating BusyBox version
- ❌ NOT for Swift code changes

### When to Rebuild Dev Image

Rebuild the dev image when:
- ✅ First time (one-time 5 min setup)
- ✅ After updating Containerfile
- ✅ After updating helper scripts
- ❌ NOT for Swift or BusyBox code changes

## 🛠️ Build Targets Explained

### `development` Target

**What it includes:**
- Swift 6.2+ toolchain
- BusyBox build tools (gcc, make, etc.)
- Development tools (vim, gdb, lldb, strace)
- Helper scripts (`build-busybox`, `build-swift`)
- Git configuration

**What it does NOT include:**
- Pre-built BusyBox library (you build it)
- Pre-built SwiftyBox binary (you build it)

**Use when:**
- Developing Swift code
- Modifying BusyBox configuration
- Debugging issues
- Running tests

### `production` Target

**What it includes:**
- Swift runtime
- Compiled SwiftyBox binary
- BusyBox shared library
- 115 command symlinks
- Minimal system files

**What it does NOT include:**
- Build tools
- Source code
- Development utilities

**Use when:**
- Creating releases
- Testing full integration
- Deploying to production
- CI/CD pipelines

## 🎯 How Build Targets Work

The Containerfile defines stages that build on each other:

```
build-base (Swift + basic build tools)
    ├── development ← Dev target stops here
    ├── busybox-builder
    └── swift-builder
        └── installer
            └── production ← Prod target ends here
```

**Development target:**
- Stops at `development` stage
- Gives you tools to build things yourself
- Keeps container size reasonable
- Mounts your source code from host

**Production target:**
- Goes through all stages
- Builds everything from source
- Optimizes and strips binaries
- Creates minimal final image

## 📁 File Structure

```
swiftybox/
├── Containerfile              ← SINGLE unified file
│   ├── development target
│   └── production target
├── .devcontainer/
│   ├── devcontainer.json      ← Points to ../Containerfile (development)
│   ├── build-busybox.sh       ← Copied into dev image
│   ├── build-swift.sh         ← Copied into dev image
│   └── README.md
├── devcontainer-cli.sh        ← CLI wrapper
└── Sources/                   ← Your code
```

## 🌐 Proxy Configuration

Both targets automatically support HTTPS proxy:

**Automatic Detection:**
```bash
export HTTPS_PROXY="http://localhost:4128"
# CLI script converts to host.containers.internal automatically
```

**Certificates:**
- Place in: `~/.config/proxy-cas.pem`
- Auto-mounted by devcontainer-cli.sh
- Used for git, curl, Swift Package Manager

**Manual Override:**
```bash
podman build \
  --build-arg HTTPS_PROXY="http://your-proxy:port" \
  --target development \
  -t swiftybox-dev .
```

## 🧪 Testing

### Development Container

```bash
# Enter container
./devcontainer-cli.sh shell

# Run Swift tests
swift test

# Run specific test
swift test --filter LsCommandTests

# Test binary
.build/release/swiftybox echo "Hello!"
```

### Production Image

```bash
# Build production image
podman build -t swiftybox:test .

# Quick tests
podman run --rm swiftybox:test /bin/echo "Hello!"
podman run --rm swiftybox:test /bin/ls -la
podman run --rm swiftybox:test /bin/sh -c 'pwd && whoami'

# Interactive
podman run -it --rm swiftybox:test /bin/sh
```

## 💡 Tips & Tricks

### Speed Up Development

1. **Keep container running** - Don't stop/start for every change
2. **Use build cache** - Don't delete `.build/` directory
3. **Parallel make** - BusyBox uses all CPU cores automatically
4. **Incremental Swift builds** - Only changed files recompile

### Debugging

```bash
# Build in debug mode
./devcontainer-cli.sh exec build-swift debug

# Use lldb
./devcontainer-cli.sh exec lldb .build/debug/swiftybox
```

### Clean Rebuild

```bash
# Clean dev image cache
podman rmi swiftybox-dev:latest

# Clean production image cache
podman rmi swiftybox:latest

# Clean all build artifacts
rm -rf .build busybox-src
```

## 🔧 Customization

### Modify Development Tools

Edit the `development` stage in Containerfile:

```dockerfile
FROM build-base AS development

RUN apt-get install -y \
    your-additional-tool
```

### Change BusyBox Version

```bash
# In container
export BUSYBOX_VERSION=1.37.0
build-busybox
```

Or edit Containerfile:
```dockerfile
ARG BUSYBOX_VERSION=1.37.0
```

## 📚 Additional Resources

- [Containerfile](Containerfile) - The unified build definition
- [.devcontainer/](..devcontainer/) - VS Code integration
- [devcontainer-cli.sh](devcontainer-cli.sh) - CLI wrapper
- [Dev Containers Spec](https://containers.dev/) - Industry standard

## 🎯 Summary

**One Containerfile** with two targets:
- 🛠️ `development` - For daily development
- 🏭 `production` - For releases

**Simplicity:**
- One file to maintain
- Consistent environments
- Clear separation of concerns

**Flexibility:**
- Build either target independently
- Share common base layers
- Optimize for each use case

Ready to develop! 🚀
