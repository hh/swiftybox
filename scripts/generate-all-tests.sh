#!/bin/bash
# generate-all-tests.sh - Generate Swift tests from BusyBox test suite

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUSYBOX_TESTS="../busybox/testsuite"
OUTPUT_DIR="Tests/SwiftyBoxTests/Generated"

echo "=== SwiftyλBox Test Generator ==="
echo ""

# Check if busybox testsuite exists
if [ ! -d "$BUSYBOX_TESTS" ]; then
    echo "Error: BusyBox testsuite not found at $BUSYBOX_TESTS"
    echo "Make sure busybox is cloned at ../busybox/"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "Generating tests from BusyBox testsuite..."
echo ""

# List of commands we've implemented (from PROGRESS.md)
COMMANDS=(
    # Phase 1-5 NOFORK (44 commands)
    "echo" "pwd" "true" "false"
    "basename" "dirname" "link" "unlink" "mkdir" "rmdir" "touch" "sync" "readlink" "realpath"
    "cat" "head" "tail" "grep" "cut" "tr" "tee" "wc" "seq" "yes"
    "uname" "arch" "nproc" "whoami" "logname" "hostid" "tty" "free"
    "env" "printenv" "which" "truncate"
    "test" "printf"
    "sleep"

    # Phase 6 File Operations (8 commands)
    "ls" "cp" "mv" "rm" "ln" "chmod" "chown" "chgrp"

    # Phase 7 Text Processing (6 commands)
    "sort" "uniq" "comm" "fold" "paste" "nl"

    # Phase 8 Checksums & Utilities (8 commands)
    "md5sum" "sha256sum" "sha512sum" "cksum"
    "date" "id" "expr"

    # Phase 9 Simple Utilities (8 commands)
    "tac" "rev" "expand" "hexdump" "shuf" "stat" "du" "df"
)

# Generate tests for each command that has a .tests file
count=0
for cmd in "${COMMANDS[@]}"; do
    test_file="$BUSYBOX_TESTS/$cmd.tests"

    if [ -f "$test_file" ]; then
        echo "Generating ${cmd}Tests.swift..."
        "$SCRIPT_DIR/import-busybox-tests.py" "$test_file" > "$OUTPUT_DIR/${cmd^}Tests.swift"
        ((count++))
    else
        echo "Skipping $cmd (no $cmd.tests file found)"
    fi
done

echo ""
echo "=== Generation Complete ==="
echo "Generated $count test files in $OUTPUT_DIR/"
echo ""
echo "Next steps:"
echo "  1. Review generated files"
echo "  2. Run: swift test"
echo "  3. Fix any failing tests"
echo "  4. Add manual tests for commands without .tests files"
