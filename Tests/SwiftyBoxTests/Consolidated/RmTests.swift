// RmTests.swift
// ============================================================================
// BusyBox Test Import Metadata
// ============================================================================
// Source Type: Individual test cases (subdirectory tests)
// Source Path: busybox/testsuite/rm/
// Import Date: 2025-11-14
// Test Count: 1
// Pass Rate: 100% (1/1)
// ============================================================================
// Tests for rm (remove) command functionality

import XCTest
import Foundation

final class RmTests: XCTestCase {
    var swiftyboxPath: String {
        let cwd = FileManager.default.currentDirectoryPath
        return "\(cwd)/.build/debug/swiftybox"
    }

    var testDir: String {
        return FileManager.default.temporaryDirectory.appendingPathComponent("rm-test-\(UUID().uuidString)").path
    }

    override func tearDown() {
        super.tearDown()
        // Clean up test directories
        let tempDir = FileManager.default.temporaryDirectory.path
        let contents = try? FileManager.default.contentsOfDirectory(atPath: tempDir)
        contents?.filter { $0.hasPrefix("rm-test-") }.forEach {
            try? FileManager.default.removeItem(atPath: tempDir + "/" + $0)
        }
    }

    // MARK: - Test 1: rm removes file
    // Source: busybox/testsuite/rm/rm-removes-file
    func testRm_removesFile() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)

        let fooPath = testPath + "/foo"

        // Create test file using system touch
        let touchTask = Process()
        touchTask.executableURL = URL(fileURLWithPath: "/usr/bin/touch")
        touchTask.arguments = [fooPath]
        try? touchTask.run()
        touchTask.waitUntilExit()

        // Verify file exists
        XCTAssertTrue(FileManager.default.fileExists(atPath: fooPath), "File should exist before rm")

        // Run: rm foo
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["rm", fooPath]
        try? task.run()
        task.waitUntilExit()

        XCTAssertEqual(task.terminationStatus, 0, "rm should succeed")
        XCTAssertFalse(FileManager.default.fileExists(atPath: fooPath), "File should not exist after rm")

        try? FileManager.default.removeItem(atPath: testPath)
    }
}
