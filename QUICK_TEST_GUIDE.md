# SwiftyBox Testing - Quick Reference 🚀

## Run Tests

```bash
# All tests
./run-tests.sh

# Specific command
./run-tests.sh BasenameTests

# Specific test
./run-tests.sh BasenameTests.testBasicUsage
```

## Analyze Results

```bash
swift test 2>&1 | tee test.log
python3 scripts/analyze-test-results.py test.log
```

## Fix Workflow

1. **Run** → 2. **Analyze** → 3. **Update Tracker** → 4. **Fix** → 5. **Verify** → 6. **Document**

## Key Files

- `run-tests.sh` - Test runner
- `Tests/SwiftyBoxTests/TEST_FAILURE_TRACKER.md` - Track failures
- `Tests/SwiftyBoxTests/README.md` - Full docs
- `scripts/analyze-test-results.py` - Result analyzer

## Test Stats

- **71 test files**
- **~395 real tests**
- **28 implemented commands**
- **43 ready for TDD**

## Priority Guide

- **P0** = Critical bugs (crashes, data loss)
- **P1** = High priority (broken core functionality)
- **P2** = Medium (edge cases, nice-to-have features)
- **P3** = Low (cosmetic, rare edge cases)

## Quick Commands

```bash
# In container
distrobox enter swiftybox-dev

# Build
swift build

# Single command tests
swift test --filter BasenameTests

# Verbose output
swift test --verbose

# List all tests
swift test --list-tests
```

---
See `TESTING_INFRASTRUCTURE_SUMMARY.md` for complete details.
