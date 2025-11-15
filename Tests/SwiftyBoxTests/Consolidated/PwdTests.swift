// PwdTests.swift
// ============================================================================
// BusyBox Test Import Metadata
// ============================================================================
// Source Type: Individual test cases (subdirectory tests)
// Source Path: busybox/testsuite/pwd/
// Import Date: 2025-11-14
// Test Count: 1
// Pass Rate: 100% (1/1)
// ============================================================================
// Tests for pwd command functionality

import XCTest
import Foundation

final class PwdTests: XCTestCase {
    var swiftyboxPath: String {
        let cwd = FileManager.default.currentDirectoryPath
        return "\(cwd)/.build/debug/swiftybox"
    }

    // MARK: - Test 1: pwd prints working directory
    // Source: busybox/testsuite/pwd/pwd-prints-working-directory
    func testPwd_printsWorkingDirectory() {
        // Get external pwd (not shell builtin)
        let whichTask = Process()
        whichTask.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        whichTask.arguments = ["pwd"]

        let whichPipe = Pipe()
        whichTask.standardOutput = whichPipe

        try? whichTask.run()
        whichTask.waitUntilExit()

        let whichData = whichPipe.fileHandleForReading.readDataToEndOfFile()
        let pwdPath = String(data: whichData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "/usr/bin/pwd"

        // Get system pwd output
        let systemTask = Process()
        systemTask.executableURL = URL(fileURLWithPath: pwdPath)

        let systemPipe = Pipe()
        systemTask.standardOutput = systemPipe

        try? systemTask.run()
        systemTask.waitUntilExit()

        let systemData = systemPipe.fileHandleForReading.readDataToEndOfFile()
        let systemOutput = String(data: systemData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // Get our pwd output
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["pwd"]

        let outputPipe = Pipe()
        task.standardOutput = outputPipe

        try? task.run()
        task.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "pwd should succeed")
        XCTAssertEqual(output, systemOutput, "pwd should match system pwd")
    }
}
