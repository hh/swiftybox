# SwiftyλBox Devcontainer

This devcontainer uses the **`development` target** from the main [Containerfile](../Containerfile).

## 🎯 Unified Build System

We use **ONE Containerfile** with multiple targets:

```
../Containerfile
├── development  ← This devcontainer (with tools & helpers)
└── production   ← For releases (minimal & optimized)
```

No duplication! Development and production share the same base environment.

## Quick Start

### VS Code (Easiest)

1. Install "Dev Containers" extension
2. Open workspace in VS Code
3. Click "Reopen in Container"
4. Inside: `build-busybox` (first time), then `build-swift`

### CLI Wrapper

```bash
# From project root
cd ..

# Start devcontainer
./devcontainer-cli.sh start

# Build BusyBox (one-time)
./devcontainer-cli.sh build-busybox

# Build SwiftyBox (~3 sec)
./devcontainer-cli.sh build-swift

# Enter shell
./devcontainer-cli.sh shell
```

### Manual

```bash
# From project root
cd ..

# Build using development target
podman build --target development -t swiftybox-dev .

# Run
podman run -it --rm \
  -v $(pwd):/workspace:Z \
  -e HTTPS_PROXY="http://host.containers.internal:4128" \
  -v ~/.config/proxy-cas.pem:/certs/proxy-cas.pem:ro,Z \
  swiftybox-dev
```

## What's Inside

**Tools:**
- Swift 6.2+ toolchain
- BusyBox build tools (gcc, make, wget, etc.)
- Debuggers (gdb, lldb)
- Analysis tools (strace, ltrace, lsof)
- Editors (vim, nano)

**Helper Scripts:**
- `build-busybox` - Build BusyBox library (~2-3 min, one-time)
- `build-swift` - Build SwiftyBox (~3 sec, frequent)

**Configuration:**
- Automatic proxy detection
- SSL certificate mounting
- Git workspace trust
- VS Code extensions

## Files

```
.devcontainer/
├── devcontainer.json          # VS Code config (points to ../Containerfile)
├── build-busybox.sh           # BusyBox builder (copied into image)
├── build-swift.sh             # Swift builder (copied into image)
├── README.md                  # This file
└── DEVCONTAINER_GUIDE.md      # Detailed guide
```

## Development Workflow

```bash
# 1. Start (once)
./devcontainer-cli.sh start

# 2. Build BusyBox (first time only)
./devcontainer-cli.sh build-busybox

# 3. Edit code, then build
./devcontainer-cli.sh build-swift

# 4. Test
./devcontainer-cli.sh exec .build/release/swiftybox echo "Hello!"

# 5. Repeat 3-4

# 6. Stop
./devcontainer-cli.sh stop
```

## Proxy Support

Automatically configured! Just set on host:

```bash
export HTTPS_PROXY="http://localhost:4128"
# Devcontainer converts to host.containers.internal
```

Certificates auto-mounted from: `~/.config/proxy-cas.pem`

## Documentation

- **[DEVELOPMENT.md](../DEVELOPMENT.md)** - Complete development guide
- **[DEVCONTAINER_GUIDE.md](DEVCONTAINER_GUIDE.md)** - Detailed devcontainer docs
- **[Containerfile](../Containerfile)** - The unified build definition

## Why One Containerfile?

**Benefits:**
- ✅ No duplication
- ✅ Consistent environments
- ✅ Easier maintenance
- ✅ Clear separation (targets)
- ✅ Shared base layers

**How it works:**
```bash
# Development: stops at 'development' stage
podman build --target development .

# Production: builds all stages through to 'production'
podman build --target production .
# Or just: podman build .  (production is default)
```

---

**Ready to develop!** 🚀

See [DEVELOPMENT.md](../DEVELOPMENT.md) for complete guide.
