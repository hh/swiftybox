// DateTests.swift
// ============================================================================
// BusyBox Test Import Metadata
// ============================================================================
// Source Type: Individual test cases (subdirectory tests)
// Source Path: busybox/testsuite/date/
// Import Date: 2025-11-14
// Test Count: 7
// Pass Rate: 14.3% (1/7)
// ============================================================================
// Tests for date command functionality

import XCTest
import Foundation

final class DateTests: XCTestCase {
    var swiftyboxPath: String {
        let cwd = FileManager.default.currentDirectoryPath
        return "\(cwd)/.build/debug/swiftybox"
    }

    // MARK: - Test 1: basic date output format
    // Source: busybox/testsuite/date/date-works
    func testDate_basicOutput() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["date"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.environment = ["LC_ALL": "C"]
        try? task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "date should succeed")

        // Check format matches: Wed Nov 14 12:34:56 UTC 2025
        // Pattern: 3-letter day, 3-letter month, 1-2 digit day, HH:MM:SS, timezone, 4-digit year
        let pattern = "^[A-Z][a-z]{2} [A-Z][a-z]{2} [ 0-9][0-9] [0-2][0-9]:[0-5][0-9]:[0-6][0-9] [A-Z]+ [0-9]{4}$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(output.startIndex..., in: output)
        XCTAssertNotNil(regex?.firstMatch(in: output, range: range), "date output should match expected format, got: \(output)")
    }

    // MARK: - Test 2: date with format string
    // Source: busybox/testsuite/date/date-works-1
    func testDate_withFormatString() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["date", "+%Y"]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "date +%Y should succeed")
        XCTAssertTrue(output.count == 4, "Year should be 4 digits")
        XCTAssertTrue(Int(output) ?? 0 >= 2025, "Year should be >= 2025")
    }

    // MARK: - Test 3: date -u (UTC)
    // Source: busybox/testsuite/date/date-u-works
    func testDate_utcFlag() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["date", "-u", "-d", "2000.01.01-11:22:33"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.environment = ["TZ": "CET-1CEST-2"]
        try? task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "date -u should succeed")
        XCTAssertTrue(output.contains("UTC") || output.contains("GMT"), "UTC date should contain UTC or GMT timezone")
        XCTAssertTrue(output.contains("Sat Jan  1 11:22:33"), "Should show correct UTC time")
    }

    // MARK: - Test 4: date -R (RFC 2822 format)
    // Source: busybox/testsuite/date/date-R-works
    func testDate_rfc2822Format() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["date", "-R"]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "date -R should succeed")

        // RFC 2822 format: Wed, 14 Nov 2025 12:34:56 +0000
        let pattern = "^[A-Z][a-z]{2}, [0-9]{1,2} [A-Z][a-z]{2} [0-9]{4} [0-2][0-9]:[0-5][0-9]:[0-6][0-9] [+-][0-9]{4}$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(output.startIndex..., in: output)
        XCTAssertNotNil(regex?.firstMatch(in: output, range: range), "date -R output should match RFC 2822 format, got: \(output)")
    }

    // MARK: - Test 5: date -@ (unix timestamp)
    // Source: busybox/testsuite/date/date-@-works
    func testDate_unixTimestamp() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["date", "-d", "@1288486799"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.environment = ["TZ": "EET-2EEST,M3.5.0/3,M10.5.0/4"]
        try? task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "date -d @timestamp should succeed")
        // Just verify it returns some date output
        XCTAssertTrue(output.contains("2010"), "Should show year 2010")
        XCTAssertTrue(output.contains("Oct"), "Should show October")
    }

    // MARK: - Test 6: date with -d parsing various formats
    // Source: busybox/testsuite/date/date-format-works
    func testDate_parseTimeFormats() {
        // Test 1:2 format
        let task1 = Process()
        task1.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task1.arguments = ["date", "-d", "1:2", "+%T"]
        let pipe1 = Pipe()
        task1.standardOutput = pipe1
        try? task1.run()
        task1.waitUntilExit()

        let data1 = pipe1.fileHandleForReading.readDataToEndOfFile()
        let output1 = String(data: data1, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task1.terminationStatus, 0, "date -d 1:2 should succeed")
        XCTAssertEqual(output1, "01:02:00", "Should parse time 1:2 as 01:02:00")

        // Test 1:2:3 format
        let task2 = Process()
        task2.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task2.arguments = ["date", "-d", "1:2:3", "+%T"]
        let pipe2 = Pipe()
        task2.standardOutput = pipe2
        try? task2.run()
        task2.waitUntilExit()

        let data2 = pipe2.fileHandleForReading.readDataToEndOfFile()
        let output2 = String(data: data2, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task2.terminationStatus, 0, "date -d 1:2:3 should succeed")
        XCTAssertEqual(output2, "01:02:03", "Should parse time 1:2:3 as 01:02:03")
    }

    // MARK: - Test 7: date with ISO format
    // Source: busybox/testsuite/date/date-works-1
    func testDate_isoFormat() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["date", "-d", "1999-1-2 3:4:5"]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "date -d '1999-1-2 3:4:5' should succeed")
        XCTAssertTrue(output.hasPrefix("Sat Jan  2 03:04:05"), "Should parse ISO format correctly")
    }
}
