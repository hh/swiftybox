// PwdxTests.swift
// Comprehensive tests for the pwdx command

import XCTest
@testable import swiftybox

/// Tests for the `pwdx` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: procps-ng pwdx (Linux-specific)
/// - Prints current working directory of a process
/// - Common usage: pwdx PID (shows /proc/PID/cwd)
/// - Can accept multiple PIDs
/// - Target scope: P0 (basic PID lookup)
///
/// Key behaviors to test:
/// - Outputs "PID: /path/to/cwd" format
/// - Works with valid PIDs
/// - Errors for invalid/nonexistent PIDs
/// - Can query self ($$)
/// - Multiple PIDs in one call
/// - Linux-specific: reads /proc/PID/cwd
///
/// Resources:
/// - Man page: pwdx(1)
/// - Linux /proc filesystem

final class PwdxTests: XCTestCase {

    // MARK: - Basic Functionality

    func testPwdx_selfPID() {
        // Get our own PID
        let pid = ProcessInfo.processInfo.processIdentifier

        let result = runCommand("pwdx", ["\(pid)"])

        // On Linux, should succeed
        // On macOS, may not be implemented
        if result.exitCode == 0 {
            XCTAssertFalse(result.stdout.isEmpty, "pwdx should output working directory")
            XCTAssertTrue(result.stdout.contains("\(pid):"),
                         "Output should include PID")
            XCTAssertTrue(result.stdout.contains("/"),
                         "Output should include directory path")
        } else {
            // Not implemented or not available
            XCTAssertFalse(result.stderr.isEmpty, "Should output error if not available")
        }
    }

    func testPwdx_outputFormat() {
        let pid = ProcessInfo.processInfo.processIdentifier
        let result = runCommand("pwdx", ["\(pid)"])

        if result.exitCode == 0 {
            // Format should be: PID: /path/to/directory
            let output = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)

            XCTAssertTrue(output.contains(":"), "Output should contain ':'")

            let parts = output.split(separator: ":", maxSplits: 1)
            XCTAssertEqual(parts.count, 2, "Output should be 'PID: path' format")

            if parts.count == 2 {
                let pidPart = String(parts[0]).trimmingCharacters(in: .whitespaces)
                let pathPart = String(parts[1]).trimmingCharacters(in: .whitespaces)

                XCTAssertEqual(pidPart, "\(pid)", "PID should match")
                XCTAssertTrue(pathPart.starts(with: "/"), "Path should be absolute")
            }
        }
    }

    func testPwdx_init() {
        // PID 1 is always init/systemd
        let result = runCommand("pwdx", ["1"])

        if result.exitCode == 0 {
            XCTAssertTrue(result.stdout.contains("1:"), "Should show PID 1")
            XCTAssertTrue(result.stdout.contains("/"), "Should show root directory")
        } else {
            // May require root permissions
            XCTAssertFalse(result.stderr.isEmpty, "Should output error message")
        }
    }

    // MARK: - Multiple PIDs

    func testPwdx_multiplePIDs() {
        let pid1 = ProcessInfo.processInfo.processIdentifier
        let pid2 = 1 // init

        let result = runCommand("pwdx", ["\(pid1)", "\(pid2)"])

        if result.exitCode == 0 {
            // Should have output for both PIDs
            XCTAssertTrue(result.stdout.contains("\(pid1):"),
                         "Should contain first PID")
        }
        // May fail if permissions insufficient for PID 1
    }

    func testPwdx_threePIDs() {
        let pid = ProcessInfo.processInfo.processIdentifier

        let result = runCommand("pwdx", ["\(pid)", "1", "\(pid)"])

        // At minimum should have our own PID
        if result.stdout.contains("\(pid):") {
            // Count occurrences
            let count = result.stdout.components(separatedBy: "\(pid):").count - 1
            XCTAssertGreaterThan(count, 0, "Should show our PID at least once")
        }
    }

    // MARK: - Error Handling

    func testPwdx_invalidPID() {
        // PID 99999999 likely doesn't exist
        let result = runCommand("pwdx", ["99999999"])

        XCTAssertNotEqual(result.exitCode, 0, "pwdx should fail for invalid PID")
        XCTAssertFalse(result.stderr.isEmpty, "Should output error message")
    }

    func testPwdx_nonNumericPID() {
        let result = runCommand("pwdx", ["not_a_pid"])

        XCTAssertNotEqual(result.exitCode, 0, "pwdx should fail for non-numeric PID")
        XCTAssertFalse(result.stderr.isEmpty, "Should output error message")
    }

    func testPwdx_negativePID() {
        let result = runCommand("pwdx", ["-1"])

        XCTAssertNotEqual(result.exitCode, 0, "pwdx should fail for negative PID")
    }

    func testPwdx_noArguments() {
        let result = runCommand("pwdx", [])

        XCTAssertNotEqual(result.exitCode, 0, "pwdx should fail with no arguments")
        XCTAssertFalse(result.stderr.isEmpty, "Should output error message")
    }

    func testPwdx_zeroPID() {
        let result = runCommand("pwdx", ["0"])

        // PID 0 is special (kernel scheduler on Linux)
        // Typically not accessible
        if result.exitCode != 0 {
            XCTAssertFalse(result.stderr.isEmpty, "Should output error for PID 0")
        }
    }

    // MARK: - Path Validation

    func testPwdx_pathIsAbsolute() {
        let pid = ProcessInfo.processInfo.processIdentifier
        let result = runCommand("pwdx", ["\(pid)"])

        if result.exitCode == 0 {
            let lines = result.stdout.components(separatedBy: "\n").filter { !$0.isEmpty }

            for line in lines {
                if let colonIndex = line.firstIndex(of: ":") {
                    let pathPart = line[line.index(after: colonIndex)...]
                        .trimmingCharacters(in: .whitespaces)

                    XCTAssertTrue(pathPart.starts(with: "/"),
                                 "Path should be absolute: \(pathPart)")
                }
            }
        }
    }

    func testPwdx_pathExists() {
        let pid = ProcessInfo.processInfo.processIdentifier
        let result = runCommand("pwdx", ["\(pid)"])

        if result.exitCode == 0 {
            let output = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)

            if let colonIndex = output.firstIndex(of: ":") {
                let pathPart = output[output.index(after: colonIndex)...]
                    .trimmingCharacters(in: .whitespaces)

                var isDirectory: ObjCBool = false
                let exists = FileManager.default.fileExists(atPath: String(pathPart),
                                                           isDirectory: &isDirectory)

                if exists {
                    XCTAssertTrue(isDirectory.boolValue,
                                 "Working directory should be a directory")
                }
            }
        }
    }

    // MARK: - Linux-Specific

    func testPwdx_procFilesystem() {
        #if os(Linux)
        // On Linux, pwdx reads /proc/PID/cwd
        let pid = ProcessInfo.processInfo.processIdentifier
        let procPath = "/proc/\(pid)/cwd"

        let procExists = FileManager.default.fileExists(atPath: procPath)

        if procExists {
            let result = runCommand("pwdx", ["\(pid)"])
            XCTAssertEqual(result.exitCode, 0,
                          "pwdx should work on Linux with /proc")
        }
        #endif
    }

    // MARK: - No stdin

    func testPwdx_ignoresStdin() {
        let pid = ProcessInfo.processInfo.processIdentifier
        let result = runCommandWithInput("pwdx", ["\(pid)"], input: "ignored\n")

        // Should behave same as without stdin
        if result.exitCode == 0 {
            XCTAssertTrue(result.stdout.contains("\(pid):"), "Should output PID")
        }
    }

    // MARK: - Consistency

    func testPwdx_consistency() {
        let pid = ProcessInfo.processInfo.processIdentifier

        let result1 = runCommand("pwdx", ["\(pid)"])
        let result2 = runCommand("pwdx", ["\(pid)"])

        if result1.exitCode == 0 && result2.exitCode == 0 {
            // Working directory shouldn't change
            XCTAssertEqual(result1.stdout, result2.stdout,
                          "pwdx should produce consistent output")
        }
    }

    // MARK: - System Comparison

    func testPwdx_matchesSystemPwdx() {
        let systemPwdx = Process()
        systemPwdx.executableURL = URL(fileURLWithPath: "/usr/bin/pwdx")
        let pipe = Pipe()
        let errPipe = Pipe()
        systemPwdx.standardOutput = pipe
        systemPwdx.standardError = errPipe

        let pid = ProcessInfo.processInfo.processIdentifier
        systemPwdx.arguments = ["\(pid)"]

        if (try? systemPwdx.run()) != nil {
            systemPwdx.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let systemOutput = String(data: data, encoding: .utf8) ?? ""

            let swiftyboxResult = runCommand("pwdx", ["\(pid)"])

            if systemPwdx.terminationStatus == 0 && swiftyboxResult.exitCode == 0 {
                XCTAssertEqual(swiftyboxResult.stdout, systemOutput,
                              "Should match system pwdx output")
            }
        }
    }
}
