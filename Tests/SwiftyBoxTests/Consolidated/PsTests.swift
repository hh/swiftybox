import XCTest
@testable import swiftybox

/// Tests for ps command (process status) - procps-ng compatible
final class PsTests: XCTestCase {

    // MARK: - Basic ps Tests

    func testPsNoArgs() {
        // ps with no arguments shows processes for current terminal
        let result = runCommand("ps", [])
        XCTAssertEqual(result.exitCode, 0, "ps should succeed")

        // Should have header
        XCTAssertTrue(result.stdout.contains("PID") || result.stdout.contains("TTY") || result.stdout.contains("CMD"),
                     "Should show header with PID, TTY, or CMD")

        // Should show at least the ps process itself
        let lines = result.stdout.split(separator: "\n").map(String.init)
        XCTAssertGreaterThan(lines.count, 1, "Should show at least header + one process")
    }

    func testPsAuxFormat() {
        // ps aux shows all processes in BSD format
        let result = runCommand("ps", ["aux"])
        XCTAssertEqual(result.exitCode, 0, "ps aux should succeed")

        // Should have header with all required fields
        let headerLine = result.stdout.split(separator: "\n").first.map(String.init) ?? ""

        XCTAssertTrue(headerLine.contains("USER"), "Header should contain USER")
        XCTAssertTrue(headerLine.contains("PID"), "Header should contain PID")
        XCTAssertTrue(headerLine.contains("%CPU") || headerLine.contains("CPU"),
                     "Header should contain %CPU")
        XCTAssertTrue(headerLine.contains("%MEM") || headerLine.contains("MEM"),
                     "Header should contain %MEM")
        XCTAssertTrue(headerLine.contains("VSZ"), "Header should contain VSZ")
        XCTAssertTrue(headerLine.contains("RSS"), "Header should contain RSS")
        XCTAssertTrue(headerLine.contains("TTY"), "Header should contain TTY")
        XCTAssertTrue(headerLine.contains("STAT") || headerLine.contains("S"),
                     "Header should contain STAT or S")
        XCTAssertTrue(headerLine.contains("START") || headerLine.contains("TIME"),
                     "Header should contain START or TIME")
        XCTAssertTrue(headerLine.contains("COMMAND") || headerLine.contains("CMD"),
                     "Header should contain COMMAND")

        // Should have multiple processes
        let lines = result.stdout.split(separator: "\n").map(String.init)
        XCTAssertGreaterThan(lines.count, 2,
                           "Should show header + at least one process (usually many)")
    }

    func testPsShowsPID1() {
        // ps aux should show PID 1 (init/systemd)
        let result = runCommand("ps", ["aux"])
        XCTAssertEqual(result.exitCode, 0, "ps aux should succeed")

        let lines = result.stdout.split(separator: "\n").map(String.init)
        let hasPID1 = lines.contains { line in
            let parts = line.split(separator: " ").filter { !$0.isEmpty }
            // Second field should be PID
            return parts.count > 1 && parts[1] == "1"
        }

        XCTAssertTrue(hasPID1, "ps aux should show PID 1 (init process)")
    }

    // MARK: - Process Selection Tests

    func testPsWithPIDOption() {
        // ps -p <pid> shows specific process
        // Use PID 1 which always exists
        let result = runCommand("ps", ["-p", "1"])
        XCTAssertEqual(result.exitCode, 0, "ps -p 1 should succeed")

        // Should show header + PID 1
        XCTAssertTrue(result.stdout.contains("1"), "Should show PID 1")

        let lines = result.stdout.split(separator: "\n").map(String.init).filter { !$0.isEmpty }
        XCTAssertEqual(lines.count, 2, "Should have exactly header + one process line")
    }

    func testPsWithMultiplePIDs() {
        // ps -p 1,2 shows multiple specific processes
        let result = runCommand("ps", ["-p", "1,2"])
        // May succeed or fail depending on whether PID 2 exists
        // But should at least try
        XCTAssertTrue(result.exitCode == 0 || !result.stderr.isEmpty,
                     "ps -p should either succeed or show error")
    }

    func testPsWithNonexistentPID() {
        // ps -p <huge number> should fail gracefully
        let result = runCommand("ps", ["-p", "9999999"])
        // Should either exit with error or produce empty output
        XCTAssertTrue(result.exitCode != 0 || result.stdout.split(separator: "\n").count <= 1,
                     "ps with nonexistent PID should fail or show only header")
    }

    // MARK: - Output Format Tests

    func testPsAuxFieldFormat() {
        let result = runCommand("ps", ["aux"])
        XCTAssertEqual(result.exitCode, 0, "ps aux should succeed")

        let lines = result.stdout.split(separator: "\n").map(String.init)
        // Skip header
        let processLines = lines.dropFirst().filter { !$0.isEmpty }

        for line in processLines.prefix(5) {  // Check first 5 processes
            let parts = line.split(separator: " ").filter { !$0.isEmpty }

            // Should have at least 11 fields: USER PID %CPU %MEM VSZ RSS TTY STAT START TIME COMMAND
            XCTAssertGreaterThanOrEqual(parts.count, 10,
                                       "Process line should have at least 10 fields, got \(parts.count) in: \(line)")

            if parts.count >= 2 {
                // PID should be a number
                XCTAssertNotNil(Int(parts[1]), "PID field should be a number, got: \(parts[1])")
            }

            if parts.count >= 5 {
                // VSZ should be a number
                XCTAssertNotNil(Int(parts[4]), "VSZ field should be a number, got: \(parts[4])")
            }

            if parts.count >= 6 {
                // RSS should be a number
                XCTAssertNotNil(Int(parts[5]), "RSS field should be a number, got: \(parts[5])")
            }
        }
    }

    // MARK: - Process State Tests

    func testPsShowsProcessStates() {
        let result = runCommand("ps", ["aux"])
        XCTAssertEqual(result.exitCode, 0, "ps aux should succeed")

        // Should show various process states: R (running), S (sleeping), D (disk wait), Z (zombie), T (stopped)
        let validStates = ["R", "S", "D", "Z", "T", "I"]
        let hasValidState = validStates.contains { state in
            result.stdout.contains(state)
        }
        XCTAssertTrue(hasValidState, "Should show at least one valid process state")
    }

    // MARK: - User Filter Tests

    func testPsShowsUserColumn() {
        let result = runCommand("ps", ["aux"])
        XCTAssertEqual(result.exitCode, 0, "ps aux should succeed")

        // Should show root user (always present on Unix systems)
        XCTAssertTrue(result.stdout.contains("root"), "Should show root user processes")
    }

    // MARK: - TTY Tests

    func testPsShowsTTY() {
        let result = runCommand("ps", ["aux"])
        XCTAssertEqual(result.exitCode, 0, "ps aux should succeed")

        // Should show processes with and without TTY
        let hasTTY = result.stdout.contains("tty") || result.stdout.contains("pts")
        let hasNoTTY = result.stdout.contains("?")

        XCTAssertTrue(hasTTY || hasNoTTY,
                     "Should show TTY information (either terminal name or ?)")
    }

    // MARK: - Command Display Tests

    func testPsShowsCommandName() {
        let result = runCommand("ps", ["aux"])
        XCTAssertEqual(result.exitCode, 0, "ps aux should succeed")

        let lines = result.stdout.split(separator: "\n").map(String.init)
        let processLines = lines.dropFirst().filter { !$0.isEmpty }

        for line in processLines.prefix(3) {
            // Last field(s) should be the command
            let parts = line.split(separator: " ").filter { !$0.isEmpty }
            XCTAssertGreaterThan(parts.count, 10,
                               "Should have enough fields to include command")

            // Command should not be empty
            if parts.count > 10 {
                let command = parts[10...]
                XCTAssertFalse(command.joined().isEmpty, "Command should not be empty")
            }
        }
    }

    // MARK: - Performance Tests

    func testPsCompletesQuickly() {
        // ps should complete in reasonable time even with many processes
        let start = Date()
        let result = runCommand("ps", ["aux"])
        let elapsed = Date().timeIntervalSince(start)

        XCTAssertEqual(result.exitCode, 0, "ps aux should succeed")
        XCTAssertLessThan(elapsed, 5.0, "ps aux should complete within 5 seconds")
    }

    // MARK: - Error Handling Tests

    func testPsWithInvalidOption() {
        let result = runCommand("ps", ["--invalid-option-xyz"])
        XCTAssertNotEqual(result.exitCode, 0, "ps with invalid option should fail")
        XCTAssertFalse(result.stderr.isEmpty, "Should produce error message")
    }

    // MARK: - Output Consistency Tests

    func testPsAuxOutputConsistency() {
        // Run ps aux twice and check format is consistent
        let result1 = runCommand("ps", ["aux"])
        let result2 = runCommand("ps", ["aux"])

        XCTAssertEqual(result1.exitCode, 0, "First ps aux should succeed")
        XCTAssertEqual(result2.exitCode, 0, "Second ps aux should succeed")

        let lines1 = result1.stdout.split(separator: "\n").map(String.init)
        let lines2 = result2.stdout.split(separator: "\n").map(String.init)

        // Headers should be identical
        if let header1 = lines1.first, let header2 = lines2.first {
            XCTAssertEqual(header1, header2, "Headers should be consistent across runs")
        }

        // Should have similar number of lines (within reason)
        XCTAssertTrue(abs(lines1.count - lines2.count) < 20,
                     "Number of processes should be similar between runs")
    }
}
