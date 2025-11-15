# Test Failure Tracker 🐛

## Purpose
Track all test failures, categorize root causes, and manage fixes systematically.

## How to Use This Tracker

### 1. Run Tests and Capture Results
```bash
# In dev container or environment with Swift
cd /path/to/swiftybox
swift test 2>&1 | tee test-results.log

# Or run specific test files
swift test --filter CommandTests
```

### 2. Update This Document
For each failing test, add an entry below with:
- **Test Name**: Full test method name
- **Command**: Which SwiftyBox command is being tested
- **Status**: `🔴 FAILING` | `🟡 IN PROGRESS` | `🟢 FIXED`
- **Root Cause**: Why it's failing (implementation bug, test bug, missing feature)
- **Priority**: `P0` (critical) | `P1` (high) | `P2` (medium) | `P3` (low)
- **Notes**: Additional context

### 3. Fix Workflow
1. Pick a failing test (start with P0/P1)
2. Investigate root cause
3. Update status to `🟡 IN PROGRESS`
4. Fix implementation OR update test
5. Verify fix with `swift test --filter TestName`
6. Update status to `🟢 FIXED`
7. Commit changes

---

## Test Results Summary

**Last Run**: [DATE - TO BE FILLED]

| Category | Count | Pass Rate |
|----------|-------|-----------|
| **Total Tests** | ??? | ???% |
| **Passing** | ??? | - |
| **Failing** | ??? | - |
| **Skipped** | ??? | - |

---

## Failures By Command

### Template (copy this for each command):
```markdown
### CommandName (X/Y tests passing)

**Overall Status**: 🔴 FAILING | 🟡 MIXED | 🟢 PASSING

#### Failing Tests:

1. **testSomething**
   - Status: 🔴 FAILING
   - Root Cause: [implementation bug | test bug | missing feature]
   - Priority: P?
   - Notes: Brief description
   - Owner: [optional]
   - Issue: #??? [optional GitHub issue link]

2. **testAnotherThing**
   - Status: 🔴 FAILING
   - Root Cause: ...
```

---

## Active Failures (Fill in after test run)

### Basename (???/??? tests passing)
**Overall Status**: ???

### Cat (???/??? tests passing)
**Overall Status**: ???

### Cp (???/??? tests passing)
**Overall Status**: ???

### Cut (???/??? tests passing)
**Overall Status**: ???

### Date (???/??? tests passing)
**Overall Status**: ???

### Dirname (???/??? tests passing)
**Overall Status**: ???

### Du (???/??? tests passing)
**Overall Status**: ???

### Echo (???/??? tests passing)
**Overall Status**: ???

### Expr (???/??? tests passing)
**Overall Status**: ???

### False (???/??? tests passing)
**Overall Status**: ???

### Hostid (???/??? tests passing)
**Overall Status**: ???

### Id (???/??? tests passing)
**Overall Status**: ???

### Ln (???/??? tests passing)
**Overall Status**: ???

### Ls (???/??? tests passing)
**Overall Status**: ???

### Md5sum (???/??? tests passing)
**Overall Status**: ???

### Mkdir (???/??? tests passing)
**Overall Status**: ???

### Mv (???/??? tests passing)
**Overall Status**: ???

### Paste (???/??? tests passing)
**Overall Status**: ???

### Pwd (???/??? tests passing)
**Overall Status**: ???

### Rm (???/??? tests passing)
**Overall Status**: ???

### Rmdir (???/??? tests passing)
**Overall Status**: ???

### Tail (???/??? tests passing)
**Overall Status**: ???

### Tee (???/??? tests passing)
**Overall Status**: ???

### Touch (???/??? tests passing)
**Overall Status**: ???

### Tr (???/??? tests passing)
**Overall Status**: ???

### True (???/??? tests passing)
**Overall Status**: ???

### Wc (???/??? tests passing)
**Overall Status**: ???

### Which (???/??? tests passing)
**Overall Status**: ???

---

## Unimplemented Commands (Tests exist but command not implemented)

These tests will fail because the command doesn't exist yet. Track implementation progress here.

| Command | Tests Ready | Implementation Status | Priority |
|---------|-------------|----------------------|----------|
| ash | ??? tests | ❌ Not started | P? |
| bunzip2 | ??? tests | ❌ Not started | P? |
| bzcat | ??? tests | ❌ Not started | P? |
| cmp | ??? tests | ❌ Not started | P? |
| comm | ??? tests | ❌ Not started | P? |
| dd | ??? tests | ❌ Not started | P? |
| diff | ??? tests | ❌ Not started | P? |
| expand | ??? tests | ❌ Not started | P? |
| factor | ??? tests | ❌ Not started | P? |
| find | ??? tests | ❌ Not started | P? |
| fold | ??? tests | ❌ Not started | P? |
| grep | ??? tests | ❌ Not started | P? |
| gunzip | ??? tests | ❌ Not started | P? |
| gzip | ??? tests | ❌ Not started | P? |
| head | ??? tests | ❌ Not started | P? |
| hexdump | ??? tests | ❌ Not started | P? |
| hostname | ??? tests | ❌ Not started | P? |
| nl | ??? tests | ❌ Not started | P? |
| od | ??? tests | ❌ Not started | P? |
| patch | ??? tests | ❌ Not started | P? |
| printf | ??? tests | ❌ Not started | P? |
| readlink | ??? tests | ❌ Not started | P? |
| realpath | ??? tests | ❌ Not started | P? |
| rev | ??? tests | ❌ Not started | P? |
| sed | ??? tests | ❌ Not started | P? |
| seq | ??? tests | ❌ Not started | P? |
| sort | ??? tests | ❌ Not started | P? |
| strings | ??? tests | ❌ Not started | P? |
| sum | ??? tests | ❌ Not started | P? |
| tar | ??? tests | ❌ Not started | P? |
| test | ??? tests | ❌ Not started | P? |
| tree | ??? tests | ❌ Not started | P? |
| tsort | ??? tests | ❌ Not started | P? |
| uncompress | ??? tests | ❌ Not started | P? |
| unexpand | ??? tests | ❌ Not started | P? |
| uniq | ??? tests | ❌ Not started | P? |
| uptime | ??? tests | ❌ Not started | P? |
| wget | ??? tests | ❌ Not started | P? |
| xargs | ??? tests | ❌ Not started | P? |
| xxd | ??? tests | ❌ Not started | P? |

---

## Common Failure Patterns

Track recurring issues across multiple tests:

### Pattern 1: [Name the pattern]
- **Description**: What's the common issue?
- **Affected Tests**: List of tests
- **Root Cause**: Why is this happening?
- **Fix Strategy**: How to fix it systematically

### Pattern 2: Exit Code Mismatches
- **Description**: Tests expect exit code X but get Y
- **Affected Tests**: TBD
- **Root Cause**: TBD
- **Fix Strategy**: TBD

### Pattern 3: Output Format Differences
- **Description**: Output is correct but formatting differs
- **Affected Tests**: TBD
- **Root Cause**: TBD
- **Fix Strategy**: TBD

---

## Statistics & Progress

### Overall Progress
- [ ] Initial test run completed
- [ ] All failures categorized
- [ ] P0 failures fixed
- [ ] P1 failures fixed
- [ ] 80% pass rate achieved
- [ ] 90% pass rate achieved
- [ ] 95% pass rate achieved

### By Priority
| Priority | Total | Fixed | Remaining | % Complete |
|----------|-------|-------|-----------|------------|
| P0 (Critical) | ??? | ??? | ??? | ???% |
| P1 (High) | ??? | ??? | ??? | ???% |
| P2 (Medium) | ??? | ??? | ??? | ???% |
| P3 (Low) | ??? | ??? | ??? | ???% |

### By Root Cause
| Cause | Count | % of Total |
|-------|-------|------------|
| Implementation Bug | ??? | ???% |
| Missing Feature | ??? | ???% |
| Test Bug | ??? | ???% |
| Edge Case | ??? | ???% |
| Platform Difference | ??? | ???% |

---

## Notes & Decisions

### Test Philosophy
- **When to fix code vs test**: Fix implementation unless test is clearly wrong
- **Acceptable differences**: Document platform-specific differences
- **Skipping tests**: Only skip if truly platform-incompatible

### Key Decisions
- [DATE] Decision about X
- [DATE] Decision about Y

---

## Quick Commands

```bash
# Run all tests
swift test

# Run specific command tests
swift test --filter BasenameTests

# Run single test
swift test --filter BasenameTests.testBasicUsage

# Run with verbose output
swift test --verbose

# Generate test report
swift test 2>&1 | tee test-report-$(date +%Y%m%d).log

# Count passing/failing
swift test 2>&1 | grep -E "(Test Case.*passed|Test Case.*failed)" | wc -l

# Show only failures
swift test 2>&1 | grep -E "failed|error" | grep -v "0 errors"
```

---

**Last Updated**: [DATE]
**Updated By**: [NAME]
