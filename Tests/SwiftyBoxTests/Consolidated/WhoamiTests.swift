// WhoamiTests.swift
// Comprehensive tests for the whoami command

import XCTest
@testable import swiftybox

/// Tests for the `whoami` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: GNU coreutils whoami
/// - Prints effective user name
/// - Equivalent to `id -un`
/// - POSIX: Uses geteuid() and getpwuid()
/// - Common usage: whoami (no options)
/// - Target scope: P0 (basic functionality only)
///
/// Key behaviors to test:
/// - Outputs current effective username
/// - Exit code 0 on success
/// - No options supported (or --help/--version only)
/// - Single line output
/// - Should match id -un output
///
/// Resources:
/// - GNU: https://www.gnu.org/software/coreutils/manual/html_node/whoami-invocation.html
/// - POSIX: geteuid(), getpwuid()

final class WhoamiTests: XCTestCase {

    // MARK: - Basic Functionality

    func testBasicWhoami() {
        let result = runCommand("whoami", [])

        XCTAssertEqual(result.exitCode, 0, "whoami should exit with 0")
        XCTAssertFalse(result.stdout.isEmpty, "whoami should output username")
        XCTAssertEqual(result.stderr, "", "whoami should not output to stderr")
        XCTAssertTrue(result.stdout.hasSuffix("\n"), "whoami should end with newline")
    }

    func testOutputsUsername() {
        let result = runCommand("whoami", [])
        let username = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)

        XCTAssertFalse(username.isEmpty, "whoami should output username")
        XCTAssertGreaterThan(username.count, 0, "username should have at least one character")
        XCTAssertLessThan(username.count, 256, "username should be reasonable length")
    }

    func testSingleLineOutput() {
        let result = runCommand("whoami", [])
        let lines = result.stdout.components(separatedBy: "\n").filter { !$0.isEmpty }

        XCTAssertEqual(lines.count, 1, "whoami should output exactly one line")
    }

    func testMatchesIdUn() {
        // whoami should be equivalent to id -un
        let whoamiResult = runCommand("whoami", [])
        let idResult = runCommand("id", ["-un"])

        XCTAssertEqual(whoamiResult.stdout, idResult.stdout,
                      "whoami should match id -un output")
    }

    func testValidUsernameFormat() {
        let result = runCommand("whoami", [])
        let username = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)

        // Username should not contain certain characters
        XCTAssertFalse(username.contains("\n"), "username should not contain newline")
        XCTAssertFalse(username.contains("\t"), "username should not contain tab")
        XCTAssertFalse(username.contains(" "), "username should not contain space")
        XCTAssertFalse(username.contains("/"), "username should not contain slash")
    }

    // MARK: - No Arguments

    func testNoArgumentsRequired() {
        let result = runCommand("whoami", [])
        XCTAssertEqual(result.exitCode, 0, "whoami should work with no arguments")
    }

    func testIgnoresExtraArguments() {
        // GNU whoami treats extra arguments as error
        let result = runCommand("whoami", ["extra"])

        // Either fails (strict) or ignores (permissive)
        if result.exitCode != 0 {
            XCTAssertFalse(result.stderr.isEmpty, "If whoami fails, should output error")
        }
    }

    // MARK: - Consistency

    func testConsistentOutput() {
        let result1 = runCommand("whoami", [])
        let result2 = runCommand("whoami", [])

        XCTAssertEqual(result1.stdout, result2.stdout,
                      "whoami should produce consistent output")
    }

    func testMultipleCalls() {
        let results = (0..<5).map { _ in runCommand("whoami", []) }

        XCTAssertTrue(results.allSatisfy { $0.exitCode == 0 },
                     "All whoami calls should succeed")

        let firstOutput = results[0].stdout
        XCTAssertTrue(results.allSatisfy { $0.stdout == firstOutput },
                     "All whoami calls should produce same output")
    }

    // MARK: - No stdin

    func testIgnoresStdin() {
        let result = runCommandWithInput("whoami", [], input: "ignored input\n")

        XCTAssertEqual(result.exitCode, 0, "whoami should ignore stdin")
        XCTAssertFalse(result.stdout.isEmpty, "whoami should output username")
    }

    // MARK: - System Comparison

    func testMatchesSystemWhoami() {
        let systemWhoami = Process()
        systemWhoami.executableURL = URL(fileURLWithPath: "/usr/bin/whoami")
        let pipe = Pipe()
        systemWhoami.standardOutput = pipe

        if (try? systemWhoami.run()) != nil {
            systemWhoami.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let systemOutput = String(data: data, encoding: .utf8) ?? ""

            let swiftyboxResult = runCommand("whoami", [])

            XCTAssertEqual(swiftyboxResult.stdout, systemOutput,
                          "Should match system whoami output")
        }
    }

    // MARK: - Performance

    func testQuickExecution() {
        let start = Date()
        let result = runCommand("whoami", [])
        let duration = Date().timeIntervalSince(start)

        XCTAssertEqual(result.exitCode, 0, "whoami should succeed")
        XCTAssertLessThan(duration, 1.0, "whoami should execute quickly")
    }
}
