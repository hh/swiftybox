# Sessions 5-7: Optimized for Speed & Moderate Risk

**Strategy**: Quick wins, proven parallel approach, moderate risk
**Goal**: 80-85% pass rate (800-850 passing tests)
**Timeline**: 4-6 hours parallel execution

---

## 🎯 Optimized Session Breakdown

### **Session 5: Easy Wins - Simple Broken Commands**
**Branch**: `fix/easy-wins`
**Duration**: 3-4 hours
**Risk**: LOW
**Expected Gain**: +50-60 tests

#### Strategy: Fix commands with clear, simple issues

**Commands** (ordered by ease + impact):

1. **head (4 tests)** - ⭐ EASIEST
   - Issue: Line/byte counting off
   - Fix: Simple -n NUM and -c NUM logic
   - Risk: Very low
   - Time: 20 min

2. **seq (20 tests)** - ⭐ HIGH IMPACT
   - Issue: Number sequence generation
   - Fix: Handle START [INCREMENT] END
   - Risk: Low (arithmetic only)
   - Time: 45 min

3. **expand (3 tests)** - ⭐ EASY
   - Issue: Tab-to-space conversion
   - Fix: Tab stop calculation (8-space default)
   - Risk: Low
   - Time: 30 min

4. **fold (5 tests)** - ⭐ EASY
   - Issue: Line wrapping at width
   - Fix: Break lines at N chars
   - Risk: Low
   - Time: 30 min

5. **rev (5 tests)** - ⭐ EASY
   - Issue: Character reversal
   - Fix: Reverse each line (String.reversed())
   - Risk: Low (Unicode already handled by Swift)
   - Time: 20 min

6. **tac (tests added Session 3)** - ⭐ MODERATE
   - Issue: Reverse cat (output lines backwards)
   - Fix: Read lines into array, reverse, print
   - Risk: Low-Medium (memory for large files)
   - Time: 30 min

7. **paste (5 tests)** - MODERATE
   - Issue: Merge lines from files side-by-side
   - Fix: Read files in parallel, join with delimiter
   - Risk: Medium (multiple file handles)
   - Time: 45 min

8. **uniq (6/7 tests failing)** - ⭐ HIGH VALUE
   - Issue: Duplicate line detection broken
   - Fix: Compare adjacent lines, track counts
   - Risk: Low (Session 4 already improved)
   - Time: 45 min

9. **cut (4/5 tests failing)** - MODERATE
   - Issue: Field/character extraction
   - Fix: -f fields, -d delimiter, -c characters
   - Risk: Medium (parsing logic)
   - Time: 60 min

**Total Expected**: ~50-55 tests fixed
**Estimated Time**: 3-4 hours
**Risk Level**: LOW-MEDIUM

---

### **Session 6: Medium Wins - Core Utilities**
**Branch**: `fix/core-utilities`
**Duration**: 4-5 hours
**Risk**: MEDIUM
**Expected Gain**: +40-50 tests

#### Strategy: Fix critical commands, skip if too complex

**Commands** (ordered by impact):

1. **grep (10 tests)** - ⭐ CRITICAL (but risky)
   - Issue: Pattern matching not working
   - Fix: Basic literal matching first, then simple regex
   - Risk: Medium-High (regex complexity)
   - **Bailout clause**: If basic matching works, mark partial success
   - Time: 90 min (with bailout option)

2. **test/[ (13 tests)** - ⭐ CRITICAL + EASY
   - Issue: Shell test operators
   - Fix: Implement -f, -d, -e, -z, -n, -eq, -ne, -lt, -gt
   - Risk: Low (just file/string tests)
   - Time: 60 min

3. **comm (9 tests)** - MODERATE
   - Issue: Line-by-line comparison broken
   - Fix: Compare sorted files, output 3 columns
   - Risk: Medium (Session 4 partially fixed, may need more)
   - Time: 45 min

4. **nl (4 tests)** - EASY (if actually broken)
   - Issue: Line numbering
   - Fix: Add line numbers with format options
   - Risk: Low
   - Time: 30 min

5. **unexpand (10/11 tests)** - MODERATE
   - Issue: Space-to-tab conversion (inverse of expand)
   - Fix: Convert spaces to tabs at tab stops
   - Risk: Medium (edge cases)
   - Time: 45 min

6. **tr (tests failing)** - MODERATE
   - Issue: Character translation
   - Fix: SET1 → SET2 character mapping
   - Risk: Medium (character sets, ranges)
   - Time: 60 min

**Bailout Commands** (skip if time runs out):
- hexdump (complex format strings)
- sed (too complex for quick win)

**Total Expected**: ~40-50 tests fixed
**Estimated Time**: 4-5 hours
**Risk Level**: MEDIUM

---

### **Session 7: Quick Implementations + Polish**
**Branch**: `implement/quick-wins`
**Duration**: 3-4 hours
**Risk**: LOW-MEDIUM
**Expected Gain**: +20-35 tests

#### Strategy: Implement EASY missing commands, fix low-hanging fruit

**Part A: Easy Implementations** (2 hours)

1. **hostname (6 tests)** - ⭐ EASIEST
   - Tests exist, command doesn't
   - Implementation:
     ```swift
     // Read: gethostname() syscall
     // Write: sethostname() syscall or write to /etc/hostname
     ```
   - Risk: Very low (standard syscall)
   - Time: 45 min

2. **printf (1 test)** - MODERATE
   - Tests exist, command doesn't
   - Implementation: Basic format string parser
   - Risk: Medium (format string complexity)
   - **Scope**: Just handle %s, %d, %x, \\n, \\t
   - Time: 60 min

**Part B: Checksum Fixes** (1-1.5 hours)

3. **md5sum (4/6 failing)** - EASY
   - Issue: Format or file reading problems
   - Fix: Correct output format (hash + filename)
   - Risk: Low (crypto already implemented)
   - Time: 30 min

4. **sha256sum (Session 3, some failing)** - EASY
   - Issue: Similar to md5sum
   - Fix: Format consistency, -c (check) mode
   - Risk: Low
   - Time: 30 min

5. **sha512sum (Session 3, some failing)** - EASY
   - Issue: Similar to above
   - Fix: Format consistency
   - Risk: Low
   - Time: 20 min

**Part C: Low-Hanging Fruit** (30-60 min)

6. **Fix 1-3 test failures in Session 2/3 commands**
   - sleep, yes, nproc, link, etc.
   - Pick easiest 5-10 fixes
   - Time: 10-15 min each

**Total Expected**: +20-35 tests
**Estimated Time**: 3-4 hours
**Risk Level**: LOW-MEDIUM

---

## 📊 Expected Outcomes

### Conservative Estimate
```
Current:     678 passing (67.5%)
+Session 5:  +50 tests  → 728 passing (72.5%)
+Session 6:  +40 tests  → 768 passing (76.5%)
+Session 7:  +20 tests  → 788 passing (78.5%)
```

### Optimistic Estimate
```
Current:     678 passing (67.5%)
+Session 5:  +60 tests  → 738 passing (73.5%)
+Session 6:  +50 tests  → 788 passing (78.5%)
+Session 7:  +35 tests  → 823 passing (82.0%)
```

### Target: **78-82% pass rate** (788-823 passing tests)
**Gain**: **+11-15 percentage points**

---

## 🎯 Quick Win Priority Matrix

| Command | Tests | Difficulty | Impact | Priority |
|---------|-------|------------|--------|----------|
| seq | 20 | Easy | High | ⭐⭐⭐ |
| test/[ | 13 | Easy | High | ⭐⭐⭐ |
| grep | 10 | Medium | High | ⭐⭐⭐ |
| unexpand | 10 | Medium | Medium | ⭐⭐ |
| comm | 9 | Medium | Medium | ⭐⭐ |
| uniq | 6 | Easy | Medium | ⭐⭐⭐ |
| hostname | 6 | Easy | Low | ⭐⭐ |
| fold | 5 | Easy | Low | ⭐⭐ |
| rev | 5 | Easy | Low | ⭐⭐ |
| paste | 5 | Medium | Low | ⭐⭐ |
| tac | ? | Easy | Low | ⭐⭐ |
| cut | 4 | Medium | Medium | ⭐⭐ |
| head | 4 | Easy | Medium | ⭐⭐⭐ |
| nl | 4 | Easy | Low | ⭐⭐ |
| md5sum | 4 | Easy | Low | ⭐⭐ |
| expand | 3 | Easy | Low | ⭐⭐ |

---

## ⚠️ Commands We're SKIPPING (Too Risky/Complex)

**Deferred to Later**:
- **factor** (12 tests) - Prime factorization algorithm complex
- **sed** (6/10 failing) - Stream editor too complex for quick win
- **od** (26 tests) - Octal dump, complex formats
- **hexdump** (1 test) - Similar to od
- **patch** (17 tests) - Diff application too complex
- **find** (tests failing) - Directory traversal with complex predicates
- **tar** (partial) - Archive format too complex
- **xargs** - Command building complex

**Why Skip**:
- High complexity
- Low ROI for time invested
- Can tackle in Session 8-9 if desired

---

## 🚀 Launch Instructions

### Step 1: Create Worktrees
```bash
cd /var/home/hh/w/swift/swiftybox
git worktree add ../swiftybox-worktrees/session5-easy-wins fix/easy-wins
git worktree add ../swiftybox-worktrees/session6-core-utils fix/core-utilities
git worktree add ../swiftybox-worktrees/session7-quick-impl implement/quick-wins
```

### Step 2: Launch Sessions

#### Session 5 Prompt (Easy Wins):
```
I'm working on Session 5: Easy Wins - Simple Broken Commands.

Current: 1,004 tests, 678 passing (67.5%)
Goal: Fix simple broken commands for quick wins

Commands to fix (in priority order):
1. head (4 tests) - Line/byte counting [EASIEST - START HERE]
2. seq (20 tests) - Number sequences [HIGH IMPACT]
3. expand (3 tests) - Tab-to-space conversion [EASY]
4. fold (5 tests) - Line wrapping [EASY]
5. rev (5 tests) - Character reversal [EASY]
6. tac (tests) - Reverse cat [MODERATE]
7. paste (5 tests) - Merge files side-by-side [MODERATE]
8. uniq (6/7 failing) - Duplicate detection [HIGH VALUE]
9. cut (4/5 failing) - Field extraction [MODERATE]

Strategy: Start with easiest (head, seq, expand, fold, rev)
Target: Fix ~50-60 tests in 3-4 hours
Risk: LOW - all straightforward fixes
```

#### Session 6 Prompt (Core Utilities):
```
I'm working on Session 6: Core Utilities - Medium Difficulty Fixes.

Current: 1,004 tests, 678 passing (67.5%)
Goal: Fix critical commands with moderate complexity

Commands to fix (in priority order):
1. test/[ (13 tests) - Shell test operators [CRITICAL + EASY]
2. grep (10 tests) - Pattern matching [CRITICAL but MODERATE RISK]
   - Start with literal matching, add simple regex if time permits
   - BAILOUT OK if partial success achieved
3. comm (9 tests) - Line comparison [MODERATE]
4. nl (4 tests) - Line numbering [EASY if broken]
5. unexpand (10/11 failing) - Space-to-tab [MODERATE]
6. tr (failing) - Character translation [MODERATE]

SKIP if too complex: hexdump, sed (save for later)

Strategy: Fix test/[ first (easiest + critical), then grep (partial OK)
Target: Fix ~40-50 tests in 4-5 hours
Risk: MEDIUM - grep has complexity, others manageable
```

#### Session 7 Prompt (Quick Implementations):
```
I'm working on Session 7: Quick Implementations + Polish.

Current: 1,004 tests, 678 passing (67.5%)
Goal: Implement easy missing commands + fix checksum issues

Part A - Implementations:
1. hostname (6 tests) - gethostname/sethostname syscalls [EASIEST]
2. printf (1 test) - Basic format strings (%s, %d, %x, \\n, \\t only)

Part B - Checksum Fixes:
3. md5sum (4/6 failing) - Output format fixes
4. sha256sum (some failing) - Format consistency, -c mode
5. sha512sum (some failing) - Format consistency

Part C - Low-Hanging Fruit:
6. Fix 1-2 test failures in Session 2/3 commands
   - Pick easiest 5-10 fixes from: sleep, yes, nproc, link, env, free

Strategy: hostname first (easiest), then checksums, then printf
Target: +20-35 tests in 3-4 hours
Risk: LOW-MEDIUM - mostly straightforward work
```

---

## ✅ Success Criteria

### Session 5 Success:
- ✅ head, seq, expand, fold, rev all passing
- ✅ 50+ tests fixed
- ✅ Pass rate → 72-74%

### Session 6 Success:
- ✅ test/[ 100% passing (critical!)
- ✅ grep at least 50% working (partial OK)
- ✅ 40+ tests fixed
- ✅ Pass rate → 76-78%

### Session 7 Success:
- ✅ hostname implemented and passing
- ✅ Checksums all passing
- ✅ 20+ tests fixed
- ✅ Pass rate → 78-82%

### Overall Success:
- ✅ **78%+ pass rate** (780+ tests passing)
- ✅ **Critical commands working** (test, grep partial)
- ✅ **Clean foundation** for 85-90% in next round

---

## 📈 Path to 90%

After Sessions 5-7 (78-82%):
- **Session 8**: Fix remaining grep issues, add sed basic support → 85%
- **Session 9**: Polish and edge cases → 90%+

**This plan gets you 80% of the way with minimal risk!**

---

## ⏱️ Timeline

**Parallel Execution**:
- All 3 sessions run simultaneously
- Total wall-clock time: **4-6 hours**
- Can monitor and adjust mid-flight

**Sequential would be**: 10-13 hours

---

Ready to launch with this optimized plan? 🚀
