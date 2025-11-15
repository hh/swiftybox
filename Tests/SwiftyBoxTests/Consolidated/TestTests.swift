// TestTests.swift
// Tests for the `test` command - conditional expression evaluator

import XCTest
@testable import swiftybox

/// Tests for the `test` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: POSIX test command
/// - The `test` command evaluates conditional expressions
/// - Returns 0 (true) or 1 (false)
/// - Also aliased as `[` command (requires trailing `]`)
/// - Supports string tests, numeric tests, file tests, and logical operators
///
/// Resources:
/// - POSIX: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/test.html

final class TestTests: XCTestCase {

    // MARK: - Basic Functionality

    func testEmptyExpression() {
        // Empty expression is false
        let result = TestCommand.main(["test"])
        XCTAssertEqual(result, 1)
    }

    func testSingleStringNonEmpty() {
        // Non-empty string is true
        let result = TestCommand.main(["test", "a"])
        XCTAssertEqual(result, 0)
    }

    func testSingleStringEmpty() {
        // Empty string would require explicit empty arg, but we can't really test that
        // In shell: test "" returns 1
        // For our implementation, we test with single arg
        let result = TestCommand.main(["test", ""])
        XCTAssertEqual(result, 1)
    }

    // MARK: - Negation Operator

    func testNegationOfEmptyExpression() {
        // ! alone is true (negation of false)
        let result = TestCommand.main(["test", "!"])
        XCTAssertEqual(result, 0)
    }

    func testNegationOfNonEmptyString() {
        // ! with another arg is false (negation of true)
        let result = TestCommand.main(["test", "!", "a"])
        XCTAssertEqual(result, 1)
    }

    // MARK: - String Comparison Operators

    func testStringEqual() {
        let result = TestCommand.main(["test", "a", "=", "a"])
        XCTAssertEqual(result, 0)
    }

    func testStringNotEqual() {
        let result = TestCommand.main(["test", "a", "!=", "b"])
        XCTAssertEqual(result, 0)
    }

    func testStringEqualWithDoubleEquals() {
        let result = TestCommand.main(["test", "foo", "==", "foo"])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Integer Comparison Operators

    func testIntegerEqual() {
        let result = TestCommand.main(["test", "5", "-eq", "5"])
        XCTAssertEqual(result, 0)
    }

    func testIntegerNotEqual() {
        let result = TestCommand.main(["test", "5", "-ne", "3"])
        XCTAssertEqual(result, 0)
    }

    func testIntegerGreaterThan() {
        let result = TestCommand.main(["test", "5", "-gt", "3"])
        XCTAssertEqual(result, 0)
    }

    func testIntegerLessThan() {
        let result = TestCommand.main(["test", "3", "-lt", "5"])
        XCTAssertEqual(result, 0)
    }

    func testIntegerGreaterOrEqual() {
        let result = TestCommand.main(["test", "5", "-ge", "5"])
        XCTAssertEqual(result, 0)
    }

    func testIntegerLessOrEqual() {
        let result = TestCommand.main(["test", "5", "-le", "5"])
        XCTAssertEqual(result, 0)
    }

    // MARK: - String Tests (unary operators)

    func testStringNonEmpty() {
        let result = TestCommand.main(["test", "-n", "hello"])
        XCTAssertEqual(result, 0)
    }

    func testStringEmpty() {
        let result = TestCommand.main(["test", "-z", ""])
        XCTAssertEqual(result, 0)
    }

    func testStringZeroNonEmpty() {
        let result = TestCommand.main(["test", "-z", "hello"])
        XCTAssertEqual(result, 1)
    }

    // MARK: - File Tests

    func testFileExists() {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        FileManager.default.createFile(atPath: tempFile.path, contents: Data())
        defer { try? FileManager.default.removeItem(at: tempFile) }

        let result = TestCommand.main(["test", "-e", tempFile.path])
        XCTAssertEqual(result, 0)
    }

    func testFileNotExists() {
        let nonExistent = "/tmp/nonexistent-\(UUID().uuidString)"
        let result = TestCommand.main(["test", "-e", nonExistent])
        XCTAssertEqual(result, 1)
    }

    func testRegularFile() {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        FileManager.default.createFile(atPath: tempFile.path, contents: Data())
        defer { try? FileManager.default.removeItem(at: tempFile) }

        let result = TestCommand.main(["test", "-f", tempFile.path])
        XCTAssertEqual(result, 0)
    }

    func testDirectory() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let result = TestCommand.main(["test", "-d", tempDir.path])
        XCTAssertEqual(result, 0)
    }

    func testFileSize() {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? "test content".write(to: tempFile, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: tempFile) }

        let result = TestCommand.main(["test", "-s", tempFile.path])
        XCTAssertEqual(result, 0)
    }

    func testFileSizeZero() {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        FileManager.default.createFile(atPath: tempFile.path, contents: Data())
        defer { try? FileManager.default.removeItem(at: tempFile) }

        let result = TestCommand.main(["test", "-s", tempFile.path])
        XCTAssertEqual(result, 1)
    }

    // MARK: - Logical Operators

    func testLogicalAnd() {
        // true AND true = true
        let result = TestCommand.main(["test", "a", "-a", "b"])
        XCTAssertEqual(result, 0)
    }

    func testLogicalAndWithFalse() {
        // true AND false = false
        let result = TestCommand.main(["test", "a", "-a", ""])
        XCTAssertEqual(result, 1)
    }

    func testLogicalOr() {
        // false OR true = true
        let result = TestCommand.main(["test", "", "-o", "b"])
        XCTAssertEqual(result, 0)
    }

    func testLogicalOrBothFalse() {
        // false OR false = false
        let result = TestCommand.main(["test", "", "-o", ""])
        XCTAssertEqual(result, 1)
    }

    // MARK: - Complex Expressions

    func testComplexNegationAndComparison() {
        // ! a = b is true (because a != b)
        let result = TestCommand.main(["test", "!", "a", "=", "b"])
        XCTAssertEqual(result, 0)
    }

    func testComplexNegationOfEqual() {
        // ! a = a is false (because a == a)
        let result = TestCommand.main(["test", "!", "a", "=", "a"])
        XCTAssertEqual(result, 1)
    }

    func testComplexAndOr() {
        // (a = a) AND (b = c) is false
        let result = TestCommand.main(["test", "a", "=", "a", "-a", "b", "=", "c"])
        XCTAssertEqual(result, 1)
    }

    func testComplexAndOrTrue() {
        // (a = a) AND (c = c) is true
        let result = TestCommand.main(["test", "a", "=", "a", "-a", "c", "=", "c"])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Edge Cases

    func testOperatorAsOperand() {
        // When an operator appears where an operand is expected
        // For example: test -lt = -gt  should be treated as string comparison
        let result = TestCommand.main(["test", "-lt", "=", "-gt"])
        XCTAssertEqual(result, 1)  // -lt != -gt
    }

    func testOptionAsString() {
        // test --help should be true (non-empty string)
        let result = TestCommand.main(["test", "--help"])
        XCTAssertEqual(result, 0)
    }

    func testDashFAsString() {
        // test -f alone should be treated as a non-empty string
        let result = TestCommand.main(["test", "-f"])
        XCTAssertEqual(result, 0)
    }

    func testNegatedDashF() {
        // test ! -f should be false (negation of non-empty string)
        let result = TestCommand.main(["test", "!", "-f"])
        XCTAssertEqual(result, 1)
    }
}
