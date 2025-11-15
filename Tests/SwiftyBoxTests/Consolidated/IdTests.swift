// IdTests.swift
// ============================================================================
// BusyBox Test Import Metadata
// ============================================================================
// Source Type: Individual test cases (subdirectory tests)
// Source Path: busybox/testsuite/id/
// Import Date: 2025-11-14
// Test Count: 4
// Pass Rate: 50.0% (2/4)
// ============================================================================
// Tests for id command functionality

import XCTest
import Foundation

final class IdTests: XCTestCase {
    var swiftyboxPath: String {
        let cwd = FileManager.default.currentDirectoryPath
        return "\(cwd)/.build/debug/swiftybox"
    }

    // MARK: - Test 1: id -g works
    // Source: busybox/testsuite/id/id-g-works
    func testId_gFlagWorks() {
        // Get system id -g
        let systemTask = Process()
        systemTask.executableURL = URL(fileURLWithPath: "/usr/bin/id")
        systemTask.arguments = ["-g"]

        let systemPipe = Pipe()
        systemTask.standardOutput = systemPipe

        try? systemTask.run()
        systemTask.waitUntilExit()

        let systemData = systemPipe.fileHandleForReading.readDataToEndOfFile()
        let systemOutput = String(data: systemData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // Get our id -g
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["id", "-g"]

        let outputPipe = Pipe()
        task.standardOutput = outputPipe

        try? task.run()
        task.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "id -g should succeed")
        XCTAssertEqual(output, systemOutput, "id -g should match system id")
    }

    // MARK: - Test 2: id -u works
    // Source: busybox/testsuite/id/id-u-works
    func testId_uFlagWorks() {
        // Get system id -u
        let systemTask = Process()
        systemTask.executableURL = URL(fileURLWithPath: "/usr/bin/id")
        systemTask.arguments = ["-u"]

        let systemPipe = Pipe()
        systemTask.standardOutput = systemPipe

        try? systemTask.run()
        systemTask.waitUntilExit()

        let systemData = systemPipe.fileHandleForReading.readDataToEndOfFile()
        let systemOutput = String(data: systemData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // Get our id -u
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["id", "-u"]

        let outputPipe = Pipe()
        task.standardOutput = outputPipe

        try? task.run()
        task.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "id -u should succeed")
        XCTAssertEqual(output, systemOutput, "id -u should match system id")
    }

    // MARK: - Test 3: id -un works
    // Source: busybox/testsuite/id/id-un-works
    func testId_unFlagsWork() {
        // Get system id -un
        let systemTask = Process()
        systemTask.executableURL = URL(fileURLWithPath: "/usr/bin/id")
        systemTask.arguments = ["-un"]

        let systemPipe = Pipe()
        systemTask.standardOutput = systemPipe

        try? systemTask.run()
        systemTask.waitUntilExit()

        let systemData = systemPipe.fileHandleForReading.readDataToEndOfFile()
        let systemOutput = String(data: systemData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // Get our id -un
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["id", "-un"]

        let outputPipe = Pipe()
        task.standardOutput = outputPipe

        try? task.run()
        task.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "id -un should succeed")
        XCTAssertEqual(output, systemOutput, "id -un should match system id")
    }

    // MARK: - Test 4: id -ur works
    // Source: busybox/testsuite/id/id-ur-works
    func testId_urFlagsWork() {
        // Get system id -ur
        let systemTask = Process()
        systemTask.executableURL = URL(fileURLWithPath: "/usr/bin/id")
        systemTask.arguments = ["-ur"]

        let systemPipe = Pipe()
        systemTask.standardOutput = systemPipe

        try? systemTask.run()
        systemTask.waitUntilExit()

        let systemData = systemPipe.fileHandleForReading.readDataToEndOfFile()
        let systemOutput = String(data: systemData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // Get our id -ur
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["id", "-ur"]

        let outputPipe = Pipe()
        task.standardOutput = outputPipe

        try? task.run()
        task.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "id -ur should succeed")
        XCTAssertEqual(output, systemOutput, "id -ur should match system id")
    }
}
