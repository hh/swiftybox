// TailTests.swift
// ============================================================================
// BusyBox Test Import Metadata
// ============================================================================
// Source Type: Individual test cases (subdirectory tests)
// Source Path: busybox/testsuite/tail/
// Import Date: 2025-11-14
// Test Count: 2
// Pass Rate: 100% (2/2)
// ============================================================================
// Tests for tail command functionality

import XCTest
import Foundation

final class TailTests: XCTestCase {
    var swiftyboxPath: String {
        let cwd = FileManager.default.currentDirectoryPath
        return "\(cwd)/.build/debug/swiftybox"
    }

    var testDir: String {
        return FileManager.default.temporaryDirectory.appendingPathComponent("tail-test-\(UUID().uuidString)").path
    }

    override func tearDown() {
        super.tearDown()
        // Clean up test directories
        let tempDir = FileManager.default.temporaryDirectory.path
        let contents = try? FileManager.default.contentsOfDirectory(atPath: tempDir)
        contents?.filter { $0.hasPrefix("tail-test-") }.forEach {
            try? FileManager.default.removeItem(atPath: tempDir + "/" + $0)
        }
    }

    // MARK: - Test 1: tail -n works
    // Source: busybox/testsuite/tail/tail-n-works
    func testTail_nFlagWorks() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)

        let inputPath = testPath + "/input"
        let outputPath = testPath + "/output"

        // Create input file
        try? "abc\ndef\n123\n".write(toFile: inputPath, atomically: true, encoding: .utf8)

        // Expected output (last 2 lines)
        let expected = "def\n123\n"

        // Run: tail -n 2 input
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["tail", "-n", "2", inputPath]

        let outputPipe = Pipe()
        task.standardOutput = outputPipe

        try? task.run()
        task.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "tail -n 2 should succeed")
        XCTAssertEqual(output, expected, "tail -n 2 should print last 2 lines")

        try? FileManager.default.removeItem(atPath: testPath)
    }

    // MARK: - Test 2: tail works (SUSv2 format)
    // Source: busybox/testsuite/tail/tail-works
    func testTail_susv2Format() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)

        let inputPath = testPath + "/input"

        // Create input file
        try? "abc\ndef\n123\n".write(toFile: inputPath, atomically: true, encoding: .utf8)

        // Expected output (last 2 lines)
        let expected = "def\n123\n"

        // Run: tail -2 input (SUSv2 format, equivalent to -n 2)
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["tail", "-2", inputPath]

        let outputPipe = Pipe()
        task.standardOutput = outputPipe

        try? task.run()
        task.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "tail -2 should succeed")
        XCTAssertEqual(output, expected, "tail -2 should print last 2 lines")

        try? FileManager.default.removeItem(atPath: testPath)
    }
}
