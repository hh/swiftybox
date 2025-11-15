#!/usr/bin/env python3
"""
Analyze SwiftyBox test results and generate comprehensive reports
"""

import re
import sys
from collections import defaultdict
from dataclasses import dataclass
from typing import List, Dict

@dataclass
class TestSuite:
    name: str
    total: int
    passed: int
    failed: int
    duration: float

@dataclass
class TestFailure:
    suite: str
    test_name: str
    reason: str

def parse_test_results(filename: str = "test-results.txt"):
    """Parse Swift test output and extract statistics"""

    suites = []
    failures = []
    current_suite = None

    with open(filename, 'r') as f:
        content = f.read()

    # Extract test suite summaries
    suite_pattern = r"Test Suite '(\w+)' (passed|failed) at.*?Executed (\d+) tests?, with (\d+) failures?"
    for match in re.finditer(suite_pattern, content, re.MULTILINE | re.DOTALL):
        name = match.group(1)
        status = match.group(2)
        total = int(match.group(3))
        failed = int(match.group(4))
        passed = total - failed

        # Skip meta suites
        if name not in ['All tests', 'debug.xctest']:
            suites.append(TestSuite(
                name=name,
                total=total,
                passed=passed,
                failed=failed,
                duration=0.0
            ))

    # Extract individual test failures
    failure_pattern = r"Test Case '(\w+)\.(\w+)' failed"
    for match in re.finditer(failure_pattern, content):
        suite = match.group(1)
        test = match.group(2)
        failures.append(TestFailure(
            suite=suite,
            test_name=test,
            reason="See detailed output"
        ))

    return suites, failures

def analyze_by_category(suites: List[TestSuite]) -> Dict[str, List[TestSuite]]:
    """Group test suites by implementation category"""

    # Command categories based on PROGRESS.md
    nofork_commands = {
        'EchoTests', 'TrueTests', 'FalseTests', 'PwdTests', 'BasenameTests',
        'DirnameTests', 'PrintfTests', 'TestTests', 'SeqTests', 'YesTests',
        'LogNameTests', 'WhoamiTests', 'HostnameTests', 'UnameTests',
        'UsleepTests', 'SleepTests', 'NohupTests', 'EnvTests', 'WcTests',
        'HeadTests', 'TailTests', 'CatTests', 'TacTests', 'CutTests',
        'TrTests', 'TeeTests', 'GrepTests', 'SedTests', 'AwkTests',
        'XargsTests', 'ReadlinkTests', 'RealpathTests', 'FactorTests',
        'ExprTests', 'MktempTests', 'DateTests', 'IdTests', 'HostidTests',
        'Md5sumTests', 'Sha1sumTests', 'Sha256sumTests', 'Sha512sumTests',
        'RevTests', 'ExpandTests', 'UnexpandTests', 'HexdumpTests',
        'ShufTests', 'StatTests', 'DuTests', 'DfTests'
    }

    file_ops = {
        'LsTests', 'CpTests', 'MvTests', 'RmTests', 'LnTests',
        'ChmodTests', 'ChownTests', 'ChgrpTests', 'MkdirTests',
        'RmdirTests', 'TouchTests'
    }

    text_processing = {
        'SortTests', 'UniqTests', 'CommTests', 'FoldTests',
        'PasteTests', 'NlTests', 'DiffTests', 'PatchTests',
        'CmpTests', 'StringsTests', 'OdTests'
    }

    unimplemented = {
        'AshTests', 'CalTests', 'TarTests', 'GzipTests', 'GunzipTests',
        'Bunzip2Tests', 'BzcatTests', 'UncompressTests', 'DdTests',
        'FindTests', 'WhichTests', 'TreeTests', 'PidofTests',
        'WgetTests', 'XxdTests', 'TsortTests', 'SumTests', 'UptimeTests'
    }

    categories = {
        'NOFORK (Phases 1-5)': [],
        'File Operations (Phase 6)': [],
        'Text Processing (Phase 7+)': [],
        'Unimplemented': [],
        'Other': []
    }

    for suite in suites:
        if suite.name in nofork_commands:
            categories['NOFORK (Phases 1-5)'].append(suite)
        elif suite.name in file_ops:
            categories['File Operations (Phase 6)'].append(suite)
        elif suite.name in text_processing:
            categories['Text Processing (Phase 7+)'].append(suite)
        elif suite.name in unimplemented:
            categories['Unimplemented'].append(suite)
        else:
            categories['Other'].append(suite)

    return categories

def print_summary(suites: List[TestSuite], failures: List[TestFailure]):
    """Print comprehensive test summary"""

    total_tests = sum(s.total for s in suites)
    total_passed = sum(s.passed for s in suites)
    total_failed = sum(s.failed for s in suites)

    print("=" * 80)
    print("SWIFTYBOX TEST RESULTS SUMMARY")
    print("=" * 80)
    print()
    print(f"Total Test Suites: {len(suites)}")
    print(f"Total Tests:       {total_tests}")
    print(f"Passed:            {total_passed} ({100*total_passed/total_tests:.1f}%)")
    print(f"Failed:            {total_failed} ({100*total_failed/total_tests:.1f}%)")
    print()

    # Group by category
    categories = analyze_by_category(suites)

    for cat_name, cat_suites in categories.items():
        if not cat_suites:
            continue

        cat_total = sum(s.total for s in cat_suites)
        cat_passed = sum(s.passed for s in cat_suites)
        cat_failed = sum(s.failed for s in cat_suites)

        print("-" * 80)
        print(f"{cat_name}")
        print("-" * 80)
        print(f"  Test Suites: {len(cat_suites)}")
        print(f"  Tests:       {cat_total}")
        print(f"  Passed:      {cat_passed} ({100*cat_passed/cat_total:.1f}%)" if cat_total > 0 else "  Passed:      0")
        print(f"  Failed:      {cat_failed} ({100*cat_failed/cat_total:.1f}%)" if cat_total > 0 else "  Failed:      0")
        print()

        # Show suite breakdown
        passed_suites = [s for s in cat_suites if s.failed == 0]
        failed_suites = [s for s in cat_suites if s.failed > 0]

        if passed_suites:
            print(f"  ✅ Fully Passing ({len(passed_suites)}):")
            for suite in sorted(passed_suites, key=lambda x: x.name):
                print(f"     - {suite.name}: {suite.passed}/{suite.total}")

        if failed_suites:
            print(f"  ❌ Has Failures ({len(failed_suites)}):")
            for suite in sorted(failed_suites, key=lambda x: -x.failed):
                print(f"     - {suite.name}: {suite.failed} failures ({suite.passed}/{suite.total} passed)")
        print()

    # Top failing test suites
    print("=" * 80)
    print("TOP 10 FAILING TEST SUITES")
    print("=" * 80)
    top_failures = sorted(suites, key=lambda x: -x.failed)[:10]
    for i, suite in enumerate(top_failures, 1):
        if suite.failed > 0:
            print(f"{i:2}. {suite.name:25} {suite.failed:3} failures ({suite.passed}/{suite.total} passed)")
    print()

def generate_failure_tracker(suites: List[TestSuite], failures: List[TestFailure]):
    """Generate TEST_FAILURE_TRACKER.md"""

    content = """# Test Failure Tracker

**Generated:** Automated analysis
**Status:** Initial test run complete

## Overview

"""

    total_tests = sum(s.total for s in suites)
    total_passed = sum(s.passed for s in suites)
    total_failed = sum(s.failed for s in suites)

    content += f"- **Total Tests:** {total_tests}\n"
    content += f"- **Passed:** {total_passed} ({100*total_passed/total_tests:.1f}%)\n"
    content += f"- **Failed:** {total_failed} ({100*total_failed/total_tests:.1f}%)\n"
    content += f"- **Test Suites:** {len(suites)}\n\n"

    # Category breakdown
    categories = analyze_by_category(suites)

    content += "## Status by Category\n\n"

    for cat_name, cat_suites in categories.items():
        if not cat_suites:
            continue

        cat_total = sum(s.total for s in cat_suites)
        cat_passed = sum(s.passed for s in cat_suites)
        cat_failed = sum(s.failed for s in cat_suites)

        content += f"### {cat_name}\n\n"
        content += f"- Suites: {len(cat_suites)}\n"
        content += f"- Tests: {cat_total}\n"
        content += f"- Passed: {cat_passed} ({100*cat_passed/cat_total:.1f}%)\n" if cat_total > 0 else "- Passed: 0\n"
        content += f"- Failed: {cat_failed} ({100*cat_failed/cat_total:.1f}%)\n\n" if cat_total > 0 else "- Failed: 0\n\n"

        # List suites
        for suite in sorted(cat_suites, key=lambda x: x.name):
            status = "✅" if suite.failed == 0 else "❌"
            content += f"{status} **{suite.name}**: {suite.passed}/{suite.total} passed"
            if suite.failed > 0:
                content += f" ({suite.failed} failed)"
            content += "\n"
        content += "\n"

    # Detailed failures
    content += "## Detailed Failure List\n\n"
    content += "Test suites with failures (sorted by failure count):\n\n"

    failed_suites = sorted([s for s in suites if s.failed > 0], key=lambda x: -x.failed)

    for suite in failed_suites:
        content += f"### {suite.name}\n\n"
        content += f"- **Failed:** {suite.failed}/{suite.total}\n"
        content += f"- **Passed:** {suite.passed}/{suite.total}\n"
        content += f"- **File:** `Tests/SwiftyBoxTests/Consolidated/{suite.name}.swift`\n\n"
        content += "**Action Items:**\n"
        content += "- [ ] Review test expectations\n"
        content += "- [ ] Fix implementation issues\n"
        content += "- [ ] Re-run tests\n\n"

    return content

if __name__ == "__main__":
    filename = sys.argv[1] if len(sys.argv) > 1 else "test-results.txt"

    try:
        suites, failures = parse_test_results(filename)
        print_summary(suites, failures)

        # Generate tracker
        tracker_content = generate_failure_tracker(suites, failures)
        with open("TEST_FAILURE_TRACKER.md", "w") as f:
            f.write(tracker_content)

        print("=" * 80)
        print("✅ Generated TEST_FAILURE_TRACKER.md")
        print("=" * 80)

    except FileNotFoundError:
        print(f"Error: Could not find {filename}")
        print("Please run: swift test 2>&1 | tee test-results.txt")
        sys.exit(1)
