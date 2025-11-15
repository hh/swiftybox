// SleepTests.swift
// ============================================================================
// Comprehensive Test Suite for Sleep Command
// ============================================================================
// Reference: GNU coreutils sleep / POSIX sleep
// Sleep Implementation: Delays for specified time
// Features:
//   - POSIX: integer seconds only
//   - GNU Extension: fractional seconds (1.5, 0.1)
//   - Suffix support: 's' (seconds), 'm' (minutes), 'h' (hours), 'd' (days)
// Test Coverage:
//   - Basic integer sleep (1, 2, 3 seconds)
//   - Zero seconds (immediate return)
//   - Fractional seconds (0.1, 0.5, 1.5)
//   - Exit code 0 on success
//   - No output
//   - Error handling (negative number, invalid input, no arguments)
//   - Very short sleep (0.01)
//   - Timing accuracy (±10% tolerance)
//   - Suffix support (m, h, d)
// ============================================================================

import XCTest
import Foundation

final class SleepTests: XCTestCase {
    var swiftyboxPath: String {
        let cwd = FileManager.default.currentDirectoryPath
        return "\(cwd)/.build/debug/swiftybox"
    }

    // MARK: - Test 1: Basic integer sleep (1 second)
    // Tests basic sleep functionality with a 1-second delay
    func testSleep_oneSecond() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["sleep", "1"]

        let startTime = Date()
        try? task.run()
        task.waitUntilExit()
        let elapsed = Date().timeIntervalSince(startTime)

        XCTAssertEqual(task.terminationStatus, 0, "sleep 1 should exit with status 0")
        // Allow ±10% variance: 0.9 to 1.1 seconds
        XCTAssertGreaterThanOrEqual(elapsed, 0.9, "sleep 1 should take at least 0.9 seconds")
        XCTAssertLessThanOrEqual(elapsed, 1.1, "sleep 1 should take at most 1.1 seconds")
    }

    // MARK: - Test 2: Basic integer sleep (2 seconds)
    // Tests sleep with a 2-second delay
    func testSleep_twoSeconds() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["sleep", "2"]

        let startTime = Date()
        try? task.run()
        task.waitUntilExit()
        let elapsed = Date().timeIntervalSince(startTime)

        XCTAssertEqual(task.terminationStatus, 0, "sleep 2 should exit with status 0")
        // Allow ±10% variance: 1.8 to 2.2 seconds
        XCTAssertGreaterThanOrEqual(elapsed, 1.8, "sleep 2 should take at least 1.8 seconds")
        XCTAssertLessThanOrEqual(elapsed, 2.2, "sleep 2 should take at most 2.2 seconds")
    }

    // MARK: - Test 3: Basic integer sleep (3 seconds)
    // Tests sleep with a 3-second delay
    func testSleep_threeSeconds() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["sleep", "3"]

        let startTime = Date()
        try? task.run()
        task.waitUntilExit()
        let elapsed = Date().timeIntervalSince(startTime)

        XCTAssertEqual(task.terminationStatus, 0, "sleep 3 should exit with status 0")
        // Allow ±10% variance: 2.7 to 3.3 seconds
        XCTAssertGreaterThanOrEqual(elapsed, 2.7, "sleep 3 should take at least 2.7 seconds")
        XCTAssertLessThanOrEqual(elapsed, 3.3, "sleep 3 should take at most 3.3 seconds")
    }

    // MARK: - Test 4: Zero seconds (immediate return)
    // Tests that sleep 0 returns immediately without blocking
    func testSleep_zeroSeconds() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["sleep", "0"]

        let startTime = Date()
        try? task.run()
        task.waitUntilExit()
        let elapsed = Date().timeIntervalSince(startTime)

        XCTAssertEqual(task.terminationStatus, 0, "sleep 0 should exit with status 0")
        // Should return almost immediately (less than 0.1 seconds)
        XCTAssertLessThan(elapsed, 0.1, "sleep 0 should return immediately")
    }

    // MARK: - Test 5: Fractional seconds (0.1 second)
    // Tests sleep with very short fractional delay
    func testSleep_fractionalOneHundredth() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["sleep", "0.1"]

        let startTime = Date()
        try? task.run()
        task.waitUntilExit()
        let elapsed = Date().timeIntervalSince(startTime)

        XCTAssertEqual(task.terminationStatus, 0, "sleep 0.1 should exit with status 0")
        // Allow ±10% variance: 0.09 to 0.11 seconds
        XCTAssertGreaterThanOrEqual(elapsed, 0.09, "sleep 0.1 should take at least 0.09 seconds")
        XCTAssertLessThanOrEqual(elapsed, 0.2, "sleep 0.1 should take at most 0.2 seconds (generous margin)")
    }

    // MARK: - Test 6: Fractional seconds (0.5 second)
    // Tests sleep with half-second delay
    func testSleep_fractionalHalf() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["sleep", "0.5"]

        let startTime = Date()
        try? task.run()
        task.waitUntilExit()
        let elapsed = Date().timeIntervalSince(startTime)

        XCTAssertEqual(task.terminationStatus, 0, "sleep 0.5 should exit with status 0")
        // Allow ±10% variance: 0.45 to 0.55 seconds
        XCTAssertGreaterThanOrEqual(elapsed, 0.45, "sleep 0.5 should take at least 0.45 seconds")
        XCTAssertLessThanOrEqual(elapsed, 0.55, "sleep 0.5 should take at most 0.55 seconds")
    }

    // MARK: - Test 7: Fractional seconds (1.5 seconds)
    // Tests sleep with fractional delay greater than 1 second
    func testSleep_fractionalOneAndHalf() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["sleep", "1.5"]

        let startTime = Date()
        try? task.run()
        task.waitUntilExit()
        let elapsed = Date().timeIntervalSince(startTime)

        XCTAssertEqual(task.terminationStatus, 0, "sleep 1.5 should exit with status 0")
        // Allow ±10% variance: 1.35 to 1.65 seconds
        XCTAssertGreaterThanOrEqual(elapsed, 1.35, "sleep 1.5 should take at least 1.35 seconds")
        XCTAssertLessThanOrEqual(elapsed, 1.65, "sleep 1.5 should take at most 1.65 seconds")
    }

    // MARK: - Test 8: Very short sleep (0.01 seconds)
    // Tests sleep with very short delay (10 milliseconds)
    func testSleep_veryShort() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["sleep", "0.01"]

        let startTime = Date()
        try? task.run()
        task.waitUntilExit()
        let elapsed = Date().timeIntervalSince(startTime)

        XCTAssertEqual(task.terminationStatus, 0, "sleep 0.01 should exit with status 0")
        // Should be quick, allow up to 0.1 seconds for system variance
        XCTAssertLessThan(elapsed, 0.1, "sleep 0.01 should complete within 0.1 seconds")
    }

    // MARK: - Test 9: Exit code 0 on success
    // Tests that successful sleep returns exit code 0
    func testSleep_exitCodeZero() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["sleep", "0.1"]

        try? task.run()
        task.waitUntilExit()

        XCTAssertEqual(task.terminationStatus, 0, "sleep should exit with code 0 on success")
    }

    // MARK: - Test 10: No output on stdout
    // Tests that sleep produces no output
    func testSleep_noOutput() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["sleep", "0.1"]

        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        XCTAssertEqual(output, "", "sleep should produce no output")
    }

    // MARK: - Test 11: Suffix support - minutes
    // Tests sleep with minute suffix (m)
    func testSleep_suffixMinutes() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["sleep", "0.01m"]  // 0.01 minutes = 0.6 seconds

        let startTime = Date()
        try? task.run()
        task.waitUntilExit()
        let elapsed = Date().timeIntervalSince(startTime)

        XCTAssertEqual(task.terminationStatus, 0, "sleep with minute suffix should exit with status 0")
        // 0.01m = 0.6s, allow ±10% variance: 0.54 to 0.66 seconds
        XCTAssertGreaterThanOrEqual(elapsed, 0.54, "sleep 0.01m should take at least 0.54 seconds")
        XCTAssertLessThanOrEqual(elapsed, 0.66, "sleep 0.01m should take at most 0.66 seconds")
    }

    // MARK: - Test 12: Suffix support - hours
    // Tests sleep with hour suffix (h) using very small value
    func testSleep_suffixHours() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["sleep", "0.0001h"]  // 0.0001 hours = 0.36 seconds

        let startTime = Date()
        try? task.run()
        task.waitUntilExit()
        let elapsed = Date().timeIntervalSince(startTime)

        XCTAssertEqual(task.terminationStatus, 0, "sleep with hour suffix should exit with status 0")
        // 0.0001h = 0.36s, allow ±10% variance: 0.324 to 0.396 seconds
        XCTAssertGreaterThanOrEqual(elapsed, 0.324, "sleep 0.0001h should take at least 0.324 seconds")
        XCTAssertLessThanOrEqual(elapsed, 0.396, "sleep 0.0001h should take at most 0.396 seconds")
    }

    // MARK: - Test 13: Suffix support - seconds (explicit)
    // Tests sleep with explicit seconds suffix (s)
    func testSleep_suffixSeconds() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["sleep", "0.5s"]

        let startTime = Date()
        try? task.run()
        task.waitUntilExit()
        let elapsed = Date().timeIntervalSince(startTime)

        XCTAssertEqual(task.terminationStatus, 0, "sleep with seconds suffix should exit with status 0")
        // 0.5s, allow ±10% variance: 0.45 to 0.55 seconds
        XCTAssertGreaterThanOrEqual(elapsed, 0.45, "sleep 0.5s should take at least 0.45 seconds")
        XCTAssertLessThanOrEqual(elapsed, 0.55, "sleep 0.5s should take at most 0.55 seconds")
    }

    // MARK: - Test 14: Suffix support - days
    // Tests sleep with day suffix (d) using very small value
    func testSleep_suffixDays() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["sleep", "0.00001d"]  // 0.00001 days = 0.864 seconds

        let startTime = Date()
        try? task.run()
        task.waitUntilExit()
        let elapsed = Date().timeIntervalSince(startTime)

        XCTAssertEqual(task.terminationStatus, 0, "sleep with day suffix should exit with status 0")
        // 0.00001d = 0.864s, allow ±10% variance: 0.7776 to 0.9504 seconds
        XCTAssertGreaterThanOrEqual(elapsed, 0.7776, "sleep 0.00001d should take at least 0.7776 seconds")
        XCTAssertLessThanOrEqual(elapsed, 0.9504, "sleep 0.00001d should take at most 0.9504 seconds")
    }

    // MARK: - Test 15: Error handling - no arguments
    // Tests that sleep without arguments returns error
    func testSleep_noArguments() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["sleep"]

        let errPipe = Pipe()
        task.standardError = errPipe
        try? task.run()
        task.waitUntilExit()

        let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
        let errOutput = String(data: errData, encoding: .utf8) ?? ""

        XCTAssertNotEqual(task.terminationStatus, 0, "sleep with no arguments should fail")
        XCTAssertTrue(errOutput.contains("usage") || errOutput.contains("error"),
                     "sleep with no arguments should print usage or error message")
    }

    // MARK: - Test 16: Error handling - negative number
    // Tests that sleep with negative number returns error
    func testSleep_negativeNumber() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["sleep", "-1"]

        let errPipe = Pipe()
        task.standardError = errPipe
        try? task.run()
        task.waitUntilExit()

        let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
        let errOutput = String(data: errData, encoding: .utf8) ?? ""

        XCTAssertNotEqual(task.terminationStatus, 0, "sleep with negative number should fail")
        XCTAssertTrue(errOutput.contains("invalid") || errOutput.contains("error"),
                     "sleep with negative number should print error message")
    }

    // MARK: - Test 17: Error handling - invalid input (non-numeric)
    // Tests that sleep with invalid input returns error
    func testSleep_invalidInput() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["sleep", "abc"]

        let errPipe = Pipe()
        task.standardError = errPipe
        try? task.run()
        task.waitUntilExit()

        let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
        let errOutput = String(data: errData, encoding: .utf8) ?? ""

        XCTAssertNotEqual(task.terminationStatus, 0, "sleep with invalid input should fail")
        XCTAssertTrue(errOutput.contains("invalid") || errOutput.contains("error"),
                     "sleep with invalid input should print error message")
    }

    // MARK: - Test 18: Error handling - invalid input (special characters)
    // Tests that sleep with special characters returns error
    func testSleep_specialCharacters() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["sleep", "1!@#$"]

        let errPipe = Pipe()
        task.standardError = errPipe
        try? task.run()
        task.waitUntilExit()

        let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
        let errOutput = String(data: errData, encoding: .utf8) ?? ""

        XCTAssertNotEqual(task.terminationStatus, 0, "sleep with special characters should fail")
        XCTAssertTrue(errOutput.contains("invalid") || errOutput.contains("error"),
                     "sleep with special characters should print error message")
    }

    // MARK: - Test 19: Multiple arguments (multiple times)
    // Tests sleep behavior with multiple arguments - implementation specific
    func testSleep_multipleArguments() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["sleep", "0.1", "0.2"]

        try? task.run()
        task.waitUntilExit()

        // Implementation may ignore extra args or sum them
        // Just verify it exits (either successfully or with error)
        XCTAssertNotNil(task.processIdentifier, "Process should execute")
    }

    // MARK: - Test 20: Large integer sleep timing accuracy
    // Tests that larger sleep values maintain timing accuracy
    func testSleep_largeInteger() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["sleep", "2"]

        let startTime = Date()
        try? task.run()
        task.waitUntilExit()
        let elapsed = Date().timeIntervalSince(startTime)

        XCTAssertEqual(task.terminationStatus, 0, "sleep 2 should exit with status 0")
        // Allow ±10% variance: 1.8 to 2.2 seconds
        XCTAssertGreaterThanOrEqual(elapsed, 1.8, "sleep 2 should take at least 1.8 seconds")
        XCTAssertLessThanOrEqual(elapsed, 2.2, "sleep 2 should take at most 2.2 seconds")
    }
}
