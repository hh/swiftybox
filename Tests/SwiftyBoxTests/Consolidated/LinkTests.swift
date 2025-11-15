// LinkTests.swift
// Comprehensive tests for the link command

import XCTest
@testable import SwiftyBox

/// Tests for the `link` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: GNU coreutils link
/// - POSIX: link() system call - create hard link
/// - BusyBox: Simple wrapper around link() syscall
/// - GNU: link FILE1 FILE2 (no options)
/// - Common usage: link existing_file new_link
/// - Target scope: P0 (basic hard link creation)
///
/// Key behaviors to test:
/// - Creates hard link to existing file
/// - Requires exactly 2 arguments
/// - Both files point to same inode
/// - Cannot link directories (POSIX restriction)
/// - Cannot cross filesystem boundaries
/// - Exit code 0 on success, non-zero on error
///
/// Resources:
/// - GNU: https://www.gnu.org/software/coreutils/manual/html_node/link-invocation.html
/// - POSIX: link(2) system call
/// - Man page: link(1)

final class LinkTests: XCTestCase {

    // MARK: - Basic Functionality

    func testBasicHardLink() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }

        let sourceFile = tempDir.appendingPathComponent("source")
        let linkFile = tempDir.appendingPathComponent("link")

        // Create source file
        let testData = "test data\n".data(using: .utf8)!
        try? testData.write(to: sourceFile)

        // Create hard link
        let result = runCommand("link", [sourceFile.path, linkFile.path])

        XCTAssertEqual(result.exitCode, 0, "link should succeed")
        XCTAssertEqual(result.stdout, "", "link should produce no output")
        XCTAssertEqual(result.stderr, "", "link should produce no stderr")

        // Verify link exists
        XCTAssertTrue(FileManager.default.fileExists(atPath: linkFile.path),
                     "Link file should exist")

        // Verify content matches
        let linkData = try? Data(contentsOf: linkFile)
        XCTAssertEqual(linkData, testData, "Link should have same content")
    }

    func testHardLinkSharesInode() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }

        let sourceFile = tempDir.appendingPathComponent("source")
        let linkFile = tempDir.appendingPathComponent("link")

        try? "test".write(to: sourceFile, atomically: true, encoding: .utf8)

        _ = runCommand("link", [sourceFile.path, linkFile.path])

        // Get inodes (requires stat command or system call)
        #if os(Linux) || os(macOS)
        var sourceStat = stat()
        var linkStat = stat()

        stat(sourceFile.path, &sourceStat)
        stat(linkFile.path, &linkStat)

        XCTAssertEqual(sourceStat.st_ino, linkStat.st_ino,
                      "Hard links should share the same inode")
        #endif
    }

    func testModifyingOneAffectsBoth() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }

        let sourceFile = tempDir.appendingPathComponent("source")
        let linkFile = tempDir.appendingPathComponent("link")

        try? "original".write(to: sourceFile, atomically: true, encoding: .utf8)
        _ = runCommand("link", [sourceFile.path, linkFile.path])

        // Modify through link
        try? "modified".write(to: linkFile, atomically: true, encoding: .utf8)

        // Read from original
        let sourceContent = try? String(contentsOf: sourceFile, encoding: .utf8)
        XCTAssertEqual(sourceContent, "modified",
                      "Modifying one hard link should affect the other")
    }

    // MARK: - Error Handling

    func testLinkNonexistentFile() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }

        let nonexistent = tempDir.appendingPathComponent("nonexistent")
        let linkFile = tempDir.appendingPathComponent("link")

        let result = runCommand("link", [nonexistent.path, linkFile.path])

        XCTAssertNotEqual(result.exitCode, 0, "link should fail for nonexistent source")
        XCTAssertFalse(result.stderr.isEmpty, "link should output error message")
    }

    func testLinkToExistingFile() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }

        let sourceFile = tempDir.appendingPathComponent("source")
        let existingFile = tempDir.appendingPathComponent("existing")

        try? "source".write(to: sourceFile, atomically: true, encoding: .utf8)
        try? "existing".write(to: existingFile, atomically: true, encoding: .utf8)

        let result = runCommand("link", [sourceFile.path, existingFile.path])

        XCTAssertNotEqual(result.exitCode, 0, "link should fail if target exists")
        XCTAssertFalse(result.stderr.isEmpty, "link should output error message")
    }

    func testLinkWithOneArgument() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }

        let sourceFile = tempDir.appendingPathComponent("source")
        try? "test".write(to: sourceFile, atomically: true, encoding: .utf8)

        let result = runCommand("link", [sourceFile.path])

        XCTAssertNotEqual(result.exitCode, 0, "link should fail with only one argument")
        XCTAssertFalse(result.stderr.isEmpty, "link should output error message")
    }

    func testLinkWithNoArguments() {
        let result = runCommand("link", [])

        XCTAssertNotEqual(result.exitCode, 0, "link should fail with no arguments")
        XCTAssertFalse(result.stderr.isEmpty, "link should output error message")
    }

    func testLinkWithTooManyArguments() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }

        let file1 = tempDir.appendingPathComponent("file1")
        let file2 = tempDir.appendingPathComponent("file2")
        let file3 = tempDir.appendingPathComponent("file3")

        try? "test".write(to: file1, atomically: true, encoding: .utf8)

        let result = runCommand("link", [file1.path, file2.path, file3.path])

        XCTAssertNotEqual(result.exitCode, 0, "link should fail with too many arguments")
        XCTAssertFalse(result.stderr.isEmpty, "link should output error message")
    }

    // MARK: - Edge Cases

    func testLinkToSymlink() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }

        let targetFile = tempDir.appendingPathComponent("target")
        let symlinkFile = tempDir.appendingPathComponent("symlink")
        let hardlinkFile = tempDir.appendingPathComponent("hardlink")

        try? "test".write(to: targetFile, atomically: true, encoding: .utf8)
        try? FileManager.default.createSymbolicLink(atPath: symlinkFile.path,
                                                    withDestinationPath: targetFile.path)

        let result = runCommand("link", [symlinkFile.path, hardlinkFile.path])

        // link to a symlink should create hard link to the target
        // (follows symlink behavior)
        if result.exitCode == 0 {
            XCTAssertTrue(FileManager.default.fileExists(atPath: hardlinkFile.path),
                         "Hard link should be created")
        }
    }

    func testCannotLinkDirectory() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        let sourceDir = tempDir.appendingPathComponent("sourcedir")
        let linkDir = tempDir.appendingPathComponent("linkdir")

        try? FileManager.default.createDirectory(at: sourceDir, withIntermediateDirectories: true)

        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }

        let result = runCommand("link", [sourceDir.path, linkDir.path])

        XCTAssertNotEqual(result.exitCode, 0,
                         "link should fail when trying to link directory")
        XCTAssertFalse(result.stderr.isEmpty, "link should output error message")
    }

    // MARK: - Link Count

    func testLinkIncreasesLinkCount() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }

        let sourceFile = tempDir.appendingPathComponent("source")
        let linkFile = tempDir.appendingPathComponent("link")

        try? "test".write(to: sourceFile, atomically: true, encoding: .utf8)

        #if os(Linux) || os(macOS)
        var statBefore = stat()
        stat(sourceFile.path, &statBefore)
        let linksBefore = statBefore.st_nlink

        _ = runCommand("link", [sourceFile.path, linkFile.path])

        var statAfter = stat()
        stat(sourceFile.path, &statAfter)
        let linksAfter = statAfter.st_nlink

        XCTAssertEqual(linksAfter, linksBefore + 1,
                      "Hard link should increase link count by 1")
        #endif
    }
}
