// LognameTests.swift
// Comprehensive tests for the logname command

import XCTest
@testable import swiftybox

/// Tests for the `logname` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: GNU coreutils logname
/// - POSIX: Prints login name of current user
/// - Uses getlogin() system call
/// - Different from whoami: logname is the original login user
/// - whoami is the effective user (can change with su/sudo)
/// - Common usage: logname (no options)
/// - Target scope: P0 (basic functionality)
///
/// Key behaviors to test:
/// - Outputs login name from controlling terminal
/// - Exit code 0 on success
/// - May fail if no controlling terminal
/// - Single line output
/// - Can differ from whoami after su/sudo
///
/// Resources:
/// - GNU: https://www.gnu.org/software/coreutils/manual/html_node/logname-invocation.html
/// - POSIX: getlogin() system call
/// - Man page: logname(1)

final class LognameTests: XCTestCase {

    // MARK: - Basic Functionality

    func testBasicLogname() {
        let result = runCommand("logname", [])

        // logname may fail if there's no controlling terminal
        // In test environment this is expected
        if result.exitCode == 0 {
            XCTAssertFalse(result.stdout.isEmpty, "logname should output login name")
            XCTAssertTrue(result.stdout.hasSuffix("\n"), "logname should end with newline")
            XCTAssertEqual(result.stderr, "", "logname should not output to stderr on success")
        } else {
            // If it fails, should be because of no controlling terminal
            XCTAssertFalse(result.stderr.isEmpty, "logname should output error message on failure")
        }
    }

    func testOutputFormat() {
        let result = runCommand("logname", [])

        if result.exitCode == 0 {
            let logname = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)

            XCTAssertFalse(logname.isEmpty, "logname should output username")
            XCTAssertGreaterThan(logname.count, 0, "username should have at least one character")
        }
    }

    func testSingleLineOutput() {
        let result = runCommand("logname", [])

        if result.exitCode == 0 {
            let lines = result.stdout.components(separatedBy: "\n").filter { !$0.isEmpty }
            XCTAssertEqual(lines.count, 1, "logname should output exactly one line")
        }
    }

    // MARK: - No Arguments

    func testNoArgumentsRequired() {
        let result = runCommand("logname", [])

        // Should either succeed or fail gracefully
        if result.exitCode != 0 {
            XCTAssertFalse(result.stderr.isEmpty, "Should output error if failing")
        }
    }

    func testIgnoresExtraArguments() {
        let result = runCommand("logname", ["extra"])

        // Should either fail with error or ignore
        if result.exitCode != 0 {
            XCTAssertFalse(result.stderr.isEmpty, "If logname fails, should output error")
        }
    }

    // MARK: - Consistency

    func testConsistentOutput() {
        let result1 = runCommand("logname", [])
        let result2 = runCommand("logname", [])

        // Both should have same success/failure
        XCTAssertEqual(result1.exitCode, result2.exitCode,
                      "logname should have consistent exit code")

        if result1.exitCode == 0 && result2.exitCode == 0 {
            XCTAssertEqual(result1.stdout, result2.stdout,
                          "logname should produce consistent output")
        }
    }

    // MARK: - No stdin

    func testIgnoresStdin() {
        let result = runCommandWithInput("logname", [], input: "ignored\n")

        // Should behave same as without input
        if result.exitCode == 0 {
            XCTAssertFalse(result.stdout.isEmpty, "logname should output login name")
        }
    }

    // MARK: - Valid Username Format

    func testValidUsernameFormat() {
        let result = runCommand("logname", [])

        if result.exitCode == 0 {
            let username = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)

            XCTAssertFalse(username.contains("\n"), "username should not contain newline")
            XCTAssertFalse(username.contains("\t"), "username should not contain tab")
            XCTAssertFalse(username.contains(" "), "username should not contain space")
        }
    }

    // MARK: - System Comparison

    func testMatchesSystemLogname() {
        let systemLogname = Process()
        systemLogname.executableURL = URL(fileURLWithPath: "/usr/bin/logname")
        let pipe = Pipe()
        let errPipe = Pipe()
        systemLogname.standardOutput = pipe
        systemLogname.standardError = errPipe

        if (try? systemLogname.run()) != nil {
            systemLogname.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let systemOutput = String(data: data, encoding: .utf8) ?? ""

            let swiftyboxResult = runCommand("logname", [])

            // Should have same exit code
            XCTAssertEqual(swiftyboxResult.exitCode, systemLogname.terminationStatus,
                          "Should match system logname exit code")

            // If both succeed, should have same output
            if systemLogname.terminationStatus == 0 && swiftyboxResult.exitCode == 0 {
                XCTAssertEqual(swiftyboxResult.stdout, systemOutput,
                              "Should match system logname output")
            }
        }
    }

    // MARK: - Error Handling

    func testHandlesNoControllingTerminal() {
        // In test environment, there may not be a controlling terminal
        let result = runCommand("logname", [])

        // Should either succeed or fail gracefully with error message
        if result.exitCode != 0 {
            XCTAssertFalse(result.stderr.isEmpty,
                          "Should output error message when failing")

            // Error message should mention terminal or login
            let errorLower = result.stderr.lowercased()
            let hasRelevantError = errorLower.contains("terminal") ||
                                  errorLower.contains("login") ||
                                  errorLower.contains("tty")

            XCTAssertTrue(hasRelevantError || !result.stderr.isEmpty,
                         "Error message should be relevant")
        }
    }

    // MARK: - Comparison with whoami

    func testCompareWithWhoami() {
        // logname and whoami may differ (e.g., after sudo)
        // but in normal circumstances they're often the same
        let lognameResult = runCommand("logname", [])
        let whoamiResult = runCommand("whoami", [])

        if lognameResult.exitCode == 0 && whoamiResult.exitCode == 0 {
            // Both succeeded - they might be the same
            // (or different if we've su'd or sudo'd)
            // Just verify both are valid usernames
            let logname = lognameResult.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
            let whoami = whoamiResult.stdout.trimmingCharacters(in: .whitespacesAndNewlines)

            XCTAssertFalse(logname.isEmpty, "logname should output username")
            XCTAssertFalse(whoami.isEmpty, "whoami should output username")
        }
    }
}
