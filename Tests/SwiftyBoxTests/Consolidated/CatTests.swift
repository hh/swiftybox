// CatTests.swift
// ============================================================================
// BusyBox Test Import Metadata
// ============================================================================
// Source Type: Individual test cases (subdirectory tests)
// Source Path: busybox/testsuite/cat/
// Import Date: 2025-11-14
// Test Count: 2
// Pass Rate: 100% (2/2)
// ============================================================================
// Tests for cat (concatenate) command functionality

import XCTest
import Foundation

final class CatTests: XCTestCase {
    var swiftyboxPath: String {
        let cwd = FileManager.default.currentDirectoryPath
        return "\(cwd)/.build/debug/swiftybox"
    }

    var testDir: String {
        return FileManager.default.temporaryDirectory.appendingPathComponent("cat-test-\(UUID().uuidString)").path
    }

    override func tearDown() {
        super.tearDown()
        // Clean up test directories
        let tempDir = FileManager.default.temporaryDirectory.path
        let contents = try? FileManager.default.contentsOfDirectory(atPath: tempDir)
        contents?.filter { $0.hasPrefix("cat-test-") }.forEach {
            try? FileManager.default.removeItem(atPath: tempDir + "/" + $0)
        }
    }

    // MARK: - Test 1: cat prints a file
    // Source: busybox/testsuite/cat/cat-prints-a-file
    func testCat_printsFile() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)

        let fooPath = testPath + "/foo"
        let barPath = testPath + "/bar"

        // Create test file
        try? "I WANT\n".write(toFile: fooPath, atomically: true, encoding: .utf8)

        // Run: cat foo > bar
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["cat", fooPath]

        let outputPipe = Pipe()
        task.standardOutput = outputPipe

        try? task.run()
        task.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        try? data.write(to: URL(fileURLWithPath: barPath))

        XCTAssertEqual(task.terminationStatus, 0, "cat should succeed")

        // Compare files
        let fooContent = try? String(contentsOfFile: fooPath, encoding: .utf8)
        let barContent = try? String(contentsOfFile: barPath, encoding: .utf8)

        XCTAssertEqual(fooContent, barContent, "cat output should match input file")

        try? FileManager.default.removeItem(atPath: testPath)
    }

    // MARK: - Test 2: cat prints file and standard input
    // Source: busybox/testsuite/cat/cat-prints-a-file-and-standard-input
    func testCat_printsFileAndStdin() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)

        let fooPath = testPath + "/foo"
        let barPath = testPath + "/bar"
        let bazPath = testPath + "/baz"

        // Create test file
        try? "I WANT\n".write(toFile: fooPath, atomically: true, encoding: .utf8)

        // Expected output
        try? "I WANT\nSOMETHING\n".write(toFile: bazPath, atomically: true, encoding: .utf8)

        // Run: echo SOMETHING | cat foo - > bar
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["cat", fooPath, "-"]

        let inputPipe = Pipe()
        let outputPipe = Pipe()
        task.standardInput = inputPipe
        task.standardOutput = outputPipe

        try? task.run()

        // Write to stdin
        let stdinData = "SOMETHING\n".data(using: .utf8)!
        inputPipe.fileHandleForWriting.write(stdinData)
        try? inputPipe.fileHandleForWriting.close()

        task.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        try? data.write(to: URL(fileURLWithPath: barPath))

        XCTAssertEqual(task.terminationStatus, 0, "cat should succeed")

        // Compare files
        let barContent = try? String(contentsOfFile: barPath, encoding: .utf8)
        let bazContent = try? String(contentsOfFile: bazPath, encoding: .utf8)

        XCTAssertEqual(barContent, bazContent, "cat foo - should concatenate file and stdin")

        try? FileManager.default.removeItem(atPath: testPath)
    }
}
