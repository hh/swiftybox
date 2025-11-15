#!/usr/bin/env python3
"""
Import BusyBox test cases and convert them to Swift test format.

This script parses BusyBox .tests files (which use the testing.sh framework)
and generates Swift XCTest test cases.

Usage:
    ./import-busybox-tests.py ../busybox/testsuite/echo.tests > Tests/SwiftyBoxTests/Generated/EchoTests.swift
    ./import-busybox-tests.py --all ../busybox/testsuite/
"""

import re
import sys
import argparse
from pathlib import Path
from typing import List, Dict, Optional, Tuple


class BusyBoxTest:
    """Represents a single BusyBox test case"""

    def __init__(self, name: str, command: str, expected: str,
                 input_file: str = "", stdin: str = ""):
        self.name = name
        self.command = command
        self.expected = expected
        self.input_file = input_file
        self.stdin = stdin

    def to_swift_method(self, index: int) -> str:
        """Convert to Swift XCTest method"""
        # Clean up name for Swift method name
        sanitized = self._sanitize_name(self.name or f"Test{index}")
        # Add index to ensure uniqueness
        method_name = f"test{sanitized}_{index}"

        # Escape strings for Swift
        name_escaped = self._escape_swift_string(self.name)
        command_escaped = self._escape_swift_string(self.command)
        expected_escaped = self._escape_swift_string(self.expected)
        input_escaped = self._escape_swift_string(self.input_file)
        stdin_escaped = self._escape_swift_string(self.stdin)

        # Build test method
        lines = [
            f"    func {method_name}() {{",
            f"        runner.testing(",
            f'            "{name_escaped}",',
            f'            command: "{command_escaped}",',
        ]

        # Add expected output
        has_more = self.input_file or self.stdin
        if has_more:
            lines.append(f'            expectedOutput: "{expected_escaped}",')
        else:
            lines.append(f'            expectedOutput: "{expected_escaped}"')

        # Add optional parameters
        if self.input_file and self.stdin:
            lines.append(f'            inputFile: "{input_escaped}",')
            lines.append(f'            stdin: "{stdin_escaped}"')
        elif self.input_file:
            lines.append(f'            inputFile: "{input_escaped}"')
        elif self.stdin:
            lines.append(f'            stdin: "{stdin_escaped}"')

        lines.append("        )")
        lines.append("    }")

        return "\n".join(lines)

    @staticmethod
    def _sanitize_name(name: str) -> str:
        """Convert test name to valid Swift method name"""
        # Remove special characters, replace spaces with underscores
        name = re.sub(r'[^a-zA-Z0-9_]', '_', name)
        # Remove leading digits
        name = re.sub(r'^[0-9]+', '', name)
        # Capitalize first letter of each word
        parts = name.split('_')
        return ''.join(p.capitalize() for p in parts if p)

    @staticmethod
    def _escape_swift_string(s: str) -> str:
        """Escape string for Swift string literal"""
        if not s:
            return ""
        return (s.replace('\\', '\\\\')
                 .replace('"', '\\"')
                 .replace('\n', '\\n')
                 .replace('\t', '\\t')
                 .replace('\r', '\\r'))


def preprocess_multiline_content(content: str) -> str:
    """Join lines ending with backslash continuation"""
    lines = content.split('\n')
    result = []
    i = 0

    while i < len(lines):
        line = lines[i]
        # Check if line ends with backslash (continuation)
        while i < len(lines) and line.rstrip().endswith('\\'):
            # Remove trailing backslash and whitespace
            line = line.rstrip()[:-1].rstrip()
            i += 1
            if i < len(lines):
                # Append next line (with leading whitespace removed)
                line += ' ' + lines[i].lstrip()
        result.append(line)
        i += 1

    return '\n'.join(result)


def parse_busybox_test_file(filepath: Path) -> Tuple[str, List[BusyBoxTest]]:
    """Parse a BusyBox .tests file and extract test cases"""
    tests = []
    raw_content = filepath.read_text()

    # Preprocess: join multi-line continuations
    content = preprocess_multiline_content(raw_content)

    # Extract command name from filename
    command_name = filepath.stem.replace('.tests', '')

    # Pattern to match testing() function calls
    # testing "description" "command" "expected" "input" "stdin"
    pattern = r'''testing\s+
        ['"]([^'"]*)['"]\s+           # Test name (group 1)
        ['"]([^'"]*)['"]\s+           # Command (group 2)
        ['"]([^'"]*)['"]\s*           # Expected output (group 3)
        (?:['"]([^'"]*)['"]\s*)?      # Input file (group 4, optional)
        (?:['"]([^'"]*)['"]\s*)?      # Stdin (group 5, optional)
    '''

    # Also handle multi-line strings in shell scripts
    # This is a simplified parser - may need enhancement
    for match in re.finditer(pattern, content, re.VERBOSE | re.MULTILINE):
        name = match.group(1) or ""
        command = match.group(2) or ""
        expected = match.group(3) or ""
        input_file = match.group(4) or ""
        stdin = match.group(5) or ""

        tests.append(BusyBoxTest(name, command, expected, input_file, stdin))

    return command_name, tests


def generate_swift_test_file(command_name: str, tests: List[BusyBoxTest]) -> str:
    """Generate complete Swift test file"""
    class_name = command_name.capitalize() + "Tests"

    lines = [
        f"// {class_name}.swift",
        f"// Auto-generated from BusyBox {command_name}.tests",
        "// DO NOT EDIT - regenerate with import-busybox-tests.py",
        "",
        "import XCTest",
        "",
        f"final class {class_name}: XCTestCase {{",
        "    var runner: TestRunner!",
        "    var swiftyboxPath: String {",
        "        let cwd = FileManager.default.currentDirectoryPath",
        '        return "\\(cwd)/.build/debug/swiftybox"',
        "    }",
        "",
        "    override func setUp() {",
        "        super.setUp()",
        '        runner = TestRunner(verbose: ProcessInfo.processInfo.environment["VERBOSE"] != nil,',
        "                           swiftyboxPath: swiftyboxPath)",
        "    }",
        "",
        "    override func tearDown() {",
        "        runner.printSummary()",
        '        XCTAssertEqual(runner.failureCount, 0, "\\(runner.failureCount) tests failed")',
        "        super.tearDown()",
        "    }",
        "",
    ]

    # Add test methods
    for i, test in enumerate(tests, 1):
        lines.append(test.to_swift_method(i))
        lines.append("")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(
        description="Import BusyBox tests and convert to Swift"
    )
    parser.add_argument("path", help="Path to .tests file or testsuite directory")
    parser.add_argument("--all", action="store_true",
                       help="Process all .tests files in directory")
    parser.add_argument("--output-dir", default="Tests/SwiftyBoxTests/Generated",
                       help="Output directory for generated tests")

    args = parser.parse_args()
    path = Path(args.path)

    if args.all:
        if not path.is_dir():
            print(f"Error: {path} is not a directory", file=sys.stderr)
            sys.exit(1)

        output_dir = Path(args.output_dir)
        output_dir.mkdir(parents=True, exist_ok=True)

        # Process all .tests files
        for test_file in sorted(path.glob("*.tests")):
            command_name, tests = parse_busybox_test_file(test_file)

            if not tests:
                print(f"Skipping {test_file.name}: no tests found", file=sys.stderr)
                continue

            swift_code = generate_swift_test_file(command_name, tests)
            output_file = output_dir / f"{command_name.capitalize()}Tests.swift"

            output_file.write_text(swift_code)
            print(f"Generated {output_file} ({len(tests)} tests)")

    else:
        if not path.exists():
            print(f"Error: {path} does not exist", file=sys.stderr)
            sys.exit(1)

        command_name, tests = parse_busybox_test_file(path)

        if not tests:
            print(f"Warning: no tests found in {path}", file=sys.stderr)

        swift_code = generate_swift_test_file(command_name, tests)
        print(swift_code)


if __name__ == "__main__":
    main()
