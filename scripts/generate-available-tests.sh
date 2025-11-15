#!/bin/bash
# generate-available-tests.sh - Generate Swift tests from all available BusyBox .tests files

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

echo "Scanning for available .tests files..."
echo ""

# Find all .tests files and generate Swift tests for them
count=0
skipped=0

for test_file in "$BUSYBOX_TESTS"/*.tests; do
    if [ ! -f "$test_file" ]; then
        continue
    fi

    # Extract command name from filename
    filename=$(basename "$test_file")
    cmd="${filename%.tests}"

    # Skip some special test files
    if [[ "$cmd" == "all_sourcecode" || "$cmd" == "busybox" || "$cmd" == "parse" ]]; then
        echo "Skipping $cmd (special test file)"
        ((skipped++))
        continue
    fi

    echo "Generating ${cmd}Tests.swift from $filename..."

    # Generate the test file
    if "$SCRIPT_DIR/import-busybox-tests.py" "$test_file" > "$OUTPUT_DIR/${cmd^}Tests.swift" 2>/dev/null; then
        ((count++))
    else
        echo "  Warning: Failed to parse $filename"
        rm -f "$OUTPUT_DIR/${cmd^}Tests.swift"
        ((skipped++))
    fi
done

echo ""
echo "=== Generation Complete ==="
echo "Generated: $count test files"
echo "Skipped: $skipped files"
echo "Output: $OUTPUT_DIR/"
echo ""
echo "Generated test files:"
ls -1 "$OUTPUT_DIR"/*.swift 2>/dev/null | sed 's/.*\//  - /' || echo "  (none)"
echo ""
echo "Next steps:"
echo "  1. Review generated files in $OUTPUT_DIR/"
echo "  2. Run: swift test"
echo "  3. Fix any failing tests"
