// MvTests.swift
// ============================================================================
// BusyBox Test Import Metadata
// ============================================================================
// Source Type: Individual test cases (subdirectory tests)
// Source Path: busybox/testsuite/mv/
// Import Date: 2025-11-14
// Test Count: 14
// Pass Rate: 78.6% (11/14)
// ============================================================================
// Tests for mv command edge cases and scenarios

import XCTest
import Foundation

final class MvTests: XCTestCase {
    var swiftyboxPath: String {
        let cwd = FileManager.default.currentDirectoryPath
        return "\(cwd)/.build/debug/swiftybox"
    }

    // MARK: - Test 1: files-to-dir
    // Source: busybox/testsuite/mv/mv-files-to-dir
    func testMv_multipleFilesToDir() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-mv-multi-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Create test files
        try? "file number one\n".write(toFile: tempDir.appendingPathComponent("file1").path, atomically: true, encoding: .utf8)
        try? "file number two\n".write(toFile: tempDir.appendingPathComponent("file2").path, atomically: true, encoding: .utf8)

        // Create symlink
        try? FileManager.default.createSymbolicLink(
            atPath: tempDir.appendingPathComponent("link1").path,
            withDestinationPath: "file2"
        )

        // Create directory with file
        try? FileManager.default.createDirectory(at: tempDir.appendingPathComponent("dir1"), withIntermediateDirectories: true)
        try? "".write(toFile: tempDir.appendingPathComponent("dir1/file3").path, atomically: true, encoding: .utf8)

        // Create destination
        try? FileManager.default.createDirectory(at: tempDir.appendingPathComponent("there"), withIntermediateDirectories: true)

        // Run mv
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["mv", "file1", "file2", "link1", "dir1", "there"]
        task.currentDirectoryURL = tempDir
        try? task.run()
        task.waitUntilExit()

        // Verify
        XCTAssertEqual(task.terminationStatus, 0, "mv should succeed")
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("there/file1").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("there/file2").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("there/dir1/file3").path))

        // Check symlink is preserved
        let linkPath = tempDir.appendingPathComponent("there/link1").path
        if let linkDest = try? FileManager.default.destinationOfSymbolicLink(atPath: linkPath) {
            XCTAssertEqual(linkDest, "file2", "Symlink should be preserved")
        } else {
            XCTFail("link1 should be a symlink")
        }

        // Verify sources are removed
        XCTAssertFalse(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("file1").path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("file2").path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("link1").path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("dir1/file3").path))
    }

    // MARK: - Test 2: files-to-dir-2
    // Source: busybox/testsuite/mv/mv-files-to-dir-2
    func testMv_filesWithTargetDirOption() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-mv-t-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Create test files
        try? "file number one\n".write(toFile: tempDir.appendingPathComponent("file1").path, atomically: true, encoding: .utf8)
        try? "file number two\n".write(toFile: tempDir.appendingPathComponent("file2").path, atomically: true, encoding: .utf8)

        // Create symlink
        try? FileManager.default.createSymbolicLink(
            atPath: tempDir.appendingPathComponent("link1").path,
            withDestinationPath: "file2"
        )

        // Create directory
        try? FileManager.default.createDirectory(at: tempDir.appendingPathComponent("dir1"), withIntermediateDirectories: true)
        try? "".write(toFile: tempDir.appendingPathComponent("dir1/file3").path, atomically: true, encoding: .utf8)

        // Create destination
        try? FileManager.default.createDirectory(at: tempDir.appendingPathComponent("there"), withIntermediateDirectories: true)

        // Run mv -t
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["mv", "-t", "there", "file1", "file2", "link1", "dir1"]
        task.currentDirectoryURL = tempDir
        try? task.run()
        task.waitUntilExit()

        // Verify
        XCTAssertEqual(task.terminationStatus, 0, "mv -t should succeed")
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("there/file1").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("there/file2").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("there/dir1/file3").path))

        // Verify sources removed
        XCTAssertFalse(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("file1").path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("file2").path))
    }

    // MARK: - Test 3: follows-links
    // Source: busybox/testsuite/mv/mv-follows-links
    func testMv_followsSymlinks() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-mv-follow-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Create file and symlink
        try? "".write(toFile: tempDir.appendingPathComponent("foo").path, atomically: true, encoding: .utf8)
        try? FileManager.default.createSymbolicLink(
            atPath: tempDir.appendingPathComponent("bar").path,
            withDestinationPath: "foo"
        )

        // Run mv
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["mv", "bar", "baz"]
        task.currentDirectoryURL = tempDir
        try? task.run()
        task.waitUntilExit()

        // Verify
        XCTAssertEqual(task.terminationStatus, 0, "mv should succeed")
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("baz").path))
    }

    // MARK: - Test 4: moves-empty-file
    // Source: busybox/testsuite/mv/mv-moves-empty-file
    func testMv_movesEmptyFile() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-mv-empty-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Create empty file
        try? "".write(toFile: tempDir.appendingPathComponent("foo").path, atomically: true, encoding: .utf8)

        // Run mv
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["mv", "foo", "bar"]
        task.currentDirectoryURL = tempDir
        try? task.run()
        task.waitUntilExit()

        // Verify
        XCTAssertEqual(task.terminationStatus, 0, "mv should succeed")
        XCTAssertFalse(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("foo").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("bar").path))
    }

    // MARK: - Test 5: moves-file
    // Source: busybox/testsuite/mv/mv-moves-file
    func testMv_movesFile() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-mv-file-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Create file
        try? "".write(toFile: tempDir.appendingPathComponent("foo").path, atomically: true, encoding: .utf8)

        // Run mv
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["mv", "foo", "bar"]
        task.currentDirectoryURL = tempDir
        try? task.run()
        task.waitUntilExit()

        // Verify
        XCTAssertEqual(task.terminationStatus, 0, "mv should succeed")
        XCTAssertFalse(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("foo").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("bar").path))
    }

    // MARK: - Test 6: moves-hardlinks
    // Source: busybox/testsuite/mv/mv-moves-hardlinks
    func testMv_movesHardlinks() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-mv-hardlink-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Create file and hard link
        try? "".write(toFile: tempDir.appendingPathComponent("foo").path, atomically: true, encoding: .utf8)
        try? FileManager.default.linkItem(
            atPath: tempDir.appendingPathComponent("foo").path,
            toPath: tempDir.appendingPathComponent("bar").path
        )

        // Run mv
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["mv", "bar", "baz"]
        task.currentDirectoryURL = tempDir
        try? task.run()
        task.waitUntilExit()

        // Verify
        XCTAssertEqual(task.terminationStatus, 0, "mv should succeed")
        XCTAssertFalse(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("bar").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("baz").path))
    }

    // MARK: - Test 7: moves-large-file
    // Source: busybox/testsuite/mv/mv-moves-large-file
    func testMv_movesLargeFile() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-mv-large-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Create large sparse file
        let ddTask = Process()
        ddTask.executableURL = URL(fileURLWithPath: "/bin/dd")
        ddTask.arguments = ["if=/dev/zero", "of=\(tempDir.path)/foo", "seek=10k", "count=1"]
        try? ddTask.run()
        ddTask.waitUntilExit()

        // Run mv
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["mv", "foo", "bar"]
        task.currentDirectoryURL = tempDir
        try? task.run()
        task.waitUntilExit()

        // Verify
        XCTAssertEqual(task.terminationStatus, 0, "mv should succeed")
        XCTAssertFalse(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("foo").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("bar").path))
    }

    // MARK: - Test 8: moves-small-file
    // Source: busybox/testsuite/mv/mv-moves-small-file
    func testMv_movesSmallFile() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-mv-small-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Create small file
        try? "I WANT\n".write(toFile: tempDir.appendingPathComponent("foo").path, atomically: true, encoding: .utf8)

        // Run mv
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["mv", "foo", "bar"]
        task.currentDirectoryURL = tempDir
        try? task.run()
        task.waitUntilExit()

        // Verify
        XCTAssertEqual(task.terminationStatus, 0, "mv should succeed")
        XCTAssertFalse(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("foo").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("bar").path))
    }

    // MARK: - Test 9: moves-symlinks
    // Source: busybox/testsuite/mv/mv-moves-symlinks
    func testMv_movesSymlinks() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-mv-symlink-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Create file and symlink
        try? "".write(toFile: tempDir.appendingPathComponent("foo").path, atomically: true, encoding: .utf8)
        try? FileManager.default.createSymbolicLink(
            atPath: tempDir.appendingPathComponent("bar").path,
            withDestinationPath: "foo"
        )

        // Run mv
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["mv", "bar", "baz"]
        task.currentDirectoryURL = tempDir
        try? task.run()
        task.waitUntilExit()

        // Verify
        XCTAssertEqual(task.terminationStatus, 0, "mv should succeed")
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("foo").path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("bar").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("baz").path))

        // Verify baz is a symlink
        let linkPath = tempDir.appendingPathComponent("baz").path
        if let linkDest = try? FileManager.default.destinationOfSymbolicLink(atPath: linkPath) {
            XCTAssertEqual(linkDest, "foo", "Symlink should be preserved")
        } else {
            XCTFail("baz should be a symlink")
        }
    }

    // MARK: - Test 10: moves-unreadable-files
    // Source: busybox/testsuite/mv/mv-moves-unreadable-files
    func testMv_movesUnreadableFiles() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-mv-unread-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Create file and make it unreadable
        let fooPath = tempDir.appendingPathComponent("foo").path
        try? "".write(toFile: fooPath, atomically: true, encoding: .utf8)
        try? FileManager.default.setAttributes([.posixPermissions: 0o000], ofItemAtPath: fooPath)

        // Run mv
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["mv", "foo", "bar"]
        task.currentDirectoryURL = tempDir
        try? task.run()
        task.waitUntilExit()

        // Verify - mv should still work (doesn't need to read file content)
        XCTAssertEqual(task.terminationStatus, 0, "mv should succeed even on unreadable files")
        XCTAssertFalse(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("foo").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("bar").path))
    }

    // MARK: - Test 11: preserves-hard-links
    // Source: busybox/testsuite/mv/mv-preserves-hard-links
    func testMv_preservesHardLinks() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-mv-hardlink-preserve-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Create file and hard link
        try? "".write(toFile: tempDir.appendingPathComponent("foo").path, atomically: true, encoding: .utf8)
        try? FileManager.default.linkItem(
            atPath: tempDir.appendingPathComponent("foo").path,
            toPath: tempDir.appendingPathComponent("bar").path
        )

        // Create destination directory
        try? FileManager.default.createDirectory(at: tempDir.appendingPathComponent("baz"), withIntermediateDirectories: true)

        // Run mv
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["mv", "foo", "bar", "baz"]
        task.currentDirectoryURL = tempDir
        try? task.run()
        task.waitUntilExit()

        // Verify
        XCTAssertEqual(task.terminationStatus, 0, "mv should succeed")

        // Check if hard link is preserved (same inode)
        let fooAttrs = try? FileManager.default.attributesOfItem(atPath: tempDir.appendingPathComponent("baz/foo").path)
        let barAttrs = try? FileManager.default.attributesOfItem(atPath: tempDir.appendingPathComponent("baz/bar").path)

        if let fooInode = fooAttrs?[.systemFileNumber] as? UInt64,
           let barInode = barAttrs?[.systemFileNumber] as? UInt64 {
            XCTAssertEqual(fooInode, barInode, "Hard links should be preserved")
        }
    }

    // MARK: - Test 12: preserves-links
    // Source: busybox/testsuite/mv/mv-preserves-links
    func testMv_preservesSymlinks() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-mv-symlink-preserve-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Create file and symlink
        try? "".write(toFile: tempDir.appendingPathComponent("foo").path, atomically: true, encoding: .utf8)
        try? FileManager.default.createSymbolicLink(
            atPath: tempDir.appendingPathComponent("bar").path,
            withDestinationPath: "foo"
        )

        // Run mv
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["mv", "bar", "baz"]
        task.currentDirectoryURL = tempDir
        try? task.run()
        task.waitUntilExit()

        // Verify
        XCTAssertEqual(task.terminationStatus, 0, "mv should succeed")

        let linkPath = tempDir.appendingPathComponent("baz").path
        if let linkDest = try? FileManager.default.destinationOfSymbolicLink(atPath: linkPath) {
            XCTAssertEqual(linkDest, "foo", "Symlink should be preserved")
        } else {
            XCTFail("baz should be a symlink")
        }
    }

    // MARK: - Test 13: refuses-mv-dir-to-subdir
    // Source: busybox/testsuite/mv/mv-refuses-mv-dir-to-subdir
    func testMv_refusesMvDirToSubdir() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-mv-subdir-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Create test files
        try? "file number one\n".write(toFile: tempDir.appendingPathComponent("file1").path, atomically: true, encoding: .utf8)
        try? "file number two\n".write(toFile: tempDir.appendingPathComponent("file2").path, atomically: true, encoding: .utf8)

        // Create symlink
        try? FileManager.default.createSymbolicLink(
            atPath: tempDir.appendingPathComponent("link1").path,
            withDestinationPath: "file2"
        )

        // Create directory
        try? FileManager.default.createDirectory(at: tempDir.appendingPathComponent("dir1"), withIntermediateDirectories: true)
        try? "".write(toFile: tempDir.appendingPathComponent("dir1/file3").path, atomically: true, encoding: .utf8)

        // Create destination
        try? FileManager.default.createDirectory(at: tempDir.appendingPathComponent("there"), withIntermediateDirectories: true)

        // First mv should succeed
        let task1 = Process()
        task1.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task1.arguments = ["mv", "file1", "file2", "link1", "dir1", "there"]
        task1.currentDirectoryURL = tempDir
        try? task1.run()
        task1.waitUntilExit()

        XCTAssertEqual(task1.terminationStatus, 0, "First mv should succeed")

        // Try to mv directory to its own subdirectory - should fail
        let task2 = Process()
        task2.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task2.arguments = ["mv", "there", "there/dir1"]
        task2.currentDirectoryURL = tempDir
        try? task2.run()
        task2.waitUntilExit()

        XCTAssertNotEqual(task2.terminationStatus, 0, "mv dir to subdir should fail")
    }

    // MARK: - Test 14: removes-source-file
    // Source: busybox/testsuite/mv/mv-removes-source-file
    func testMv_removesSourceFile() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-mv-remove-src-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Create file
        try? "".write(toFile: tempDir.appendingPathComponent("foo").path, atomically: true, encoding: .utf8)

        // Run mv
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["mv", "foo", "bar"]
        task.currentDirectoryURL = tempDir
        try? task.run()
        task.waitUntilExit()

        // Verify
        XCTAssertEqual(task.terminationStatus, 0, "mv should succeed")
        XCTAssertFalse(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("foo").path), "Source should be removed")
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("bar").path), "Destination should exist")
    }
}
