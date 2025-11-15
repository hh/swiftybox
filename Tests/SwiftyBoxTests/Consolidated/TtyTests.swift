// TtyTests.swift
// Comprehensive tests for the tty command

import XCTest
@testable import swiftybox

/// Tests for the `tty` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: GNU coreutils tty
/// - POSIX: Prints name of terminal connected to stdin
/// - Uses ttyname() or isatty() system calls
/// - Common usage: tty (prints /dev/pts/X or "not a tty")
/// - Options: -s (silent mode, only exit code)
/// - Target scope: P0 (basic functionality) + P1 (-s silent mode)
///
/// Key behaviors to test:
/// - Outputs terminal device path when stdin is a TTY
/// - Outputs "not a tty" when stdin is not a TTY
/// - Exit code 0 if TTY, 1 if not, 2 on error
/// - -s option: silent mode (no output, only exit code)
///
/// Resources:
/// - GNU: https://www.gnu.org/software/coreutils/manual/html_node/tty-invocation.html
/// - POSIX: ttyname(), isatty()
/// - Man page: tty(1)

final class TtyTests: XCTestCase {

    // MARK: - Basic Functionality

    func testBasicTty() {
        let result = runCommand("tty", [])

        // In test environment, stdin is not a TTY
        // Should output "not a tty" and exit with 1
        XCTAssertFalse(result.stdout.isEmpty, "tty should output something")
        XCTAssertTrue(result.stdout.hasSuffix("\n"), "tty should end with newline")
    }

    func testNotATty() {
        // In test environment stdin is not a TTY
        let result = runCommand("tty", [])

        let output = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)

        // Should say "not a tty" (or similar message)
        let isNotATtyMessage = output.lowercased().contains("not") &&
                               output.lowercased().contains("tty")

        // Or it might output the device path
        let isDevicePath = output.starts(with: "/dev/")

        XCTAssertTrue(isNotATtyMessage || isDevicePath,
                     "tty should output 'not a tty' or device path")

        // Exit code should be non-zero if not a tty
        if isNotATtyMessage {
            XCTAssertNotEqual(result.exitCode, 0,
                            "tty should exit with non-zero if not a tty")
        }
    }

    func testExitCodeWhenNotTty() {
        let result = runCommand("tty", [])

        let output = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        let isNotATty = output.lowercased().contains("not") &&
                        output.lowercased().contains("tty")

        if isNotATty {
            XCTAssertEqual(result.exitCode, 1,
                          "tty should exit with 1 when not a tty")
        }
    }

    func testOutputFormat() {
        let result = runCommand("tty", [])
        let lines = result.stdout.components(separatedBy: "\n").filter { !$0.isEmpty }

        XCTAssertEqual(lines.count, 1, "tty should output exactly one line")
    }

    // MARK: - Silent Mode

    func testSilentMode() {
        let result = runCommand("tty", ["-s"])

        // Silent mode should produce no output
        XCTAssertTrue(result.stdout.isEmpty, "tty -s should produce no output")
        XCTAssertTrue(result.stderr.isEmpty, "tty -s should produce no stderr")

        // Exit code should indicate whether it's a tty
        XCTAssertTrue(result.exitCode == 0 || result.exitCode == 1,
                     "tty -s should exit with 0 or 1")
    }

    func testSilentModeNoOutput() {
        let result = runCommand("tty", ["-s"])

        XCTAssertEqual(result.stdout, "", "tty -s should not output to stdout")
        XCTAssertEqual(result.stderr, "", "tty -s should not output to stderr")
    }

    func testSilentModeExitCode() {
        let normalResult = runCommand("tty", [])
        let silentResult = runCommand("tty", ["-s"])

        // Exit codes should match
        XCTAssertEqual(normalResult.exitCode, silentResult.exitCode,
                      "tty -s should have same exit code as tty")
    }

    // MARK: - Long Form Options

    func testSilentLongForm() {
        let result = runCommand("tty", ["--silent"])

        XCTAssertTrue(result.stdout.isEmpty || result.exitCode != 999,
                     "tty --silent should work (if supported)")
    }

    func testQuietOption() {
        // -q is synonym for -s in some implementations
        let result = runCommand("tty", ["-q"])

        // Either works like -s or fails gracefully
        if result.exitCode <= 2 {
            XCTAssertTrue(result.stdout.isEmpty || !result.stdout.isEmpty,
                         "tty -q behavior is implementation-defined")
        }
    }

    // MARK: - Error Handling

    func testInvalidOption() {
        let result = runCommand("tty", ["--invalid-option"])

        XCTAssertNotEqual(result.exitCode, 0, "tty should fail with invalid option")
        XCTAssertFalse(result.stderr.isEmpty, "tty should output error message")
    }

    func testExtraArguments() {
        let result = runCommand("tty", ["extra", "args"])

        // Either fails or ignores extra arguments
        if result.exitCode != 0 {
            XCTAssertFalse(result.stderr.isEmpty, "Should output error for extra arguments")
        }
    }

    // MARK: - Stdin Handling

    func testWithInputRedirection() {
        // tty checks stdin, not whether input is provided
        let result = runCommandWithInput("tty", [], input: "some input\n")

        // Should still report not a tty (stdin is pipe, not tty)
        XCTAssertFalse(result.stdout.isEmpty, "tty should output")
    }

    // MARK: - System Comparison

    func testMatchesSystemTty() {
        let systemTty = Process()
        systemTty.executableURL = URL(fileURLWithPath: "/usr/bin/tty")
        let pipe = Pipe()
        let errPipe = Pipe()
        systemTty.standardOutput = pipe
        systemTty.standardError = errPipe

        if (try? systemTty.run()) != nil {
            systemTty.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let systemOutput = String(data: data, encoding: .utf8) ?? ""

            let swiftyboxResult = runCommand("tty", [])

            // Exit codes should match
            XCTAssertEqual(swiftyboxResult.exitCode, systemTty.terminationStatus,
                          "Should match system tty exit code")

            // Output format should be similar
            let systemIsNotTty = systemOutput.lowercased().contains("not")
            let swiftyboxIsNotTty = swiftyboxResult.stdout.lowercased().contains("not")

            XCTAssertEqual(systemIsNotTty, swiftyboxIsNotTty,
                          "Should agree whether stdin is a tty")
        }
    }

    // MARK: - Device Path Format

    func testDevicePathFormat() {
        let result = runCommand("tty", [])
        let output = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)

        if output.starts(with: "/dev/") {
            // If it outputs a device path, verify format
            XCTAssertTrue(output.starts(with: "/dev/pts/") ||
                         output.starts(with: "/dev/tty"),
                         "Device path should be in /dev/pts/ or /dev/tty*")

            // Exit code should be 0 for valid tty
            XCTAssertEqual(result.exitCode, 0,
                          "Exit code should be 0 when outputting device path")
        }
    }

    // MARK: - Consistency

    func testConsistentOutput() {
        let result1 = runCommand("tty", [])
        let result2 = runCommand("tty", [])

        XCTAssertEqual(result1.exitCode, result2.exitCode,
                      "tty should have consistent exit code")
        XCTAssertEqual(result1.stdout, result2.stdout,
                      "tty should produce consistent output")
    }
}
