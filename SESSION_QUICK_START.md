# SwiftyλBox Testing Sessions - Quick Start Cards

**Choose your session below and follow the checklist!**

---

## 🔴 SESSION 1: CRITICAL PATH - Compilation Fixes

**You are the blocker! All other sessions wait for you.**

### ⏱️ Time Budget: 30-60 minutes

### ✅ Quick Start Checklist

```bash
# 1. Setup (2 min)
cd /var/home/hh/w/swift/swiftybox
git checkout -b test/compilation-fixes

# 2. Read context (5 min)
cat TEST_STATUS.md | less              # Has the fix script!
cat TEST_FAILURE_TRACKER.md | less    # Template you'll fill out

# 3. Fix compilation errors (30 min)
# Run the automated fix script from TEST_STATUS.md or fix manually:
#   - Tuple comparisons → CommandResult usage
#   - Missing imports
#   - Type mismatches

# Verify compilation works:
swift build

# 4. Run baseline tests (10 min)
./run-tests.sh 2>&1 | tee baseline-results.txt

# 5. Analyze results (10 min)
python3 scripts/analyze-test-results.py baseline-results.txt > baseline-analysis.md

# 6. Update tracker (5 min)
# Edit TEST_FAILURE_TRACKER.md with actual pass/fail counts

# 7. Commit & notify (5 min)
git add .
git commit -m "fix: Resolve test compilation errors

- Fixed tuple comparison issues
- Updated CommandResult usage
- All 431 tests now compile
- Baseline: X% pass rate (Y passing, Z failing)"

git push origin test/compilation-fixes

# 8. NOTIFY OTHER SESSIONS
echo "✅ SESSION 1 COMPLETE - UNBLOCKED" > SESSION_1_DONE.txt
```

### 🎯 Success Criteria
- [ ] `swift build` succeeds with no errors
- [ ] `swift test` runs all tests (even if some fail)
- [ ] baseline-results.txt created
- [ ] baseline-analysis.md created
- [ ] TEST_FAILURE_TRACKER.md updated with real data
- [ ] Other sessions notified

### 🚨 Common Issues
- **Tuple comparisons**: Replace with `result.exitCode`, `result.stdout`, `result.stderr`
- **Import errors**: Add `@testable import SwiftyBox`
- **Type mismatches**: Check CommandResult struct definition

### 📝 Deliverables
1. ✅ Compiling test suite
2. ✅ baseline-results.txt
3. ✅ baseline-analysis.md
4. ✅ Updated TEST_FAILURE_TRACKER.md
5. ✅ Git commit on test/compilation-fixes

---

## 🟢 SESSION 2: Simple Commands - New Tests

**Wait for Session 1 to complete before starting!**

### ⏱️ Time Budget: 3-4 hours

### ✅ Quick Start Checklist

```bash
# 0. WAIT for Session 1 notification
cat SESSION_1_DONE.txt  # Should say "UNBLOCKED"

# 1. Setup (2 min)
cd /var/home/hh/w/swift/swiftybox
git checkout main
git pull  # Get Session 1's fixes
git checkout -b test/simple-commands

# 2. Read your bible (15 min)
cat TEST_DEVELOPMENT_STRATEGY.md | less    # How to write great tests
cat PARALLEL_SESSION_PLAN.md | less        # Your assignments (Session 2 section)

# 3. Work through commands (3 hours)
# Your assignments: 20 simple commands (see Session 2 section)
#
# For each command:
#   a) Research (10 min): man <command>, busybox <command> --help, <command> --help
#   b) Document (5 min): Add implementation notes to test file
#   c) Write tests (20 min): 8-12 test cases
#   d) Verify (5 min): Test against system command
#
# Total per command: ~40 min
# You can parallelize or do sequentially

# Template:
# Tests/SwiftyBoxTests/Consolidated/YesTests.swift
# Tests/SwiftyBoxTests/Consolidated/ArchTests.swift
# Tests/SwiftyBoxTests/Consolidated/WhoamiTests.swift
# ... etc

# 4. Run your tests (5 min)
swift test --filter YesTests
swift test --filter ArchTests
# ... etc

# 5. Commit (10 min)
git add Tests/SwiftyBoxTests/Consolidated/*Tests.swift
git commit -m "test: Add comprehensive tests for 20 simple commands

Commands tested:
- yes, arch, clear, sync, link, unlink
- whoami, logname, tty, nproc, uname, printenv
- fsync, truncate, sleep, usleep, pwdx
- (+ improvements to true, false, hostid)

Total: 100+ new test cases following TEST_DEVELOPMENT_STRATEGY.md"

git push origin test/simple-commands
```

### 🎯 Your 20 Commands (Group by difficulty)

**Trivial (8 commands, 1 hour):**
1. yes (NEW) - infinite output
2. arch (NEW) - print architecture
3. clear (NEW) - terminal clear
4. sync (NEW) - flush buffers
5. link (NEW) - hard link
6. unlink (NEW) - remove file
7. true (VERIFY) - exit 0
8. false (VERIFY) - exit 1

**Simple Info (9 commands, 1.5 hours):**
9. whoami (NEW)
10. logname (NEW)
11. tty (NEW)
12. nproc (NEW)
13. uname (NEW)
14. printenv (NEW)
15. hostid (VERIFY)
16. env (NEW)
17. free (NEW)

**File/Timing (3 commands, 0.5 hours):**
18. fsync (NEW)
19. truncate (NEW)
20. sleep (NEW)

### 🎯 Success Criteria
- [ ] All 20 commands have test files
- [ ] 100+ new test cases total (avg 5 per command)
- [ ] Each file has implementation notes
- [ ] 80%+ of your new tests pass
- [ ] Committed to test/simple-commands

### 📚 Key Resources
- `TEST_DEVELOPMENT_STRATEGY.md` - Your testing bible
- `Tests/SwiftyBoxTests/Consolidated/EchoTests.swift` - Good example
- `Tests/SwiftyBoxTests/TestRunner.swift` - Helper functions
- GNU coreutils manual: https://www.gnu.org/software/coreutils/manual/

### 💡 Pro Tips
1. **Start simple**: Begin with yes, arch, whoami (easiest)
2. **Use the template**: Copy from TEST_DEVELOPMENT_STRATEGY.md
3. **Compare to system**: Run your test against both SwiftyBox and system command
4. **Document as you go**: Add implementation notes immediately
5. **Test edge cases**: Empty input, invalid args, special chars

---

## 🔵 SESSION 3: Complex Commands - New Tests

**Wait for Session 1 to complete before starting!**

### ⏱️ Time Budget: 4-6 hours

### ✅ Quick Start Checklist

```bash
# 0. WAIT for Session 1 notification
cat SESSION_1_DONE.txt  # Should say "UNBLOCKED"

# 1. Setup (2 min)
cd /var/home/hh/w/swift/swiftybox
git checkout main
git pull  # Get Session 1's fixes
git checkout -b test/complex-commands

# 2. Read your bible (20 min)
cat TEST_DEVELOPMENT_STRATEGY.md | less
cat PARALLEL_SESSION_PLAN.md | less  # Session 3 section
# Pay special attention to the "stat deep dive" example

# 3. Work through commands (4-5 hours)
# Your assignments: 15 complex commands
# Prioritize: stat, chmod, chown, sha256sum first
#
# For each command:
#   a) Research (20 min): Deep dive into format strings, options, edge cases
#   b) Document (10 min): Comprehensive implementation notes
#   c) Write tests (30-45 min): 12-20 test cases per command
#   d) Verify (10 min): Test against GNU version
#
# Total per command: ~70-85 min
# Focus on quality over quantity

# 4. Run your tests (10 min)
swift test --filter StatTests
swift test --filter ChmodTests
# ... etc

# 5. Commit (15 min)
git add Tests/SwiftyBoxTests/Consolidated/*Tests.swift
git commit -m "test: Add comprehensive tests for 15 complex commands

Priority commands:
- stat (format strings, file info, filesystem info)
- chmod (numeric, symbolic, recursive, sticky bits)
- chown/chgrp (ownership, groups, recursive)
- sha256sum/sha512sum/cksum (checksums, check mode)

Additional:
- du/df (disk usage, human readable)
- shuf/tac/rev (text manipulation)
- expand/hexdump/mktemp

Total: 200+ test cases with deep coverage"

git push origin test/complex-commands
```

### 🎯 Your 15 Commands (Prioritized)

**Tier 1 - DO FIRST (4 commands, 2.5 hours):**
1. **stat** (NEW) - File/filesystem info, format strings ⭐⭐⭐
2. **chmod** (NEW) - Permissions (numeric + symbolic) ⭐⭐⭐
3. **chown** (NEW) - Ownership changes ⭐⭐
4. **sha256sum** (NEW) - Checksums with check mode ⭐⭐

**Tier 2 - DO SECOND (5 commands, 2 hours):**
5. **chgrp** (NEW) - Group changes ⭐⭐
6. **cksum** (NEW) - CRC checksums ⭐
7. **sha512sum** (NEW) - SHA-512 checksums ⭐
8. **df** (NEW) - Disk free space ⭐⭐
9. **du** (ENHANCE) - Disk usage (already has 6 tests, add more) ⭐⭐

**Tier 3 - DO IF TIME (6 commands, 1.5 hours):**
10. **shuf** (NEW) - Shuffle lines ⭐
11. **tac** (NEW) - Reverse cat ⭐
12. **rev** (ENHANCE) - Reverse characters ⭐
13. **expand** (ENHANCE) - Tab expansion ⭐
14. **hexdump** (ENHANCE) - Hex viewer ⭐⭐
15. **mktemp** (NEW) - Temp file creation ⭐

⭐ = Complexity level

### 🎯 Success Criteria
- [ ] Tier 1 commands 100% complete (stat, chmod, chown, sha256sum)
- [ ] Tier 2 commands 80%+ complete
- [ ] 200+ new test cases total
- [ ] Format strings tested thoroughly (stat, hexdump)
- [ ] Recursive operations tested (chmod, chown, du)
- [ ] 80%+ of your new tests pass
- [ ] Committed to test/complex-commands

### 📚 Key Resources
- `TEST_DEVELOPMENT_STRATEGY.md` - stat deep dive example
- `Tests/SwiftyBoxTests/Consolidated/SortTests.swift` - 17 tests, good model
- `Tests/SwiftyBoxTests/Consolidated/ExprTests.swift` - 26 tests, comprehensive
- GNU coreutils manual (especially stat): https://www.gnu.org/software/coreutils/manual/

### 💡 Pro Tips
1. **stat is the hardest**: Budget 90 min for stat alone, it has format strings
2. **chmod symbolic mode**: Test `u+x`, `go-w`, `a=r`, combinations
3. **Test recursion carefully**: Create temp directory structures
4. **Known checksum values**: Use echo "test" | sha256sum for test data
5. **Permission edge cases**: setuid, setgid, sticky bit (chmod 4755, 2755, 1755)

### 🧪 Example Test Data

```swift
// stat format strings to test:
// %a - octal permissions (755)
// %A - human permissions (drwxr-xr-x)
// %F - file type (regular file, directory, symbolic link)
// %n - filename
// %s - size in bytes
// %U - user name
// %G - group name

// chmod symbolic modes to test:
// u+x, go-w, a=r
// u+rwx,go+rx,go-w
// a-x

// Known checksums for testing:
let testString = "test\n"
// echo "test" | sha256sum
// f2ca1bb6c7e907d06dafe4687e579fce76b37e4e93b7605022da52e6ccc26fd2
```

---

## 🟡 SESSION 4: Fix Failures & Cleanup

**Wait for Session 1 to complete before starting!**

### ⏱️ Time Budget: 3-5 hours

### ✅ Quick Start Checklist

```bash
# 0. WAIT for Session 1 notification
cat SESSION_1_DONE.txt  # Should say "UNBLOCKED"

# 1. Setup (2 min)
cd /var/home/hh/w/swift/swiftybox
git checkout main
git pull  # Get Session 1's fixes
git checkout -b test/fix-failures

# 2. Read baseline results (20 min)
cat baseline-results.txt | less
cat baseline-analysis.md | less
cat TEST_FAILURE_TRACKER.md | less

# Take notes:
# - Which commands have highest failure rate?
# - Are failures in implementation or tests?
# - Any patterns (all file I/O failing? permission issues?)

# 3. Prioritize failures (15 min)
# Create priority list:
#   P0: NOFORK commands (44 total)
#   P0: Core commands (echo, cat, ls, cp, mv, sort, grep)
#   P1: NOEXEC commands with >50% failure
#   P2: Everything else

# 4. Fix failures (2-3 hours)
# For each failure:
for test in $(grep FAILED baseline-results.txt | awk '{print $1}'); do
    # a) Reproduce
    swift test --filter "$test"

    # b) Debug - add prints to see what's wrong

    # c) Fix implementation OR test
    #    - If implementation wrong: edit Sources/SwiftyBox/Commands/
    #    - If test wrong: edit Tests/SwiftyBoxTests/Consolidated/

    # d) Verify
    swift test --filter "$test"

    # e) Update tracker
    # Mark as FIXED in TEST_FAILURE_TRACKER.md
done

# 5. Clean up placeholders (1-2 hours)
# 21 files have placeholder tests (see baseline-analysis.md)
# For each:
#   - Replace "TODO" with real tests
#   - Or remove if test doesn't make sense yet
#   - Verify tests pass

# 6. Final verification (10 min)
swift test 2>&1 | tee final-results.txt

# Calculate pass rate:
# Should be ≥90%

# 7. Commit (10 min)
git add .
git commit -m "fix: Resolve test failures and remove placeholders

Fixed:
- NOFORK commands: 44/44 passing (100%)
- Core commands: 100% passing
- Overall: X% pass rate (Y passing, Z failing)

Cleaned up:
- Removed 21 placeholder tests
- Replaced with real tests or TODOs for unimplemented features

Remaining issues:
- [List any unfixable issues with explanations]"

git push origin test/fix-failures
```

### 🎯 Your Priority Matrix

**P0 - Must Fix (Target: 100% pass rate):**
- All 44 NOFORK commands
- echo, cat, pwd, true, false
- ls, cp, mv, rm, mkdir
- sort, uniq, head, tail, wc

**P1 - Should Fix (Target: 90% pass rate):**
- grep, sed (if implemented)
- chmod, chown, chgrp
- md5sum, sha256sum
- All other NOEXEC commands

**P2 - Nice to Fix (Target: 80% pass rate):**
- Advanced features
- Edge cases
- Optional functionality

### 🎯 Success Criteria
- [ ] ≥90% overall test pass rate
- [ ] 100% pass rate on NOFORK commands
- [ ] 100% pass rate on core commands (echo, cat, ls, cp, mv)
- [ ] All 21 placeholder tests cleaned up
- [ ] TEST_FAILURE_TRACKER.md updated with final status
- [ ] Committed to test/fix-failures

### 🔍 Common Failure Patterns

**Pattern 1: Path Issues**
```swift
// WRONG: Hardcoded paths
let result = runCommand(["cat", "/tmp/myfile"])

// RIGHT: Create temp file
let tmpFile = FileManager.default.temporaryDirectory
    .appendingPathComponent(UUID().uuidString)
```

**Pattern 2: Timing Issues**
```swift
// WRONG: Exact timing
let start = Date()
_ = runCommand(["sleep", "1"])
let elapsed = Date().timeIntervalSince(start)
XCTAssertEqual(elapsed, 1.0) // FLAKY!

// RIGHT: Range
XCTAssertGreaterThan(elapsed, 0.95)
XCTAssertLessThan(elapsed, 1.05)
```

**Pattern 3: Environment**
```swift
// WRONG: Assume env vars
XCTAssertTrue(result.stdout.contains("HOME="))

// RIGHT: Set explicitly
setenv("TEST_VAR", "value", 1)
defer { unsetenv("TEST_VAR") }
```

**Pattern 4: File Permissions**
```swift
// WRONG: Assume umask
try "test".write(toFile: path, atomically: true, encoding: .utf8)
// File might be 644 or 664 depending on umask!

// RIGHT: Set explicitly
FileManager.default.createFile(atPath: path, contents: data)
try FileManager.default.setAttributes([.posixPermissions: 0o644], ofItemAtPath: path)
```

### 📚 Key Resources
- `baseline-results.txt` - Full test output from Session 1
- `baseline-analysis.md` - Analyzed failures from Session 1
- `TEST_FAILURE_TRACKER.md` - Your working document
- Existing working tests - Learn from tests that pass!

### 💡 Pro Tips
1. **Start with easy wins**: Fix tests with simple issues first (path problems, typos)
2. **Group by command**: Fix all tests for one command before moving to next
3. **Check existing code**: Often implementation is fine, test expectation is wrong
4. **Document unfixable**: If something can't be fixed, document why in TEST_FAILURE_TRACKER.md
5. **Regression test**: After each fix, run full test suite for that command

### 🧹 Placeholder Cleanup Checklist

21 files with placeholders (from Session 1):
- [ ] ExpandTests.swift
- [ ] FoldTests.swift
- [ ] GrepTests.swift
- [ ] HeadTests.swift
- [ ] NlTests.swift
- [ ] PrintfTests.swift
- [ ] RevTests.swift
- [ ] SeqTests.swift
- [ ] TestTests.swift (the `test` command, not the test framework!)
- [ ] UniqTests.swift
- [ ] (+ 11 more for unimplemented commands)

For each:
1. Open file
2. Find `TODO` or placeholder comments
3. Replace with real test OR remove
4. Verify tests pass
5. Check off list

---

## 📊 Final Integration

### When All Sessions Complete

```bash
# Merge order:
git checkout main

# 1. Merge Session 1 (already done)
git merge test/compilation-fixes

# 2. Merge Session 2
git merge test/simple-commands
swift test  # Verify

# 3. Merge Session 3
git merge test/complex-commands
swift test  # Verify

# 4. Merge Session 4
git merge test/fix-failures
swift test  # Final verification

# 5. Final stats
swift test 2>&1 | grep -E "(Test Suite|failed|passed)"

# Should see:
# Test Suite 'All tests' passed at ...
# Executed XXX tests, with Y failures (Y < 10% of XXX)
```

### Victory Metrics 🎉

```bash
# Before:
echo "43/73 commands tested (59%)"
echo "431 test cases"
echo "0% passing (compilation blocked)"

# After:
echo "73/73 commands tested (100%)"
echo "700+ test cases"
echo "90%+ passing"

# Improvement:
echo "+30 commands (+69%)"
echo "+269 tests (+62%)"
echo "+90% pass rate"
```

---

## 🆘 Need Help?

### Quick References
1. **Test writing**: `TEST_DEVELOPMENT_STRATEGY.md`
2. **Your assignments**: `PARALLEL_SESSION_PLAN.md`
3. **Current status**: `TEST_STATUS.md`
4. **Failure tracking**: `TEST_FAILURE_TRACKER.md`

### Good Example Tests
- `Tests/SwiftyBoxTests/Consolidated/ExprTests.swift` - 26 tests, comprehensive
- `Tests/SwiftyBoxTests/Consolidated/SortTests.swift` - 17 tests, well-organized
- `Tests/SwiftyBoxTests/Consolidated/EchoTests.swift` - 11 tests, good coverage

### External Resources
- GNU coreutils manual: https://www.gnu.org/software/coreutils/manual/
- POSIX spec: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/
- BusyBox source: https://git.busybox.net/busybox/tree/

### Test Runner Helpers
```swift
// Run command
let result = runCommand(["echo", "hello"])
// result.exitCode, result.stdout, result.stderr

// Run with stdin
let result = runCommandWithInput(["cat"], input: "test\n")

// File operations
let tmpFile = createTempFile()
defer { try? FileManager.default.removeItem(atPath: tmpFile) }
```

---

## ✅ Session Completion Checklist

### Session 1
- [ ] Tests compile (`swift build` succeeds)
- [ ] Baseline run complete (`./run-tests.sh` succeeds)
- [ ] baseline-results.txt exists
- [ ] baseline-analysis.md created
- [ ] TEST_FAILURE_TRACKER.md updated
- [ ] Other sessions notified
- [ ] Committed and pushed

### Session 2
- [ ] 20 commands have tests
- [ ] 100+ new test cases
- [ ] Implementation notes in each file
- [ ] 80%+ tests pass
- [ ] Committed and pushed

### Session 3
- [ ] Tier 1 commands complete (stat, chmod, chown, sha256sum)
- [ ] 200+ new test cases
- [ ] Format strings tested (stat)
- [ ] Recursive operations tested (chmod, chown)
- [ ] 80%+ tests pass
- [ ] Committed and pushed

### Session 4
- [ ] ≥90% overall pass rate
- [ ] 100% NOFORK pass rate
- [ ] 100% core commands pass rate
- [ ] 21 placeholders cleaned up
- [ ] TEST_FAILURE_TRACKER.md final update
- [ ] Committed and pushed

---

**Good luck! Let's get SwiftyλBox to 90%+ test coverage! 🚀**
