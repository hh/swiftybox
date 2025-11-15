// CommTests.swift
// Tests for the `comm` command - compare sorted files line by line

import XCTest
@testable import swiftybox

/// Tests for the `comm` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: POSIX comm command
/// - Compares two sorted files line by line
/// - Output has three columns:
///   Column 1: Lines unique to FILE1
///   Column 2: Lines unique to FILE2 (prefixed with TAB)
///   Column 3: Lines common to both (prefixed with two TABs)
/// - Options: -1, -2, -3 to suppress respective columns
/// - Supports stdin with `-` as filename
///
/// Resources:
/// - POSIX: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/comm.html

final class CommTests: XCTestCase {

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

    // MARK: - Basic Functionality

    func testBasicComm() {
        let file1 = createTempFile(content: "a\nb\nc\n")
        let file2 = createTempFile(content: "b\nc\nd\n")
        defer { cleanup(file1, file2) }

        let result = CommCommand.main(["comm", file1, file2])
        XCTAssertEqual(result, 0)
        // Expected output:
        // a       (only in file1)
        //     b   (common)
        //     c   (common)
        // d       (only in file2)
    }

    func testIdenticalFiles() {
        let file1 = createTempFile(content: "a\nb\nc\n")
        let file2 = createTempFile(content: "a\nb\nc\n")
        defer { cleanup(file1, file2) }

        let result = CommCommand.main(["comm", file1, file2])
        XCTAssertEqual(result, 0)
        // All lines should be in column 3 (common to both)
    }

    func testCompletelyDifferent() {
        let file1 = createTempFile(content: "a\nb\nc\n")
        let file2 = createTempFile(content: "x\ny\nz\n")
        defer { cleanup(file1, file2) }

        let result = CommCommand.main(["comm", file1, file2])
        XCTAssertEqual(result, 0)
        // All lines from file1 in column 1, all from file2 in column 2
    }

    // MARK: - Column Suppression

    func testSuppressColumn1() {
        let file1 = createTempFile(content: "a\nb\n")
        let file2 = createTempFile(content: "b\nc\n")
        defer { cleanup(file1, file2) }

        let result = CommCommand.main(["comm", "-1", file1, file2])
        XCTAssertEqual(result, 0)
        // Should only show columns 2 and 3
    }

    func testSuppressColumn2() {
        let file1 = createTempFile(content: "a\nb\n")
        let file2 = createTempFile(content: "b\nc\n")
        defer { cleanup(file1, file2) }

        let result = CommCommand.main(["comm", "-2", file1, file2])
        XCTAssertEqual(result, 0)
        // Should only show columns 1 and 3
    }

    func testSuppressColumn3() {
        let file1 = createTempFile(content: "a\nb\n")
        let file2 = createTempFile(content: "b\nc\n")
        defer { cleanup(file1, file2) }

        let result = CommCommand.main(["comm", "-3", file1, file2])
        XCTAssertEqual(result, 0)
        // Should only show columns 1 and 2 (differences only)
    }

    func testSuppressMultipleColumns() {
        let file1 = createTempFile(content: "a\nb\n")
        let file2 = createTempFile(content: "b\nc\n")
        defer { cleanup(file1, file2) }

        // Suppress columns 1 and 2, show only common lines
        let result = CommCommand.main(["comm", "-12", file1, file2])
        XCTAssertEqual(result, 0)
    }

    func testSuppressAllColumns() {
        let file1 = createTempFile(content: "a\nb\n")
        let file2 = createTempFile(content: "b\nc\n")
        defer { cleanup(file1, file2) }

        // Suppress all columns - nothing should be output
        let result = CommCommand.main(["comm", "-123", file1, file2])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Edge Cases

    func testEmptyFile1() {
        let file1 = createTempFile(content: "")
        let file2 = createTempFile(content: "a\nb\n")
        defer { cleanup(file1, file2) }

        let result = CommCommand.main(["comm", file1, file2])
        XCTAssertEqual(result, 0)
        // All lines should be in column 2
    }

    func testEmptyFile2() {
        let file1 = createTempFile(content: "a\nb\n")
        let file2 = createTempFile(content: "")
        defer { cleanup(file1, file2) }

        let result = CommCommand.main(["comm", file1, file2])
        XCTAssertEqual(result, 0)
        // All lines should be in column 1
    }

    func testBothFilesEmpty() {
        let file1 = createTempFile(content: "")
        let file2 = createTempFile(content: "")
        defer { cleanup(file1, file2) }

        let result = CommCommand.main(["comm", file1, file2])
        XCTAssertEqual(result, 0)
        // No output
    }

    // MARK: - Error Handling

    func testMissingArguments() {
        let result = CommCommand.main(["comm"])
        XCTAssertNotEqual(result, 0)
    }

    func testOnlyOneFile() {
        let file1 = createTempFile(content: "a\nb\n")
        defer { cleanup(file1) }

        let result = CommCommand.main(["comm", file1])
        XCTAssertNotEqual(result, 0)
    }

    func testNonExistentFile() {
        let file1 = createTempFile(content: "a\nb\n")
        defer { cleanup(file1) }

        let result = CommCommand.main(["comm", file1, "/nonexistent/file"])
        XCTAssertNotEqual(result, 0)
    }

    // MARK: - Sorting Edge Cases

    func testUnsortedFiles() {
        // comm expects sorted input, but should still work
        let file1 = createTempFile(content: "c\na\nb\n")
        let file2 = createTempFile(content: "b\nc\na\n")
        defer { cleanup(file1, file2) }

        // Result will be incorrect for unsorted files, but shouldn't crash
        let result = CommCommand.main(["comm", file1, file2])
        XCTAssertEqual(result, 0)
    }

    func testDuplicateLines() {
        let file1 = createTempFile(content: "a\na\nb\n")
        let file2 = createTempFile(content: "a\nb\nb\n")
        defer { cleanup(file1, file2) }

        let result = CommCommand.main(["comm", file1, file2])
        XCTAssertEqual(result, 0)
    }

    func testSingleLine() {
        let file1 = createTempFile(content: "a\n")
        let file2 = createTempFile(content: "a\n")
        defer { cleanup(file1, file2) }

        let result = CommCommand.main(["comm", file1, file2])
        XCTAssertEqual(result, 0)
    }

    func testNoTrailingNewline() {
        let file1 = createTempFile(content: "a\nb")
        let file2 = createTempFile(content: "b\nc")
        defer { cleanup(file1, file2) }

        let result = CommCommand.main(["comm", file1, file2])
        XCTAssertEqual(result, 0)
    }
}
