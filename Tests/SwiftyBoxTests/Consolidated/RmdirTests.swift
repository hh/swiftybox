// RmdirTests.swift
// ============================================================================
// BusyBox Test Import Metadata
// ============================================================================
// Source Type: Individual test cases (subdirectory tests)
// Source Path: busybox/testsuite/rmdir/
// Import Date: 2025-11-14
// Test Count: 1
// Pass Rate: 0% (0/1)
// ============================================================================
// Tests for rmdir command functionality

import XCTest
import Foundation

final class RmdirTests: XCTestCase {
    var swiftyboxPath: String {
        let cwd = FileManager.default.currentDirectoryPath
        return "\(cwd)/.build/debug/swiftybox"
    }

    var testDir: String {
        return FileManager.default.temporaryDirectory.appendingPathComponent("rmdir-test-\(UUID().uuidString)").path
    }

    override func tearDown() {
        super.tearDown()
        // Clean up test directories
        let tempDir = FileManager.default.temporaryDirectory.path
        let contents = try? FileManager.default.contentsOfDirectory(atPath: tempDir)
        contents?.filter { $0.hasPrefix("rmdir-test-") }.forEach {
            try? FileManager.default.removeItem(atPath: tempDir + "/" + $0)
        }
    }

    // MARK: - Test 1: rmdir -p removes parent directories
    // Source: busybox/testsuite/rmdir/rmdir-removes-parent-directories
    func testRmdir_removesParentDirectories() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)

        let fooPath = testPath + "/foo"
        let barPath = fooPath + "/bar"

        // Create parent and child directories
        try? FileManager.default.createDirectory(atPath: barPath, withIntermediateDirectories: true)

        // Verify directories exist
        XCTAssertTrue(FileManager.default.fileExists(atPath: fooPath), "Parent directory should exist")
        XCTAssertTrue(FileManager.default.fileExists(atPath: barPath), "Child directory should exist")

        // Run: rmdir -p foo/bar
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["rmdir", "-p", barPath]
        task.currentDirectoryURL = URL(fileURLWithPath: testPath)
        try? task.run()
        task.waitUntilExit()

        XCTAssertEqual(task.terminationStatus, 0, "rmdir -p should succeed")

        // Verify both directories are removed
        XCTAssertFalse(FileManager.default.fileExists(atPath: barPath), "Child directory should be removed")
        XCTAssertFalse(FileManager.default.fileExists(atPath: fooPath), "Parent directory should be removed")

        try? FileManager.default.removeItem(atPath: testPath)
    }
}
