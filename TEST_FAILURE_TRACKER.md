# Test Failure Tracker

**Generated:** Automated analysis
**Status:** Initial test run complete

## Overview

- **Total Tests:** 492
- **Passed:** 118 (24.0%)
- **Failed:** 374 (76.0%)
- **Test Suites:** 74

## Status by Category

### NOFORK (Phases 1-5)

- Suites: 34
- Tests: 215
- Passed: 47 (21.9%)
- Failed: 168 (78.1%)

❌ **BasenameTests**: 1/2 passed (1 failed)
✅ **CatTests**: 2/2 passed
❌ **CutTests**: 1/5 passed (4 failed)
❌ **DateTests**: -1/7 passed (8 failed)
❌ **DirnameTests**: 6/7 passed (1 failed)
❌ **DuTests**: 3/6 passed (3 failed)
❌ **EchoTests**: 6/11 passed (5 failed)
❌ **ExpandTests**: 0/3 passed (3 failed)
❌ **ExprTests**: 14/26 passed (12 failed)
❌ **FactorTests**: 0/12 passed (12 failed)
✅ **FalseTests**: 2/2 passed
❌ **GrepTests**: 0/10 passed (10 failed)
❌ **HeadTests**: 0/4 passed (4 failed)
❌ **HexdumpTests**: 0/1 passed (1 failed)
✅ **HostidTests**: 1/1 passed
❌ **HostnameTests**: -3/6 passed (9 failed)
❌ **IdTests**: 2/4 passed (2 failed)
❌ **Md5sumTests**: 2/6 passed (4 failed)
❌ **PrintfTests**: 0/1 passed (1 failed)
✅ **PwdTests**: 1/1 passed
❌ **ReadlinkTests**: 0/6 passed (6 failed)
❌ **RealpathTests**: 0/10 passed (10 failed)
❌ **RevTests**: 0/5 passed (5 failed)
❌ **SedTests**: 4/10 passed (6 failed)
❌ **SeqTests**: 3/23 passed (20 failed)
❌ **Sha1sumTests**: 0/1 passed (1 failed)
✅ **TailTests**: 2/2 passed
✅ **TeeTests**: 2/2 passed
❌ **TestTests**: 0/13 passed (13 failed)
❌ **TrTests**: -4/5 passed (9 failed)
✅ **TrueTests**: 2/2 passed
❌ **UnexpandTests**: 1/11 passed (10 failed)
❌ **WcTests**: 1/5 passed (4 failed)
❌ **XargsTests**: -1/3 passed (4 failed)

### File Operations (Phase 6)

- Suites: 8
- Tests: 51
- Passed: 29 (56.9%)
- Failed: 22 (43.1%)

❌ **CpTests**: 12/17 passed (5 failed)
✅ **LnTests**: 6/6 passed
❌ **LsTests**: -1/7 passed (8 failed)
✅ **MkdirTests**: 2/2 passed
❌ **MvTests**: 11/14 passed (3 failed)
✅ **RmTests**: 1/1 passed
❌ **RmdirTests**: -1/1 passed (2 failed)
❌ **TouchTests**: -1/3 passed (4 failed)

### Text Processing (Phase 7+)

- Suites: 11
- Tests: 120
- Passed: 8 (6.7%)
- Failed: 112 (93.3%)

❌ **CmpTests**: 2/4 passed (2 failed)
❌ **CommTests**: 0/9 passed (9 failed)
❌ **DiffTests**: 0/20 passed (20 failed)
❌ **FoldTests**: 0/5 passed (5 failed)
❌ **NlTests**: 0/4 passed (4 failed)
❌ **OdTests**: 0/26 passed (26 failed)
❌ **PasteTests**: 0/5 passed (5 failed)
❌ **PatchTests**: 0/17 passed (17 failed)
❌ **SortTests**: 9/17 passed (8 failed)
❌ **StringsTests**: -4/6 passed (10 failed)
❌ **UniqTests**: 1/7 passed (6 failed)

### Unimplemented

- Suites: 18
- Tests: 45
- Passed: -7 (-15.6%)
- Failed: 52 (115.6%)

❌ **AshTests**: 0/1 passed (1 failed)
✅ **Bunzip2Tests**: 1/1 passed
✅ **BzcatTests**: 1/1 passed
❌ **CalTests**: 0/3 passed (3 failed)
❌ **DdTests**: -1/7 passed (8 failed)
❌ **FindTests**: -3/3 passed (6 failed)
❌ **GunzipTests**: 0/1 passed (1 failed)
❌ **GzipTests**: -2/2 passed (4 failed)
❌ **PidofTests**: 0/6 passed (6 failed)
❌ **SumTests**: 0/1 passed (1 failed)
❌ **TarTests**: 1/3 passed (2 failed)
❌ **TreeTests**: 0/1 passed (1 failed)
❌ **TsortTests**: 1/5 passed (4 failed)
❌ **UncompressTests**: 0/2 passed (2 failed)
❌ **UptimeTests**: -5/3 passed (8 failed)
❌ **WgetTests**: 2/3 passed (1 failed)
❌ **WhichTests**: -2/1 passed (3 failed)
❌ **XxdTests**: 0/1 passed (1 failed)

### Other

- Suites: 3
- Tests: 61
- Passed: 41 (67.2%)
- Failed: 20 (32.8%)

❌ **BasicCommandTests**: 24/27 passed (3 failed)
❌ **FileOperationTests**: 9/11 passed (2 failed)
❌ **TextProcessingTests**: 8/23 passed (15 failed)

## Detailed Failure List

Test suites with failures (sorted by failure count):

### OdTests

- **Failed:** 26/26
- **Passed:** 0/26
- **File:** `Tests/SwiftyBoxTests/Consolidated/OdTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### DiffTests

- **Failed:** 20/20
- **Passed:** 0/20
- **File:** `Tests/SwiftyBoxTests/Consolidated/DiffTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### SeqTests

- **Failed:** 20/23
- **Passed:** 3/23
- **File:** `Tests/SwiftyBoxTests/Consolidated/SeqTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### PatchTests

- **Failed:** 17/17
- **Passed:** 0/17
- **File:** `Tests/SwiftyBoxTests/Consolidated/PatchTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### TextProcessingTests

- **Failed:** 15/23
- **Passed:** 8/23
- **File:** `Tests/SwiftyBoxTests/Consolidated/TextProcessingTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### TestTests

- **Failed:** 13/13
- **Passed:** 0/13
- **File:** `Tests/SwiftyBoxTests/Consolidated/TestTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### ExprTests

- **Failed:** 12/26
- **Passed:** 14/26
- **File:** `Tests/SwiftyBoxTests/Consolidated/ExprTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### FactorTests

- **Failed:** 12/12
- **Passed:** 0/12
- **File:** `Tests/SwiftyBoxTests/Consolidated/FactorTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### GrepTests

- **Failed:** 10/10
- **Passed:** 0/10
- **File:** `Tests/SwiftyBoxTests/Consolidated/GrepTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### RealpathTests

- **Failed:** 10/10
- **Passed:** 0/10
- **File:** `Tests/SwiftyBoxTests/Consolidated/RealpathTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### StringsTests

- **Failed:** 10/6
- **Passed:** -4/6
- **File:** `Tests/SwiftyBoxTests/Consolidated/StringsTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### UnexpandTests

- **Failed:** 10/11
- **Passed:** 1/11
- **File:** `Tests/SwiftyBoxTests/Consolidated/UnexpandTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### CommTests

- **Failed:** 9/9
- **Passed:** 0/9
- **File:** `Tests/SwiftyBoxTests/Consolidated/CommTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### HostnameTests

- **Failed:** 9/6
- **Passed:** -3/6
- **File:** `Tests/SwiftyBoxTests/Consolidated/HostnameTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### TrTests

- **Failed:** 9/5
- **Passed:** -4/5
- **File:** `Tests/SwiftyBoxTests/Consolidated/TrTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### DateTests

- **Failed:** 8/7
- **Passed:** -1/7
- **File:** `Tests/SwiftyBoxTests/Consolidated/DateTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### DdTests

- **Failed:** 8/7
- **Passed:** -1/7
- **File:** `Tests/SwiftyBoxTests/Consolidated/DdTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### LsTests

- **Failed:** 8/7
- **Passed:** -1/7
- **File:** `Tests/SwiftyBoxTests/Consolidated/LsTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### SortTests

- **Failed:** 8/17
- **Passed:** 9/17
- **File:** `Tests/SwiftyBoxTests/Consolidated/SortTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### UptimeTests

- **Failed:** 8/3
- **Passed:** -5/3
- **File:** `Tests/SwiftyBoxTests/Consolidated/UptimeTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### FindTests

- **Failed:** 6/3
- **Passed:** -3/3
- **File:** `Tests/SwiftyBoxTests/Consolidated/FindTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### PidofTests

- **Failed:** 6/6
- **Passed:** 0/6
- **File:** `Tests/SwiftyBoxTests/Consolidated/PidofTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### ReadlinkTests

- **Failed:** 6/6
- **Passed:** 0/6
- **File:** `Tests/SwiftyBoxTests/Consolidated/ReadlinkTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### SedTests

- **Failed:** 6/10
- **Passed:** 4/10
- **File:** `Tests/SwiftyBoxTests/Consolidated/SedTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### UniqTests

- **Failed:** 6/7
- **Passed:** 1/7
- **File:** `Tests/SwiftyBoxTests/Consolidated/UniqTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### CpTests

- **Failed:** 5/17
- **Passed:** 12/17
- **File:** `Tests/SwiftyBoxTests/Consolidated/CpTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### EchoTests

- **Failed:** 5/11
- **Passed:** 6/11
- **File:** `Tests/SwiftyBoxTests/Consolidated/EchoTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### FoldTests

- **Failed:** 5/5
- **Passed:** 0/5
- **File:** `Tests/SwiftyBoxTests/Consolidated/FoldTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### PasteTests

- **Failed:** 5/5
- **Passed:** 0/5
- **File:** `Tests/SwiftyBoxTests/Consolidated/PasteTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### RevTests

- **Failed:** 5/5
- **Passed:** 0/5
- **File:** `Tests/SwiftyBoxTests/Consolidated/RevTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### CutTests

- **Failed:** 4/5
- **Passed:** 1/5
- **File:** `Tests/SwiftyBoxTests/Consolidated/CutTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### GzipTests

- **Failed:** 4/2
- **Passed:** -2/2
- **File:** `Tests/SwiftyBoxTests/Consolidated/GzipTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### HeadTests

- **Failed:** 4/4
- **Passed:** 0/4
- **File:** `Tests/SwiftyBoxTests/Consolidated/HeadTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### Md5sumTests

- **Failed:** 4/6
- **Passed:** 2/6
- **File:** `Tests/SwiftyBoxTests/Consolidated/Md5sumTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### NlTests

- **Failed:** 4/4
- **Passed:** 0/4
- **File:** `Tests/SwiftyBoxTests/Consolidated/NlTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### TouchTests

- **Failed:** 4/3
- **Passed:** -1/3
- **File:** `Tests/SwiftyBoxTests/Consolidated/TouchTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### TsortTests

- **Failed:** 4/5
- **Passed:** 1/5
- **File:** `Tests/SwiftyBoxTests/Consolidated/TsortTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### WcTests

- **Failed:** 4/5
- **Passed:** 1/5
- **File:** `Tests/SwiftyBoxTests/Consolidated/WcTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### XargsTests

- **Failed:** 4/3
- **Passed:** -1/3
- **File:** `Tests/SwiftyBoxTests/Consolidated/XargsTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### BasicCommandTests

- **Failed:** 3/27
- **Passed:** 24/27
- **File:** `Tests/SwiftyBoxTests/Consolidated/BasicCommandTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### CalTests

- **Failed:** 3/3
- **Passed:** 0/3
- **File:** `Tests/SwiftyBoxTests/Consolidated/CalTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### DuTests

- **Failed:** 3/6
- **Passed:** 3/6
- **File:** `Tests/SwiftyBoxTests/Consolidated/DuTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### ExpandTests

- **Failed:** 3/3
- **Passed:** 0/3
- **File:** `Tests/SwiftyBoxTests/Consolidated/ExpandTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### MvTests

- **Failed:** 3/14
- **Passed:** 11/14
- **File:** `Tests/SwiftyBoxTests/Consolidated/MvTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### WhichTests

- **Failed:** 3/1
- **Passed:** -2/1
- **File:** `Tests/SwiftyBoxTests/Consolidated/WhichTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### CmpTests

- **Failed:** 2/4
- **Passed:** 2/4
- **File:** `Tests/SwiftyBoxTests/Consolidated/CmpTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### FileOperationTests

- **Failed:** 2/11
- **Passed:** 9/11
- **File:** `Tests/SwiftyBoxTests/Consolidated/FileOperationTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### IdTests

- **Failed:** 2/4
- **Passed:** 2/4
- **File:** `Tests/SwiftyBoxTests/Consolidated/IdTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### RmdirTests

- **Failed:** 2/1
- **Passed:** -1/1
- **File:** `Tests/SwiftyBoxTests/Consolidated/RmdirTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### TarTests

- **Failed:** 2/3
- **Passed:** 1/3
- **File:** `Tests/SwiftyBoxTests/Consolidated/TarTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### UncompressTests

- **Failed:** 2/2
- **Passed:** 0/2
- **File:** `Tests/SwiftyBoxTests/Consolidated/UncompressTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### AshTests

- **Failed:** 1/1
- **Passed:** 0/1
- **File:** `Tests/SwiftyBoxTests/Consolidated/AshTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### BasenameTests

- **Failed:** 1/2
- **Passed:** 1/2
- **File:** `Tests/SwiftyBoxTests/Consolidated/BasenameTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### DirnameTests

- **Failed:** 1/7
- **Passed:** 6/7
- **File:** `Tests/SwiftyBoxTests/Consolidated/DirnameTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### GunzipTests

- **Failed:** 1/1
- **Passed:** 0/1
- **File:** `Tests/SwiftyBoxTests/Consolidated/GunzipTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### HexdumpTests

- **Failed:** 1/1
- **Passed:** 0/1
- **File:** `Tests/SwiftyBoxTests/Consolidated/HexdumpTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### PrintfTests

- **Failed:** 1/1
- **Passed:** 0/1
- **File:** `Tests/SwiftyBoxTests/Consolidated/PrintfTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### Sha1sumTests

- **Failed:** 1/1
- **Passed:** 0/1
- **File:** `Tests/SwiftyBoxTests/Consolidated/Sha1sumTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### SumTests

- **Failed:** 1/1
- **Passed:** 0/1
- **File:** `Tests/SwiftyBoxTests/Consolidated/SumTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### TreeTests

- **Failed:** 1/1
- **Passed:** 0/1
- **File:** `Tests/SwiftyBoxTests/Consolidated/TreeTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### WgetTests

- **Failed:** 1/3
- **Passed:** 2/3
- **File:** `Tests/SwiftyBoxTests/Consolidated/WgetTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

### XxdTests

- **Failed:** 1/1
- **Passed:** 0/1
- **File:** `Tests/SwiftyBoxTests/Consolidated/XxdTests.swift`

**Action Items:**
- [ ] Review test expectations
- [ ] Fix implementation issues
- [ ] Re-run tests

