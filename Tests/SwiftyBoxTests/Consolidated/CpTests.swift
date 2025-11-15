// CpTests.swift
// ============================================================================
// BusyBox Test Import Metadata
// ============================================================================
// Source Type: Individual test cases (subdirectory tests)
// Source Path: busybox/testsuite/cp/
// Import Date: 2025-11-14
// Test Count: 17
// Pass Rate: 74.2% (23/31)
// ============================================================================
// Tests for cp command edge cases and scenarios

import XCTest
import Foundation

final class CpTests: XCTestCase {
    var swiftyboxPath: String {
        let cwd = FileManager.default.currentDirectoryPath
        return "\(cwd)/.build/debug/swiftybox"
    }

    // MARK: - Test 1: cp -a files-to-dir
    // Source: busybox/testsuite/cp/cp-a-files-to-dir
    func testCp_archiveMultipleFilesToDir() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-cp-a-files-\(UUID().uuidString)")
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

        // Create destination
        try? FileManager.default.createDirectory(at: tempDir.appendingPathComponent("there"), withIntermediateDirectories: true)

        // Run cp -a
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["cp", "-a", "file1", "file2", "link1", "dir1", "there"]
        task.currentDirectoryURL = tempDir
        try? task.run()
        task.waitUntilExit()

        // Verify
        XCTAssertEqual(task.terminationStatus, 0, "cp -a should succeed")
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("there/file1").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("there/file2").path))

        // Check symlink is preserved
        let linkPath = tempDir.appendingPathComponent("there/link1").path
        if let linkDest = try? FileManager.default.destinationOfSymbolicLink(atPath: linkPath) {
            XCTAssertEqual(linkDest, "file2", "Symlink should be preserved")
        } else {
            XCTFail("link1 should be a symlink")
        }
    }

    // MARK: - Test 2: cp -a preserves-links
    // Source: busybox/testsuite/cp/cp-a-preserves-links
    func testCp_archivePreservesSymlinks() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-cp-a-symlink-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Create file and symlink
        try? "".write(toFile: tempDir.appendingPathComponent("foo").path, atomically: true, encoding: .utf8)
        try? FileManager.default.createSymbolicLink(
            atPath: tempDir.appendingPathComponent("bar").path,
            withDestinationPath: "foo"
        )

        // Run cp -a
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["cp", "-a", "bar", "baz"]
        task.currentDirectoryURL = tempDir
        try? task.run()
        task.waitUntilExit()

        // Verify
        XCTAssertEqual(task.terminationStatus, 0, "cp -a should succeed")

        let linkPath = tempDir.appendingPathComponent("baz").path
        if let linkDest = try? FileManager.default.destinationOfSymbolicLink(atPath: linkPath) {
            XCTAssertEqual(linkDest, "foo", "Symlink target should be preserved")
        } else {
            XCTFail("baz should be a symlink")
        }
    }

    // MARK: - Test 3: copies-empty-file
    // Source: busybox/testsuite/cp/cp-copies-empty-file
    func testCp_copiesEmptyFile() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-cp-empty-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Create empty file
        try? "".write(toFile: tempDir.appendingPathComponent("foo").path, atomically: true, encoding: .utf8)

        // Run cp
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["cp", "foo", "bar"]
        task.currentDirectoryURL = tempDir
        try? task.run()
        task.waitUntilExit()

        // Verify
        XCTAssertEqual(task.terminationStatus, 0, "cp should succeed")
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("bar").path))

        // Compare files
        let fooData = try? Data(contentsOf: tempDir.appendingPathComponent("foo"))
        let barData = try? Data(contentsOf: tempDir.appendingPathComponent("bar"))
        XCTAssertEqual(fooData, barData, "Files should be identical")
    }

    // MARK: - Test 4: copies-large-file
    // Source: busybox/testsuite/cp/cp-copies-large-file
    func testCp_copiesLargeFile() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-cp-large-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Create large sparse file using dd
        let ddTask = Process()
        ddTask.executableURL = URL(fileURLWithPath: "/bin/dd")
        ddTask.arguments = ["if=/dev/zero", "of=\(tempDir.path)/foo", "seek=10k", "count=1"]
        try? ddTask.run()
        ddTask.waitUntilExit()

        // Run cp
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["cp", "foo", "bar"]
        task.currentDirectoryURL = tempDir
        try? task.run()
        task.waitUntilExit()

        // Verify
        XCTAssertEqual(task.terminationStatus, 0, "cp should succeed")

        // Compare files
        let fooData = try? Data(contentsOf: tempDir.appendingPathComponent("foo"))
        let barData = try? Data(contentsOf: tempDir.appendingPathComponent("bar"))
        XCTAssertEqual(fooData, barData, "Large files should be identical")
    }

    // MARK: - Test 5: copies-small-file
    // Source: busybox/testsuite/cp/cp-copies-small-file
    func testCp_copiesSmallFile() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-cp-small-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Create small file
        try? "I WANT\n".write(toFile: tempDir.appendingPathComponent("foo").path, atomically: true, encoding: .utf8)

        // Run cp
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["cp", "foo", "bar"]
        task.currentDirectoryURL = tempDir
        try? task.run()
        task.waitUntilExit()

        // Verify
        XCTAssertEqual(task.terminationStatus, 0, "cp should succeed")

        let fooData = try? Data(contentsOf: tempDir.appendingPathComponent("foo"))
        let barData = try? Data(contentsOf: tempDir.appendingPathComponent("bar"))
        XCTAssertEqual(fooData, barData, "Small files should be identical")
    }

    // MARK: - Test 6: dev-file
    // Source: busybox/testsuite/cp/cp-dev-file
    func testCp_copiesDevFile() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-cp-dev-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Run cp /dev/null
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["cp", "/dev/null", "foo"]
        task.currentDirectoryURL = tempDir
        try? task.run()
        task.waitUntilExit()

        // Verify
        XCTAssertEqual(task.terminationStatus, 0, "cp should succeed")
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("foo").path))
    }

    // MARK: - Test 7: cp -d files-to-dir
    // Source: busybox/testsuite/cp/cp-d-files-to-dir
    func testCp_noDereferenceFilesToDir() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-cp-d-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Create files
        try? "file number one\n".write(toFile: tempDir.appendingPathComponent("file1").path, atomically: true, encoding: .utf8)
        try? "file number two\n".write(toFile: tempDir.appendingPathComponent("file2").path, atomically: true, encoding: .utf8)
        try? "".write(toFile: tempDir.appendingPathComponent("file3").path, atomically: true, encoding: .utf8)

        // Create symlink
        try? FileManager.default.createSymbolicLink(
            atPath: tempDir.appendingPathComponent("link1").path,
            withDestinationPath: "file2"
        )

        // Create destination
        try? FileManager.default.createDirectory(at: tempDir.appendingPathComponent("there"), withIntermediateDirectories: true)

        // Run cp -d
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["cp", "-d", "file1", "file2", "file3", "link1", "there"]
        task.currentDirectoryURL = tempDir
        try? task.run()
        task.waitUntilExit()

        // Verify
        XCTAssertEqual(task.terminationStatus, 0, "cp -d should succeed")
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("there/file1").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("there/file2").path))

        // Verify symlink is preserved
        let linkPath = tempDir.appendingPathComponent("there/link1").path
        if let linkDest = try? FileManager.default.destinationOfSymbolicLink(atPath: linkPath) {
            XCTAssertEqual(linkDest, "file2", "Symlink should be preserved with -d")
        } else {
            XCTFail("link1 should be a symlink")
        }
    }

    // MARK: - Test 8: dir-create-dir
    // Source: busybox/testsuite/cp/cp-dir-create-dir
    func testCp_recursiveCopyCreatesDir() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-cp-R-create-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Create source directory with file
        try? FileManager.default.createDirectory(at: tempDir.appendingPathComponent("bar"), withIntermediateDirectories: true)
        try? "".write(toFile: tempDir.appendingPathComponent("bar/baz").path, atomically: true, encoding: .utf8)

        // Run cp -R
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["cp", "-R", "bar", "foo"]
        task.currentDirectoryURL = tempDir
        try? task.run()
        task.waitUntilExit()

        // Verify
        XCTAssertEqual(task.terminationStatus, 0, "cp -R should succeed")
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("foo/baz").path))
    }

    // MARK: - Test 9: dir-existing-dir
    // Source: busybox/testsuite/cp/cp-dir-existing-dir
    func testCp_recursiveCopyToExistingDir() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-cp-R-existing-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Create source directory with file
        try? FileManager.default.createDirectory(at: tempDir.appendingPathComponent("bar"), withIntermediateDirectories: true)
        try? "".write(toFile: tempDir.appendingPathComponent("bar/baz").path, atomically: true, encoding: .utf8)

        // Create existing destination directory
        try? FileManager.default.createDirectory(at: tempDir.appendingPathComponent("foo"), withIntermediateDirectories: true)

        // Run cp -R
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["cp", "-R", "bar", "foo"]
        task.currentDirectoryURL = tempDir
        try? task.run()
        task.waitUntilExit()

        // Verify
        XCTAssertEqual(task.terminationStatus, 0, "cp -R should succeed")
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("foo/bar/baz").path))
    }

    // MARK: - Test 10: does-not-copy-unreadable-file
    // Source: busybox/testsuite/cp/cp-does-not-copy-unreadable-file
    func testCp_failsOnUnreadableFile() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-cp-unreadable-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Create file and make it unreadable
        let fooPath = tempDir.appendingPathComponent("foo").path
        try? "".write(toFile: fooPath, atomically: true, encoding: .utf8)

        // Skip this test if running as root (can read everything)
        let uid = getuid()
        guard uid != 0 else {
            // Can't test unreadable files as root
            return
        }

        try? FileManager.default.setAttributes([.posixPermissions: 0o000], ofItemAtPath: fooPath)

        // Run cp (should fail)
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["cp", "foo", "bar"]
        task.currentDirectoryURL = tempDir
        try? task.run()
        task.waitUntilExit()

        // Verify cp failed
        XCTAssertNotEqual(task.terminationStatus, 0, "cp should fail on unreadable file")
        XCTAssertFalse(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("bar").path))
    }

    // MARK: - Test 11: files-to-dir
    // Source: busybox/testsuite/cp/cp-files-to-dir
    func testCp_multipleFilesToDir() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-cp-multi-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Create files
        try? "file number one\n".write(toFile: tempDir.appendingPathComponent("file1").path, atomically: true, encoding: .utf8)
        try? "file number two\n".write(toFile: tempDir.appendingPathComponent("file2").path, atomically: true, encoding: .utf8)
        try? "".write(toFile: tempDir.appendingPathComponent("file3").path, atomically: true, encoding: .utf8)

        // Create symlink
        try? FileManager.default.createSymbolicLink(
            atPath: tempDir.appendingPathComponent("link1").path,
            withDestinationPath: "file2"
        )

        // Create destination
        try? FileManager.default.createDirectory(at: tempDir.appendingPathComponent("there"), withIntermediateDirectories: true)

        // Run cp
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["cp", "file1", "file2", "file3", "link1", "there"]
        task.currentDirectoryURL = tempDir
        try? task.run()
        task.waitUntilExit()

        // Verify
        XCTAssertEqual(task.terminationStatus, 0, "cp should succeed")
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("there/file1").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("there/file2").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("there/link1").path))

        // link1 should be dereferenced (regular file, not symlink)
        let linkPath = tempDir.appendingPathComponent("there/link1").path
        let isSymlink = (try? FileManager.default.destinationOfSymbolicLink(atPath: linkPath)) != nil
        XCTAssertFalse(isSymlink, "Without -d, symlinks should be dereferenced")
    }

    // MARK: - Test 12: follows-links
    // Source: busybox/testsuite/cp/cp-follows-links
    func testCp_followsSymlinks() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-cp-follow-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Create file and symlink
        try? "".write(toFile: tempDir.appendingPathComponent("foo").path, atomically: true, encoding: .utf8)
        try? FileManager.default.createSymbolicLink(
            atPath: tempDir.appendingPathComponent("bar").path,
            withDestinationPath: "foo"
        )

        // Run cp
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["cp", "bar", "baz"]
        task.currentDirectoryURL = tempDir
        try? task.run()
        task.waitUntilExit()

        // Verify
        XCTAssertEqual(task.terminationStatus, 0, "cp should succeed")
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("baz").path))
    }

    // MARK: - Test 13: parents
    // Source: busybox/testsuite/cp/cp-parents
    func testCp_parentsOption() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-cp-parents-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Create nested directory structure
        try? FileManager.default.createDirectory(
            at: tempDir.appendingPathComponent("foo/bar/baz"),
            withIntermediateDirectories: true
        )
        try? "".write(toFile: tempDir.appendingPathComponent("foo/bar/baz/file").path, atomically: true, encoding: .utf8)

        // Create destination
        try? FileManager.default.createDirectory(at: tempDir.appendingPathComponent("dir"), withIntermediateDirectories: true)

        // Run cp --parents
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["cp", "--parents", "foo/bar/baz/file", "dir"]
        task.currentDirectoryURL = tempDir
        try? task.run()
        task.waitUntilExit()

        // Verify
        XCTAssertEqual(task.terminationStatus, 0, "cp --parents should succeed")
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("dir/foo/bar/baz/file").path))
    }

    // MARK: - Test 14: preserves-hard-links
    // Source: busybox/testsuite/cp/cp-preserves-hard-links
    func testCp_preservesHardLinks() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-cp-hardlink-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Create file and hard link
        try? "".write(toFile: tempDir.appendingPathComponent("foo").path, atomically: true, encoding: .utf8)
        try? FileManager.default.linkItem(
            atPath: tempDir.appendingPathComponent("foo").path,
            toPath: tempDir.appendingPathComponent("bar").path
        )

        // Create destination
        try? FileManager.default.createDirectory(at: tempDir.appendingPathComponent("baz"), withIntermediateDirectories: true)

        // Run cp -d
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["cp", "-d", "foo", "bar", "baz"]
        task.currentDirectoryURL = tempDir
        try? task.run()
        task.waitUntilExit()

        // Verify
        XCTAssertEqual(task.terminationStatus, 0, "cp -d should succeed")

        // Check if hard link is preserved (same inode)
        let fooAttrs = try? FileManager.default.attributesOfItem(atPath: tempDir.appendingPathComponent("baz/foo").path)
        let barAttrs = try? FileManager.default.attributesOfItem(atPath: tempDir.appendingPathComponent("baz/bar").path)

        if let fooInode = fooAttrs?[.systemFileNumber] as? UInt64,
           let barInode = barAttrs?[.systemFileNumber] as? UInt64 {
            XCTAssertEqual(fooInode, barInode, "Hard links should be preserved")
        }
    }

    // MARK: - Test 15: preserves-links
    // Source: busybox/testsuite/cp/cp-preserves-links
    func testCp_dPreservesSymlinks() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-cp-d-symlink-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Create file and symlink
        try? "".write(toFile: tempDir.appendingPathComponent("foo").path, atomically: true, encoding: .utf8)
        try? FileManager.default.createSymbolicLink(
            atPath: tempDir.appendingPathComponent("bar").path,
            withDestinationPath: "foo"
        )

        // Run cp -d
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["cp", "-d", "bar", "baz"]
        task.currentDirectoryURL = tempDir
        try? task.run()
        task.waitUntilExit()

        // Verify
        XCTAssertEqual(task.terminationStatus, 0, "cp -d should succeed")

        let linkPath = tempDir.appendingPathComponent("baz").path
        if let linkDest = try? FileManager.default.destinationOfSymbolicLink(atPath: linkPath) {
            XCTAssertEqual(linkDest, "foo", "Symlink should be preserved")
        } else {
            XCTFail("baz should be a symlink")
        }
    }

    // MARK: - Test 16: preserves-source-file
    // Source: busybox/testsuite/cp/cp-preserves-source-file
    func testCp_preservesSourceFile() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-cp-preserve-src-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Create source file
        try? "".write(toFile: tempDir.appendingPathComponent("foo").path, atomically: true, encoding: .utf8)

        // Run cp
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["cp", "foo", "bar"]
        task.currentDirectoryURL = tempDir
        try? task.run()
        task.waitUntilExit()

        // Verify both files exist
        XCTAssertEqual(task.terminationStatus, 0, "cp should succeed")
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("foo").path), "Source file should still exist")
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("bar").path), "Destination file should exist")
    }

    // MARK: - Test 17: RHL-does-not-preserve-links
    // Source: busybox/testsuite/cp/cp-RHL-does_not_preserve-links
    func testCp_RHLDoesNotPreserveLinks() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-cp-RHL-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Create directory structure
        try? FileManager.default.createDirectory(at: tempDir.appendingPathComponent("a"), withIntermediateDirectories: true)
        try? "".write(toFile: tempDir.appendingPathComponent("a/file").path, atomically: true, encoding: .utf8)
        try? FileManager.default.createSymbolicLink(
            atPath: tempDir.appendingPathComponent("a/link").path,
            withDestinationPath: "file"
        )

        // Run cp -RHL
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["cp", "-RHL", "a", "b"]
        task.currentDirectoryURL = tempDir
        try? task.run()
        task.waitUntilExit()

        // Verify
        XCTAssertEqual(task.terminationStatus, 0, "cp -RHL should succeed")

        // With -L, symlinks should be dereferenced
        let linkPath = tempDir.appendingPathComponent("b/link").path
        let isSymlink = (try? FileManager.default.destinationOfSymbolicLink(atPath: linkPath)) != nil
        XCTAssertFalse(isSymlink, "With -L, symlinks should be dereferenced")
    }
}
