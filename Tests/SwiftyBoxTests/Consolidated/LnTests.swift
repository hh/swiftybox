// LnTests.swift
// ============================================================================
// BusyBox Test Import Metadata
// ============================================================================
// Source Type: Individual test cases (subdirectory tests)
// Source Path: busybox/testsuite/ln/
// Import Date: 2025-11-14
// Test Count: 6
// Pass Rate: 100% (6/6)
// ============================================================================
// Tests for ln (link) command functionality

import XCTest
import Foundation

final class LnTests: XCTestCase {
    var swiftyboxPath: String {
        let cwd = FileManager.default.currentDirectoryPath
        return "\(cwd)/.build/debug/swiftybox"
    }

    var testDir: String {
        return FileManager.default.temporaryDirectory.appendingPathComponent("ln-test-\(UUID().uuidString)").path
    }

    override func tearDown() {
        super.tearDown()
        // Clean up test directories
        let tempDir = FileManager.default.temporaryDirectory.path
        let contents = try? FileManager.default.contentsOfDirectory(atPath: tempDir)
        contents?.filter { $0.hasPrefix("ln-test-") }.forEach {
            try? FileManager.default.removeItem(atPath: tempDir + "/" + $0)
        }
    }

    // MARK: - Test 1: ln creates hard links
    // Source: busybox/testsuite/ln/ln-creates-hard-links
    func testLn_createsHardLinks() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)

        let file1 = testPath + "/file1"
        let link1 = testPath + "/link1"

        // Create source file
        try? "file number one\n".write(toFile: file1, atomically: true, encoding: .utf8)

        // Create hard link
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["ln", file1, link1]
        task.currentDirectoryURL = URL(fileURLWithPath: testPath)
        try? task.run()
        task.waitUntilExit()

        XCTAssertEqual(task.terminationStatus, 0, "ln should succeed")

        // Verify both files exist
        XCTAssertTrue(FileManager.default.fileExists(atPath: file1), "file1 should exist")
        XCTAssertTrue(FileManager.default.fileExists(atPath: link1), "link1 should exist")

        // Verify link1 is NOT a symlink (it's a hard link)
        var isSymlink: ObjCBool = false
        FileManager.default.fileExists(atPath: link1, isDirectory: &isSymlink)
        XCTAssertFalse(isSymlink.boolValue, "link1 should not be a symlink")

        // Verify content is the same
        let content1 = try? String(contentsOfFile: file1)
        let content2 = try? String(contentsOfFile: link1)
        XCTAssertEqual(content1, content2, "Hard link should have same content")

        try? FileManager.default.removeItem(atPath: testPath)
    }

    // MARK: - Test 2: ln -s creates soft links (symlinks)
    // Source: busybox/testsuite/ln/ln-creates-soft-links
    func testLn_createsSoftLinks() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)

        let file1 = testPath + "/file1"
        let link1 = testPath + "/link1"

        // Create source file
        try? "file number one\n".write(toFile: file1, atomically: true, encoding: .utf8)

        // Create soft link
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["ln", "-s", file1, link1]
        task.currentDirectoryURL = URL(fileURLWithPath: testPath)
        try? task.run()
        task.waitUntilExit()

        XCTAssertEqual(task.terminationStatus, 0, "ln -s should succeed")

        // Verify link1 is a symlink
        let attrs = try? FileManager.default.attributesOfItem(atPath: link1)
        let fileType = attrs?[.type] as? FileAttributeType
        XCTAssertEqual(fileType, .typeSymbolicLink, "link1 should be a symbolic link")

        // Verify symlink points to file1
        let destination = try? FileManager.default.destinationOfSymbolicLink(atPath: link1)
        XCTAssertEqual(destination, file1, "Symlink should point to file1")

        try? FileManager.default.removeItem(atPath: testPath)
    }

    // MARK: - Test 3: ln -f creates hard links (force)
    // Source: busybox/testsuite/ln/ln-force-creates-hard-links
    func testLn_forceCreatesHardLinks() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)

        let file1 = testPath + "/file1"
        let link1 = testPath + "/link1"

        // Create source and destination files
        try? "file number one\n".write(toFile: file1, atomically: true, encoding: .utf8)
        try? "file number two\n".write(toFile: link1, atomically: true, encoding: .utf8)

        // Force create hard link (should overwrite link1)
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["ln", "-f", file1, link1]
        task.currentDirectoryURL = URL(fileURLWithPath: testPath)
        try? task.run()
        task.waitUntilExit()

        XCTAssertEqual(task.terminationStatus, 0, "ln -f should succeed")

        // Verify both files exist
        XCTAssertTrue(FileManager.default.fileExists(atPath: file1), "file1 should exist")
        XCTAssertTrue(FileManager.default.fileExists(atPath: link1), "link1 should exist")

        // Verify content matches file1 (not the original link1)
        let content = try? String(contentsOfFile: link1)
        XCTAssertEqual(content, "file number one\n", "link1 should have file1's content after force link")

        try? FileManager.default.removeItem(atPath: testPath)
    }

    // MARK: - Test 4: ln -f -s creates soft links (force)
    // Source: busybox/testsuite/ln/ln-force-creates-soft-links
    func testLn_forceCreatesSoftLinks() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)

        let file1 = testPath + "/file1"
        let link1 = testPath + "/link1"

        // Create source and destination files
        try? "file number one\n".write(toFile: file1, atomically: true, encoding: .utf8)
        try? "file number two\n".write(toFile: link1, atomically: true, encoding: .utf8)

        // Force create soft link (should overwrite link1)
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["ln", "-f", "-s", file1, link1]
        task.currentDirectoryURL = URL(fileURLWithPath: testPath)
        try? task.run()
        task.waitUntilExit()

        XCTAssertEqual(task.terminationStatus, 0, "ln -f -s should succeed")

        // Verify link1 is a symlink
        let attrs = try? FileManager.default.attributesOfItem(atPath: link1)
        let fileType = attrs?[.type] as? FileAttributeType
        XCTAssertEqual(fileType, .typeSymbolicLink, "link1 should be a symbolic link")

        // Verify symlink points to file1
        let destination = try? FileManager.default.destinationOfSymbolicLink(atPath: link1)
        XCTAssertEqual(destination, file1, "Symlink should point to file1")

        try? FileManager.default.removeItem(atPath: testPath)
    }

    // MARK: - Test 5: ln fails without force when file exists (hard link)
    // Source: busybox/testsuite/ln/ln-preserves-hard-links
    func testLn_preservesHardLinks() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)

        let file1 = testPath + "/file1"
        let link1 = testPath + "/link1"

        // Create source and destination files
        try? "file number one\n".write(toFile: file1, atomically: true, encoding: .utf8)
        try? "file number two\n".write(toFile: link1, atomically: true, encoding: .utf8)

        // Try to create hard link without force (should fail)
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["ln", file1, link1]
        task.currentDirectoryURL = URL(fileURLWithPath: testPath)
        task.standardError = Pipe()
        try? task.run()
        task.waitUntilExit()

        XCTAssertNotEqual(task.terminationStatus, 0, "ln should fail when link1 already exists")

        // Verify link1 still has original content
        let content = try? String(contentsOfFile: link1)
        XCTAssertEqual(content, "file number two\n", "link1 should preserve original content")

        try? FileManager.default.removeItem(atPath: testPath)
    }

    // MARK: - Test 6: ln -s fails without force when file exists (soft link)
    // Source: busybox/testsuite/ln/ln-preserves-soft-links
    func testLn_preservesSoftLinks() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)

        let file1 = testPath + "/file1"
        let link1 = testPath + "/link1"

        // Create source and destination files
        try? "file number one\n".write(toFile: file1, atomically: true, encoding: .utf8)
        try? "file number two\n".write(toFile: link1, atomically: true, encoding: .utf8)

        // Try to create soft link without force (should fail)
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["ln", "-s", file1, link1]
        task.currentDirectoryURL = URL(fileURLWithPath: testPath)
        task.standardError = Pipe()
        try? task.run()
        task.waitUntilExit()

        XCTAssertNotEqual(task.terminationStatus, 0, "ln -s should fail when link1 already exists")

        // Verify link1 still has original content (not a symlink)
        let content = try? String(contentsOfFile: link1)
        XCTAssertEqual(content, "file number two\n", "link1 should preserve original content")

        try? FileManager.default.removeItem(atPath: testPath)
    }
}
