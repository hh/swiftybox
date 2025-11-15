import XCTest
@testable import swiftybox

final class UptimeTests: XCTestCase {
    func testUptimeWorks() {
        let result = runCommand("uptime", [])
        XCTAssertEqual(result.exitCode, 0, "uptime should succeed")
        XCTAssertFalse(result.stdout.isEmpty, "uptime should produce output")

        // uptime output typically contains time, uptime duration, users, and load average
        // Format varies, but should contain some numbers
        let output = result.stdout.lowercased()

        // Should contain some indicators of uptime info
        let hasTimeInfo = output.contains("up") || output.contains("day") ||
                         output.contains("min") || output.contains("user") ||
                         output.contains("load")

        XCTAssertTrue(hasTimeInfo, "uptime should show system uptime information")
    }

    func testUptimeFormat() {
        let result = runCommand("uptime", [])
        XCTAssertEqual(result.exitCode, 0, "uptime should succeed")

        // Output should be a single line (or at least contain data)
        let trimmed = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertFalse(trimmed.isEmpty, "uptime output should not be empty")

        // Should contain at least some digits (time, load average, etc.)
        let hasDigits = trimmed.contains(where: { $0.isNumber })
        XCTAssertTrue(hasDigits, "uptime should contain numeric information")
    }

    func testUptimeNoArgs() {
        // uptime should not require arguments
        let result = runCommand("uptime", [])
        XCTAssertEqual(result.exitCode, 0, "uptime with no args should succeed")
        XCTAssertTrue(result.stderr.isEmpty, "uptime should not produce errors")
    }
}
