// TeeTests.swift
// ============================================================================
// BusyBox Test Import Metadata
// ============================================================================
// Source Type: Individual test cases (subdirectory tests)
// Source Path: busybox/testsuite/tee/
// Import Date: 2025-11-14
// Test Count: 2
// Pass Rate: 100% (2/2)
// ============================================================================
// Tests for tee command functionality

import XCTest
import Foundation

final class TeeTests: XCTestCase {
    var swiftyboxPath: String {
        let cwd = FileManager.default.currentDirectoryPath
        return "\(cwd)/.build/debug/swiftybox"
    }

    var testDir: String {
        return FileManager.default.temporaryDirectory.appendingPathComponent("tee-test-\(UUID().uuidString)").path
    }

    override func tearDown() {
        super.tearDown()
        // Clean up test directories
        let tempDir = FileManager.default.temporaryDirectory.path
        let contents = try? FileManager.default.contentsOfDirectory(atPath: tempDir)
        contents?.filter { $0.hasPrefix("tee-test-") }.forEach {
            try? FileManager.default.removeItem(atPath: tempDir + "/" + $0)
        }
    }

    // MARK: - Test 1: tee -a appends input
    // Source: busybox/testsuite/tee/tee-appends-input
    func testTee_appendsInput() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)

        let fooPath = testPath + "/foo"
        let barPath = testPath + "/bar"

        // Create foo with one line
        try? "i'm a little teapot\n".write(toFile: fooPath, atomically: true, encoding: .utf8)

        // Copy foo to bar
        try? FileManager.default.copyItem(atPath: fooPath, toPath: barPath)

        // Append another line to foo manually (for comparison)
        if let handle = FileHandle(forWritingAtPath: fooPath) {
            handle.seekToEndOfFile()
            handle.write("i'm a little teapot\n".data(using: .utf8)!)
            handle.closeFile()
        }

        // Run: echo "i'm a little teapot" | tee -a bar > /dev/null
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["tee", "-a", barPath]

        let inputPipe = Pipe()
        let outputPipe = Pipe()
        task.standardInput = inputPipe
        task.standardOutput = outputPipe

        try? task.run()

        // Write to stdin
        inputPipe.fileHandleForWriting.write("i'm a little teapot\n".data(using: .utf8)!)
        try? inputPipe.fileHandleForWriting.close()

        task.waitUntilExit()

        XCTAssertEqual(task.terminationStatus, 0, "tee -a should succeed")

        // Compare files
        let fooContent = try? String(contentsOfFile: fooPath, encoding: .utf8)
        let barContent = try? String(contentsOfFile: barPath, encoding: .utf8)

        XCTAssertEqual(fooContent, barContent, "tee -a should append to file, matching expected output")

        try? FileManager.default.removeItem(atPath: testPath)
    }

    // MARK: - Test 2: tee tees input (writes to file and stdout)
    // Source: busybox/testsuite/tee/tee-tees-input
    func testTee_teesInput() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)

        let fooPath = testPath + "/foo"
        let barPath = testPath + "/bar"
        let bazPath = testPath + "/baz"

        // Create expected content
        try? "i'm a little teapot\n".write(toFile: fooPath, atomically: true, encoding: .utf8)

        // Run: echo "i'm a little teapot" | tee bar > baz
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["tee", barPath]

        let inputPipe = Pipe()
        let outputPipe = Pipe()
        task.standardInput = inputPipe
        task.standardOutput = outputPipe

        try? task.run()

        // Write to stdin
        inputPipe.fileHandleForWriting.write("i'm a little teapot\n".data(using: .utf8)!)
        try? inputPipe.fileHandleForWriting.close()

        task.waitUntilExit()

        // Save stdout to baz
        let bazData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        try? bazData.write(to: URL(fileURLWithPath: bazPath))

        XCTAssertEqual(task.terminationStatus, 0, "tee should succeed")

        // Compare all three files (should be identical)
        let fooContent = try? String(contentsOfFile: fooPath, encoding: .utf8)
        let barContent = try? String(contentsOfFile: barPath, encoding: .utf8)
        let bazContent = try? String(contentsOfFile: bazPath, encoding: .utf8)

        XCTAssertEqual(fooContent, barContent, "tee should write input to file (bar)")
        XCTAssertEqual(fooContent, bazContent, "tee should write input to stdout (baz)")

        try? FileManager.default.removeItem(atPath: testPath)
    }
}
