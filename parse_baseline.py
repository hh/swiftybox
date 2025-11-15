#!/usr/bin/env python3
"""Parse baseline test results and generate summary"""

import re
import sys

def parse_baseline(filename):
    with open(filename, 'r') as f:
        content = f.read()

    # Find all test suite results
    pattern = r"Test Suite '(\w+)Tests' (passed|failed) at.*\n\s+Executed (\d+) tests?, with (\d+) failures?"
    matches = re.findall(pattern, content)

    results = {}
    for command, status, total, failures in matches:
        total = int(total)
        failures = int(failures)
        passing = total - failures

        results[command] = {
            'total': total,
            'passing': passing,
            'failing': failures,
            'status': '✅' if failures == 0 else '❌' if passing == 0 else '⚠️'
        }

    return results

def print_summary(results):
    print("# Baseline Test Results by Command\n")
    print("| Command | Total | Passing | Failing | Status |")
    print("|---------|-------|---------|---------|--------|")

    for cmd in sorted(results.keys()):
        r = results[cmd]
        print(f"| {cmd} | {r['total']} | {r['passing']} | {r['failing']} | {r['status']} |")

    # Summary stats
    total_tests = sum(r['total'] for r in results.values())
    total_passing = sum(r['passing'] for r in results.values())
    total_failing = sum(r['failing'] for r in results.values())

    fully_passing = sum(1 for r in results.values() if r['failing'] == 0 and r['total'] > 0)
    partially_passing = sum(1 for r in results.values() if r['passing'] > 0 and r['failing'] > 0)
    fully_failing = sum(1 for r in results.values() if r['passing'] == 0 and r['total'] > 0)

    print(f"\n## Summary")
    print(f"- **Total Commands**: {len(results)}")
    print(f"- **Total Tests**: {total_tests}")
    print(f"- **Passing Tests**: {total_passing} ({100*total_passing//total_tests}%)")
    print(f"- **Failing Tests**: {total_failing} ({100*total_failing//total_tests}%)")
    print(f"\n### Commands by Status")
    print(f"- ✅ **Fully Passing**: {fully_passing} commands")
    print(f"- ⚠️ **Partially Passing**: {partially_passing} commands")
    print(f"- ❌ **Fully Failing**: {fully_failing} commands")

if __name__ == '__main__':
    results = parse_baseline('baseline-results.txt')
    print_summary(results)
