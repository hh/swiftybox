// DirnameTests.swift
// ============================================================================
// BusyBox Test Import Metadata
// ============================================================================
// Source Type: Individual test cases (subdirectory tests)
// Source Path: busybox/testsuite/dirname/
// Import Date: 2025-11-14
// Test Count: 7
// Pass Rate: 71.4% (5/7)
// ============================================================================
// Tests for dirname command edge cases and scenarios

import XCTest
import Foundation

final class DirnameTests: XCTestCase {
    var swiftyboxPath: String {
        let cwd = FileManager.default.currentDirectoryPath
        return "\(cwd)/.build/debug/swiftybox"
    }

    // MARK: - Test 1: handles-absolute-path
    // Source: busybox/testsuite/dirname/dirname-handles-absolute-path
    func testDirname_handlesAbsolutePath() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["dirname", "/foo/bar/baz"]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "dirname should succeed")
        XCTAssertEqual(output, "/foo/bar", "dirname should extract parent directory")
    }

    // MARK: - Test 2: handles-empty-path
    // Source: busybox/testsuite/dirname/dirname-handles-empty-path
    func testDirname_handlesEmptyPath() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["dirname", ""]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "dirname should succeed")
        XCTAssertEqual(output, ".", "dirname of empty string should be '.'")
    }

    // MARK: - Test 3: handles-multiple-slashes
    // Source: busybox/testsuite/dirname/dirname-handles-multiple-slashes
    func testDirname_handlesMultipleSlashes() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["dirname", "foo/bar///baz"]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "dirname should succeed")
        XCTAssertEqual(output, "foo/bar", "dirname should handle multiple slashes")
    }

    // MARK: - Test 4: handles-relative-path
    // Source: busybox/testsuite/dirname/dirname-handles-relative-path
    func testDirname_handlesRelativePath() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["dirname", "foo/bar/baz"]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "dirname should succeed")
        XCTAssertEqual(output, "foo/bar", "dirname should extract parent from relative path")
    }

    // MARK: - Test 5: handles-root
    // Source: busybox/testsuite/dirname/dirname-handles-root
    func testDirname_handlesRoot() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["dirname", "/"]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "dirname should succeed")
        XCTAssertEqual(output, "/", "dirname of '/' should be '/'")
    }

    // MARK: - Test 6: handles-single-component
    // Source: busybox/testsuite/dirname/dirname-handles-single-component
    func testDirname_handlesSingleComponent() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["dirname", "foo"]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "dirname should succeed")
        XCTAssertEqual(output, ".", "dirname of single component should be '.'")
    }

    // MARK: - Test 7: works (matches system dirname)
    // Source: busybox/testsuite/dirname/dirname-works
    func testDirname_matchesSystemDirname() {
        let currentDir = FileManager.default.currentDirectoryPath

        // Run system dirname
        let systemTask = Process()
        systemTask.executableURL = URL(fileURLWithPath: "/usr/bin/dirname")
        systemTask.arguments = [currentDir]
        let systemPipe = Pipe()
        systemTask.standardOutput = systemPipe
        try? systemTask.run()
        systemTask.waitUntilExit()

        let systemData = systemPipe.fileHandleForReading.readDataToEndOfFile()
        let systemOutput = String(data: systemData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // Run our dirname
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["dirname", currentDir]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "dirname should succeed")
        XCTAssertEqual(output, systemOutput, "dirname should match system dirname output")
    }
}
