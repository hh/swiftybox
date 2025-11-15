// DuTests.swift
// ============================================================================
// BusyBox Test Import Metadata
// ============================================================================
// Source Type: Individual test cases (subdirectory tests)
// Source Path: busybox/testsuite/du/
// Import Date: 2025-11-14
// Test Count: 6
// Pass Rate: 50.0% (3/6)
// ============================================================================
// Tests for du (disk usage) command functionality

import XCTest
import Foundation

final class DuTests: XCTestCase {
    var swiftyboxPath: String {
        let cwd = FileManager.default.currentDirectoryPath
        return "\(cwd)/.build/debug/swiftybox"
    }

    var testDir: String {
        return FileManager.default.temporaryDirectory.appendingPathComponent("du-test-\(UUID().uuidString)").path
    }

    override func tearDown() {
        super.tearDown()
        // Clean up test directories
        let tempDir = FileManager.default.temporaryDirectory.path
        let contents = try? FileManager.default.contentsOfDirectory(atPath: tempDir)
        contents?.filter { $0.hasPrefix("du-test-") }.forEach {
            try? FileManager.default.removeItem(atPath: tempDir + "/" + $0)
        }
    }

    // MARK: - Test 1: du -h (human readable)
    // Source: busybox/testsuite/du/du-h-works
    func testDu_humanReadableFlag() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)

        // Create a 1MB file
        let filePath = testPath + "/file"
        let data = Data(repeating: 0, count: 1024 * 1024) // 1MB
        try? data.write(to: URL(fileURLWithPath: filePath))

        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["du", "-h", filePath]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()

        let output = pipe.fileHandleForReading.readDataToEndOfFile()
        let result = String(data: output, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "du -h should succeed")
        XCTAssertTrue(result.contains("M") || result.contains("K"), "Output should contain human-readable size")

        try? FileManager.default.removeItem(atPath: testPath)
    }

    // MARK: - Test 2: du -k (kilobytes)
    // Source: busybox/testsuite/du/du-k-works
    func testDu_kilobytesFlag() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)

        // Create files
        let file1 = testPath + "/file1"
        let file2 = testPath + "/file2"
        let data1 = Data(repeating: 0, count: 64 * 1024) // 64KB
        let data2 = Data(repeating: 0, count: 16 * 1024) // 16KB
        try? data1.write(to: URL(fileURLWithPath: file1))
        try? data2.write(to: URL(fileURLWithPath: file2))

        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["du", "-k", testPath]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()

        let output = pipe.fileHandleForReading.readDataToEndOfFile()
        let result = String(data: output, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "du -k should succeed")

        // Extract size from output (format: "SIZE\tPATH")
        let components = result.split(separator: "\t")
        if let sizeStr = components.first, let size = Int(sizeStr) {
            // Size should be around 80-88 KB (accounting for filesystem overhead)
            XCTAssertTrue(size >= 80 && size <= 100, "Size should be approximately 80-88 KB, got \(size)")
        } else {
            XCTFail("Could not parse size from output: \(result)")
        }

        try? FileManager.default.removeItem(atPath: testPath)
    }

    // MARK: - Test 3: du -l (count hard links)
    // Source: busybox/testsuite/du/du-l-works
    func testDu_countHardLinks() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)

        // Create file and hard link
        let file1 = testPath + "/file1"
        let link1 = testPath + "/file1.1"
        let file2 = testPath + "/file2"

        let data1 = Data(repeating: 0, count: 64 * 1024) // 64KB
        let data2 = Data(repeating: 0, count: 16 * 1024) // 16KB
        try? data1.write(to: URL(fileURLWithPath: file1))
        try? data2.write(to: URL(fileURLWithPath: file2))

        // Create hard link
        try? FileManager.default.linkItem(atPath: file1, toPath: link1)

        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["du", "-l", testPath]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()

        let output = pipe.fileHandleForReading.readDataToEndOfFile()
        let result = String(data: output, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "du -l should succeed")

        // With -l flag, hard links are counted separately
        // Size should be larger (144-156 KB range)
        let components = result.split(separator: "\t")
        if let sizeStr = components.first, let size = Int(sizeStr) {
            XCTAssertTrue(size >= 140 && size <= 160, "Size with hard links should be approximately 144-156 KB, got \(size)")
        }

        try? FileManager.default.removeItem(atPath: testPath)
    }

    // MARK: - Test 4: du -m (megabytes)
    // Source: busybox/testsuite/du/du-m-works
    func testDu_megabytesFlag() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)

        // Create a 1MB file
        let filePath = testPath + "/file"
        let data = Data(repeating: 0, count: 1024 * 1024) // 1MB
        try? data.write(to: URL(fileURLWithPath: filePath))

        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["du", "-m", filePath]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()

        let output = pipe.fileHandleForReading.readDataToEndOfFile()
        let result = String(data: output, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "du -m should succeed")

        // Should show "1\tfile"
        XCTAssertTrue(result.hasPrefix("1\t"), "Should show size as 1 MB")

        try? FileManager.default.removeItem(atPath: testPath)
    }

    // MARK: - Test 5: du -s (summary only)
    // Source: busybox/testsuite/du/du-s-works
    func testDu_summaryFlag() {
        // Test on a real directory
        let testPath = "/usr/bin"

        // Get system du output
        let systemTask = Process()
        systemTask.executableURL = URL(fileURLWithPath: "/usr/bin/du")
        systemTask.arguments = ["-s", testPath]
        let systemPipe = Pipe()
        systemTask.standardOutput = systemPipe
        systemTask.standardError = Pipe()
        try? systemTask.run()
        systemTask.waitUntilExit()

        let systemOutput = systemPipe.fileHandleForReading.readDataToEndOfFile()
        let systemResult = String(data: systemOutput, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // Get our du output
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["du", "-s", testPath]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        try? task.run()
        task.waitUntilExit()

        let output = pipe.fileHandleForReading.readDataToEndOfFile()
        let result = String(data: output, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "du -s should succeed")

        // Compare outputs (allowing for small differences due to timing)
        let systemSize = systemResult.split(separator: "\t").first.map { Int($0) ?? 0 } ?? 0
        let ourSize = result.split(separator: "\t").first.map { Int($0) ?? 0 } ?? 0

        // Allow 10% variance
        let variance = Double(systemSize) * 0.1
        XCTAssertTrue(abs(Double(systemSize - ourSize)) <= variance,
                     "Size should be close to system du: expected ~\(systemSize), got \(ourSize)")
    }

    // MARK: - Test 6: du basic functionality
    // Source: busybox/testsuite/du/du-works
    func testDu_basicFunctionality() {
        // Test on a real directory
        let testPath = "/usr/bin"

        // Get system du output
        let systemTask = Process()
        systemTask.executableURL = URL(fileURLWithPath: "/usr/bin/du")
        systemTask.arguments = [testPath]
        let systemPipe = Pipe()
        systemTask.standardOutput = systemPipe
        systemTask.standardError = Pipe()
        try? systemTask.run()
        systemTask.waitUntilExit()

        let systemOutput = systemPipe.fileHandleForReading.readDataToEndOfFile()
        let systemResult = String(data: systemOutput, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // Get our du output
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["du", testPath]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        try? task.run()
        task.waitUntilExit()

        let output = pipe.fileHandleForReading.readDataToEndOfFile()
        let result = String(data: output, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "du should succeed")

        // Just verify we got some output
        XCTAssertFalse(result.isEmpty, "du should produce output")

        // Count lines - should be similar (within reason)
        let systemLines = systemResult.split(separator: "\n").count
        let ourLines = result.split(separator: "\n").count

        // Allow for some variance in directory traversal
        let variance = max(10, systemLines / 10)
        XCTAssertTrue(abs(systemLines - ourLines) <= variance,
                     "Line count should be similar: expected ~\(systemLines), got \(ourLines)")
    }
}
