// BasenameTests.swift
// ============================================================================
// BusyBox Test Import Metadata
// ============================================================================
// Source Type: Individual test cases (subdirectory tests)
// Source Path: busybox/testsuite/basename/
// Import Date: 2025-11-14
// Test Count: 2
// Pass Rate: 50.0% (1/2)
// ============================================================================
// Tests for basename command functionality

import XCTest
import Foundation

final class BasenameTests: XCTestCase {
    var swiftyboxPath: String {
        let cwd = FileManager.default.currentDirectoryPath
        return "\(cwd)/.build/debug/swiftybox"
    }

    // MARK: - Test 1: basename does not remove identical extension
    // Source: busybox/testsuite/basename/basename-does-not-remove-identical-extension
    func testBasename_doesNotRemoveIdenticalExtension() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["basename", "foo", "foo"]

        let outputPipe = Pipe()
        task.standardOutput = outputPipe

        try? task.run()
        task.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "basename should succeed")
        XCTAssertEqual(output, "foo", "basename foo foo should return 'foo'")
    }

    // MARK: - Test 2: basename works with current directory
    // Source: busybox/testsuite/basename/basename-works
    func testBasename_worksWithCurrentDirectory() {
        let currentDir = FileManager.default.currentDirectoryPath

        // Get system basename
        let systemTask = Process()
        systemTask.executableURL = URL(fileURLWithPath: "/usr/bin/basename")
        systemTask.arguments = [currentDir]

        let systemPipe = Pipe()
        systemTask.standardOutput = systemPipe

        try? systemTask.run()
        systemTask.waitUntilExit()

        let systemData = systemPipe.fileHandleForReading.readDataToEndOfFile()
        let systemOutput = String(data: systemData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // Get our basename
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["basename", currentDir]

        let outputPipe = Pipe()
        task.standardOutput = outputPipe

        try? task.run()
        task.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "basename should succeed")
        XCTAssertEqual(output, systemOutput, "basename output should match system basename")
    }
}
