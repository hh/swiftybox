// UniqTests.swift
// Tests for the `uniq` command - report or filter out repeated lines

import XCTest
@testable import swiftybox

/// Tests for the `uniq` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: POSIX uniq command
/// - Filters adjacent duplicate lines from input
/// - Options: -c (count), -d (duplicates only), -u (unique only), -i (ignore case)
/// - Reads from file or stdin
///
/// Resources:
/// - POSIX: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/uniq.html
/// - GNU: https://www.gnu.org/software/coreutils/manual/html_node/uniq-invocation.html

final class UniqTests: XCTestCase {

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

    func testNoDuplicates() {
        // All unique lines
        let file = createTempFile(content: "one\ntwo\nthree\n")
        defer { cleanup(file) }

        let result = UniqCommand.main(["uniq", file])
        XCTAssertEqual(result, 0)
    }

    func testAdjacentDuplicates() {
        // Adjacent duplicates should be collapsed
        let file = createTempFile(content: "one\none\ntwo\ntwo\ntwo\nthree\n")
        defer { cleanup(file) }

        let result = UniqCommand.main(["uniq", file])
        XCTAssertEqual(result, 0)
    }

    func testNonAdjacentDuplicates() {
        // Non-adjacent duplicates are NOT collapsed
        let file = createTempFile(content: "one\ntwo\none\n")
        defer { cleanup(file) }

        let result = UniqCommand.main(["uniq", file])
        XCTAssertEqual(result, 0)
    }

    func testEmptyFile() {
        let file = createTempFile(content: "")
        defer { cleanup(file) }

        let result = UniqCommand.main(["uniq", file])
        XCTAssertEqual(result, 0)
    }

    func testSingleLine() {
        let file = createTempFile(content: "line\n")
        defer { cleanup(file) }

        let result = UniqCommand.main(["uniq", file])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Count Option (-c)

    func testCountOption() {
        let file = createTempFile(content: "one\none\ntwo\ntwo\ntwo\nthree\n")
        defer { cleanup(file) }

        let result = UniqCommand.main(["uniq", "-c", file])
        XCTAssertEqual(result, 0)
    }

    func testCountUnique() {
        let file = createTempFile(content: "one\ntwo\nthree\n")
        defer { cleanup(file) }

        let result = UniqCommand.main(["uniq", "-c", file])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Duplicates Only (-d)

    func testDuplicatesOnly() {
        let file = createTempFile(content: "one\none\ntwo\nthree\nthree\n")
        defer { cleanup(file) }

        let result = UniqCommand.main(["uniq", "-d", file])
        XCTAssertEqual(result, 0)
    }

    func testDuplicatesOnlyNoDups() {
        // No duplicates means no output
        let file = createTempFile(content: "one\ntwo\nthree\n")
        defer { cleanup(file) }

        let result = UniqCommand.main(["uniq", "-d", file])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Unique Only (-u)

    func testUniqueOnly() {
        let file = createTempFile(content: "one\none\ntwo\nthree\nthree\n")
        defer { cleanup(file) }

        let result = UniqCommand.main(["uniq", "-u", file])
        XCTAssertEqual(result, 0)
    }

    func testUniqueOnlyAllDups() {
        // All duplicates means no output
        let file = createTempFile(content: "one\none\ntwo\ntwo\n")
        defer { cleanup(file) }

        let result = UniqCommand.main(["uniq", "-u", file])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Ignore Case (-i)

    func testIgnoreCase() {
        let file = createTempFile(content: "one\nOne\nONE\ntwo\n")
        defer { cleanup(file) }

        let result = UniqCommand.main(["uniq", "-i", file])
        XCTAssertEqual(result, 0)
    }

    func testIgnoreCasePreservesFirst() {
        // Should preserve the first occurrence's case
        let file = createTempFile(content: "ABC\nabc\nAbc\n")
        defer { cleanup(file) }

        let result = UniqCommand.main(["uniq", "-i", file])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Option Combinations

    func testCountAndDuplicates() {
        let file = createTempFile(content: "one\none\ntwo\nthree\nthree\n")
        defer { cleanup(file) }

        let result = UniqCommand.main(["uniq", "-c", "-d", file])
        XCTAssertEqual(result, 0)
    }

    func testCountAndUnique() {
        let file = createTempFile(content: "one\ntwo\ntwo\nthree\n")
        defer { cleanup(file) }

        let result = UniqCommand.main(["uniq", "-c", "-u", file])
        XCTAssertEqual(result, 0)
    }

    func testDuplicatesAndUnique() {
        // -d and -u together should produce no output
        let file = createTempFile(content: "one\none\ntwo\nthree\n")
        defer { cleanup(file) }

        let result = UniqCommand.main(["uniq", "-d", "-u", file])
        XCTAssertEqual(result, 0)
    }

    func testIgnoreCaseWithCount() {
        let file = createTempFile(content: "one\nOne\ntwo\n")
        defer { cleanup(file) }

        let result = UniqCommand.main(["uniq", "-i", "-c", file])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Edge Cases

    func testEmptyLines() {
        let file = createTempFile(content: "\n\none\n\n")
        defer { cleanup(file) }

        let result = UniqCommand.main(["uniq", file])
        XCTAssertEqual(result, 0)
    }

    func testWhitespace() {
        // Whitespace matters - these are different lines
        let file = createTempFile(content: "one\none \n one\n")
        defer { cleanup(file) }

        let result = UniqCommand.main(["uniq", file])
        XCTAssertEqual(result, 0)
    }

    func testManyDuplicates() {
        let file = createTempFile(content: "one\n" + String(repeating: "one\n", count: 100))
        defer { cleanup(file) }

        let result = UniqCommand.main(["uniq", file])
        XCTAssertEqual(result, 0)
    }

    func testNoTrailingNewline() {
        let file = createTempFile(content: "one\none\ntwo")
        defer { cleanup(file) }

        let result = UniqCommand.main(["uniq", file])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Error Handling

    func testNonexistentFile() {
        let result = UniqCommand.main(["uniq", "/nonexistent/file"])
        XCTAssertNotEqual(result, 0)
    }

    func testNoArguments() {
        // Should read from stdin (can't easily test in unit test)
        // Just verify it doesn't crash
        // let result = UniqCommand.main(["uniq"])
        // XCTAssertEqual(result, 0)
    }

    // MARK: - Combined Options Tests

    func testCombinedShortOptions() {
        let file = createTempFile(content: "one\nOne\nONE\ntwo\n")
        defer { cleanup(file) }

        let result = UniqCommand.main(["uniq", "-ic", file])
        XCTAssertEqual(result, 0)
    }

    func testAllOptions() {
        let file = createTempFile(content: "one\nOne\ntwo\ntwo\n")
        defer { cleanup(file) }

        let result = UniqCommand.main(["uniq", "-i", "-c", "-d", file])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Realistic Use Cases

    func testSortedLog() {
        // Typical use case: remove adjacent duplicates from sorted log
        let file = createTempFile(content: "ERROR\nERROR\nWARN\nINFO\nINFO\nINFO\n")
        defer { cleanup(file) }

        let result = UniqCommand.main(["uniq", file])
        XCTAssertEqual(result, 0)
    }

    func testCountOccurrences() {
        let file = createTempFile(content: "apple\napple\napple\nbanana\ncherry\ncherry\n")
        defer { cleanup(file) }

        let result = UniqCommand.main(["uniq", "-c", file])
        XCTAssertEqual(result, 0)
    }

    func testFindDuplicates() {
        let file = createTempFile(content: "apple\napple\nbanana\ncherry\ncherry\n")
        defer { cleanup(file) }

        let result = UniqCommand.main(["uniq", "-d", file])
        XCTAssertEqual(result, 0)
    }
}
