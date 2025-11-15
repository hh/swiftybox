// ArchTests.swift
// Comprehensive tests for the arch command

import XCTest
@testable import swiftybox

/// Tests for the `arch` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: GNU coreutils arch (deprecated, use uname -m instead)
/// - BusyBox: Simple implementation, prints machine hardware name
/// - GNU: Equivalent to `uname -m`
/// - Common usage: arch (no options supported)
/// - Target scope: P0 (basic functionality only)
///
/// Key behaviors to test:
/// - Outputs machine architecture (x86_64, aarch64, armv7l, etc.)
/// - Exit code 0 on success
/// - No options supported
/// - Output should match `uname -m`
///
/// Resources:
/// - GNU: https://www.gnu.org/software/coreutils/manual/html_node/arch-invocation.html
/// - POSIX: Not in POSIX (use uname -m)

final class ArchTests: XCTestCase {

    // MARK: - Basic Functionality

    func testBasicArch() {
        let result = runCommand("arch", [])

        XCTAssertEqual(result.exitCode, 0, "arch should exit with 0")
        XCTAssertTrue(result.stdout.hasSuffix("\n"), "arch should output newline")
        XCTAssertEqual(result.stderr, "", "arch should not output to stderr")

        let arch = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertFalse(arch.isEmpty, "arch should output architecture")
    }

    func testValidArchitectureName() {
        let result = runCommand("arch", [])
        let arch = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)

        // Common architectures
        let validArchitectures = [
            "x86_64", "aarch64", "arm64", "armv7l", "armv6l",
            "i386", "i686", "ppc64", "ppc64le", "s390x", "riscv64"
        ]

        let isValid = validArchitectures.contains(arch) ||
                     arch.starts(with: "arm") ||
                     arch.starts(with: "x86")

        XCTAssertTrue(isValid, "arch should output a valid architecture name, got: \(arch)")
    }

    func testMatchesUnameM() {
        // arch should be equivalent to uname -m
        let archResult = runCommand("arch", [])
        let unameResult = runCommand("uname", ["-m"])

        XCTAssertEqual(archResult.stdout, unameResult.stdout,
                      "arch should match uname -m output")
    }

    func testSingleLineOutput() {
        let result = runCommand("arch", [])
        let lines = result.stdout.components(separatedBy: "\n").filter { !$0.isEmpty }

        XCTAssertEqual(lines.count, 1, "arch should output exactly one line")
    }

    // MARK: - Error Handling

    func testIgnoresArguments() {
        // arch traditionally ignores all arguments (some implementations)
        // or treats them as errors (GNU)
        let result = runCommand("arch", ["foo"])

        // Either succeeds (ignoring args) or fails with error
        // Both behaviors are acceptable
        if result.exitCode != 0 {
            XCTAssertFalse(result.stderr.isEmpty, "If arch fails, should output error")
        }
    }

    func testNoStdinRequired() {
        // arch doesn't read stdin
        let result = runCommandWithInput("arch", [], input: "should be ignored\n")

        XCTAssertEqual(result.exitCode, 0, "arch should not require stdin")
        XCTAssertFalse(result.stdout.isEmpty, "arch should output architecture")
    }

    // MARK: - Output Format

    func testOutputContainsNoWhitespace() {
        let result = runCommand("arch", [])
        let arch = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)

        XCTAssertFalse(arch.contains(" "), "arch output should not contain spaces")
        XCTAssertFalse(arch.contains("\t"), "arch output should not contain tabs")
    }

    func testOutputIsLowercase() {
        // Architecture names are typically lowercase
        let result = runCommand("arch", [])
        let arch = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)

        XCTAssertEqual(arch, arch.lowercased(), "arch output should be lowercase")
    }

    func testConsistentOutput() {
        // Running arch multiple times should give same result
        let result1 = runCommand("arch", [])
        let result2 = runCommand("arch", [])

        XCTAssertEqual(result1.stdout, result2.stdout, "arch should give consistent output")
    }

    // MARK: - Comparison with System

    func testMatchesSystemArch() {
        // Compare with system arch command if available
        let systemArch = Process()
        systemArch.executableURL = URL(fileURLWithPath: "/usr/bin/arch")
        let pipe = Pipe()
        systemArch.standardOutput = pipe

        if (try? systemArch.run()) != nil {
            systemArch.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let systemOutput = String(data: data, encoding: .utf8) ?? ""

            let swiftyboxResult = runCommand("arch", [])

            // Should match system arch
            XCTAssertEqual(swiftyboxResult.stdout, systemOutput,
                          "Should match system arch output")
        }
    }
}
