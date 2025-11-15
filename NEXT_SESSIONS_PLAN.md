# SwiftyλBox - Next Parallel Sessions Plan

**Date**: 2025-11-14
**Current Status**: 1,004 tests, 678 passing (67.5%), 326 failing (32.5%)
**Goal**: Reach 90%+ pass rate (900+ passing tests)

---

## Current Situation Analysis

### What's Working ✅
- **44 commands** with tests passing completely or mostly passing
- Solid test infrastructure in place
- 1,004 comprehensive tests with GNU/BSD research
- All parallel session workflows proven successful

### What Needs Work ⚠️
- **326 failing tests** (32.5% failure rate)
- Many failures are **implementation gaps**, not bad tests
- Some commands not implemented at all
- Some commands partially implemented

---

## Failure Analysis by Category

### Category 1: Not Implemented (Command Returns 127)
**Impact**: ~50-60 failing tests
**Priority**: P1 (Medium - nice to have but not critical)

Commands:
- factor, gunzip, gzip, hostname, od, patch, pidof
- printf, sha1sum, strings, sum, tree, uncompress, wget, xargs, xxd
- find (partial), tar (partial)

**Strategy**: Document as "future work" OR implement basic versions

### Category 2: Implemented But Broken (Most/All Tests Fail)
**Impact**: ~100-120 failing tests
**Priority**: P0 (Critical - we have the code, just needs fixes)

Commands with ALL tests failing:
- comm (9 tests) - Implementation exists but broken
- expand (3 tests) - Tab expansion issues
- fold (5 tests) - Line folding issues
- grep (10 tests) - Basic functionality broken
- head (4 tests) - Output issues
- hexdump (1 test) - Not working
- nl (4 tests was passing, now check) - Line numbering
- paste (5 tests) - Column pasting issues
- rev (5 tests) - Character reversal issues
- tac (tests added in Session 3, now failing)
- test/[ (13 tests) - Shell test command broken

**Strategy**: Fix implementations - highest ROI!

### Category 3: Partially Working (50%+ Tests Fail)
**Impact**: ~80-100 failing tests
**Priority**: P0-P1 (Fix the basics, enhance later)

Commands:
- cp (5/17 failing) - Missing features
- cut (4/5 failing) - Field cutting issues
- du (tests added, some fail) - Disk usage calculation
- ls (tests failing) - Listing issues
- md5sum (4/6 failing) - Checksum issues
- mv (3/14 failing) - Move operations
- sed (6/10 failing) - Stream editing
- seq (20/23 failing) - Sequence generation
- sha256sum, sha512sum (Session 3, some fail) - Checksum issues
- sort (8/17 failing) - Sorting edge cases
- tr (tests failing) - Character translation
- unexpand (10/11 failing) - Tab compression
- uniq (6/7 failing) - Duplicate detection
- which, rmdir, touch (minor issues)

**Strategy**: Fix core functionality first, then edge cases

### Category 4: Minor Issues (1-3 Tests Fail)
**Impact**: ~40-60 failing tests
**Priority**: P2 (Polish - do after P0/P1)

Commands:
- cmp, date, dd, fileops, gzip, link, mv, nproc, sleep, etc.
- Most Session 2/3 commands with 1-2 failures
- Usually edge cases or advanced features

**Strategy**: Fix during polish phase

---

## Recommended Next Session Strategy

### **Option A: Implementation-Focused (Recommended)**
**Goal**: Fix broken implementations to maximize pass rate quickly
**Expected Gain**: +15-20 percentage points (to 82-87% pass rate)

**3 Parallel Sessions**:

#### Session 5: Fix Critical Broken Commands
- **Focus**: Commands with code but ALL tests fail
- **Commands**: comm, grep, head, expand, fold, paste, rev, tac, test/[
- **Approach**: Debug and fix existing implementations
- **Expected**: Fix ~60-80 tests

#### Session 6: Fix Partially Broken Commands
- **Focus**: Commands that work but have many failures
- **Commands**: cut, seq, uniq, unexpand, tr, nl
- **Approach**: Fix core bugs, then edge cases
- **Expected**: Fix ~40-60 tests

#### Session 7: Implement Missing NOFORK Commands
- **Focus**: Simple commands that should exist (highest performance value)
- **Commands**: Implement basic versions of high-priority missing commands
- **Candidates**: hostname, printf, factor (if simple)
- **Approach**: TDD - tests exist, write implementations
- **Expected**: +20-30 passing tests

### **Option B: Mixed Approach**
**Goal**: Balance fixes and new features
**Expected Gain**: +12-15 percentage points

**3 Parallel Sessions**:

#### Session 5: Fix Top 10 Broken Commands
- grep, comm, head, test, seq, uniq, cut, nl, fold, paste

#### Session 6: Polish Session 2/3 Commands
- Fix 1-3 test failures in Session 2/3 commands
- sleep, nproc, link, yes, etc.
- **Expected**: +30-40 tests

#### Session 7: Checksum & Hash Commands
- Fix md5sum, sha256sum, sha512sum
- Implement sha1sum, sum
- **Expected**: +15-20 tests

---

## Detailed Session 5-7 Breakdown (Option A)

### SESSION 5: Fix Critical Broken Commands
**Branch**: `fix/critical-broken-commands`
**Duration**: 4-6 hours
**Priority**: P0

#### Commands to Fix (9 commands, ~70 failing tests):

**1. grep (10 tests failing)** - P0
- Issue: Basic pattern matching not working
- Fix: Implement basic regex matching
- Tests exist with clear expectations

**2. comm (9 tests failing)** - P0
- Issue: Column comparison broken (Session 4 partially fixed)
- Fix: Debug line-by-line comparison logic
- Implementation exists in Sources/swiftybox/Comm.swift

**3. test/[ (13 tests failing)** - P0
- Issue: Shell test operators not working
- Fix: Implement -f, -d, -e, -z, -n, etc.
- Critical for shell scripts!

**4. head (4 tests failing)** - P0
- Issue: Line/byte counting broken
- Fix: Fix -n and -c options
- Simple implementation needed

**5. seq (20/23 tests failing)** - P0
- Issue: Number sequence generation broken
- Fix: Handle start, step, end properly
- Tests are comprehensive

**6. expand (3 tests failing)** - P1
- Issue: Tab-to-space conversion
- Fix: Implement tab stop logic

**7. fold (5 tests failing)** - P1
- Issue: Line wrapping broken
- Fix: Implement width-based wrapping

**8. paste (5 tests failing)** - P1
- Issue: Column merging not working
- Fix: Implement parallel file reading

**9. rev (5 tests failing)** - P1
- Issue: Character reversal (Session 3 added tests)
- Fix: Fix Unicode-aware reversal

**10. tac (tests added Session 3, now failing)** - P1
- Issue: Reverse cat not working
- Fix: Read file backwards line-by-line

### SESSION 6: Fix Partially Broken Commands
**Branch**: `fix/partial-broken-commands`
**Duration**: 4-6 hours
**Priority**: P0-P1

#### Commands to Fix (6 commands, ~50 failing tests):

**1. uniq (6/7 tests failing)** - P0
- Issue: Duplicate detection broken
- Fix: Adjacent line comparison
- Session 4 enhanced tests

**2. cut (4/5 tests failing)** - P0
- Issue: Field extraction broken
- Fix: Implement -f, -d, -c properly

**3. unexpand (10/11 tests failing)** - P0
- Issue: Space-to-tab conversion
- Fix: Inverse of expand

**4. tr (tests failing)** - P0
- Issue: Character translation
- Fix: Implement SET1 → SET2 mapping

**5. nl (4 tests, was passing?)** - P1
- Check current status
- Fix if needed

**6. cp, mv edge cases** - P1
- Fix remaining 3-5 failures each
- Mostly permission/symlink edge cases

### SESSION 7: Implement Missing Commands (TDD)
**Branch**: `implement/missing-nofork`
**Duration**: 3-5 hours
**Priority**: P1

#### Commands to Implement:

**1. hostname** - NOFORK
- Tests exist (6 tests, all failing)
- Simple: read/write /etc/hostname or gethostname()
- **Impact**: +6 tests

**2. printf** - NOFORK
- Tests exist (1 test)
- Implement basic printf format strings
- **Impact**: +1 test (but important command!)

**3. factor** - If simple
- Tests exist (12 tests)
- Prime factorization
- **Impact**: +12 tests if implemented

**4. Basic ls fixes** - NOEXEC
- Tests failing
- Fix most common issues
- **Impact**: +5-6 tests

**5. Checksum commands** - NOEXEC
- md5sum fixes (4/6 failing)
- sha256sum fixes (Session 3, some fail)
- sha512sum fixes (Session 3, some fail)
- **Impact**: +10-15 tests

---

## Alternative: Option B Breakdown

### SESSION 5: Fix Top 10 Most-Broken
1. grep (10 tests)
2. seq (20 tests)
3. test (13 tests)
4. comm (9 tests)
5. uniq (6 tests)
6. fold (5 tests)
7. paste (5 tests)
8. rev (5 tests)
9. cut (4 tests)
10. head (4 tests)

**Total**: ~81 tests, biggest impact

### SESSION 6: Polish Session 2/3 Commands
- Fix 1-2 test failures in each Session 2/3 command
- sleep, yes, nproc, link, env, free, etc.
- **Target**: 20 commands × 1-2 fixes = +25-35 tests

### SESSION 7: Checksum & Utility Commands
- md5sum, sha256sum, sha512sum fixes
- Implement hostname, printf
- ls improvements
- **Target**: +20-30 tests

---

## Success Metrics

### Current State
- 1,004 tests total
- 678 passing (67.5%)
- 326 failing (32.5%)

### After Sessions 5-7 (Option A Target)
- 1,004 tests total
- **850-870 passing (85-87%)**
- 134-154 failing (13-15%)

### After Sessions 5-7 (Option B Target)
- 1,004 tests total
- **800-830 passing (80-83%)**
- 174-204 failing (17-20%)

### Stretch Goal
- **900+ passing (90%+)**
- Would require Session 8-9 for polish

---

## Recommended Approach: **Option A**

**Why Option A**:
1. **Highest ROI**: Fixing broken implementations gives most value
2. **Leverages existing work**: Tests already written, just need fixes
3. **Clear goals**: Each command has specific failing tests to target
4. **Achievable**: 85-87% pass rate is realistic
5. **Foundation for 90%**: Gets us close to stretch goal

**Why Not Option B**:
- Fixing 1-2 test failures is tedious
- Lower overall impact
- Harder to parallelize effectively

---

## Session 5-7 Quick Start Commands

### Prepare Worktrees
```bash
cd /var/home/hh/w/swift/swiftybox
git worktree add ../swiftybox-worktrees/session5-fix-critical fix/critical-broken-commands
git worktree add ../swiftybox-worktrees/session6-fix-partial fix/partial-broken-commands
git worktree add ../swiftybox-worktrees/session7-implement-missing implement/missing-nofork
```

### Session 5 Prompt
```
I'm working on Session 5: Fix Critical Broken Commands.

Current status: 1,004 tests, 678 passing (67.5%), 326 failing.

My task: Fix 10 commands that have implementations but ALL/MOST tests fail:
- grep (10 tests) - pattern matching broken
- comm (9 tests) - column comparison issues
- test/[ (13 tests) - shell test operators
- head (4 tests) - line/byte counting
- seq (20 tests) - number sequences
- expand (3 tests) - tab expansion
- fold (5 tests) - line folding
- paste (5 tests) - column merging
- rev (5 tests) - character reversal
- tac (tests failing) - reverse cat

Debug each implementation, fix the bugs, verify all tests pass.
Target: Fix ~70 failing tests, reach ~75% pass rate.

Focus on grep, comm, test, head, seq first (highest impact).
```

### Session 6 Prompt
```
I'm working on Session 6: Fix Partially Broken Commands.

Current status: 1,004 tests, 678 passing (67.5%), 326 failing.

My task: Fix 6 commands that work partially but have many failures:
- uniq (6/7 failing) - duplicate detection
- cut (4/5 failing) - field extraction
- unexpand (10/11 failing) - space-to-tab
- tr (tests failing) - character translation
- cp, mv (3-5 failures each) - edge cases

Fix core bugs first, then edge cases.
Target: Fix ~50 failing tests, contribute to 80%+ pass rate.
```

### Session 7 Prompt
```
I'm working on Session 7: Implement Missing NOFORK Commands.

Current status: 1,004 tests, 678 passing (67.5%), 326 failing.

My task: Implement simple commands that are missing but have tests:
- hostname (6 tests) - read/write hostname
- printf (1 test) - format string output
- factor (12 tests) - prime factorization (if feasible)
- ls (fixes) - basic listing improvements
- Checksums (md5sum, sha256sum, sha512sum fixes)

Use TDD - tests exist, implement to make them pass.
Target: +20-30 passing tests.
```

---

## Timeline

**Parallel Execution** (Sessions 5-7 simultaneously):
- Session 5: 4-6 hours
- Session 6: 4-6 hours
- Session 7: 3-5 hours

**Total Time**: ~4-6 hours (parallel) or ~11-17 hours (sequential)

**Expected Completion**: Same day if started fresh

---

## After Sessions 5-7: Next Steps

### If 85%+ Pass Rate Achieved ✅
**Session 8-9**: Polish to 90%+
- Fix remaining edge cases
- Implement missing nice-to-have commands
- Performance optimizations

### If 80-85% Pass Rate
**Session 8**: Continue fixes
- Focus on remaining broken commands
- More implementation work needed

### If <80% Pass Rate
- Re-assess strategy
- May need more fundamental fixes

---

## Risk Mitigation

### Risk: Commands Too Broken to Fix Quickly
**Mitigation**:
- Prioritize P0 commands first
- Document remaining issues
- Acceptable to skip some P1 commands

### Risk: Session Conflicts
**Mitigation**:
- Clear boundaries (different commands)
- Unlikely conflicts with Option A

### Risk: Test Failures After "Fix"
**Mitigation**:
- Run tests frequently during development
- Each session includes verification

---

## Decision Time

**Recommended**: **Option A** - Implementation-Focused

**Next Actions**:
1. Create 3 worktrees for Sessions 5-7
2. Launch 3 parallel sessions
3. Target: 85-87% pass rate (850-870 passing tests)

**Alternative**: **Option B** - Mixed Approach (if you prefer balanced work)

---

Which option do you prefer? Or would you like a custom session plan?
