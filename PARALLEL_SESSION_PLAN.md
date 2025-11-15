# SwiftyλBox Parallel Testing Sessions - Work Breakdown

## Overview

**Goal**: Achieve 90%+ test coverage with best-in-class implementations

**Strategy**: 4 parallel sessions working independently with clear boundaries

**Timeline**: ~4-6 hours for full completion

**Documentation**: Each agent should follow [TEST_DEVELOPMENT_STRATEGY.md](./TEST_DEVELOPMENT_STRATEGY.md)

---

## Session Architecture

```
Session 1 (CRITICAL PATH) ──┬──> Session 2 (New Tests - Simple)
                            ├──> Session 3 (New Tests - Complex)
                            └──> Session 4 (Fix Failures)

Session 1 MUST complete first (30-60 min)
Sessions 2-4 can run in parallel after Session 1
```

---

## SESSION 1: Unblock & Baseline (CRITICAL PATH)

**Branch**: `test/compilation-fixes`
**Priority**: P0 - MUST complete before other sessions
**Estimated Time**: 30-60 minutes
**Agent**: Senior engineer (critical path blocker)

### Objectives
1. Fix all compilation errors preventing tests from running
2. Execute full test suite to establish baseline
3. Document baseline pass/fail rates
4. Unblock Sessions 2-4

### Tasks

#### Task 1.1: Fix Compilation Errors (30 min)
```bash
# Issues to fix:
# 1. Tuple comparison in test assertions
# 2. Missing CommandResult usage
# 3. Any module import issues

# Reference: TEST_STATUS.md has automated fix script
```

**Files to Fix** (priority order):
1. `Tests/SwiftyBoxTests/Consolidated/ExprTests.swift` - Tuple comparisons
2. `Tests/SwiftyBoxTests/Consolidated/IdTests.swift` - CommandResult usage
3. Any other compilation errors discovered

**Fix Strategy**:
```swift
// BEFORE (won't compile):
XCTAssertEqual(result, (0, "output\n", ""))

// AFTER (compiles):
let result = runCommand(["expr", "1", "+", "1"])
XCTAssertEqual(result.exitCode, 0)
XCTAssertEqual(result.stdout, "2\n")
XCTAssertEqual(result.stderr, "")
```

#### Task 1.2: Run Baseline Tests (10 min)
```bash
cd /var/home/hh/w/swift/swiftybox
./run-tests.sh 2>&1 | tee baseline-results.txt
```

#### Task 1.3: Analyze Results (15 min)
```bash
# Use analysis script
python3 scripts/analyze-test-results.py baseline-results.txt > baseline-analysis.md

# Manual triage:
# - Which commands have 100% pass rate?
# - Which commands are completely broken?
# - Which have partial failures?
```

#### Task 1.4: Update Tracking Documents (5 min)
```bash
# Update TEST_FAILURE_TRACKER.md with actual results
# Format:
# | Command | Total Tests | Passing | Failing | Status |
# |---------|-------------|---------|---------|--------|
# | echo    | 11          | 11      | 0       | ✅     |
# | sort    | 17          | 15      | 2       | ⚠️     |
```

### Deliverables
- ✅ All tests compile successfully
- ✅ `baseline-results.txt` - Full test run output
- ✅ `baseline-analysis.md` - Analysis of results
- ✅ Updated `TEST_FAILURE_TRACKER.md`
- ✅ Git commit on `test/compilation-fixes` branch

### Success Criteria
- `swift test` completes without compilation errors
- At least 60% of existing tests pass (baseline)
- Clear documentation of what's broken

### Exit Criteria for Unblocking Sessions 2-4
```bash
# When this succeeds, notify other sessions to begin:
swift test --parallel 2>&1 | grep -E "(Test Suite|failed|passed)"
```

---

## SESSION 2: New Tests - Simple Commands

**Branch**: `test/simple-commands`
**Priority**: P1
**Estimated Time**: 3-4 hours
**Agent**: Mid-level engineer
**Blocked By**: Session 1 completion

### Objectives
Create comprehensive tests for 15 simple commands (mostly NOFORK, simple I/O)

### Command Assignments

#### Group A: Trivial Commands (1 hour, 30-40 tests total)
Simple success/failure, minimal options

1. **true** (ALREADY HAS TESTS - verify quality)
   - Should have: exit code 0, no output, ignore all args

2. **false** (ALREADY HAS TESTS - verify quality)
   - Should have: exit code 1, no output, ignore all args

3. **yes** (NEW)
   - GNU ref: Infinite output of string
   - Tests: default "y", custom string, stop on SIGPIPE
   - Edge: binary safe, very long strings

4. **arch** (NEW)
   - GNU ref: Print machine architecture
   - Tests: returns valid arch (x86_64, aarch64, etc.)
   - Edge: compare to `uname -m`

5. **clear** (NEW)
   - Reference: terminfo/ncurses
   - Tests: outputs terminal escape sequence
   - Edge: behavior when not a TTY

6. **sync** (NEW)
   - POSIX ref: Flush filesystem buffers
   - Tests: exit code 0, no output
   - Note: Hard to test actual syncing

7. **link** (NEW)
   - POSIX ref: Create hard link
   - Tests: basic link, cross-filesystem (should fail), permissions
   - Edge: linking to symlink, nonexistent target

8. **unlink** (NEW)
   - POSIX ref: Remove file
   - Tests: basic unlink, directory (should fail), nonexistent
   - Edge: remove last link to file

#### Group B: Simple Info Commands (1.5 hours, 40-50 tests total)

9. **whoami** (NEW)
   - GNU ref: Print effective user name
   - Tests: returns valid username, no options
   - Edge: compare to `id -un`

10. **logname** (NEW)
    - POSIX ref: Print login name
    - Tests: returns login user (may differ from whoami)
    - Edge: behavior when no controlling terminal

11. **tty** (NEW)
    - POSIX ref: Print terminal name
    - Tests: returns /dev/pts/X when TTY, "not a tty" otherwise
    - Edge: exit code differs (0 for TTY, 1 for not)

12. **nproc** (NEW)
    - GNU ref: Print number of processing units
    - Tests: returns integer > 0, --all vs --ignore=N
    - Edge: compare to /proc/cpuinfo, sysconf

13. **hostid** (ALREADY HAS TESTS - verify quality)
    - Check: 8-char hex output, consistency

14. **uname** (NEW)
    - POSIX ref: Print system information
    - Tests: -s (kernel), -n (hostname), -r (release), -m (machine), -a (all)
    - Edge: compare to /proc/version, combination of flags

15. **printenv** (NEW)
    - GNU ref: Print environment variables
    - Tests: all vars, specific var, nonexistent var (empty), no args
    - Edge: vars with special chars, empty values

#### Group C: Simple File Commands (30 min, 15-20 tests)

16. **fsync** (NEW)
    - Linux-specific: Flush file data to disk
    - Tests: sync file, directory, nonexistent (error)
    - Edge: permission errors, read-only filesystem

17. **truncate** (NEW)
    - GNU ref: Shrink/extend file size
    - Tests: -s SIZE, create new, expand, shrink, negative size (error)
    - Edge: sparse files, symlinks

#### Group D: Sleep/Timing (30 min, 10-15 tests)

18. **sleep** (NEW)
    - POSIX ref: Delay for specified time
    - Tests: integer seconds, fractional (1.5), multiple args, invalid input
    - Edge: very large values, zero, negative (error)

19. **usleep** (NEW)
    - BusyBox-specific: Sleep in microseconds
    - Tests: basic delay, invalid input
    - Edge: Compare timing accuracy (acceptable variance)

20. **pwdx** (NEW)
    - Linux-specific: Print working directory of process
    - Tests: valid PID, invalid PID (error), multiple PIDs, self ($$)
    - Edge: permission denied, zombie process

### Test Development Guidelines

For each command:
1. **Research** (10 min): Check GNU, POSIX, man pages
2. **Document** (5 min): Add implementation notes to test file
3. **Write Tests** (15-20 min): Aim for 8-12 tests per command
4. **Verify** (5 min): Run against system command

### Template for Each Command

```swift
import XCTest
@testable import SwiftyBox

/// Tests for the `<COMMAND>` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: GNU coreutils / POSIX / BusyBox
/// - Options: <list main options>
/// - Common usage: <top 3 use cases>
/// - Target scope: P0 (POSIX) + P1 (common extensions)
///
/// Resources:
/// - GNU: https://www.gnu.org/software/coreutils/manual/html_node/<command>-invocation.html
/// - POSIX: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/<command>.html

final class <Command>Tests: XCTestCase {

    // MARK: - Basic Functionality

    func testBasicOperation() {
        // Most common usage
    }

    func testWithOptions() {
        // Common options
    }

    // MARK: - Edge Cases

    func testEdgeCase1() { }

    // MARK: - Error Handling

    func testInvalidInput() {
        // Should fail gracefully
    }

    func testMissingArguments() { }
}
```

### Deliverables
- 20 test files (some improved, 15+ new)
- 100+ new test cases total
- Each file documented with implementation notes
- All tests pass or have clear TODOs for implementation

### Quality Checklist
- [ ] Each command has 8-12 test cases minimum
- [ ] Implementation notes documented
- [ ] Compared against GNU/system version
- [ ] Edge cases covered
- [ ] Error handling tested
- [ ] Test names are descriptive

---

## SESSION 3: New Tests - Complex Commands

**Branch**: `test/complex-commands`
**Priority**: P1
**Estimated Time**: 4-6 hours
**Agent**: Senior engineer (complex commands)
**Blocked By**: Session 1 completion

### Objectives
Create comprehensive tests for 15 complex/feature-rich commands

### Command Assignments

#### Group A: File Metadata Commands (2 hours, 60-80 tests total)

1. **stat** (NEW)
   - GNU ref: Display file/filesystem status
   - Tests: basic info, -f (filesystem), -c (format), -L (follow symlinks)
   - Edge: special files (/dev/null), symlinks, nonexistent, format strings
   - **Complexity**: Format string parser, multiple info types

2. **du** (ALREADY HAS TESTS - enhance)
   - Current: 6 tests
   - Add: -a (all files), -d DEPTH, -h (human), -s (summary), --apparent-size
   - Edge: symlinks, hard links (don't double count), permission denied
   - **Complexity**: Recursive traversal, size calculation modes

3. **df** (NEW)
   - GNU ref: Report filesystem disk space
   - Tests: default output, -h (human), -i (inodes), -T (type), -a (all)
   - Edge: multiple filesystems, special filesystems (/proc, /dev)
   - **Complexity**: Parse /proc/mounts, calculate percentages

#### Group B: Checksum Commands (1.5 hours, 40-50 tests total)

4. **cksum** (NEW)
   - POSIX ref: CRC checksum
   - Tests: basic file, stdin, multiple files, -c (check mode)
   - Edge: binary files, empty files, large files
   - **Complexity**: CRC32 algorithm, check mode parsing

5. **sha256sum** (NEW)
   - GNU ref: SHA-256 checksums
   - Tests: file, stdin, -c (check), -b (binary), multiple files, --check format
   - Edge: Unicode filenames, very large files, malformed check files
   - **Complexity**: Parsing check format, binary vs text mode

6. **sha512sum** (NEW)
   - Same as sha256sum but SHA-512
   - **Complexity**: Same as sha256sum

#### Group C: File Modification Commands (1.5 hours, 40-50 tests total)

7. **chmod** (NEW)
   - POSIX ref: Change file mode
   - Tests: numeric (755), symbolic (u+x), -R (recursive), --reference
   - Edge: setuid/setgid, sticky bit, invalid modes, symlinks
   - **Complexity**: Mode string parser, recursive directory walk

8. **chown** (NEW)
   - POSIX ref: Change file owner
   - Tests: user, user:group, :group, -R, -h (no deref symlinks), --reference
   - Edge: invalid user/group, numeric IDs, symlinks
   - **Complexity**: User/group name resolution, recursive

9. **chgrp** (NEW)
   - POSIX ref: Change group ownership
   - Tests: basic group change, -R, -h, --reference
   - Edge: invalid group, numeric GID, symlinks
   - **Complexity**: Similar to chown but simpler

#### Group D: Advanced Text/Data Commands (1.5 hours, 40-50 tests total)

10. **shuf** (NEW)
    - GNU ref: Shuffle lines
    - Tests: basic shuffle, -n (count), -e (args as input), -i (range), --random-source
    - Edge: empty input, single line, very large files, reproducibility
    - **Complexity**: Random number generation, sampling algorithms

11. **tac** (NEW)
    - GNU ref: Reverse cat (line by line)
    - Tests: basic reverse, multiple files, stdin, -s (separator)
    - Edge: no trailing newline, custom separators, very long lines
    - **Complexity**: Reading file backwards efficiently

12. **rev** (ALREADY HAS TESTS - verify quality)
    - Current: 5 tests (may have placeholders)
    - Enhance: Unicode handling, empty lines, very long lines
    - **Complexity**: Character reversal (grapheme clusters for Unicode)

13. **expand** (ALREADY HAS TESTS - verify quality)
    - Current: 3 tests (may have placeholders)
    - Enhance: -t (tab stops), multiple tab stops, -i (initial tabs only)
    - **Complexity**: Tab stop calculation

14. **hexdump** (ALREADY HAS TESTS - enhance)
    - Current: 1 test (minimal)
    - Add: -C (canonical), -n LENGTH, -s OFFSET, -e FORMAT
    - Edge: binary data, non-printable chars, large files
    - **Complexity**: Format strings, byte grouping

#### Group E: Temp File & Miscellaneous (30 min, 10-15 tests)

15. **mktemp** (NEW)
    - GNU ref: Create temporary file/directory
    - Tests: basic file, -d (directory), -u (dry-run), template with XXXXXX, -p (tmpdir)
    - Edge: permissions (600), name uniqueness, insufficient X's (error)
    - **Complexity**: Secure random name generation

### High-Priority Commands (Focus Here First)

**Tier 1**: stat, chmod, chown, sha256sum (most commonly used)
**Tier 2**: df, du, cksum, chgrp, shuf
**Tier 3**: tac, rev, expand, hexdump, mktemp

### Deep Dive Example: `stat` Command

```swift
// IMPLEMENTATION NOTES:
// - Reference: GNU coreutils stat
// - BusyBox: Limited format support
// - GNU: Rich format strings, filesystem info
// - Target: P0 (basic info) + P1 (common formats)
//
// Format specifiers to support:
//   %a - Access rights in octal
//   %A - Access rights in human readable form
//   %F - File type
//   %n - File name
//   %s - Total size in bytes
//   %U - User name
//   %G - Group name
//   ... (many more)

final class StatTests: XCTestCase {

    func testBasicFileInfo() {
        // Default output format
    }

    func testFormatStringNumericPermissions() {
        // stat -c "%a" file
    }

    func testFormatStringHumanPermissions() {
        // stat -c "%A" file
    }

    func testFormatStringFileSize() {
        // stat -c "%s" file
    }

    func testFormatStringOwnership() {
        // stat -c "%U:%G" file
    }

    func testFormatStringFileType() {
        // stat -c "%F" file
        // regular file, directory, symbolic link, etc.
    }

    func testFilesystemInfo() {
        // stat -f /
    }

    func testFollowSymlinks() {
        // stat -L symlink (show target info)
    }

    func testSymlinkInfo() {
        // stat symlink (show link info, not target)
    }

    func testSpecialFiles() {
        // stat /dev/null, /dev/zero
    }

    func testNonexistentFile() {
        // Should fail with error
    }

    func testPermissionDenied() {
        // Create unreadable file, stat it
    }
}
```

### Deliverables
- 15 test files (mix of new and enhanced)
- 200+ test cases total
- Comprehensive format string testing for stat
- Permission/ownership test coverage
- Checksum validation tests

### Quality Checklist
- [ ] Format string parsers tested thoroughly (stat, hexdump)
- [ ] Permission/ownership changes verified (chmod, chown, chgrp)
- [ ] Checksum algorithms tested with known values
- [ ] Edge cases for recursive operations
- [ ] Error handling for invalid inputs

---

## SESSION 4: Fix Failing Tests

**Branch**: `test/fix-failures`
**Priority**: P1
**Estimated Time**: 3-5 hours (depends on baseline)
**Agent**: Senior engineer (debugging skills required)
**Blocked By**: Session 1 completion (needs baseline)

### Objectives
Fix all failing tests from baseline run, prioritizing by command importance

### Process

#### Step 1: Analyze Baseline (30 min)
```bash
# Get Session 1's results
cat baseline-analysis.md
cat TEST_FAILURE_TRACKER.md

# Categorize failures:
# - Implementation bugs (command is wrong)
# - Test bugs (test expectations are wrong)
# - Environment issues (filesystem, permissions)
# - Incomplete implementations (missing features)
```

#### Step 2: Prioritize Failures (15 min)

**Priority Matrix:**
```
P0 (Fix First):
- NOFORK commands (44 total) - highest performance value
- Commands with >50% failure rate
- Core commands (echo, cat, ls, cp, mv)

P1 (Fix Second):
- NOEXEC commands (30 total)
- Commands with <50% failure rate
- Commonly used utilities

P2 (Fix If Time):
- Advanced features
- Placeholder cleanup
- Optional enhancements
```

#### Step 3: Fix Failures (2-4 hours)

**For Each Failing Test:**

1. **Reproduce locally**
   ```bash
   swift test --filter <CommandTests>/<testName>
   ```

2. **Debug**
   ```swift
   // Add debug output
   print("Expected: \(expected)")
   print("Actual: \(actual)")
   print("Command: \(args)")
   ```

3. **Identify Root Cause**
   - Is implementation wrong?
   - Is test expectation wrong?
   - Is it an environment issue?

4. **Fix**
   - If implementation: Fix in `Sources/SwiftyBox/Commands/`
   - If test: Fix in `Tests/SwiftyBoxTests/Consolidated/`
   - Document the fix

5. **Verify**
   ```bash
   # Test passes
   swift test --filter <test>

   # Regression check
   swift test --filter <CommandTests>
   ```

6. **Update Tracker**
   - Mark as fixed in TEST_FAILURE_TRACKER.md

#### Step 4: Cleanup Placeholders (1-2 hours)

**Files with Placeholders** (21 total, from Session 1 findings):
- ExpandTests.swift
- FoldTests.swift
- GrepTests.swift
- HeadTests.swift
- NlTests.swift
- PrintfTests.swift
- RevTests.swift
- SeqTests.swift
- TestTests.swift
- UniqTests.swift
- (+ 11 more unimplemented commands)

**For Each:**
1. Identify placeholder code
2. Replace with real test data
3. Add more test cases if needed
4. Verify tests pass

**Example Placeholder Fix:**
```swift
// BEFORE (placeholder):
func testBasicGrep() {
    // TODO: implement grep test
    XCTAssertTrue(true) // placeholder
}

// AFTER (real test):
func testBasicGrep() {
    let input = "foo\nbar\nbaz\n"
    let result = runCommandWithInput(["grep", "bar"], input: input)
    XCTAssertEqual(result.exitCode, 0)
    XCTAssertEqual(result.stdout, "bar\n")
    XCTAssertEqual(result.stderr, "")
}
```

### Common Failure Patterns

#### Pattern 1: Path Assumptions
```swift
// WRONG: Assumes specific path
let result = runCommand(["ls", "/tmp/myfile"])

// RIGHT: Create temp file
let tmpFile = createTempFile()
defer { try? FileManager.default.removeItem(atPath: tmpFile) }
let result = runCommand(["ls", tmpFile])
```

#### Pattern 2: Timing Issues
```swift
// WRONG: Exact timing expectations
let result = runCommand(["sleep", "1"])
XCTAssertEqual(duration, 1.0) // Flaky!

// RIGHT: Allow variance
XCTAssertGreaterThan(duration, 0.9)
XCTAssertLessThan(duration, 1.1)
```

#### Pattern 3: Environment Dependencies
```swift
// WRONG: Assumes environment variable
let result = runCommand(["env"])
XCTAssertTrue(result.stdout.contains("HOME=")) // May not be set!

// RIGHT: Set explicitly
setenv("TEST_VAR", "value", 1)
let result = runCommand(["env"])
XCTAssertTrue(result.stdout.contains("TEST_VAR=value"))
```

### Deliverables
- All P0 failures fixed (NOFORK + core commands)
- Most P1 failures fixed (NOEXEC commands)
- Placeholder tests replaced with real tests
- Updated TEST_FAILURE_TRACKER.md with final status
- Document unfixable issues (if any) with explanations

### Success Criteria
- ≥90% test pass rate
- All NOFORK commands at 100% pass rate
- All core commands (echo, cat, ls, cp, mv, grep, sort) at 100%
- No test compilation warnings

---

## Cross-Session Coordination

### Communication Protocol

**Session 1 → All Others:**
```markdown
# Session 1 Complete Notification

**Status**: ✅ UNBLOCKED - Sessions 2-4 may proceed

**Results**:
- Tests compiling: YES
- Total tests run: 431
- Pass rate: 68% (293 passing, 138 failing)
- Top failures: grep (8/10 failing), test (11/13 failing)

**Files**:
- `baseline-results.txt` - full output
- `baseline-analysis.md` - analyzed results
- `TEST_FAILURE_TRACKER.md` - updated with actual data

**Notes**:
- Session 4: Focus on grep and test commands (highest failure rate)
- Sessions 2-3: Proceed with new tests as planned
```

### Branch Strategy

```bash
# Session 1
git checkout -b test/compilation-fixes
# ... work ...
git commit -m "fix: Resolve test compilation errors

- Fixed tuple comparison issues in ExprTests
- Updated IdTests to use CommandResult
- All 431 tests now compile successfully"
git push origin test/compilation-fixes

# Create PR, merge to main ASAP (unblocks others)

# Session 2
git checkout main
git pull
git checkout -b test/simple-commands
# ... work ...
git commit -m "test: Add comprehensive tests for 15 simple commands

- Added tests for yes, arch, clear, sync, link, unlink
- Added tests for whoami, logname, tty, nproc, uname, printenv
- Added tests for fsync, truncate, sleep, usleep, pwdx
- Total: 100+ new test cases

All tests follow TEST_DEVELOPMENT_STRATEGY.md guidelines"
git push origin test/simple-commands

# Session 3
git checkout main
git pull
git checkout -b test/complex-commands
# ... similar ...

# Session 4
git checkout main
git pull
git checkout -b test/fix-failures
# ... similar ...
```

### Merge Order

1. **Session 1** → main (CRITICAL PATH)
2. **Session 2** → main (no conflicts expected)
3. **Session 3** → main (no conflicts expected)
4. **Session 4** → main (may conflict with 2/3, but implementation fixes take precedence)

### Conflict Resolution

**If Sessions 2/3/4 conflict:**
- Implementation changes (Session 4) take precedence
- New tests (Sessions 2/3) rebase on top
- Run full test suite before final merge

---

## Success Metrics

### Per-Session Metrics

**Session 1:**
- ✅ 0 compilation errors
- ✅ Baseline established
- ✅ Unblocked other sessions within 1 hour

**Session 2:**
- ✅ 15 commands have tests
- ✅ 100+ new test cases
- ✅ All tests documented with implementation notes
- ✅ 80%+ pass rate on new tests

**Session 3:**
- ✅ 15 commands have comprehensive tests
- ✅ 200+ new test cases
- ✅ Complex features tested (format strings, recursion, checksums)
- ✅ 80%+ pass rate on new tests

**Session 4:**
- ✅ 90%+ overall test pass rate
- ✅ 100% pass rate on NOFORK commands
- ✅ 100% pass rate on core commands
- ✅ All placeholders removed

### Overall Project Metrics

**Before:**
- 43/73 commands with tests (59%)
- 431 test cases
- 0% tests passing (compilation blocked)

**After:**
- 73/73 commands with tests (100%)
- 700+ test cases
- 90%+ tests passing
- 0 placeholders
- 100% documented with implementation notes

---

## Agent Instructions Summary

### For Session 1 Agent:
```bash
cd /var/home/hh/w/swift/swiftybox
git checkout -b test/compilation-fixes

# Read these first:
cat TEST_STATUS.md                    # Has automated fix script
cat TEST_FAILURE_TRACKER.md          # Template to fill out

# Your mission:
1. Fix compilation errors (30-60 min)
2. Run: ./run-tests.sh > baseline-results.txt
3. Analyze and document results
4. Commit and notify other sessions
```

### For Session 2 Agent:
```bash
cd /var/home/hh/w/swift/swiftybox
git checkout -b test/simple-commands

# Read these first:
cat TEST_DEVELOPMENT_STRATEGY.md     # Your testing bible
cat PARALLEL_SESSION_PLAN.md         # Your specific assignments (Session 2)

# Your mission:
1. Wait for Session 1 to complete
2. Create tests for 15 simple commands
3. Follow test strategy guidelines
4. Aim for 100+ new test cases
```

### For Session 3 Agent:
```bash
cd /var/home/hh/w/swift/swiftybox
git checkout -b test/complex-commands

# Read these first:
cat TEST_DEVELOPMENT_STRATEGY.md     # Your testing bible
cat PARALLEL_SESSION_PLAN.md         # Your specific assignments (Session 3)

# Your mission:
1. Wait for Session 1 to complete
2. Create comprehensive tests for 15 complex commands
3. Focus on stat, chmod, chown, sha256sum first
4. Aim for 200+ new test cases
```

### For Session 4 Agent:
```bash
cd /var/home/hh/w/swift/swiftybox
git checkout -b test/fix-failures

# Read these first:
cat baseline-results.txt              # From Session 1
cat baseline-analysis.md              # From Session 1
cat TEST_FAILURE_TRACKER.md          # From Session 1

# Your mission:
1. Wait for Session 1 to complete
2. Fix failing tests in priority order (NOFORK first)
3. Clean up 21 placeholder tests
4. Get to 90%+ pass rate
```

---

## Timeline Gantt Chart

```
Hour 0 ├─────────────────────────────────────────┐
       │ Session 1: Fix Compilation              │
Hour 1 ├─────────────────────────────────────────┤
       │         BLOCKER - MUST COMPLETE         │
       ├─────────────────────────────────────────┤
       │ ✅ UNBLOCK                              │
       ├─────────┬───────────────┬───────────────┤
       │ Sess 2: │ Session 3:    │ Session 4:    │
Hour 2 │ Simple  │ Complex       │ Fix Failures  │
       │ Tests   │ Tests         │               │
Hour 3 │         │               │               │
       │         │               │               │
Hour 4 │         │               │               │
       ├─────────┤               │               │
Hour 5 │ ✅ Done │               │               │
       │         ├───────────────┤               │
Hour 6 │         │ ✅ Done       │               │
       │         │               ├───────────────┤
Hour 7 │         │               │ ✅ Done       │
       └─────────┴───────────────┴───────────────┘
```

**Critical Path**: Session 1 (1 hour) → Session 4 (3-5 hours) = **4-6 hours total**

**Parallel Efficiency**: Sessions 2-4 run concurrently after Session 1 completes

---

## Risk Mitigation

### Risk 1: Session 1 Takes Too Long
**Impact**: Blocks all other sessions
**Mitigation**:
- Use automated fix script in TEST_STATUS.md
- Assign most experienced engineer
- If >2 hours, escalate and reassign

### Risk 2: Test Failures Higher Than Expected
**Impact**: Session 4 takes much longer
**Mitigation**:
- Session 4 focuses on P0 only (NOFORK + core)
- Create follow-up issues for P1/P2 failures
- Accept 80% pass rate if needed

### Risk 3: Merge Conflicts
**Impact**: Delays integration
**Mitigation**:
- Clear boundaries between sessions (different commands)
- Session 1 merges first (establishes baseline)
- Sessions 2-3 unlikely to conflict (different files)
- Session 4 rebases on others if needed

### Risk 4: Implementation Gaps Discovered
**Impact**: Tests can't pass without major refactoring
**Mitigation**:
- Mark tests as @available (*, deprecated, message: "Requires implementation")
- Create issues for missing features
- Focus on what can be fixed in timeframe

---

## Final Checklist

**Before Starting:**
- [ ] All 4 agents have read TEST_DEVELOPMENT_STRATEGY.md
- [ ] All agents have read PARALLEL_SESSION_PLAN.md
- [ ] Git branches created
- [ ] Communication channel established

**Session 1 Complete When:**
- [ ] All tests compile (`swift build` succeeds)
- [ ] Baseline test run complete
- [ ] baseline-results.txt exists
- [ ] baseline-analysis.md created
- [ ] TEST_FAILURE_TRACKER.md updated
- [ ] Committed to test/compilation-fixes branch
- [ ] Other sessions notified

**Session 2 Complete When:**
- [ ] 15 commands have tests
- [ ] 100+ new test cases written
- [ ] All test files have implementation notes
- [ ] Tests pass at ≥80% rate
- [ ] Committed to test/simple-commands branch

**Session 3 Complete When:**
- [ ] 15 commands have comprehensive tests
- [ ] 200+ new test cases written
- [ ] Complex features tested thoroughly
- [ ] Tests pass at ≥80% rate
- [ ] Committed to test/complex-commands branch

**Session 4 Complete When:**
- [ ] Overall pass rate ≥90%
- [ ] NOFORK commands at 100%
- [ ] Core commands at 100%
- [ ] Placeholders removed
- [ ] TEST_FAILURE_TRACKER.md updated with final status
- [ ] Committed to test/fix-failures branch

**All Sessions Complete When:**
- [ ] All 4 branches merged to main
- [ ] Final test run shows ≥90% pass rate
- [ ] No compilation warnings
- [ ] Documentation updated (PROGRESS.md, README.md)

---

## Post-Completion

### Documentation Updates
1. Update PROGRESS.md with new test coverage stats
2. Update README.md with testing instructions
3. Create TESTING.md guide for future contributors

### Celebration Metrics 🎉
```
Before:  43/73 commands tested (59%), 431 tests, 0% passing
After:   73/73 commands tested (100%), 700+ tests, 90%+ passing
Improvement: +30 commands, +269 tests, +90% pass rate

Achievement unlocked: Comprehensive test coverage! 🏆
```

### Next Steps
1. Set up CI/CD to run tests automatically
2. Add test coverage reporting
3. Create test writing guide for new commands
4. Consider property-based testing for complex commands

---

## Questions?

If stuck, refer to:
1. **TEST_DEVELOPMENT_STRATEGY.md** - How to write great tests
2. **TEST_STATUS.md** - Current status and fix scripts
3. **Existing test files** - Learn from good examples (ExprTests.swift, SortTests.swift)
4. **GNU test suites** - https://git.savannah.gnu.org/cgit/coreutils.git/tree/tests

Good luck! Let's make SwiftyλBox have best-in-class test coverage! 🚀
