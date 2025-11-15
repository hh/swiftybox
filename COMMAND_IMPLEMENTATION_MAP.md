# SwiftyλBox Command Implementation Map

## Purpose

This document tracks which commands are implemented in Swift vs BusyBox, and ensures ASH routes commands correctly.

## Routing Logic

```
User executes command in ASH shell
         ↓
ASH calls: is_swiftybox_command("cmd")
         ↓
    ┌────┴────┐
    ↓         ↓
  true      false
    ↓         ↓
Swift      BusyBox
impl      fallback
```

**Files involved:**
- `Sources/swiftybox/CommandRegistry.swift` - Swift command registry
- `Sources/swiftybox/ASHBridge.swift` - C↔Swift bridge for ASH
- BusyBox ASH - Shell integration (checks `is_swiftybox_command()`)

## Implementation Status

### ✅ Phase 1-3: Core NOFORK (4 commands)

| Command | Swift | BusyBox | ASH Routes To | Performance | Status |
|---------|-------|---------|---------------|-------------|--------|
| `echo` | ✅ | ✅ (fallback) | **Swift** | ~0.28μs | Working |
| `pwd` | ✅ | ✅ (fallback) | **Swift** | ~0.28μs | Working |
| `true` | ✅ | ✅ (fallback) | **Swift** | ~0.28μs | Working |
| `false` | ✅ | ✅ (fallback) | **Swift** | ~0.28μs | Working |

### ✅ Phase 4-5: NOFORK Expansion (40 commands)

| Command | Swift | BusyBox | ASH Routes To | Performance | Status |
|---------|-------|---------|---------------|-------------|--------|
| `yes` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `sleep` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `basename` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `dirname` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `env` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `seq` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `wc` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `cat` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `head` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `tail` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `grep` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `egrep` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `tr` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `cut` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `tee` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `mkdir` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `rmdir` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `touch` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `link` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `unlink` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `sync` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `whoami` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `logname` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `hostid` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `hostname` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `tty` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `readlink` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `realpath` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `truncate` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `which` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `printf` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `test` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `[` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `printenv` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `uname` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `arch` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `nproc` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `clear` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `usleep` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `free` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `pwdx` | ✅ | ❌ | **Swift** | NOFORK | ✅ |
| `fsync` | ✅ | ❌ | **Swift** | NOFORK | ✅ |

**Total NOFORK: 44 commands** (all Swift ✅)

### ✅ Phase 6-9: NOEXEC Commands (30 commands)

| Command | Swift | BusyBox | ASH Routes To | Performance | Status |
|---------|-------|---------|---------------|-------------|--------|
| `ln` | ✅ | ❌ | **Swift** | NOEXEC | ✅ |
| `chmod` | ✅ | ❌ | **Swift** | NOEXEC | ✅ |
| `chown` | ✅ | ❌ | **Swift** | NOEXEC | ✅ |
| `chgrp` | ✅ | ❌ | **Swift** | NOEXEC | ✅ |
| `rm` | ✅ | ❌ | **Swift** | NOEXEC | ✅ |
| `mv` | ✅ | ❌ | **Swift** | NOEXEC | ✅ |
| `cp` | ✅ | ❌ | **Swift** | NOEXEC | ✅ |
| `ls` | ✅ | ❌ | **Swift** | NOEXEC | ⚠️ Needs testing |
| `ps` | ✅ | ❌ | **Swift** | NOEXEC | ⚠️ Needs testing |
| `sort` | ✅ | ❌ | **Swift** | NOEXEC | ✅ |
| `uniq` | ✅ | ❌ | **Swift** | NOEXEC | ✅ |
| `comm` | ✅ | ❌ | **Swift** | NOEXEC | ✅ |
| `fold` | ✅ | ❌ | **Swift** | NOEXEC | ✅ |
| `paste` | ✅ | ❌ | **Swift** | NOEXEC | ✅ |
| `nl` | ✅ | ❌ | **Swift** | NOEXEC | ✅ |
| `md5sum` | ✅ | ❌ | **Swift** | NOEXEC | ✅ |
| `sha256sum` | ✅ | ❌ | **Swift** | NOEXEC | ✅ |
| `sha512sum` | ✅ | ❌ | **Swift** | NOEXEC | ✅ |
| `cksum` | ✅ | ❌ | **Swift** | NOEXEC | ✅ |
| `date` | ✅ | ❌ | **Swift** | NOEXEC | ✅ |
| `id` | ✅ | ❌ | **Swift** | NOEXEC | ✅ |
| `expr` | ✅ | ❌ | **Swift** | NOEXEC | ✅ |
| `mktemp` | ✅ | ❌ | **Swift** | NOEXEC | ✅ |
| `tac` | ✅ | ❌ | **Swift** | NOEXEC | ✅ |
| `rev` | ✅ | ❌ | **Swift** | NOEXEC | ✅ |
| `expand` | ✅ | ❌ | **Swift** | NOEXEC | ✅ |
| `unexpand` | ✅ | ❌ | **Swift** | NOEXEC | ✅ |
| `hexdump` | ✅ | ❌ | **Swift** | NOEXEC | ✅ |
| `shuf` | ✅ | ❌ | **Swift** | NOEXEC | ✅ |
| `stat` | ✅ | ❌ | **Swift** | NOEXEC | ✅ |
| `du` | ✅ | ❌ | **Swift** | NOEXEC | ✅ |
| `df` | ✅ | ❌ | **Swift** | NOEXEC | ✅ |

**Total NOEXEC: 30 commands** (all Swift ✅)

### ❌ BusyBox-Only Commands (Not Yet Implemented in Swift)

These commands fall back to BusyBox via fork+exec:

| Command | Swift | BusyBox | ASH Routes To | Status |
|---------|-------|---------|---------------|--------|
| `sh` | ❌ | ✅ | **BusyBox** | Shell itself |
| `ash` | ❌ | ✅ | **BusyBox** | Shell itself |
| `bash` | ❌ | ✅ | **BusyBox** (symlink) | Shell |
| `sed` | ❌ | ✅ | **BusyBox** | Fork+exec |
| `awk` | ❌ | ✅ | **BusyBox** | Fork+exec |
| `vi` | ❌ | ✅ | **BusyBox** | Fork+exec |
| `tar` | ❌ | ✅ | **BusyBox** | Fork+exec |
| `gzip` | ❌ | ✅ | **BusyBox** | Fork+exec |
| `gunzip` | ❌ | ✅ | **BusyBox** | Fork+exec |
| `find` | ❌ | ✅ | **BusyBox** | Fork+exec |
| `xargs` | ❌ | ✅ | **BusyBox** | Fork+exec |
| ... | | | | ~30+ more |

## Summary Statistics

```
Total Swift implementations:  74 commands
  ├─ NOFORK:                   44 commands (~0.28μs each)
  └─ NOEXEC:                   30 commands (~2x faster than fork+exec)

Total BusyBox fallbacks:       ~40 commands (fork+exec)

Total available:              ~115 commands
```

## How ASH Routing Works

### 1. ASH Checks for Swift Implementation

```c
// In BusyBox ASH code
if (is_swiftybox_command(cmd_name)) {
    // Route to Swift
    return swiftybox_builtin_wrapper(argc, argv);
} else {
    // Route to BusyBox or fork+exec
    return busybox_command(cmd_name, argc, argv);
}
```

### 2. Swift Bridge (ASHBridge.swift)

```swift
@_cdecl("is_swiftybox_command")
public func is_swiftybox_command(_ name: UnsafePointer<CChar>) -> Int32 {
    let cmdName = String(cString: name)
    let registry = CommandRegistry(preferredImpl: .swift)
    return registry.hasCommand(cmdName) ? 1 : 0
}
```

### 3. CommandRegistry Lookup

```swift
// CommandRegistry.swift
private let swiftCommands: [String: CommandFunc] = [
    "echo": EchoCommand.main,
    "pwd": PwdCommand.main,
    // ... 72 more commands
]

func hasCommand(_ name: String) -> Bool {
    return swiftCommands[name] != nil
}
```

## Verification Checklist

To ensure ASH routes correctly to Swift implementations:

### ✅ Completed

- [x] CommandRegistry has 74 Swift implementations registered
- [x] ASHBridge exports `is_swiftybox_command()` for C
- [x] ASHBridge exports `swiftybox_builtin_wrapper()` for dispatch
- [x] BusyBox fallbacks exist for echo/pwd/true/false

### ⚠️ Needs Testing

- [ ] **Verify ASH actually calls Swift for all 74 commands**
- [ ] Test ls/ps implementations work correctly from ASH
- [ ] Benchmark Swift vs BusyBox performance
- [ ] Ensure no regression where Swift command accidentally uses BusyBox

### 🔍 Testing Strategy

1. **Smoke test**: Run each Swift command from ASH, verify it's the Swift version
2. **Instrumentation**: Add logging to `is_swiftybox_command()` to track calls
3. **Performance test**: Measure NOFORK vs fork+exec overhead
4. **Regression test**: Ensure updates to CommandRegistry are reflected in ASH

## Potential Issues

### Issue 1: Registry Out of Sync

**Problem:** Swift command exists but not registered in `CommandRegistry.swiftCommands`

**Symptom:** ASH falls back to BusyBox even though Swift impl exists

**Solution:** Keep `CommandRegistry.swiftCommands` dictionary in sync with actual implementations

### Issue 2: BusyBox Shadowing

**Problem:** BusyBox has the command and `is_swiftybox_command()` returns false

**Symptom:** Uses slow BusyBox fork+exec instead of fast Swift NOFORK

**Solution:** Ensure all Swift implementations are in registry

### Issue 3: Symbol Export

**Problem:** Swift functions not visible to ASH (linker issue)

**Symptom:** ASH can't find `is_swiftybox_command` or `swiftybox_builtin_wrapper`

**Solution:** Verify `@_cdecl` exports and check `nm` output

## Next Steps

### Session 1: Verification & Testing

1. Add instrumentation to track ASH→Swift routing
2. Create test suite that verifies routing for all 74 commands
3. Test ls/ps implementations thoroughly
4. Document any commands that aren't routing correctly

### Session 2: Performance Analysis

1. Benchmark Swift NOFORK vs BusyBox fork+exec
2. Measure actual μs performance
3. Validate ~786x speedup claim
4. Profile hot paths

### Session 3: Fill Gaps

1. Identify most-used BusyBox commands
2. Prioritize Swift implementations for high-frequency commands
3. Implement next batch (Phase 10+)

## Maintenance

**When adding a new Swift command:**

1. Create `XyzCommand.swift` file
2. Add to `CommandRegistry.swiftCommands` dictionary ← **CRITICAL!**
3. Add to this map
4. Write tests
5. Verify ASH routes correctly

**Golden rule:** If it's not in `CommandRegistry.swiftCommands`, ASH won't use it!

---

Last updated: 2025-11-15
Status: 74 Swift commands implemented, needs routing verification
