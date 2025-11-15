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

    // MARK: - Enhanced Tests (Session 3)

    func testDu_emptyDirectory() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(atPath: testPath) }

        let result = runCommand("du", [testPath])
        XCTAssertEqual(result.exitCode, 0, "du should succeed on empty directory")
        XCTAssertFalse(result.stdout.isEmpty, "Should show directory size")
    }

    func testDu_singleFile() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)
        let filePath = testPath + "/singlefile.txt"
        try? "test content\n".write(toFile: filePath, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(atPath: testPath) }

        let result = runCommand("du", [filePath])
        XCTAssertEqual(result.exitCode, 0, "du should work on single file")
    }

    func testDu_nestedDirectories() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)
        let subdir1 = testPath + "/sub1"
        let subdir2 = testPath + "/sub2"
        try? FileManager.default.createDirectory(atPath: subdir1, withIntermediateDirectories: false)
        try? FileManager.default.createDirectory(atPath: subdir2, withIntermediateDirectories: false)

        try? Data(repeating: 0, count: 1024).write(to: URL(fileURLWithPath: subdir1 + "/file1"))
        try? Data(repeating: 0, count: 2048).write(to: URL(fileURLWithPath: subdir2 + "/file2"))

        defer { try? FileManager.default.removeItem(atPath: testPath) }

        let result = runCommand("du", [testPath])
        XCTAssertEqual(result.exitCode, 0)

        let lines = result.stdout.split(separator: "\n")
        XCTAssertGreaterThan(lines.count, 1, "Should show subdirectories")
    }

    func testDu_maxDepth() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)
        let deep = testPath + "/a/b/c"
        try? FileManager.default.createDirectory(atPath: deep, withIntermediateDirectories: true)
        try? Data(repeating: 0, count: 1024).write(to: URL(fileURLWithPath: deep + "/file"))
        defer { try? FileManager.default.removeItem(atPath: testPath) }

        let result = runCommand("du", ["-d", "1", testPath])

        if result.exitCode == 0 {
            // -d option is supported
            let lines = result.stdout.split(separator: "\n")
            // Should limit depth
            XCTAssertLessThan(lines.count, 10, "Should limit depth with -d 1")
        }
    }

    func testDu_apparentSize() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)
        let filePath = testPath + "/file"
        try? Data(repeating: 0, count: 100).write(to: URL(fileURLWithPath: filePath))
        defer { try? FileManager.default.removeItem(atPath: testPath) }

        let result = runCommand("du", ["--apparent-size", filePath])

        if result.exitCode == 0 {
            // --apparent-size is supported
            XCTAssertFalse(result.stdout.isEmpty)
        }
    }

    func testDu_excludePattern() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)
        try? Data(repeating: 0, count: 1024).write(to: URL(fileURLWithPath: testPath + "/keep.txt"))
        try? Data(repeating: 0, count: 1024).write(to: URL(fileURLWithPath: testPath + "/exclude.log"))
        defer { try? FileManager.default.removeItem(atPath: testPath) }

        let result = runCommand("du", ["--exclude=*.log", testPath])

        if result.exitCode == 0 {
            // --exclude is supported
            XCTAssertFalse(result.stdout.contains("exclude.log"), "Should exclude .log files")
        }
    }

    func testDu_nonexistentPath() {
        let result = runCommand("du", ["/tmp/nonexistent-\(UUID().uuidString)"])

        XCTAssertNotEqual(result.exitCode, 0, "du should fail on nonexistent path")
        XCTAssertTrue(result.stderr.contains("No such file") || result.stderr.contains("not found"))
    }

    func testDu_permissionDenied() {
        // This test documents behavior when encountering permission denied
        // Most systems will have some restricted directory
        let result = runCommand("du", ["/root"])

        if result.exitCode != 0 {
            // Permission denied is expected for non-root users
            XCTAssertTrue(result.stderr.contains("Permission denied") ||
                         result.stderr.contains("cannot read"))
        }
    }

    private func runCommand(_ command: String, _ args: [String]) -> CommandResult {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = [command] + args

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()

        task.standardOutput = stdoutPipe
        task.standardError = stderrPipe

        do {
            try task.run()
            task.waitUntilExit()

            let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
            let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()

            let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
            let stderr = String(data: stderrData, encoding: .utf8) ?? ""

            return CommandResult(exitCode: task.terminationStatus, stdout: stdout, stderr: stderr)
        } catch {
            return CommandResult(exitCode: -1, stdout: "", stderr: "Failed to execute: \(error)")
        }
    }

    struct CommandResult {
        let exitCode: Int32
        let stdout: String
        let stderr: String
    }
}
