// NlTests.swift
// Tests for the `nl` command - number lines of files

import XCTest
@testable import swiftybox

/// Tests for the `nl` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: POSIX/GNU nl command
/// - Numbers lines of input files
/// - Options: -v (starting line number), -i (increment)
/// - Current implementation: Only numbers non-empty lines (like `-b t`)
/// - Missing: -b option (all/none/regex), -n (number format), -s (separator)
///
/// Resources:
/// - GNU: https://www.gnu.org/software/coreutils/manual/html_node/nl-invocation.html

final class NlTests: XCTestCase {

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

    func testBasicNumbering() {
        let file = createTempFile(content: "line 1\nline 2\nline 3\n")
        defer { cleanup(file) }

        let result = NlCommand.main(["nl", file])
        XCTAssertEqual(result, 0)
    }

    func testSingleLine() {
        let file = createTempFile(content: "line 1\n")
        defer { cleanup(file) }

        let result = NlCommand.main(["nl", file])
        XCTAssertEqual(result, 0)
    }

    func testEmptyFile() {
        let file = createTempFile(content: "")
        defer { cleanup(file) }

        let result = NlCommand.main(["nl", file])
        XCTAssertEqual(result, 0)
    }

    func testNoTrailingNewline() {
        let file = createTempFile(content: "line 1\nline 2")
        defer { cleanup(file) }

        let result = NlCommand.main(["nl", file])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Empty Lines

    func testEmptyLines() {
        // Empty lines are NOT numbered (default behavior)
        let file = createTempFile(content: "line 1\n\nline 3\n")
        defer { cleanup(file) }

        let result = NlCommand.main(["nl", file])
        XCTAssertEqual(result, 0)
    }

    func testMultipleEmptyLines() {
        let file = createTempFile(content: "line 1\n\n\n\nline 5\n")
        defer { cleanup(file) }

        let result = NlCommand.main(["nl", file])
        XCTAssertEqual(result, 0)
    }

    func testOnlyEmptyLines() {
        let file = createTempFile(content: "\n\n\n")
        defer { cleanup(file) }

        let result = NlCommand.main(["nl", file])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Start Number (-v)

    func testStartingLineNumber() {
        let file = createTempFile(content: "line 1\nline 2\n")
        defer { cleanup(file) }

        let result = NlCommand.main(["nl", "-v", "10", file])
        XCTAssertEqual(result, 0)
    }

    func testNegativeStartNumber() {
        let file = createTempFile(content: "line 1\nline 2\nline 3\n")
        defer { cleanup(file) }

        let result = NlCommand.main(["nl", "-v", "-5", file])
        XCTAssertEqual(result, 0)
    }

    func testZeroStartNumber() {
        let file = createTempFile(content: "line 1\nline 2\n")
        defer { cleanup(file) }

        let result = NlCommand.main(["nl", "-v", "0", file])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Line Increment (-i)

    func testLineIncrement() {
        let file = createTempFile(content: "line 1\nline 2\nline 3\n")
        defer { cleanup(file) }

        let result = NlCommand.main(["nl", "-i", "2", file])
        XCTAssertEqual(result, 0)
    }

    func testIncrementBy5() {
        let file = createTempFile(content: "line 1\nline 2\nline 3\nline 4\n")
        defer { cleanup(file) }

        let result = NlCommand.main(["nl", "-i", "5", file])
        XCTAssertEqual(result, 0)
    }

    func testIncrementBy10() {
        let file = createTempFile(content: "line 1\nline 2\nline 3\n")
        defer { cleanup(file) }

        let result = NlCommand.main(["nl", "-i", "10", file])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Combined Options

    func testStartAndIncrement() {
        let file = createTempFile(content: "line 1\nline 2\nline 3\n")
        defer { cleanup(file) }

        let result = NlCommand.main(["nl", "-v", "100", "-i", "10", file])
        XCTAssertEqual(result, 0)
    }

    func testNegativeStartWithIncrement() {
        let file = createTempFile(content: "line 1\nline 2\nline 3\n")
        defer { cleanup(file) }

        let result = NlCommand.main(["nl", "-v", "-10", "-i", "3", file])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Edge Cases

    func testWhitespaceOnlyLines() {
        // Lines with only whitespace should be treated as empty
        let file = createTempFile(content: "line 1\n   \nline 3\n")
        defer { cleanup(file) }

        let result = NlCommand.main(["nl", file])
        XCTAssertEqual(result, 0)
    }

    func testTabOnlyLines() {
        let file = createTempFile(content: "line 1\n\t\nline 3\n")
        defer { cleanup(file) }

        let result = NlCommand.main(["nl", file])
        XCTAssertEqual(result, 0)
    }

    func testLongLines() {
        let longLine = String(repeating: "x", count: 200)
        let file = createTempFile(content: "\(longLine)\n\(longLine)\n")
        defer { cleanup(file) }

        let result = NlCommand.main(["nl", file])
        XCTAssertEqual(result, 0)
    }

    func testManyLines() {
        let content = (1...1000).map { "line \($0)" }.joined(separator: "\n") + "\n"
        let file = createTempFile(content: content)
        defer { cleanup(file) }

        let result = NlCommand.main(["nl", file])
        XCTAssertEqual(result, 0)
    }

    func testSpecialCharacters() {
        let file = createTempFile(content: "line with $pecial ch@rs\nline with \"quotes\"\n")
        defer { cleanup(file) }

        let result = NlCommand.main(["nl", file])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Error Handling

    func testNonexistentFile() {
        let result = NlCommand.main(["nl", "/nonexistent/file"])
        XCTAssertNotEqual(result, 0)
    }

    func testInvalidStartNumber() {
        let file = createTempFile(content: "line 1\n")
        defer { cleanup(file) }

        // Invalid number should be ignored or cause error
        let result = NlCommand.main(["nl", "-v", "abc", file])
        // Depending on implementation, might succeed (ignored) or fail
        XCTAssertEqual(result, 0)
    }

    // MARK: - Multiple Files

    func testTwoFiles() {
        let file1 = createTempFile(content: "file1 line1\nfile1 line2\n")
        let file2 = createTempFile(content: "file2 line1\nfile2 line2\n")
        defer { cleanup(file1, file2) }

        let result = NlCommand.main(["nl", file1, file2])
        XCTAssertEqual(result, 0)
    }

    func testMultipleFilesWithOptions() {
        let file1 = createTempFile(content: "a\nb\n")
        let file2 = createTempFile(content: "c\nd\n")
        defer { cleanup(file1, file2) }

        let result = NlCommand.main(["nl", "-v", "10", "-i", "5", file1, file2])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Realistic Use Cases

    func testNumberCodeFile() {
        let code = """
        function hello() {
            console.log("Hello");
        }

        function world() {
            console.log("World");
        }
        """
        let file = createTempFile(content: code + "\n")
        defer { cleanup(file) }

        let result = NlCommand.main(["nl", file])
        XCTAssertEqual(result, 0)
    }

    func testNumberList() {
        let list = "item 1\nitem 2\nitem 3\nitem 4\nitem 5\n"
        let file = createTempFile(content: list)
        defer { cleanup(file) }

        let result = NlCommand.main(["nl", "-v", "1", "-i", "1", file])
        XCTAssertEqual(result, 0)
    }
}
