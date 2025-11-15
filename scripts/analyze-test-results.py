#!/usr/bin/env python3
"""
Analyze SwiftyBox test results and generate failure tracker updates.

Usage:
    swift test 2>&1 | tee test.log
    python3 scripts/analyze-test-results.py test.log
"""

import re
import sys
from pathlib import Path
from collections import defaultdict
from typing import Dict, List, Tuple

def parse_test_log(log_file: Path) -> Dict:
    """Parse swift test output and extract results"""
    content = log_file.read_text()

    results = {
        'total': 0,
        'passed': 0,
        'failed': 0,
        'skipped': 0,
        'failures': defaultdict(list),
        'by_command': defaultdict(lambda: {'passed': 0, 'failed': 0, 'total': 0})
    }

    # Pattern for test results
    # Test Case '-[SwiftyBoxTests.BasenameTests testBasicUsage]' passed (0.001 seconds).
    # Test Case '-[SwiftyBoxTests.BasenameTests testWithExtension]' failed (0.002 seconds).
    test_pattern = r"Test Case '-\[SwiftyBoxTests\.(\w+)Tests\.(\w+)\]' (passed|failed)"

    for match in re.finditer(test_pattern, content):
        command = match.group(1)
        test_name = match.group(2)
        status = match.group(3)

        results['total'] += 1
        results['by_command'][command]['total'] += 1

        if status == 'passed':
            results['passed'] += 1
            results['by_command'][command]['passed'] += 1
        elif status == 'failed':
            results['failed'] += 1
            results['by_command'][command]['failed'] += 1
            results['failures'][command].append(test_name)
        elif status == 'skipped':
            results['skipped'] += 1

    return results


def generate_summary(results: Dict) -> str:
    """Generate a summary report"""
    total = results['total']
    passed = results['passed']
    failed = results['failed']
    pass_rate = (passed / total * 100) if total > 0 else 0

    summary = []
    summary.append("=" * 70)
    summary.append("SwiftyBox Test Results Summary")
    summary.append("=" * 70)
    summary.append(f"Total Tests:  {total}")
    summary.append(f"Passed:       {passed} ({passed/total*100:.1f}%)" if total > 0 else "Passed:       0")
    summary.append(f"Failed:       {failed} ({failed/total*100:.1f}%)" if total > 0 else "Failed:       0")
    summary.append(f"Pass Rate:    {pass_rate:.1f}%")
    summary.append("=" * 70)
    summary.append("")

    # Commands with failures
    if results['failures']:
        summary.append("Commands with Failures:")
        summary.append("-" * 70)
        for cmd in sorted(results['failures'].keys()):
            stats = results['by_command'][cmd]
            summary.append(f"\n{cmd}Tests: {stats['passed']}/{stats['total']} passing")
            summary.append(f"  Failed tests ({len(results['failures'][cmd])}):")
            for test in sorted(results['failures'][cmd]):
                summary.append(f"    - {test}")

    summary.append("")
    summary.append("=" * 70)
    summary.append("All Commands Status:")
    summary.append("-" * 70)

    for cmd in sorted(results['by_command'].keys()):
        stats = results['by_command'][cmd]
        status_icon = "🟢" if stats['failed'] == 0 else "🔴" if stats['passed'] == 0 else "🟡"
        summary.append(f"{status_icon} {cmd:<20} {stats['passed']:>3}/{stats['total']:<3} ({stats['passed']/stats['total']*100:.0f}%)")

    return "\n".join(summary)


def generate_tracker_update(results: Dict) -> str:
    """Generate markdown to update TEST_FAILURE_TRACKER.md"""
    lines = []
    lines.append("# Auto-Generated Tracker Update")
    lines.append(f"\n**Test Run**: {Path.cwd()}")
    lines.append(f"**Total**: {results['total']} tests")
    lines.append(f"**Passed**: {results['passed']} ({results['passed']/results['total']*100:.1f}%)")
    lines.append(f"**Failed**: {results['failed']} ({results['failed']/results['total']*100:.1f}%)")
    lines.append("\n## Commands by Status:\n")

    for cmd in sorted(results['by_command'].keys()):
        stats = results['by_command'][cmd]
        status = "🟢 PASSING" if stats['failed'] == 0 else "🟡 MIXED" if stats['passed'] > 0 else "🔴 FAILING"

        lines.append(f"### {cmd} ({stats['passed']}/{stats['total']} tests passing)")
        lines.append(f"**Overall Status**: {status}\n")

        if cmd in results['failures']:
            lines.append("#### Failing Tests:\n")
            for i, test in enumerate(sorted(results['failures'][cmd]), 1):
                lines.append(f"{i}. **{test}**")
                lines.append(f"   - Status: 🔴 FAILING")
                lines.append(f"   - Root Cause: [TO BE INVESTIGATED]")
                lines.append(f"   - Priority: P?")
                lines.append(f"   - Notes: \n")
        lines.append("")

    return "\n".join(lines)


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 analyze-test-results.py <test-log-file>")
        sys.exit(1)

    log_file = Path(sys.argv[1])
    if not log_file.exists():
        print(f"Error: {log_file} not found")
        sys.exit(1)

    print("Parsing test results...")
    results = parse_test_log(log_file)

    print("\n" + generate_summary(results))

    # Save tracker update
    tracker_update = generate_tracker_update(results)
    update_file = Path("test-tracker-update.md")
    update_file.write_text(tracker_update)
    print(f"\nTracker update saved to: {update_file}")
    print("\nNext steps:")
    print("1. Review test-tracker-update.md")
    print("2. Merge relevant sections into Tests/SwiftyBoxTests/TEST_FAILURE_TRACKER.md")
    print("3. Investigate and categorize failures")


if __name__ == "__main__":
    main()
