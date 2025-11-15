// UsleepTests.swift
// Comprehensive tests for the usleep command

import XCTest
@testable import swiftybox

/// Tests for the `usleep` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: BusyBox usleep (Linux/Unix extension)
/// - Suspends execution for microsecond intervals
/// - Common usage: usleep N (N microseconds)
/// - 1 second = 1,000,000 microseconds
/// - Target scope: P0 (basic microsecond sleep)
///
/// Key behaviors to test:
/// - Delays for specified microseconds
/// - Exit code 0 on success
/// - No output
/// - Timing accuracy (within tolerance)
/// - Error handling for invalid input
///
/// Resources:
/// - BusyBox usleep source
/// - Man page: usleep(3) system call

final class UsleepTests: XCTestCase {

    // MARK: - Basic Functionality

    func testUsleep_100milliseconds() {
        // usleep 100000 = 100ms = 0.1s
        let start = Date()
        let result = runCommand("usleep", ["100000"])
        let duration = Date().timeIntervalSince(start)

        XCTAssertEqual(result.exitCode, 0, "usleep should succeed")
        XCTAssertEqual(result.stdout, "", "usleep should produce no output")
        XCTAssertEqual(result.stderr, "", "usleep should produce no stderr")

        // Check timing (±20% tolerance for very short sleeps)
        XCTAssertGreaterThan(duration, 0.08, "Should sleep at least 80ms")
        XCTAssertLessThan(duration, 0.15, "Should sleep no more than 150ms")
    }

    func testUsleep_50milliseconds() {
        // usleep 50000 = 50ms = 0.05s
        let start = Date()
        let result = runCommand("usleep", ["50000"])
        let duration = Date().timeIntervalSince(start)

        XCTAssertEqual(result.exitCode, 0, "usleep should succeed")

        XCTAssertGreaterThan(duration, 0.03, "Should sleep at least 30ms")
        XCTAssertLessThan(duration, 0.08, "Should sleep no more than 80ms")
    }

    func testUsleep_1millisecond() {
        // usleep 1000 = 1ms
        let start = Date()
        let result = runCommand("usleep", ["1000"])
        let duration = Date().timeIntervalSince(start)

        XCTAssertEqual(result.exitCode, 0, "usleep should succeed")

        // Very short sleep, high variance expected
        XCTAssertGreaterThan(duration, 0.0, "Should take some time")
        XCTAssertLessThan(duration, 0.01, "Should be very short")
    }

    func testUsleep_500milliseconds() {
        // usleep 500000 = 500ms = 0.5s
        let start = Date()
        let result = runCommand("usleep", ["500000"])
        let duration = Date().timeIntervalSince(start)

        XCTAssertEqual(result.exitCode, 0, "usleep should succeed")

        XCTAssertGreaterThan(duration, 0.4, "Should sleep at least 400ms")
        XCTAssertLessThan(duration, 0.6, "Should sleep no more than 600ms")
    }

    // MARK: - Zero and Very Small Values

    func testUsleep_zero() {
        // usleep 0 should return immediately
        let start = Date()
        let result = runCommand("usleep", ["0"])
        let duration = Date().timeIntervalSince(start)

        XCTAssertEqual(result.exitCode, 0, "usleep 0 should succeed")
        XCTAssertLessThan(duration, 0.05, "usleep 0 should return immediately")
    }

    func testUsleep_one() {
        // usleep 1 = 1 microsecond (essentially instant)
        let start = Date()
        let result = runCommand("usleep", ["1"])
        let duration = Date().timeIntervalSince(start)

        XCTAssertEqual(result.exitCode, 0, "usleep 1 should succeed")
        XCTAssertLessThan(duration, 0.01, "usleep 1 should be very quick")
    }

    // MARK: - Output Validation

    func testUsleep_noOutput() {
        let result = runCommand("usleep", ["10000"])

        XCTAssertTrue(result.stdout.isEmpty, "usleep should not output to stdout")
        XCTAssertTrue(result.stderr.isEmpty, "usleep should not output to stderr on success")
    }

    func testUsleep_exitCodeZero() {
        let result = runCommand("usleep", ["50000"])
        XCTAssertEqual(result.exitCode, 0, "usleep should exit with 0")
    }

    // MARK: - Error Handling

    func testUsleep_noArguments() {
        let result = runCommand("usleep", [])

        XCTAssertNotEqual(result.exitCode, 0, "usleep should fail with no arguments")
        XCTAssertFalse(result.stderr.isEmpty, "usleep should output error message")
    }

    func testUsleep_invalidInput() {
        let result = runCommand("usleep", ["not_a_number"])

        XCTAssertNotEqual(result.exitCode, 0, "usleep should fail with invalid input")
        XCTAssertFalse(result.stderr.isEmpty, "usleep should output error message")
    }

    func testUsleep_negativeNumber() {
        let result = runCommand("usleep", ["-1000"])

        // Either fails or treats as invalid
        if result.exitCode != 0 {
            XCTAssertFalse(result.stderr.isEmpty, "Should output error for negative value")
        }
    }

    func testUsleep_tooManyArguments() {
        let result = runCommand("usleep", ["10000", "20000"])

        // Either fails or ignores extra arguments
        if result.exitCode != 0 {
            XCTAssertFalse(result.stderr.isEmpty, "Should output error for extra arguments")
        }
    }

    // MARK: - Large Values

    func testUsleep_1second() {
        // usleep 1000000 = 1 second
        let start = Date()
        let result = runCommand("usleep", ["1000000"])
        let duration = Date().timeIntervalSince(start)

        XCTAssertEqual(result.exitCode, 0, "usleep should succeed for 1 second")

        XCTAssertGreaterThan(duration, 0.9, "Should sleep at least 0.9s")
        XCTAssertLessThan(duration, 1.1, "Should sleep no more than 1.1s")
    }

    // MARK: - Consistency

    func testUsleep_consistency() {
        let results = (0..<3).map { _ in
            let start = Date()
            let result = runCommand("usleep", ["10000"])
            let duration = Date().timeIntervalSince(start)
            return (result, duration)
        }

        // All should succeed
        XCTAssertTrue(results.allSatisfy { $0.0.exitCode == 0 },
                     "All usleep calls should succeed")

        // All durations should be in reasonable range
        XCTAssertTrue(results.allSatisfy { $0.1 < 0.05 },
                     "All should complete quickly")
    }

    // MARK: - No stdin

    func testUsleep_ignoresStdin() {
        let result = runCommandWithInput("usleep", ["10000"], input: "ignored\n")

        XCTAssertEqual(result.exitCode, 0, "usleep should ignore stdin")
    }

    // MARK: - Comparison with sleep

    func testUsleep_comparisonWithSleep() {
        // usleep 500000 (500ms) vs sleep 0.5 should be similar
        let usleepStart = Date()
        let usleepResult = runCommand("usleep", ["500000"])
        let usleepDuration = Date().timeIntervalSince(usleepStart)

        let sleepStart = Date()
        let sleepResult = runCommand("sleep", ["0.5"])
        let sleepDuration = Date().timeIntervalSince(sleepStart)

        XCTAssertEqual(usleepResult.exitCode, 0, "usleep should succeed")
        XCTAssertEqual(sleepResult.exitCode, 0, "sleep should succeed")

        // Durations should be within 20% of each other
        let ratio = usleepDuration / sleepDuration
        XCTAssertGreaterThan(ratio, 0.8, "usleep and sleep should take similar time")
        XCTAssertLessThan(ratio, 1.2, "usleep and sleep should take similar time")
    }
}
