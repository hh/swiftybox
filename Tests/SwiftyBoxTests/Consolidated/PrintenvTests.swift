// PrintenvTests.swift
// Comprehensive tests for the printenv command

import XCTest
@testable import swiftybox

/// Tests for the `printenv` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: GNU coreutils printenv
/// - Prints environment variables
/// - Common usage: printenv (all vars), printenv VAR (specific var)
/// - GNU: printenv [VAR]... (can print multiple vars)
/// - Target scope: P0 (basic functionality)
///
/// Key behaviors to test:
/// - No args: prints all environment variables (VAR=value format)
/// - With arg: prints value of that variable
/// - Multiple args: prints value of each variable
/// - Nonexistent var: no output, exit code 1
/// - Exit code 0 if all vars found
///
/// Resources:
/// - GNU: https://www.gnu.org/software/coreutils/manual/html_node/printenv-invocation.html

final class PrintenvTests: XCTestCase {

    // MARK: - Setup and Teardown

    override func setUp() {
        super.setUp()
        // Set test environment variables
        setenv("SWIFTYBOX_TEST_VAR", "test_value", 1)
        setenv("SWIFTYBOX_TEST_VAR2", "test_value_2", 1)
    }

    override func tearDown() {
        // Clean up test environment variables
        unsetenv("SWIFTYBOX_TEST_VAR")
        unsetenv("SWIFTYBOX_TEST_VAR2")
        super.tearDown()
    }

    // MARK: - Basic Functionality

    func testPrintenvNoArgs() {
        let result = runCommand("printenv", [])

        XCTAssertEqual(result.exitCode, 0, "printenv should succeed")
        XCTAssertFalse(result.stdout.isEmpty, "printenv should output environment variables")
        XCTAssertEqual(result.stderr, "", "printenv should not output to stderr")

        // Should contain multiple variables
        let lines = result.stdout.components(separatedBy: "\n").filter { !$0.isEmpty }
        XCTAssertGreaterThan(lines.count, 5, "Should have multiple environment variables")

        // Each line should be in VAR=value format
        for line in lines {
            XCTAssertTrue(line.contains("="), "Each line should contain '='")
        }
    }

    func testPrintenvSpecificVariable() {
        let result = runCommand("printenv", ["SWIFTYBOX_TEST_VAR"])

        XCTAssertEqual(result.exitCode, 0, "printenv should succeed for existing variable")
        XCTAssertEqual(result.stdout, "test_value\n", "Should print variable value")
        XCTAssertEqual(result.stderr, "", "Should not output to stderr")
    }

    func testPrintenvPATH() {
        let result = runCommand("printenv", ["PATH"])

        XCTAssertEqual(result.exitCode, 0, "printenv PATH should succeed")
        XCTAssertFalse(result.stdout.isEmpty, "PATH should have a value")
        XCTAssertTrue(result.stdout.hasSuffix("\n"), "Should end with newline")

        // PATH typically contains /bin or /usr/bin
        XCTAssertTrue(result.stdout.contains("/bin") || result.stdout.contains("/usr"),
                     "PATH should contain standard directories")
    }

    func testPrintenvHOME() {
        let result = runCommand("printenv", ["HOME"])

        XCTAssertEqual(result.exitCode, 0, "printenv HOME should succeed")
        XCTAssertFalse(result.stdout.isEmpty, "HOME should have a value")
        XCTAssertTrue(result.stdout.starts(with: "/"), "HOME should be absolute path")
    }

    // MARK: - Multiple Variables

    func testPrintenvMultipleVariables() {
        let result = runCommand("printenv", ["SWIFTYBOX_TEST_VAR", "SWIFTYBOX_TEST_VAR2"])

        XCTAssertEqual(result.exitCode, 0, "printenv should succeed for multiple vars")
        XCTAssertTrue(result.stdout.contains("test_value"), "Should contain first value")
        XCTAssertTrue(result.stdout.contains("test_value_2"), "Should contain second value")
    }

    // MARK: - Nonexistent Variables

    func testPrintenvNonexistentVariable() {
        let result = runCommand("printenv", ["NONEXISTENT_VAR_12345"])

        XCTAssertNotEqual(result.exitCode, 0, "printenv should fail for nonexistent variable")
        XCTAssertEqual(result.stdout, "", "Should not output for nonexistent variable")
    }

    func testPrintenvMixedVariables() {
        // One exists, one doesn't
        let result = runCommand("printenv", ["SWIFTYBOX_TEST_VAR", "NONEXISTENT_VAR"])

        // Behavior can vary: some implementations print what they find, others fail
        if result.exitCode == 0 {
            XCTAssertTrue(result.stdout.contains("test_value"),
                         "Should print existing variable")
        }
    }

    // MARK: - Output Format

    func testPrintenvNoArgsFormat() {
        let result = runCommand("printenv", [])

        // Parse as VAR=value lines
        let lines = result.stdout.components(separatedBy: "\n").filter { !$0.isEmpty }

        for line in lines {
            let parts = line.split(separator: "=", maxSplits: 1)
            XCTAssertEqual(parts.count, 2, "Each line should be VAR=value format")

            let varName = String(parts[0])
            XCTAssertFalse(varName.isEmpty, "Variable name should not be empty")
            XCTAssertFalse(varName.contains(" "), "Variable name should not contain spaces")
        }
    }

    func testPrintenvSpecificVarFormat() {
        let result = runCommand("printenv", ["SWIFTYBOX_TEST_VAR"])

        // Should output just the value, not VAR=value
        XCTAssertFalse(result.stdout.contains("="), "Should not contain '=' for specific var")
        XCTAssertEqual(result.stdout, "test_value\n", "Should output just the value")
    }

    func testPrintenvContainsTestVariable() {
        let result = runCommand("printenv", [])

        XCTAssertTrue(result.stdout.contains("SWIFTYBOX_TEST_VAR=test_value"),
                     "Should contain our test variable")
    }

    // MARK: - Edge Cases

    func testPrintenvEmptyValue() {
        setenv("SWIFTYBOX_EMPTY_VAR", "", 1)
        defer { unsetenv("SWIFTYBOX_EMPTY_VAR") }

        let result = runCommand("printenv", ["SWIFTYBOX_EMPTY_VAR"])

        XCTAssertEqual(result.exitCode, 0, "Should succeed for empty variable")
        XCTAssertEqual(result.stdout, "\n", "Should output just newline for empty value")
    }

    func testPrintenvVariableWithEquals() {
        setenv("SWIFTYBOX_EQUALS_VAR", "value=with=equals", 1)
        defer { unsetenv("SWIFTYBOX_EQUALS_VAR") }

        let result = runCommand("printenv", ["SWIFTYBOX_EQUALS_VAR"])

        XCTAssertEqual(result.exitCode, 0, "Should handle value with = signs")
        XCTAssertEqual(result.stdout, "value=with=equals\n", "Should preserve = in value")
    }

    func testPrintenvVariableWithNewline() {
        setenv("SWIFTYBOX_NEWLINE_VAR", "line1\nline2", 1)
        defer { unsetenv("SWIFTYBOX_NEWLINE_VAR") }

        let result = runCommand("printenv", ["SWIFTYBOX_NEWLINE_VAR"])

        XCTAssertEqual(result.exitCode, 0, "Should handle value with newlines")
        XCTAssertTrue(result.stdout.contains("line1"), "Should contain first line")
        XCTAssertTrue(result.stdout.contains("line2"), "Should contain second line")
    }

    // MARK: - Consistency

    func testPrintenvConsistency() {
        let result1 = runCommand("printenv", ["PATH"])
        let result2 = runCommand("printenv", ["PATH"])

        XCTAssertEqual(result1.stdout, result2.stdout,
                      "printenv should produce consistent output")
    }

    // MARK: - No Stdin

    func testPrintenvIgnoresStdin() {
        let result = runCommandWithInput("printenv", ["SWIFTYBOX_TEST_VAR"],
                                         input: "ignored\n")

        XCTAssertEqual(result.exitCode, 0, "printenv should ignore stdin")
        XCTAssertEqual(result.stdout, "test_value\n", "Should output correct value")
    }
}
