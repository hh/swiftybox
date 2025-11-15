# SwiftyλBox - Build Approaches

**Simple choice:** ONE Containerfile, TWO targets.

## 🎯 The Unified Approach

```
Containerfile (single file)
├── development  ← For development (fast iteration)
└── production   ← For releases (optimized)
```

**Key insight:** Use build targets instead of separate files!

## Option 1: Development Target 🛠️

**Purpose:** Daily development, rapid iteration

```bash
# Using CLI wrapper (easiest)
./devcontainer-cli.sh start
./devcontainer-cli.sh build-busybox  # One-time
./devcontainer-cli.sh build-swift    # ~3 seconds
./devcontainer-cli.sh test

# Or manual
podman build --target development -t swiftybox-dev .
podman run -it -v $(pwd):/workspace:Z swiftybox-dev
```

**Features:**
- ✅ All development tools included
- ✅ Helper scripts (build-busybox, build-swift)
- ✅ Can rebuild both BusyBox and Swift
- ✅ VS Code integration
- ✅ 3-second Swift rebuilds
- ✅ Automatic proxy configuration

**When to use:**
- Writing Swift code
- Modifying BusyBox configuration
- Running tests
- Debugging
- Team development

**Build time:**
- First time: ~5 minutes
- Cached: ~1 minute
- Swift rebuild: ~3 seconds

---

## Option 2: Production Target 🏭

**Purpose:** Releases, deployments, testing final integration

```bash
# Build (default target)
podman build -t swiftybox:latest .

# Or explicitly
podman build --target production -t swiftybox:latest .

# Test
podman run -it --rm swiftybox:latest /bin/sh
```

**Features:**
- ✅ Builds everything from source
- ✅ Multi-stage optimization
- ✅ Minimal final image
- ✅ Ready to deploy
- ✅ No development bloat

**When to use:**
- Creating releases
- CI/CD pipelines
- Testing full build
- Deployment preparation
- Integration verification

**Build time:**
- Full build: ~8 minutes
- Cached: ~3 minutes

---

## Comparison

| Feature | Development | Production |
|---------|-------------|------------|
| **Target** | `--target development` | `--target production` (default) |
| **Purpose** | Daily dev | Releases |
| **Image size** | ~500 MB | ~300 MB |
| **Tools included** | All dev tools | Runtime only |
| **Build time (first)** | ~5 min | ~8 min |
| **Rebuild time** | ~3 sec (Swift) | ~3 min (full) |
| **Source mount** | Yes (from host) | No (copied) |
| **VS Code support** | Yes | No |
| **Can rebuild BusyBox** | Yes | N/A |
| **Can rebuild Swift** | Yes (~3 sec) | Yes (full build) |

---

## Development Workflow

**Typical session:**

```bash
# 1. Start dev container (once)
./devcontainer-cli.sh start

# 2. Build BusyBox (first time only)
./devcontainer-cli.sh build-busybox

# 3. Daily loop: edit → build → test
vim Sources/swiftybox/MyCommand.swift
./devcontainer-cli.sh build-swift        # 3 seconds
./devcontainer-cli.sh test

# 4. Repeat step 3 as needed

# 5. Stop when done
./devcontainer-cli.sh stop
```

**Before committing:**

```bash
# Verify production build still works
podman build -t swiftybox:test .
podman run -it --rm swiftybox:test /bin/sh
```

---

## Why This Works Better

### Old Approach (deprecated)
- ❌ 3 separate files
- ❌ Duplication
- ❌ Inconsistent environments
- ❌ Hard to maintain
- ❌ Confusing to choose

### New Approach (current)
- ✅ 1 file, 2 targets
- ✅ No duplication
- ✅ Consistent base
- ✅ Easy to maintain
- ✅ Clear choice

---

## How Build Targets Work

### The Containerfile Structure

```dockerfile
# Base (shared by both)
FROM swift:latest AS build-base
RUN apt-get install build-tools...

# Development target (stops here)
FROM build-base AS development
RUN apt-get install dev-tools...
COPY .devcontainer/build-*.sh /usr/local/bin/
CMD ["bash"]

# Production continues...
FROM build-base AS busybox-builder
RUN build busybox...

FROM build-base AS swift-builder
RUN build swiftybox...

# Production target (ends here)
FROM swift:latest AS production
COPY --from=swift-builder /workspace/.build/release/swiftybox /bin/
CMD ["/bin/sh"]
```

### Stopping at Different Stages

**Development build:**
```bash
podman build --target development .
```
- Stops at `development` stage
- Gets: build-base + dev tools + helpers
- Skips: busybox-builder, swift-builder, production

**Production build:**
```bash
podman build --target production .
# Or just: podman build .
```
- Runs through ALL stages
- Gets: optimized final image
- Result: minimal production container

---

## File Organization

```
swiftybox/
├── Containerfile              ← ONE FILE
│   ├── build-base stage
│   ├── development target     ← Dev stops here
│   ├── busybox-builder stage
│   ├── swift-builder stage
│   └── production target      ← Prod ends here
│
├── .devcontainer/
│   ├── devcontainer.json      ← Points to ../Containerfile (development)
│   ├── build-busybox.sh       ← Copied into dev image
│   └── build-swift.sh         ← Copied into dev image
│
├── devcontainer-cli.sh        ← Wrapper for development
│
└── Sources/                   ← Your code
```

---

## Proxy Configuration

Both targets support HTTPS proxy automatically:

```bash
# Set on host
export HTTPS_PROXY="http://localhost:4128"

# Development
./devcontainer-cli.sh start  # Auto-detects

# Production
podman build \
  --build-arg HTTPS_PROXY="http://host.containers.internal:4128" \
  .
```

Certificates: `~/.config/proxy-cas.pem` (auto-mounted in development)

---

## Quick Reference

### Development Commands

```bash
./devcontainer-cli.sh build-image    # Build dev image
./devcontainer-cli.sh start          # Start container
./devcontainer-cli.sh build-busybox  # Build BusyBox (one-time)
./devcontainer-cli.sh build-swift    # Build Swift (~3 sec)
./devcontainer-cli.sh test           # Run tests
./devcontainer-cli.sh shell          # Enter shell
./devcontainer-cli.sh stop           # Stop container
```

### Production Commands

```bash
podman build -t swiftybox:latest .                    # Build
podman run -it --rm swiftybox:latest /bin/sh          # Test
podman run --rm swiftybox:latest /bin/echo "Hello!"   # Quick test
```

---

## Benefits Summary

**One Containerfile approach:**
1. **Simpler** - One file to understand
2. **Consistent** - Same base for dev and prod
3. **Maintainable** - Changes in one place
4. **Flexible** - Different outputs from same source
5. **Standard** - Industry-standard pattern

**Two clear targets:**
1. **development** - Fast iteration, full tools
2. **production** - Optimized release, minimal size

**No confusion:**
- Development? → `--target development`
- Production? → `--target production` (or default)

---

## Migration Note

**Deprecated:**
- `dev-container.sh` → Archived to `.deprecated/`
- `.devcontainer/Containerfile` → Removed (merged into main)

**Current:**
- Use `./devcontainer-cli.sh` for development
- Use `podman build .` for production

---

**Ready to build!** 🚀

See [DEVELOPMENT.md](DEVELOPMENT.md) for complete guide.
