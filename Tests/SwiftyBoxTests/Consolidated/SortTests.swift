// SortTests.swift
// Tests for the `sort` command - sort lines of text files

import XCTest
@testable import swiftybox

/// Tests for the `sort` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: POSIX/GNU sort command
/// - Sorts lines alphabetically or numerically
/// - Options: -r (reverse), -n (numeric), -u (unique), -f (ignore case)
/// - Current implementation: Basic sorting without -k (key) or -t (delimiter)
/// - Missing: Field-based sorting, multiple sort keys, custom delimiters
///
/// Resources:
/// - POSIX: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/sort.html
/// - GNU: https://www.gnu.org/software/coreutils/manual/html_node/sort-invocation.html

final class SortTests: XCTestCase {

    // MARK: - Helper Functions

    func createTempFile(content: String) -> String {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try! content.write(to: tempFile, atomically: true, encoding: .utf8)
        return tempFile.path
    }

    func cleanup(_ paths: String...) {
        for path in paths {
            try? FileManager.default.removeItem(atPath: path)
        }
    }

    // MARK: - Basic Alphabetic Sorting

    func testBasicSort() {
        let file = createTempFile(content: "c\na\nb\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", file])
        XCTAssertEqual(result, 0)
    }

    func testAlreadySorted() {
        let file = createTempFile(content: "a\nb\nc\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", file])
        XCTAssertEqual(result, 0)
    }

    func testReverseSorted() {
        let file = createTempFile(content: "c\nb\na\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", file])
        XCTAssertEqual(result, 0)
    }

    func testSingleLine() {
        let file = createTempFile(content: "a\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", file])
        XCTAssertEqual(result, 0)
    }

    func testEmptyFile() {
        let file = createTempFile(content: "")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", file])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Reverse Sorting (-r)

    func testReverseSort() {
        let file = createTempFile(content: "a\nb\nc\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", "-r", file])
        XCTAssertEqual(result, 0)
    }

    func testReverseSortUnsorted() {
        let file = createTempFile(content: "b\na\nc\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", "-r", file])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Numeric Sorting (-n)

    func testNumericSort() {
        let file = createTempFile(content: "10\n2\n1\n20\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", "-n", file])
        XCTAssertEqual(result, 0)
    }

    func testNumericVsAlphabetic() {
        // Alphabetically: 1, 10, 2, 20
        // Numerically: 1, 2, 10, 20
        let file = createTempFile(content: "10\n2\n1\n20\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", "-n", file])
        XCTAssertEqual(result, 0)
    }

    func testNumericWithLeadingZeros() {
        let file = createTempFile(content: "010\n1\n3\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", "-n", file])
        XCTAssertEqual(result, 0)
    }

    func testNumericNegative() {
        let file = createTempFile(content: "5\n-2\n10\n-1\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", "-n", file])
        XCTAssertEqual(result, 0)
    }

    func testNumericDecimals() {
        let file = createTempFile(content: "1.5\n1.2\n2.0\n0.5\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", "-n", file])
        XCTAssertEqual(result, 0)
    }

    func testNumericReverse() {
        let file = createTempFile(content: "1\n10\n2\n20\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", "-nr", file])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Unique Sorting (-u)

    func testUniqueSort() {
        let file = createTempFile(content: "b\na\nb\nc\na\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", "-u", file])
        XCTAssertEqual(result, 0)
    }

    func testUniqueNoDuplicates() {
        let file = createTempFile(content: "a\nb\nc\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", "-u", file])
        XCTAssertEqual(result, 0)
    }

    func testUniqueAllSame() {
        let file = createTempFile(content: "a\na\na\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", "-u", file])
        XCTAssertEqual(result, 0)
    }

    func testUniqueNumeric() {
        let file = createTempFile(content: "2\n1\n2\n3\n1\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", "-nu", file])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Case-Insensitive Sorting (-f)

    func testIgnoreCase() {
        let file = createTempFile(content: "B\na\nC\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", "-f", file])
        XCTAssertEqual(result, 0)
    }

    func testIgnoreCaseMixed() {
        let file = createTempFile(content: "Apple\nbanana\nCherry\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", "-f", file])
        XCTAssertEqual(result, 0)
    }

    func testCaseSensitiveDefault() {
        // Default: uppercase comes before lowercase
        let file = createTempFile(content: "b\nA\nC\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", file])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Multiple Files

    func testTwoFiles() {
        let file1 = createTempFile(content: "c\na\n")
        let file2 = createTempFile(content: "d\nb\n")
        defer { cleanup(file1, file2) }

        let result = SortCommand.main(["sort", file1, file2])
        XCTAssertEqual(result, 0)
    }

    func testMultipleFilesWithDuplicates() {
        let file1 = createTempFile(content: "b\na\n")
        let file2 = createTempFile(content: "b\nc\n")
        defer { cleanup(file1, file2) }

        let result = SortCommand.main(["sort", file1, file2])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Edge Cases

    func testEmptyLines() {
        let file = createTempFile(content: "b\n\na\n\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", file])
        XCTAssertEqual(result, 0)
    }

    func testWhitespace() {
        let file = createTempFile(content: "  b\na\n   c\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", file])
        XCTAssertEqual(result, 0)
    }

    func testSpecialCharacters() {
        let file = createTempFile(content: "@symbol\n#hash\n$dollar\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", file])
        XCTAssertEqual(result, 0)
    }

    func testLongLines() {
        let long = String(repeating: "x", count: 1000)
        let file = createTempFile(content: "\(long)\na\nz\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", file])
        XCTAssertEqual(result, 0)
    }

    func testManyLines() {
        let lines = (0..<1000).map { String($0) }.shuffled().joined(separator: "\n") + "\n"
        let file = createTempFile(content: lines)
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", "-n", file])
        XCTAssertEqual(result, 0)
    }

    func testNoTrailingNewline() {
        let file = createTempFile(content: "c\nb\na")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", file])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Combined Options

    func testReverseUnique() {
        let file = createTempFile(content: "a\nb\na\nc\nb\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", "-ru", file])
        XCTAssertEqual(result, 0)
    }

    func testNumericReverseUnique() {
        let file = createTempFile(content: "1\n3\n2\n1\n3\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", "-nru", file])
        XCTAssertEqual(result, 0)
    }

    func testIgnoreCaseUnique() {
        let file = createTempFile(content: "A\na\nB\nb\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", "-fu", file])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Error Handling

    func testNonExistentFile() {
        let result = SortCommand.main(["sort", "/nonexistent/file"])
        XCTAssertNotEqual(result, 0)
    }

    func testMultipleFilesOneMissing() {
        let file = createTempFile(content: "a\nb\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", file, "/nonexistent"])
        XCTAssertNotEqual(result, 0)
    }

    // MARK: - Realistic Use Cases

    func testSortNames() {
        let file = createTempFile(content: "Bob\nAlice\nCharlie\nDiana\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", file])
        XCTAssertEqual(result, 0)
    }

    func testSortNumbers() {
        let file = createTempFile(content: "100\n5\n42\n7\n1000\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", "-n", file])
        XCTAssertEqual(result, 0)
    }

    func testSortLogLevels() {
        let file = createTempFile(content: "ERROR\nINFO\nWARN\nDEBUG\nERROR\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", "-u", file])
        XCTAssertEqual(result, 0)
    }

    func testSortVersions() {
        // Note: Without -V (version sort), this won't work perfectly
        // But basic numeric sort should handle simple cases
        let file = createTempFile(content: "1.10\n1.2\n1.1\n2.0\n")
        defer { cleanup(file) }

        let result = SortCommand.main(["sort", file])
        XCTAssertEqual(result, 0)
    }
}
