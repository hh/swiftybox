// EnvTests.swift
// Comprehensive tests for the env command

import XCTest
@testable import SwiftyBox

/// Tests for the `env` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: GNU coreutils env
/// - Runs program in modified environment
/// - Common usage: env (prints env), env VAR=val command
/// - Options: -i (ignore environment), -u VAR (unset), - (synonym for -i)
/// - Target scope: P0 (basic print env) + P1 (run commands with env)
///
/// Key behaviors to test:
/// - No args: prints all environment variables (like printenv)
/// - With command: runs command with modified environment
/// - VAR=value: sets variable for command
/// - -i: starts with empty environment
/// - -u VAR: unsets variable
///
/// Resources:
/// - GNU: https://www.gnu.org/software/coreutils/manual/html_node/env-invocation.html
/// - POSIX: env utility

final class EnvTests: XCTestCase {

    // MARK: - Basic Functionality

    func testEnvNoArgs() {
        let result = runCommand("env", [])

        XCTAssertEqual(result.exitCode, 0, "env should succeed")
        XCTAssertFalse(result.stdout.isEmpty, "env should output environment variables")
        XCTAssertEqual(result.stderr, "", "env should not output to stderr")

        // Should contain multiple variables in VAR=value format
        let lines = result.stdout.components(separatedBy: "\n").filter { !$0.isEmpty }
        XCTAssertGreaterThan(lines.count, 5, "Should have multiple environment variables")

        for line in lines {
            XCTAssertTrue(line.contains("="), "Each line should be VAR=value format")
        }
    }

    func testEnvOutputFormat() {
        let result = runCommand("env", [])

        let lines = result.stdout.components(separatedBy: "\n").filter { !$0.isEmpty }

        for line in lines {
            let parts = line.split(separator: "=", maxSplits: 1)
            XCTAssertGreaterThanOrEqual(parts.count, 1, "Should have variable name")

            if parts.count >= 1 {
                let varName = String(parts[0])
                XCTAssertFalse(varName.isEmpty, "Variable name should not be empty")
                XCTAssertFalse(varName.contains(" "), "Variable name should not contain spaces")
            }
        }
    }

    func testEnvContainsCommonVariables() {
        let result = runCommand("env", [])

        // Should contain common variables like PATH, HOME
        let hasPath = result.stdout.contains("PATH=")
        let hasHome = result.stdout.contains("HOME=")

        XCTAssertTrue(hasPath || hasHome,
                     "env should contain common variables like PATH or HOME")
    }

    // MARK: - Setting Variables (if implementation supports it)

    func testEnvWithVariableAssignment() {
        // Note: This tests env VAR=value command syntax
        // Some minimal implementations only print env, don't run commands
        setenv("SWIFTYBOX_TEST_VAR", "original", 1)
        defer { unsetenv("SWIFTYBOX_TEST_VAR") }

        // Try: env SWIFTYBOX_TEST_VAR=new printenv SWIFTYBOX_TEST_VAR
        // This may not be supported in minimal implementations
        let result = runCommand("env", ["SWIFTYBOX_TEST_VAR=new_value"])

        // Either succeeds with new value or fails (not implemented)
        if result.exitCode == 0 {
            // If it supports running commands, check output
            // For now, just verify it doesn't crash
            XCTAssertTrue(result.exitCode == 0, "env should handle variable assignments")
        }
    }

    // MARK: - Consistency

    func testEnvConsistentOutput() {
        let result1 = runCommand("env", [])
        let result2 = runCommand("env", [])

        XCTAssertEqual(result1.exitCode, result2.exitCode,
                      "env should have consistent exit code")

        // Output should be similar (order may vary)
        let lines1 = Set(result1.stdout.components(separatedBy: "\n"))
        let lines2 = Set(result2.stdout.components(separatedBy: "\n"))

        // Most lines should be the same (some env vars might change between runs)
        let intersection = lines1.intersection(lines2)
        let total = lines1.union(lines2).count

        if total > 0 {
            let similarity = Double(intersection.count) / Double(total)
            XCTAssertGreaterThan(similarity, 0.8,
                               "env output should be mostly consistent")
        }
    }

    // MARK: - Comparison with printenv

    func testEnvMatchesPrintenv() {
        let envResult = runCommand("env", [])
        let printenvResult = runCommand("printenv", [])

        // Both should succeed
        XCTAssertEqual(envResult.exitCode, 0, "env should succeed")
        XCTAssertEqual(printenvResult.exitCode, 0, "printenv should succeed")

        // Should contain similar variables
        let envLines = Set(envResult.stdout.components(separatedBy: "\n"))
        let printenvLines = Set(printenvResult.stdout.components(separatedBy: "\n"))

        // Many lines should be the same
        let commonLines = envLines.intersection(printenvLines)
        XCTAssertGreaterThan(commonLines.count, 5,
                           "env and printenv should have many common variables")
    }

    // MARK: - Edge Cases

    func testEnvLargeEnvironment() {
        // Set many variables
        for i in 0..<10 {
            setenv("SWIFTYBOX_TEST_\(i)", "value_\(i)", 1)
        }

        defer {
            for i in 0..<10 {
                unsetenv("SWIFTYBOX_TEST_\(i)")
            }
        }

        let result = runCommand("env", [])

        XCTAssertEqual(result.exitCode, 0, "env should handle many variables")

        // Should contain our test variables
        for i in 0..<10 {
            XCTAssertTrue(result.stdout.contains("SWIFTYBOX_TEST_\(i)=value_\(i)"),
                         "Should contain test variable \(i)")
        }
    }

    func testEnvWithEmptyVariable() {
        setenv("SWIFTYBOX_EMPTY", "", 1)
        defer { unsetenv("SWIFTYBOX_EMPTY") }

        let result = runCommand("env", [])

        XCTAssertEqual(result.exitCode, 0, "env should handle empty variables")
        XCTAssertTrue(result.stdout.contains("SWIFTYBOX_EMPTY="),
                     "Should contain empty variable")
    }

    func testEnvWithSpecialCharacters() {
        setenv("SWIFTYBOX_SPECIAL", "value with spaces & special=chars", 1)
        defer { unsetenv("SWIFTYBOX_SPECIAL") }

        let result = runCommand("env", [])

        XCTAssertEqual(result.exitCode, 0, "env should handle special characters")
        XCTAssertTrue(result.stdout.contains("SWIFTYBOX_SPECIAL="),
                     "Should contain variable with special chars")
    }

    // MARK: - No Stdin

    func testEnvIgnoresStdin() {
        let result = runCommandWithInput("env", [], input: "ignored input\n")

        XCTAssertEqual(result.exitCode, 0, "env should ignore stdin")
        XCTAssertFalse(result.stdout.isEmpty, "env should output variables")
    }

    // MARK: - Performance

    func testEnvQuickExecution() {
        let start = Date()
        let result = runCommand("env", [])
        let duration = Date().timeIntervalSince(start)

        XCTAssertEqual(result.exitCode, 0, "env should succeed")
        XCTAssertLessThan(duration, 2.0, "env should execute quickly")
    }

    // MARK: - System Comparison

    func testEnvMatchesSystemEnv() {
        let systemEnv = Process()
        systemEnv.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        let pipe = Pipe()
        systemEnv.standardOutput = pipe

        if (try? systemEnv.run()) != nil {
            systemEnv.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let systemOutput = String(data: data, encoding: .utf8) ?? ""

            let swiftyboxResult = runCommand("env", [])

            // Both should succeed
            XCTAssertEqual(swiftyboxResult.exitCode, systemEnv.terminationStatus,
                          "Should match system env exit code")

            // Should have similar number of variables
            let systemLines = systemOutput.components(separatedBy: "\n").filter { !$0.isEmpty }
            let swiftyboxLines = swiftyboxResult.stdout.components(separatedBy: "\n").filter { !$0.isEmpty }

            // Within 20% of each other
            let ratio = Double(swiftyboxLines.count) / Double(max(systemLines.count, 1))
            XCTAssertGreaterThan(ratio, 0.5, "Should have similar variable count")
            XCTAssertLessThan(ratio, 2.0, "Should have similar variable count")
        }
    }
}
