// UnameTests.swift
// ============================================================================
// BusyBox Test Import Metadata
// ============================================================================
// Source Type: GNU coreutils uname / POSIX uname
// Test Count: 14
// Target Coverage: P0 (all POSIX options) + P1 (GNU extensions)
// ============================================================================
// Comprehensive tests for uname command functionality

import XCTest
import Foundation

final class UnameTests: XCTestCase {

    // MARK: - Test 1: Default behavior (no arguments)
    // Default to -s (kernel name) when no options specified
    func testUname_defaultBehavior() {
        let result = runCommand("uname", [])

        XCTAssertEqual(result.exitCode, 0, "uname should succeed with no arguments")
        XCTAssertFalse(result.stdout.isEmpty, "uname should produce output")

        // Default output should be kernel name only (e.g., "Linux")
        let output = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertFalse(output.contains(" "), "Default output should be single word (kernel name only)")
    }

    // MARK: - Test 2: -s option (kernel/system name)
    // Prints the kernel name (e.g., Linux)
    func testUname_systemNameOption() {
        let result = runCommand("uname", ["-s"])

        XCTAssertEqual(result.exitCode, 0, "uname -s should succeed")
        XCTAssertFalse(result.stdout.isEmpty, "uname -s should produce output")

        let output = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertFalse(output.isEmpty, "system name should not be empty")
        XCTAssertFalse(output.contains(" "), "system name should not contain spaces")

        // On Linux systems, should be "Linux"
        #if os(Linux)
        XCTAssertEqual(output, "Linux", "System name should be 'Linux' on Linux systems")
        #elseif os(macOS)
        XCTAssertEqual(output, "Darwin", "System name should be 'Darwin' on macOS")
        #endif
    }

    // MARK: - Test 3: -n option (hostname/node name)
    // Prints the node name (hostname)
    func testUname_hostNameOption() {
        let result = runCommand("uname", ["-n"])

        XCTAssertEqual(result.exitCode, 0, "uname -n should succeed")
        XCTAssertFalse(result.stdout.isEmpty, "uname -n should produce output")

        let output = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertFalse(output.isEmpty, "hostname should not be empty")
        XCTAssertFalse(output.contains("\n"), "hostname should be single line")
    }

    // MARK: - Test 4: -r option (release/kernel version)
    // Prints the kernel release (version)
    func testUname_releaseOption() {
        let result = runCommand("uname", ["-r"])

        XCTAssertEqual(result.exitCode, 0, "uname -r should succeed")
        XCTAssertFalse(result.stdout.isEmpty, "uname -r should produce output")

        let output = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertFalse(output.isEmpty, "release should not be empty")

        // Release version typically contains digits
        let hasDigits = output.contains(where: { $0.isNumber })
        XCTAssertTrue(hasDigits, "release should contain version numbers")
    }

    // MARK: - Test 5: -v option (kernel version/build info)
    // Prints the kernel version (build information)
    func testUname_versionOption() {
        let result = runCommand("uname", ["-v"])

        XCTAssertEqual(result.exitCode, 0, "uname -v should succeed")
        XCTAssertFalse(result.stdout.isEmpty, "uname -v should produce output")

        let output = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertFalse(output.isEmpty, "version should not be empty")
    }

    // MARK: - Test 6: -m option (machine/architecture)
    // Prints the machine hardware name (architecture)
    func testUname_machineOption() {
        let result = runCommand("uname", ["-m"])

        XCTAssertEqual(result.exitCode, 0, "uname -m should succeed")
        XCTAssertFalse(result.stdout.isEmpty, "uname -m should produce output")

        let output = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertFalse(output.isEmpty, "machine should not be empty")
        XCTAssertFalse(output.contains(" "), "machine should not contain spaces")

        // Verify architecture matches compile target
        #if arch(x86_64)
        XCTAssertTrue(output.contains("x86_64") || output.contains("x86") || output.contains("i386"),
                      "Machine should contain x86_64 or x86 on x86_64 systems")
        #elseif arch(arm64)
        XCTAssertTrue(output.contains("arm64") || output.contains("aarch64"),
                      "Machine should contain arm64 or aarch64 on ARM64 systems")
        #elseif arch(arm)
        XCTAssertTrue(output.contains("arm"), "Machine should contain arm on ARM systems")
        #endif
    }

    // MARK: - Test 7: Combined options (-sr)
    // Multiple options should print values space-separated
    func testUname_combinedOptionsSR() {
        let result = runCommand("uname", ["-sr"])

        XCTAssertEqual(result.exitCode, 0, "uname -sr should succeed")
        XCTAssertFalse(result.stdout.isEmpty, "uname -sr should produce output")

        let output = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = output.split(separator: " ")

        XCTAssertEqual(parts.count, 2, "uname -sr should output exactly 2 fields")

        // First part should be system name
        #if os(Linux)
        XCTAssertEqual(parts[0], "Linux", "First field should be Linux")
        #elseif os(macOS)
        XCTAssertEqual(parts[0], "Darwin", "First field should be Darwin")
        #endif
    }

    // MARK: - Test 8: Combined options (-snr)
    // Three options should print values space-separated
    func testUname_combinedOptionsSNR() {
        let result = runCommand("uname", ["-snr"])

        XCTAssertEqual(result.exitCode, 0, "uname -snr should succeed")
        XCTAssertFalse(result.stdout.isEmpty, "uname -snr should produce output")

        let output = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = output.split(separator: " ")

        XCTAssertEqual(parts.count, 3, "uname -snr should output exactly 3 fields")
    }

    // MARK: - Test 9: -a option (all information)
    // Should output all available information
    func testUname_allOption() {
        let result = runCommand("uname", ["-a"])

        XCTAssertEqual(result.exitCode, 0, "uname -a should succeed")
        XCTAssertFalse(result.stdout.isEmpty, "uname -a should produce output")

        let output = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = output.split(separator: " ")

        // -a should output: sysname nodename release version machine [processor] [hwplatform] [os]
        // Minimum 5 fields, potentially up to 8
        XCTAssertGreaterThanOrEqual(parts.count, 5, "uname -a should output at least 5 fields")

        // First part should be system name
        #if os(Linux)
        XCTAssertEqual(parts[0], "Linux", "First field of -a should be Linux")
        #elseif os(macOS)
        XCTAssertEqual(parts[0], "Darwin", "First field of -a should be Darwin")
        #endif
    }

    // MARK: - Test 10: -a output contains all information
    // -a output should contain system name, hostname, release, version, and machine
    func testUname_allOptionContainsAll() {
        let resultAll = runCommand("uname", ["-a"])
        let resultS = runCommand("uname", ["-s"])
        let resultN = runCommand("uname", ["-n"])
        let resultR = runCommand("uname", ["-r"])
        let resultM = runCommand("uname", ["-m"])

        let allOutput = resultAll.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        let sysname = resultS.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        let hostname = resultN.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        let release = resultR.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        let machine = resultM.stdout.trimmingCharacters(in: .whitespacesAndNewlines)

        // All output should contain the individual outputs
        XCTAssertTrue(allOutput.contains(sysname), "-a output should contain system name")
        XCTAssertTrue(allOutput.contains(hostname), "-a output should contain hostname")
        XCTAssertTrue(allOutput.contains(release), "-a output should contain release")
        XCTAssertTrue(allOutput.contains(machine), "-a output should contain machine")
    }

    // MARK: - Test 11: Consistency (multiple calls produce same output)
    // Running uname multiple times should produce identical output
    func testUname_consistentOutput() {
        let result1 = runCommand("uname", ["-a"])
        let result2 = runCommand("uname", ["-a"])
        let result3 = runCommand("uname", ["-a"])

        let output1 = result1.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        let output2 = result2.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        let output3 = result3.stdout.trimmingCharacters(in: .whitespacesAndNewlines)

        XCTAssertEqual(output1, output2, "Multiple calls to uname -a should produce identical output")
        XCTAssertEqual(output2, output3, "Multiple calls to uname -a should produce identical output")
    }

    // MARK: - Test 12: Comparison with system uname (POSIX options)
    // Output should match system uname for POSIX options
    func testUname_matchesSystemUname() {
        let systemTask = Process()
        systemTask.executableURL = URL(fileURLWithPath: "/usr/bin/uname")
        systemTask.arguments = ["-a"]

        let systemPipe = Pipe()
        systemTask.standardOutput = systemPipe

        do {
            try systemTask.run()
            systemTask.waitUntilExit()

            let systemData = systemPipe.fileHandleForReading.readDataToEndOfFile()
            let systemOutput = String(data: systemData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            let result = runCommand("uname", ["-a"])
            let ourOutput = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)

            // Parse both outputs to compare field by field
            let systemParts = systemOutput.split(separator: " ")
            let ourParts = ourOutput.split(separator: " ")

            // First field (system name) should match
            if !systemParts.isEmpty && !ourParts.isEmpty {
                XCTAssertEqual(systemParts[0], ourParts[0], "System name should match system uname")
            }

            // Machine field should match
            if systemParts.count >= 5 && ourParts.count >= 5 {
                XCTAssertEqual(systemParts[4], ourParts[4], "Machine field should match system uname")
            }
        } catch {
            XCTSkip("System uname not available at /usr/bin/uname")
        }
    }

    // MARK: - Test 13: Invalid option handling
    // Invalid options should return error
    func testUname_invalidOption() {
        let result = runCommand("uname", ["-x"])

        XCTAssertNotEqual(result.exitCode, 0, "uname with invalid option should fail")
        XCTAssertFalse(result.stderr.isEmpty, "uname with invalid option should produce error message")
        XCTAssertTrue(result.stderr.contains("invalid option") || result.stderr.contains("unrecognized"),
                     "Error message should mention invalid option")
    }

    // MARK: - Test 14: No stdin required / Ignores stdin
    // uname should not require stdin and should produce same output regardless of stdin
    func testUname_noStdinRequired() {
        let result = runCommand("uname", ["-s"])

        XCTAssertEqual(result.exitCode, 0, "uname should succeed without stdin")
        XCTAssertFalse(result.stdout.isEmpty, "uname should produce output without stdin")

        // This test demonstrates that uname doesn't consume stdin
        // It should complete immediately without waiting for input
        let startTime = Date()
        let result2 = runCommand("uname", ["-s"])
        let elapsed = Date().timeIntervalSince(startTime)

        // Command should complete very quickly (less than 1 second)
        XCTAssertLessThan(elapsed, 1.0, "uname should complete quickly without stdin")

        // Output should match
        XCTAssertEqual(
            result.stdout.trimmingCharacters(in: .whitespacesAndNewlines),
            result2.stdout.trimmingCharacters(in: .whitespacesAndNewlines),
            "Output should be identical on consecutive calls"
        )
    }
}
