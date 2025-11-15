// MkdirTests.swift
// ============================================================================
// BusyBox Test Import Metadata
// ============================================================================
// Source Type: Individual test cases (subdirectory tests)
// Source Path: busybox/testsuite/mkdir/
// Import Date: 2025-11-14
// Test Count: 2
// Pass Rate: 100% (2/2)
// ============================================================================
// Tests for mkdir command functionality

import XCTest
import Foundation

final class MkdirTests: XCTestCase {
    var swiftyboxPath: String {
        let cwd = FileManager.default.currentDirectoryPath
        return "\(cwd)/.build/debug/swiftybox"
    }

    var testDir: String {
        return FileManager.default.temporaryDirectory.appendingPathComponent("mkdir-test-\(UUID().uuidString)").path
    }

    override func tearDown() {
        super.tearDown()
        // Clean up test directories
        let tempDir = FileManager.default.temporaryDirectory.path
        let contents = try? FileManager.default.contentsOfDirectory(atPath: tempDir)
        contents?.filter { $0.hasPrefix("mkdir-test-") }.forEach {
            try? FileManager.default.removeItem(atPath: tempDir + "/" + $0)
        }
    }

    // MARK: - Test 1: mkdir makes a directory
    // Source: busybox/testsuite/mkdir/mkdir-makes-a-directory
    func testMkdir_makesDirectory() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)

        let fooPath = testPath + "/foo"

        // Ensure directory doesn't exist
        XCTAssertFalse(FileManager.default.fileExists(atPath: fooPath), "Directory should not exist before mkdir")

        // Run: mkdir foo
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["mkdir", fooPath]
        try? task.run()
        task.waitUntilExit()

        XCTAssertEqual(task.terminationStatus, 0, "mkdir should succeed")

        // Verify directory exists
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: fooPath, isDirectory: &isDirectory)
        XCTAssertTrue(exists, "Directory should exist after mkdir")
        XCTAssertTrue(isDirectory.boolValue, "Path should be a directory")

        try? FileManager.default.removeItem(atPath: testPath)
    }

    // MARK: - Test 2: mkdir -p makes parent directories
    // Source: busybox/testsuite/mkdir/mkdir-makes-parent-directories
    func testMkdir_makesParentDirectories() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)

        let fooPath = testPath + "/foo"
        let barPath = fooPath + "/bar"

        // Ensure directories don't exist
        XCTAssertFalse(FileManager.default.fileExists(atPath: fooPath), "Parent directory should not exist")
        XCTAssertFalse(FileManager.default.fileExists(atPath: barPath), "Child directory should not exist")

        // Run: mkdir -p foo/bar
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["mkdir", "-p", barPath]
        try? task.run()
        task.waitUntilExit()

        XCTAssertEqual(task.terminationStatus, 0, "mkdir -p should succeed")

        // Verify both directories exist
        var fooIsDir: ObjCBool = false
        var barIsDir: ObjCBool = false
        let fooExists = FileManager.default.fileExists(atPath: fooPath, isDirectory: &fooIsDir)
        let barExists = FileManager.default.fileExists(atPath: barPath, isDirectory: &barIsDir)

        XCTAssertTrue(fooExists, "Parent directory should exist")
        XCTAssertTrue(fooIsDir.boolValue, "foo should be a directory")
        XCTAssertTrue(barExists, "Child directory should exist")
        XCTAssertTrue(barIsDir.boolValue, "bar should be a directory")

        try? FileManager.default.removeItem(atPath: testPath)
    }
}
