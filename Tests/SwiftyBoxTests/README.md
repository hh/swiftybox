# SwiftyBox Test Suite

## Overview

Comprehensive test suite with **71 test files** covering **~395 real test cases** imported from BusyBox.

## Test Structure

```
Tests/SwiftyBoxTests/
├── Consolidated/              # 71 command test files (~395 tests)
│   ├── BasenameTests.swift
│   ├── CatTests.swift
│   ├── ... (69 more)
├── BasicCommandTests.swift    # Legacy basic tests
├── FileOperationTests.swift   # Legacy file operation tests
├── TextProcessingTests.swift  # Legacy text processing tests
├── TestRunner.swift           # Test execution framework
├── TEST_FAILURE_TRACKER.md   # Track and manage test failures
└── README.md                  # This file
```

## Quick Start

### Run All Tests (in container)

```bash
# From host machine
./run-tests.sh

# Or manually enter container
distrobox enter swiftybox-dev
cd /var/home/hh/w/swift/swiftybox
swift test
```

### Run Specific Tests

```bash
# Single command tests
./run-tests.sh BasenameTests

# Single test method
./run-tests.sh BasenameTests.testBasicUsage

# Multiple commands with pattern
swift test --filter ".*Tests.testBasic.*"
```

### Capture and Analyze Results

```bash
# Run tests and save output
swift test 2>&1 | tee test-results.log

# Analyze results
python3 scripts/analyze-test-results.py test-results.log

# This generates:
# - Console summary
# - test-tracker-update.md (for updating TEST_FAILURE_TRACKER.md)
```

## Test Organization

### Implemented Commands (28)
Tests for commands that have working implementations:
- basename, cat, cp, cut, date, dirname, du, echo, expr, false, hostid, id, ln, ls, md5sum, mkdir, mv, paste, pwd, rm, rmdir, tail, tee, touch, tr, true, wc, which

### Unimplemented Commands (43)
Tests ready for TDD - implement to make tests pass:
- ash, bunzip2, bzcat, cmp, comm, dd, diff, expand, factor, find, fold, grep, gunzip, gzip, head, hexdump, hostname, nl, od, patch, printf, readlink, realpath, rev, sed, seq, sha1sum, sha256sum, sha512sum, sort, strings, sum, tar, test, tree, tsort, uncompress, unexpand, uniq, uptime, wget, xargs, xxd

## Test Quality

- **High-Quality Individual Tests**: 41 commands with hand-crafted tests from BusyBox subdirectories
- **Auto-Generated Tests**: 30 commands with tests from BusyBox `.tests` scripts
- **Clean Tests**: 49 files with all real test data
- **Mixed Tests**: 22 files with mostly real tests + some placeholders

## Workflow: Fixing Test Failures

### 1. Run Tests
```bash
./run-tests.sh > test-results.log 2>&1
```

### 2. Analyze Results
```bash
python3 scripts/analyze-test-results.py test-results.log
```

### 3. Update Tracker
```bash
# Review generated test-tracker-update.md
# Merge relevant sections into TEST_FAILURE_TRACKER.md
```

### 4. Pick a Failure to Fix
- Open `TEST_FAILURE_TRACKER.md`
- Choose a test (prioritize P0 > P1 > P2 > P3)
- Update status to `🟡 IN PROGRESS`

### 5. Investigate
```bash
# Run single test with verbose output
swift test --filter TestName --verbose

# Check implementation
cat Sources/swiftybox/CommandName.swift

# Check test expectations
cat Tests/SwiftyBoxTests/Consolidated/CommandNameTests.swift
```

### 6. Fix
- **If implementation bug**: Fix the command implementation
- **If test bug**: Update the test expectations
- **If missing feature**: Implement the feature

### 7. Verify
```bash
# Run the specific test
swift test --filter TestName

# Run all tests for that command
swift test --filter CommandNameTests

# Ensure no regressions
swift test
```

### 8. Update Tracker
- Mark test as `🟢 FIXED`
- Document the fix in notes
- Update statistics

## Test Patterns

### Using TestRunner
Most tests use the `TestRunner` utility:

```swift
func testExample() {
    runner.testing(
        "test description",
        command: "command args",
        expectedOutput: "expected output\n",
        inputFile: "optional file content",
        stdin: "optional stdin"
    )
}
```

### Using runCommand
Some tests use direct command execution:

```swift
func testExample() {
    let result = runCommand("command", ["arg1", "arg2"])
    XCTAssertEqual(result.exitCode, 0)
    XCTAssertEqual(result.stdout, "expected output\n")
}
```

### File-Based Tests
Tests that need temporary files:

```swift
var testDir: String!

override func setUp() {
    testDir = FileManager.default.temporaryDirectory
        .appendingPathComponent("TestName_\(UUID().uuidString)")
        .path
    try? FileManager.default.createDirectory(atPath: testDir, ...)
}

override func tearDown() {
    try? FileManager.default.removeItem(atPath: testDir)
}
```

## Common Failure Causes

### 1. Exit Code Mismatch
**Symptom**: Test expects exit code 0 but gets 1 (or vice versa)
**Causes**:
- Command returns error when it shouldn't
- Missing error handling
- Incorrect error detection

### 2. Output Format Differences
**Symptom**: Output is correct but formatting differs
**Causes**:
- Extra/missing newlines
- Different spacing
- Platform-specific formatting

### 3. Missing Features
**Symptom**: Command doesn't support required option
**Causes**:
- Feature not implemented yet
- Option parsing missing
- Edge case not handled

### 4. Platform Differences
**Symptom**: Test passes on macOS but fails on Linux (or vice versa)
**Causes**:
- Different system call behavior
- Different default values
- Path separator differences

## Statistics Tracking

Track overall progress in `TEST_FAILURE_TRACKER.md`:

- **Pass Rate Target**: 95%+
- **P0 Failures**: Must be 0
- **P1 Failures**: Target < 5%
- **P2 Failures**: Target < 10%

## Best Practices

1. **Fix One Thing at a Time**: Don't fix multiple unrelated failures in one commit
2. **Test Before Committing**: Always run `swift test` before committing
3. **Document Fixes**: Update tracker with what you fixed and why
4. **Keep Tests Updated**: If behavior changes, update tests accordingly
5. **Don't Skip Tests**: Only skip if truly platform-incompatible

## Contributing

When adding new tests:
1. Follow existing patterns (preferably use TestRunner)
2. Add meaningful test names
3. Test both success and failure cases
4. Clean up resources in tearDown()
5. Update this README if adding new patterns

## Regenerating Tests

If BusyBox tests are updated, regenerate:

```bash
cd /path/to/busybox/testsuite
python3 /path/to/swiftybox/scripts/import-busybox-tests.py --all . \
  --output-dir /path/to/swiftybox/Tests/SwiftyBoxTests/Generated

# Then merge into Consolidated/ as needed
```

## Resources

- **BusyBox Test Suite**: `../../../busybox/testsuite/`
- **Test Import Script**: `../../scripts/import-busybox-tests.py`
- **Failure Tracker**: `TEST_FAILURE_TRACKER.md`
- **Consolidation Summary**: `CONSOLIDATION_SUMMARY.md`

---

**Last Updated**: 2025-11-14
**Test Count**: ~395 real tests across 71 files
**Coverage**: All 74 SwiftyBox commands (28 implemented, 43 with tests ready)
