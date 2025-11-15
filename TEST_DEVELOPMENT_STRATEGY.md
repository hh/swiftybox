# SwiftyλBox Test Development Strategy

## Philosophy: Beyond BusyBox Parity

**Goal**: Create tests that drive SwiftyλBox to be **best-in-class**, not just BusyBox-compatible.

### Core Principle
Each command should be tested against the **canonical/reference implementation**, not just the minimal BusyBox applet version.

**Why?**
- BusyBox is designed for embedded systems with size constraints
- SwiftyλBox has no such constraints - we can be feature-complete
- Users expect full functionality when they type a command
- Better tests → better implementations → more useful tool

---

## Test Development Process for Each Command

### Step 1: Research Reference Implementations

Before writing tests, agents should identify the **canonical implementation**:

| Command Category | Reference Implementation | Why |
|-----------------|-------------------------|-----|
| **GNU Coreutils** | GNU version | Industry standard, POSIX-compliant + extensions |
| **Text Processing** | Original Unix tool | `sort`, `uniq`, `tr` - well-defined behavior |
| **Checksums** | GNU coreutils | `md5sum`, `sha256sum` - widely used format |
| **File Operations** | GNU coreutils | `ls`, `cp`, `mv` - rich feature sets |
| **BSD Tools** | FreeBSD/OpenBSD | Sometimes cleaner than GNU |

### Step 2: Compare Implementations

For each command, analyze:

```bash
# Compare help outputs
busybox echo --help    # Minimal applet
echo --help            # System version (usually GNU)
man echo               # Full specification

# Compare feature sets
busybox ls --help      # ~20 options
ls --help              # ~50+ options
```

**Document:**
1. **BusyBox features**: What the applet supports
2. **GNU/BSD features**: What the full version supports
3. **SwiftyλBox scope**: Which features to implement

### Step 3: Prioritize Features

Categorize features:

**P0 - Must Have (Core POSIX)**
- Essential for basic compatibility
- Required by shell scripts
- Example: `echo -n` (no newline)

**P1 - Should Have (Common GNU Extensions)**
- Widely used in practice
- Increases utility significantly
- Example: `ls --color`, `sort -h` (human numeric sort)

**P2 - Nice to Have (Advanced Features)**
- Power user features
- Less common but valuable
- Example: `ls --time-style`, `sort --parallel`

**P3 - Won't Have (Out of Scope)**
- Extremely rare usage
- Complexity not worth benefit
- Example: `ls --quoting-style=shell-escape`

### Step 4: Write Comprehensive Tests

For each command, create test suites covering:

#### A. POSIX Compliance Tests
```swift
// Test basic POSIX behavior that ANY implementation must support
func testPOSIXBasicFunctionality() { ... }
func testPOSIXOptionHandling() { ... }
func testPOSIXErrorCases() { ... }
```

#### B. GNU/BSD Feature Tests
```swift
// Test commonly-used extensions
func testGNUExtendedOptions() { ... }
func testBSDCompatibility() { ... }
```

#### C. Edge Cases & Error Handling
```swift
// Test robustness
func testInvalidInput() { ... }
func testLargeFiles() { ... }
func testUnicodeHandling() { ... }
func testSymbolicLinks() { ... }
```

#### D. Performance Tests (Optional)
```swift
// For commands where performance matters
func testLargeInputPerformance() { ... }
```

---

## Reference Implementation Matrix

### Coreutils Commands (Use GNU as Reference)

| Command | BusyBox Options | GNU Options | Recommended Scope |
|---------|----------------|-------------|-------------------|
| **ls** | ~20 | ~58 | P0: Basic listing, -l, -a, -h<br>P1: --color, -R, -t, -S<br>P2: --time-style, --group-directories-first |
| **sort** | ~15 | ~25 | P0: Basic sort, -n, -r, -u<br>P1: -h (human), -k (keys), -t (delimiter)<br>P2: --parallel, --compress-program |
| **cat** | ~5 | ~10 | P0: Concatenate, -n<br>P1: -b, -s, -E, -T<br>P2: --show-all |
| **echo** | 3 | 4 | P0: Basic output, -n, -e<br>P1: All (simple command) |
| **wc** | ~4 | ~8 | P0: -l, -w, -c<br>P1: -m (chars), -L (max line)<br>P2: --files0-from |
| **head** | ~5 | ~8 | P0: -n, -c<br>P1: -q, -v (quiet/verbose)<br>P2: --lines (range syntax) |
| **tail** | ~8 | ~15 | P0: -n, -c, -f<br>P1: -F, --pid, --retry<br>P2: --max-unchanged-stats |

### Text Processing (Use Original Unix + POSIX)

| Command | Reference | Key Features to Test |
|---------|-----------|---------------------|
| **grep** | GNU grep | P0: Basic regex, -i, -v, -r<br>P1: -E, -P (Perl regex), --color<br>P2: -z (null-separated) |
| **sed** | GNU sed | P0: s///, d, p<br>P1: -i (in-place), -E (extended)<br>P2: Advanced scripts |
| **tr** | POSIX tr | P0: Basic translation, -d, -s<br>P1: Character classes<br>P2: All (relatively simple) |
| **cut** | POSIX cut | P0: -f, -d, -c<br>P1: All (simple command) |
| **paste** | POSIX paste | P0: -d, -s<br>P1: All (simple command) |

### File Operations (Use GNU + Modern Features)

| Command | Modern Features to Consider |
|---------|----------------------------|
| **cp** | --reflink (CoW), --sparse, --preserve=all |
| **mv** | --no-clobber, --backup |
| **rm** | -I (interactive threshold), --one-file-system |
| **ln** | -r (relative), -t (target directory) |
| **chmod** | --reference, -c (changes only) |

### Checksums (Use GNU Coreutils Format)

| Command | Standard Behavior |
|---------|------------------|
| **md5sum** | Two-space format, -c (check), -b/t (binary/text) |
| **sha256sum** | Same as md5sum |
| **sha512sum** | Same as md5sum |
| **cksum** | POSIX CRC + size |

---

## Test Data Sources

### 1. GNU Test Suites
```bash
# Many GNU tools have extensive test suites
git clone https://git.savannah.gnu.org/git/coreutils.git
cd coreutils/tests

# Example: sort tests
ls tests/misc/sort-*
# Dozens of edge cases to learn from
```

### 2. POSIX Specification
- IEEE Std 1003.1™ (POSIX)
- Defines minimum required behavior
- Available: https://pubs.opengroup.org/onlinepubs/9699919799/

### 3. Real-World Usage
```bash
# Find common usage patterns in shell scripts
grep -r "^sort " /usr/local/bin/
grep -r "^ls " ~/.bashrc ~/.zshrc

# Popular GitHub repositories
# Search for command usage in dotfiles, scripts
```

### 4. Man Pages Comparison
```bash
# Compare different implementations
man ls              # GNU version
man -M /path/to/bsd ls   # BSD version
busybox ls --help   # BusyBox version
```

---

## Example: Comprehensive Test Plan for `sort`

### Research Phase
1. **BusyBox sort**: 15 options, basic functionality
2. **GNU sort**: 25+ options, advanced features
3. **Common usage**: `-n`, `-r`, `-u`, `-k`, `-t`, `-h` are most common

### Feature Scope Decision
```
P0 (Must Have):
  - Basic alphabetic sort
  - -n (numeric sort)
  - -r (reverse)
  - -u (unique)
  - -k (key selection)
  - -t (field separator)

P1 (Should Have):
  - -h (human-numeric: 1K, 2M, 3G)
  - -V (version sort: file1, file2, file10)
  - -g (general numeric: handles scientific notation)
  - -i (ignore case)
  - -b (ignore leading blanks)
  - -f (fold case)

P2 (Nice to Have):
  - -M (month sort: Jan, Feb, Mar)
  - -R (random sort with --random-source)
  - --parallel (multi-threaded sort)
  - -s (stable sort)

P3 (Won't Have):
  - --compress-program (external compression)
  - --files0-from (batch file processing)
```

### Test Suite Structure
```swift
// Tests/SwiftyBoxTests/Consolidated/SortTests.swift

// POSIX Compliance (10 tests)
func testBasicAlphabeticSort()
func testNumericSort()
func testReverseSort()
func testFieldSeparatorBasic()
func testKeySelectionSingleField()
func testStdinInput()
func testMultipleFiles()
func testEmptyFile()
func testEmptyLines()
func testLargeFile()

// GNU Extensions (12 tests)
func testHumanNumericSort()          // 1K, 2M, 3G
func testVersionSort()               // file1, file2, file10
func testGeneralNumericSort()        // 1e10, 2.5e-3
func testMonthSort()                 // Jan, Feb, Mar
func testIgnoreCase()
func testCaseFolding()
func testIgnoreLeadingBlanks()
func testStableSort()
func testRandomSort()
func testComplexKeySelection()       // Multiple keys
func testMergePresortedFiles()
func testCheckSorted()               // -c option

// Edge Cases (8 tests)
func testUnicodeHandling()
func testVeryLongLines()
func testMixedLineEndings()          // \n, \r\n
func testNullTerminatedLines()       // -z option
func testInvalidNumericInput()
func testDuplicateRemoval()
func testMultiColumnSort()
func testLocaleSpecificSort()

// Error Handling (5 tests)
func testNonexistentFile()
func testInvalidOption()
func testInvalidKeyFormat()
func testUnreadableFile()
func testOutputToReadOnlyLocation()

// Performance (optional, 2 tests)
func testLargeFilePerformance()      // 1M+ lines
func testManySmallFilesPerformance() // 100+ files
```

### Test Data Examples
```swift
// Use GNU-quality test data
let humanNumericInput = """
1K
2M
512
1G
1024K
2048M
"""

let versionSortInput = """
file1.txt
file10.txt
file2.txt
file20.txt
file3.txt
"""

let scientificNotationInput = """
1.5e10
2.3e-5
1.2e3
5.6e10
"""
```

---

## Agent Instructions for Each Command

When assigned a command to test, follow this process:

### 1. Research (15-30 minutes)
```bash
# Compare implementations
busybox <command> --help
<command> --help           # System version
man <command>              # Full documentation

# Find GNU test suite
cd ~/coreutils-tests
find . -name "*<command>*"

# Check POSIX spec
# https://pubs.opengroup.org/onlinepubs/9699919799/utilities/<command>.html
```

### 2. Document Findings (10 minutes)
Create a comment at the top of test file:
```swift
// IMPLEMENTATION NOTES:
// - BusyBox: 15 options, basic POSIX compliance
// - GNU: 25 options, adds -h (human), -V (version), -M (month)
// - Common usage: -n, -r, -u most frequent (90% of use cases)
// - Target scope: P0 (POSIX) + P1 (common GNU extensions)
//
// Reference: https://www.gnu.org/software/coreutils/manual/html_node/sort-invocation.html
```

### 3. Write Tests (1-3 hours depending on complexity)
- Start with POSIX compliance
- Add common GNU extensions
- Include comprehensive edge cases
- Add error handling tests

### 4. Document Unimplemented Features (5 minutes)
```swift
// TODO: Advanced features for future implementation
// - [ ] --parallel (multi-threaded sort) - P2
// - [ ] --compress-program - P3 (out of scope)
// - [ ] -M (month sort) - P2
```

### 5. Cross-Reference (5 minutes)
Check if other similar tools use this command:
- Ripgrep vs grep
- fd vs find
- exa/eza vs ls
- bat vs cat

Learn from modern alternatives!

---

## Modern Tool Alternatives to Consider

| Traditional | Modern Alternative | Key Innovations to Adopt |
|-------------|-------------------|-------------------------|
| ls | exa, eza | Git integration, better colors, tree view |
| cat | bat | Syntax highlighting, line numbers, paging |
| grep | ripgrep (rg) | Speed, smart defaults, gitignore integration |
| find | fd | Simpler syntax, faster, colored output |
| sed | sd | Simpler syntax for common cases |
| top | btop, htop | Better UI, colors, interactivity |

**Lesson**: Modern tools succeed by having **better defaults** and **better UX**, not just more features.

### Apply to SwiftyλBox:
- Default to colored output when TTY detected
- Smart defaults (like ripgrep's gitignore awareness)
- Clear error messages with suggestions
- Fast execution (Swift's performance helps here)

---

## Quality Metrics for Tests

Each command's test suite should aim for:

**Coverage:**
- ✅ All POSIX-required functionality
- ✅ Top 5 most common options/use cases
- ✅ At least 10 test cases total
- ✅ Error handling for invalid inputs

**Quality:**
- ✅ Tests use realistic data (not just "foo", "bar")
- ✅ Edge cases covered (empty input, large input, unicode)
- ✅ Clear test names describing what's being tested
- ✅ Comments explaining non-obvious test cases

**Documentation:**
- ✅ Implementation notes at top of file
- ✅ Reference to canonical implementation
- ✅ TODOs for unimplemented features
- ✅ Examples of expected output format

---

## Command-Specific Resources

### For Each Command Category:

**Coreutils (ls, cp, mv, sort, etc.):**
- Primary reference: https://www.gnu.org/software/coreutils/manual/
- Test suite: https://git.savannah.gnu.org/cgit/coreutils.git/tree/tests
- POSIX spec: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/contents.html

**Text Processing (grep, sed, awk):**
- GNU versions are standard
- sed: https://www.gnu.org/software/sed/manual/
- grep: https://www.gnu.org/software/grep/manual/

**Checksums:**
- Follow GNU coreutils format exactly
- Two-space separation, lowercase hex
- Support for -c (check) mode critical

**File Operations:**
- Consider modern filesystem features (CoW, sparse files)
- Handle symlinks, hardlinks correctly
- Preserve permissions, ownership, timestamps

---

## Success Criteria

A test suite is complete when:

1. ✅ **Coverage**: All P0 features have tests
2. ✅ **Quality**: At least 10 meaningful test cases
3. ✅ **Documentation**: Clear notes about scope and references
4. ✅ **Edge Cases**: Error handling and boundary conditions tested
5. ✅ **Comparison**: Tested against GNU/reference implementation behavior
6. ✅ **Real Data**: Uses realistic test inputs, not toy examples
7. ✅ **Future-proof**: TODOs document unimplemented advanced features

---

## Examples of Great Tests to Emulate

Look at these test files as examples:

**Excellent Coverage:**
- `ExprTests.swift` - 26 tests, comprehensive operator testing
- `SortTests.swift` - 17 tests, multiple sort modes
- `MvTests.swift` - 14 tests, edge cases well-covered

**Good Documentation:**
- `CommTests.swift` - Clear expected outputs
- `DateTests.swift` - Multiple format variations

**Edge Case Handling:**
- `RealpathTests.swift` - Symlinks, relative paths
- `CpTests.swift` - Permissions, overwrite scenarios

---

## Agent Checklist

Before submitting tests for a command:

- [ ] Researched canonical implementation (GNU/BSD/POSIX)
- [ ] Documented feature scope (P0/P1/P2/P3)
- [ ] Written at least 10 test cases
- [ ] Covered common usage patterns
- [ ] Tested error handling
- [ ] Included edge cases (empty, large, unicode, symlinks)
- [ ] Added implementation notes to test file
- [ ] Checked against system command behavior
- [ ] Documented unimplemented features as TODOs
- [ ] Used realistic test data

---

## Conclusion

**Remember:** We're not building a BusyBox clone - we're building a **modern, Swift-native, feature-complete** Unix toolkit.

Tests should drive implementations that:
- Match or exceed GNU/BSD feature sets
- Have better error messages
- Leverage Swift's safety and performance
- Provide better user experience

**When in doubt:** Look at what GNU does, look at what modern alternatives do, then do something great.
