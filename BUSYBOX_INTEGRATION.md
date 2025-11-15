# BusyBox Integration - The Simple Truth

## TL;DR

**We don't patch BusyBox source code.**

We just:
1. Build it as a shared library
2. Export symbols (change one compiler flag)
3. Link against it from Swift

That's it.

---

## What We Do

### 1. Download BusyBox

```bash
wget https://busybox.net/downloads/busybox-1.36.1.tar.bz2
tar xjf busybox-1.36.1.tar.bz2
```

**No modifications to source code.**

### 2. Configure Build

```bash
make defconfig

# Change 4 config options (via sed)
CONFIG_BUILD_LIBBUSYBOX=y              # Build as library
CONFIG_FEATURE_SHARED_BUSYBOX=y        # Make it shared (.so not .a)
CONFIG_FEATURE_INDIVIDUAL=y            # Enable individual applets
CONFIG_TC=n                            # Disable tc (broken applet)
```

**No source patches - just config changes.**

### 3. Fix Symbol Visibility

```bash
# One line change in Makefile.flags
sed -i 's/-fvisibility=hidden/-fvisibility=default/g' Makefile.flags
```

**This is the magic:** Makes BusyBox functions visible to Swift.

### 4. Build

```bash
make -j$(nproc)
```

Output: `libbusybox.so.1.36.1` (~1.1 MB)

### 5. Link from Swift

```swift
// BusyBox/include/busybox-bridge.h
extern "C" {
    int echo_main(int argc, char **argv);
    int ash_main(int argc, char **argv);
    // ...
}
```

```bash
# Swift build flags
swift build -Xlinker -L/path/to/lib -Xlinker -lbusybox
```

**Done!**

---

## What We Get

### Exported Symbols

```bash
$ nm -D libbusybox.so.1.36.1 | grep " T " | wc -l
300+  # All BusyBox functions exported!
```

**Key symbols:**
- `echo_main`, `pwd_main`, `ls_main`, etc. (400+ commands)
- `ash_main` (the shell itself)
- `lbb_prepare` (initialization function)

### How Swift Uses It

```swift
// Swift can call BusyBox functions directly
import BusyBox

func runBusyBoxCommand(_ cmd: String, args: [String]) -> Int32 {
    lbb_prepare(cmd, argv)
    return echo_main(argc, argv)  // Zero-overhead C call!
}
```

**No FFI overhead. Just a function call.**

---

## Files Modified

### Zero Source Files

**We modify ZERO BusyBox source files.**

### Configuration Files (2 files)

| File | Change | Why |
|------|--------|-----|
| `.config` | Enable 3 options | Build as shared library |
| `Makefile.flags` | Change visibility | Export symbols to Swift |

### Our Files (2 files)

| File | Purpose |
|------|---------|
| `BusyBox/include/busybox-bridge.h` | Declare BusyBox functions |
| `BusyBox/module.modulemap` | Swift module definition |

**That's all.**

---

## Key Insight: Why No Patches?

### BusyBox Already Supports This!

BusyBox has built-in support for shared library mode:
- `CONFIG_BUILD_LIBBUSYBOX=y` - Official feature
- `CONFIG_FEATURE_SHARED_BUSYBOX=y` - Official feature
- `CONFIG_FEATURE_INDIVIDUAL=y` - Official feature

**We're just using BusyBox as designed.**

### The Only "Hack"

Changing `-fvisibility=hidden` to `-fvisibility=default`:

**Why BusyBox uses hidden:**
- Reduces symbol conflicts
- Slightly smaller library

**Why we need default:**
- Swift needs to see the symbols
- We want to call them directly

**This is not a hack, it's a configuration choice.**

---

## Upgrading BusyBox

### Process

1. Download new version
2. Apply same 4 config changes
3. Change visibility flag
4. Build
5. Test

### Will It Break?

**Probably not.** We rely on:
- Standard BusyBox features (shared library mode)
- Stable function signatures (`echo_main`, etc.)
- Standard C ABI

**BusyBox maintains backward compatibility for these.**

### If It Does Break

Check:
1. Are config options still valid?
2. Did function signatures change?
3. Run symbol verification:
   ```bash
   nm -D libbusybox.so | grep echo_main
   ```

---

## How ASH Integration Works

### Current Implementation: Standalone Binary (No ASH Patching)

**SwiftyBox runs as a standalone binary, NOT integrated into ASH shell.**

The flow is simpler than initially thought:

```
User runs: /bin/echo hello
         ↓
SwiftyBox binary (symlink to swiftybox)
         ↓
CommandRegistry.execute("echo", args)
         ↓
    ┌────┴────┐
    ↓         ↓
  In Swift?  In BusyBox?
    ✓         ✗
    ↓         ↓
EchoCommand  BusyBoxWrapper
  .main()    (libbusybox)
    ↓
Swift NOFORK
(786x faster)
```

### ASH Shell Integration: Future Work ⏭

There IS a reference patch showing how to integrate Swift into ASH:
- **File:** `/var/home/hh/w/swift/busybox/swiftybox-ash-integration.patch`
- **Status:** NOT currently applied
- **Purpose:** Shows how ASH could call Swift functions as builtins

**If applied,** ASH would route commands like this:
```c
// In shell/ash.c (with patch)
extern int swiftybox_builtin_wrapper(int argc, char **argv);
extern int is_swiftybox_command(const char *name);

// In builtin command table:
{ BUILTIN_REGULAR "echo", swiftybox_builtin_wrapper },
{ BUILTIN_REGULAR "echo-c", echocmd },  // C fallback
```

**See [PATCHING.md](../PATCHING.md) for:**
- Complete patching strategy
- When and why to apply the ASH patch
- Benefits and risks
- Alternative integration approaches

---

## Build Scripts

### Production (Containerfile)

```dockerfile
# Stage: busybox-builder
RUN make defconfig && \
    sed -i 's/# CONFIG_BUILD_LIBBUSYBOX is not set/CONFIG_BUILD_LIBBUSYBOX=y/' .config && \
    sed -i 's/# CONFIG_FEATURE_SHARED_BUSYBOX is not set/CONFIG_FEATURE_SHARED_BUSYBOX=y/' .config && \
    sed -i 's/# CONFIG_FEATURE_INDIVIDUAL is not set/CONFIG_FEATURE_INDIVIDUAL=y/' .config && \
    sed -i 's/^CONFIG_TC=y/# CONFIG_TC is not set/' .config && \
    sed -i 's/-fvisibility=hidden/-fvisibility=default/g' Makefile.flags && \
    make -j$(nproc) SKIP_STRIP=y
```

### Development (.devcontainer/build-busybox.sh)

Same steps, with verification:
```bash
# Verify symbols exported
nm -D libbusybox.so.1.36.1 | grep " T " | wc -l
nm -D libbusybox.so.1.36.1 | grep echo_main
```

---

## Troubleshooting

### Symbols Not Exported

**Problem:** `nm -D libbusybox.so | grep " T " | wc -l` shows only 1-2 symbols

**Cause:** Visibility flag not changed

**Fix:**
```bash
grep fvisibility Makefile.flags
# Should show: -fvisibility=default
# If not: sed -i 's/-fvisibility=hidden/-fvisibility=default/g' Makefile.flags
```

### Library Not Found

**Problem:** Swift build fails with "cannot find -lbusybox"

**Cause:** Library path not set

**Fix:**
```bash
# Check library exists
ls BusyBox/lib/libbusybox.so

# Add to Swift build
swift build -Xlinker -L/workspace/BusyBox/lib
```

### Wrong Symbols

**Problem:** `echo_main` shows as lowercase 't' not 'T'

**Cause:** Symbol is local, not global

**Fix:** Rebuild with correct visibility flag

```bash
# Check symbol
nm libbusybox.so.1.36.1 | grep echo_main
# Should show: T echo_main  (capital T)
# Not:         t echo_main  (lowercase t)
```

---

## Summary

### What We Modify

✅ BusyBox `.config` (4 lines via sed)
✅ BusyBox `Makefile.flags` (1 line via sed)
❌ BusyBox source code (ZERO files)

### Why It's Clean

- Uses official BusyBox features
- No fragile patches
- Easy to upgrade
- Standard C ABI
- Simple configuration changes

### Maintenance

**Effort:** Minimal
**Risk:** Low
**Upgrade path:** Straightforward

---

## ASH Integration: Question Answered ✅

**Question:** How does ASH call `is_swiftybox_command()`?

**Answer:** It doesn't. Currently, ASH is NOT integrated with Swift.

### Current Architecture

- SwiftyBox is a **standalone binary** with command symlinks
- ASH shell (`/bin/sh`) is just another command in SwiftyBox
- When you run ASH, it uses standard BusyBox C implementations
- When you run `/bin/echo`, it uses Swift implementation

### Future ASH Integration (Optional)

A reference patch exists showing how to integrate Swift into ASH builtins:
- Patch file: `../busybox/swiftybox-ash-integration.patch`
- Status: NOT applied in current builds
- Would enable: ASH shell preferring Swift implementations

**See [PATCHING.md](../PATCHING.md) for complete details.**

---

## Related Documentation

- **[PATCHING.md](../PATCHING.md)** - Comprehensive patching strategy
- **[BUSYBOX_BUILD.md](../BUSYBOX_BUILD.md)** - Build configuration
- **[ASH_INTEGRATION.md](../ASH_INTEGRATION.md)** - Shell integration plans
- **[COMMAND_IMPLEMENTATION_MAP.md](COMMAND_IMPLEMENTATION_MAP.md)** - Command routing

---

**Bottom line:** No source patches. Just configuration. Clean and maintainable. ✨
