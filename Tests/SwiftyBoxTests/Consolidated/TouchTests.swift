// TouchTests.swift
// ============================================================================
// BusyBox Test Import Metadata
// ============================================================================
// Source Type: Individual test cases (subdirectory tests)
// Source Path: busybox/testsuite/touch/
// Import Date: 2025-11-14
// Test Count: 3
// Pass Rate: 33.3% (1/3)
// ============================================================================
// Tests for touch command functionality

import XCTest
import Foundation

final class TouchTests: XCTestCase {
    var swiftyboxPath: String {
        let cwd = FileManager.default.currentDirectoryPath
        return "\(cwd)/.build/debug/swiftybox"
    }

    var testDir: String {
        return FileManager.default.temporaryDirectory.appendingPathComponent("touch-test-\(UUID().uuidString)").path
    }

    override func tearDown() {
        super.tearDown()
        // Clean up test directories
        let tempDir = FileManager.default.temporaryDirectory.path
        let contents = try? FileManager.default.contentsOfDirectory(atPath: tempDir)
        contents?.filter { $0.hasPrefix("touch-test-") }.forEach {
            try? FileManager.default.removeItem(atPath: tempDir + "/" + $0)
        }
    }

    // MARK: - Test 1: touch creates file
    // Source: busybox/testsuite/touch/touch-creates-file
    func testTouch_createsFile() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)

        let filePath = testPath + "/foo"

        // Ensure file doesn't exist
        XCTAssertFalse(FileManager.default.fileExists(atPath: filePath), "File should not exist before touch")

        // Run touch
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["touch", filePath]
        try? task.run()
        task.waitUntilExit()

        XCTAssertEqual(task.terminationStatus, 0, "touch should succeed")
        XCTAssertTrue(FileManager.default.fileExists(atPath: filePath), "File should exist after touch")

        try? FileManager.default.removeItem(atPath: testPath)
    }

    // MARK: - Test 2: touch -c does not create file
    // Source: busybox/testsuite/touch/touch-does-not-create-file
    func testTouch_doesNotCreateFileWithC() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)

        let filePath = testPath + "/foo"

        // Ensure file doesn't exist
        XCTAssertFalse(FileManager.default.fileExists(atPath: filePath), "File should not exist before touch -c")

        // Run touch -c (no-create flag)
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["touch", "-c", filePath]
        try? task.run()
        task.waitUntilExit()

        XCTAssertEqual(task.terminationStatus, 0, "touch -c should succeed")
        XCTAssertFalse(FileManager.default.fileExists(atPath: filePath), "File should NOT exist after touch -c")

        try? FileManager.default.removeItem(atPath: testPath)
    }

    // MARK: - Test 3: touch continues after non-existent file
    // Source: busybox/testsuite/touch/touch-touches-files-after-non-existent-file
    func testTouch_touchesFilesAfterNonExistent() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)

        let barPath = testPath + "/bar"
        let fooPath = testPath + "/foo"

        // Create bar file with old timestamp (Jan 1, 1980)
        try? "test".write(toFile: barPath, atomically: true, encoding: .utf8)

        // Set old modification time on bar
        let oldDate = Date(timeIntervalSince1970: 315532800) // Jan 1, 1980
        try? FileManager.default.setAttributes([.modificationDate: oldDate], ofItemAtPath: barPath)

        // Run touch -c on non-existent foo and existing bar
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["touch", "-c", fooPath, barPath]
        try? task.run()
        task.waitUntilExit()

        XCTAssertEqual(task.terminationStatus, 0, "touch -c should succeed")

        // foo should not exist (because of -c flag)
        XCTAssertFalse(FileManager.default.fileExists(atPath: fooPath), "foo should not be created with -c")

        // bar should have been touched (modification time updated)
        let attrs = try? FileManager.default.attributesOfItem(atPath: barPath)
        if let modDate = attrs?[.modificationDate] as? Date {
            // Check if modification date is recent (within last day)
            let dayAgo = Date().addingTimeInterval(-86400)
            XCTAssertTrue(modDate > dayAgo, "bar should have recent modification time")
        } else {
            XCTFail("Could not read bar modification time")
        }

        try? FileManager.default.removeItem(atPath: testPath)
    }
}
