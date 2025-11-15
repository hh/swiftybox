// UnlinkTests.swift
// Comprehensive tests for the unlink command

import XCTest
@testable import SwiftyBox

/// Tests for the `unlink` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: GNU coreutils unlink
/// - POSIX: unlink() system call - remove file
/// - BusyBox: Simple wrapper around unlink() syscall
/// - GNU: unlink FILE (exactly one argument, no options)
/// - Common usage: unlink filename (removes file)
/// - Target scope: P0 (basic file removal)
///
/// Key behaviors to test:
/// - Removes file (not directory)
/// - Requires exactly 1 argument
/// - Cannot remove directories (use rmdir)
/// - Exit code 0 on success
/// - Decrements link count
/// - File deleted when link count reaches 0
///
/// Resources:
/// - GNU: https://www.gnu.org/software/coreutils/manual/html_node/unlink-invocation.html
/// - POSIX: unlink(2) system call
/// - Man page: unlink(1)

final class UnlinkTests: XCTestCase {

    // MARK: - Basic Functionality

    func testBasicUnlink() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }

        let testFile = tempDir.appendingPathComponent("testfile")
        try? "test data\n".write(to: testFile, atomically: true, encoding: .utf8)

        XCTAssertTrue(FileManager.default.fileExists(atPath: testFile.path),
                     "Test file should exist before unlink")

        let result = runCommand("unlink", [testFile.path])

        XCTAssertEqual(result.exitCode, 0, "unlink should succeed")
        XCTAssertEqual(result.stdout, "", "unlink should produce no output")
        XCTAssertEqual(result.stderr, "", "unlink should produce no stderr")

        XCTAssertFalse(FileManager.default.fileExists(atPath: testFile.path),
                      "File should not exist after unlink")
    }

    func testUnlinkRemovesFile() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }

        let testFile = tempDir.appendingPathComponent("removeme")
        try? "content".write(to: testFile, atomically: true, encoding: .utf8)

        _ = runCommand("unlink", [testFile.path])

        // Verify file is gone
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: testFile.path,
                                                     isDirectory: &isDirectory)

        XCTAssertFalse(exists, "File should be removed after unlink")
    }

    func testUnlinkNoOutput() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }

        let testFile = tempDir.appendingPathComponent("silent")
        try? "test".write(to: testFile, atomically: true, encoding: .utf8)

        let result = runCommand("unlink", [testFile.path])

        XCTAssertTrue(result.stdout.isEmpty, "unlink should not output to stdout")
        XCTAssertTrue(result.stderr.isEmpty, "unlink should not output to stderr on success")
    }

    // MARK: - Error Handling

    func testUnlinkNonexistentFile() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }

        let nonexistent = tempDir.appendingPathComponent("nonexistent")

        let result = runCommand("unlink", [nonexistent.path])

        XCTAssertNotEqual(result.exitCode, 0, "unlink should fail for nonexistent file")
        XCTAssertFalse(result.stderr.isEmpty, "unlink should output error message")
    }

    func testCannotUnlinkDirectory() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        let subDir = tempDir.appendingPathComponent("subdir")
        try? FileManager.default.createDirectory(at: subDir, withIntermediateDirectories: true)

        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }

        let result = runCommand("unlink", [subDir.path])

        XCTAssertNotEqual(result.exitCode, 0, "unlink should fail for directory")
        XCTAssertFalse(result.stderr.isEmpty, "unlink should output error message")
        XCTAssertTrue(FileManager.default.fileExists(atPath: subDir.path),
                     "Directory should still exist after failed unlink")
    }

    func testUnlinkWithNoArguments() {
        let result = runCommand("unlink", [])

        XCTAssertNotEqual(result.exitCode, 0, "unlink should fail with no arguments")
        XCTAssertFalse(result.stderr.isEmpty, "unlink should output error message")
    }

    func testUnlinkWithMultipleArguments() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }

        let file1 = tempDir.appendingPathComponent("file1")
        let file2 = tempDir.appendingPathComponent("file2")

        try? "test".write(to: file1, atomically: true, encoding: .utf8)
        try? "test".write(to: file2, atomically: true, encoding: .utf8)

        let result = runCommand("unlink", [file1.path, file2.path])

        XCTAssertNotEqual(result.exitCode, 0, "unlink should fail with multiple arguments")
        XCTAssertFalse(result.stderr.isEmpty, "unlink should output error message")
    }

    // MARK: - Hard Links

    func testUnlinkDecreasesLinkCount() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }

        let originalFile = tempDir.appendingPathComponent("original")
        let hardLink = tempDir.appendingPathComponent("hardlink")

        try? "test content".write(to: originalFile, atomically: true, encoding: .utf8)

        // Create hard link using system link()
        #if os(Linux) || os(macOS)
        link(originalFile.path, hardLink.path)

        var statBefore = stat()
        stat(originalFile.path, &statBefore)
        let linksBefore = statBefore.st_nlink

        // Unlink one of them
        let result = runCommand("unlink", [hardLink.path])
        XCTAssertEqual(result.exitCode, 0, "unlink should succeed")

        var statAfter = stat()
        stat(originalFile.path, &statAfter)
        let linksAfter = statAfter.st_nlink

        XCTAssertEqual(linksAfter, linksBefore - 1,
                      "unlink should decrease link count by 1")
        XCTAssertTrue(FileManager.default.fileExists(atPath: originalFile.path),
                     "Original file should still exist")
        #endif
    }

    func testUnlinkLastLinkDeletesFile() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }

        let singleFile = tempDir.appendingPathComponent("single")
        try? "test".write(to: singleFile, atomically: true, encoding: .utf8)

        let result = runCommand("unlink", [singleFile.path])

        XCTAssertEqual(result.exitCode, 0, "unlink should succeed")
        XCTAssertFalse(FileManager.default.fileExists(atPath: singleFile.path),
                      "File should be deleted when last link is removed")
    }

    // MARK: - Symlinks

    func testUnlinkSymlink() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }

        let targetFile = tempDir.appendingPathComponent("target")
        let symlinkFile = tempDir.appendingPathComponent("symlink")

        try? "target content".write(to: targetFile, atomically: true, encoding: .utf8)
        try? FileManager.default.createSymbolicLink(atPath: symlinkFile.path,
                                                    withDestinationPath: targetFile.path)

        let result = runCommand("unlink", [symlinkFile.path])

        XCTAssertEqual(result.exitCode, 0, "unlink should remove symlink")
        XCTAssertFalse(FileManager.default.fileExists(atPath: symlinkFile.path),
                      "Symlink should be removed")
        XCTAssertTrue(FileManager.default.fileExists(atPath: targetFile.path),
                     "Target file should still exist")
    }

    // MARK: - Permissions

    func testUnlinkReadOnlyFile() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }

        let readOnlyFile = tempDir.appendingPathComponent("readonly")
        try? "readonly content".write(to: readOnlyFile, atomically: true, encoding: .utf8)

        // Make file read-only
        try? FileManager.default.setAttributes([.posixPermissions: 0o444],
                                               ofItemAtPath: readOnlyFile.path)

        let result = runCommand("unlink", [readOnlyFile.path])

        // unlink should succeed even for read-only files (if directory is writable)
        XCTAssertEqual(result.exitCode, 0,
                      "unlink should succeed for read-only file in writable directory")
        XCTAssertFalse(FileManager.default.fileExists(atPath: readOnlyFile.path),
                      "Read-only file should be removed")
    }

    // MARK: - Edge Cases

    func testUnlinkEmptyFilename() {
        let result = runCommand("unlink", [""])

        XCTAssertNotEqual(result.exitCode, 0, "unlink should fail for empty filename")
        XCTAssertFalse(result.stderr.isEmpty, "unlink should output error message")
    }

    func testUnlinkRelativePath() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }

        let testFile = tempDir.appendingPathComponent("relative")
        try? "test".write(to: testFile, atomically: true, encoding: .utf8)

        // This test depends on current directory, so we just verify it handles relative paths
        let result = runCommand("unlink", ["./nonexistent"])
        // Should fail (file doesn't exist) but should handle relative path
        XCTAssertNotEqual(result.exitCode, 0, "Should fail for nonexistent relative path")
    }
}
