// WhichTests.swift
// ============================================================================
// BusyBox Test Import Metadata
// ============================================================================
// Source Type: Individual test cases (subdirectory tests)
// Source Path: busybox/testsuite/which/
// Import Date: 2025-11-14
// Test Count: 1
// Pass Rate: 0% (0/1)
// ============================================================================
// Tests for which command functionality

import XCTest
import Foundation

final class WhichTests: XCTestCase {
    var swiftyboxPath: String {
        let cwd = FileManager.default.currentDirectoryPath
        return "\(cwd)/.build/debug/swiftybox"
    }

    // MARK: - Test 1: which uses default PATH
    // Source: busybox/testsuite/which/which-uses-default-path
    func testWhich_usesDefaultPath() {
        // Run with unset PATH to test default PATH behavior
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["which", "ls"]

        // Unset PATH to force use of default PATH
        task.environment = [:]

        let outputPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = Pipe()

        try? task.run()
        task.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "which should succeed")
        XCTAssertFalse(output.isEmpty, "which should find ls in default PATH")
        XCTAssertTrue(output.contains("ls"), "which output should contain 'ls'")
    }
}
