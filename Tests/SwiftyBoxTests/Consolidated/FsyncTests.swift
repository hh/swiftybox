// FsyncTests.swift
// Comprehensive tests for the fsync command

import XCTest
import Foundation
@testable import SwiftyBox

/// Tests for the `fsync` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: Linux fsync command
/// - Synchronizes file data to disk (calls fsync() syscall via FileHandle.synchronize())
/// - Common usage: fsync FILE (syncs specific file)
/// - Target scope: P0 (basic file sync)
///
/// Key behaviors to test:
/// - Calls FileHandle.synchronize() to flush file buffers to disk
/// - Exit code 0 on success for all files
/// - Exit code 1 if any file fails (but continues processing)
/// - No output on success (silent operation)
/// - Error messages to stderr for failed files
/// - Requires at least one file argument
/// - Syncs multiple files when provided
/// - Works with regular files
/// - Fails gracefully for nonexistent files
/// - Fails for directories (may not support fsync)
///
/// Resources:
/// - Man page: fsync(1), fsync(2)
/// - Implementation uses FileHandle.synchronize()

final class FsyncTests: XCTestCase {

    // MARK: - Basic Functionality

    func testFsyncSingleFile() {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("fsync-test-\(UUID().uuidString).txt")
        let testData = "test data for fsync\n".data(using: .utf8)!

        // Create and write to file
        try? testData.write(to: tempFile)
        defer { try? FileManager.default.removeItem(at: tempFile) }

        let result = runCommand("fsync", [tempFile.path])

        XCTAssertEqual(result.exitCode, 0, "fsync should succeed on regular file")
        XCTAssertEqual(result.stdout, "", "fsync should produce no output on success")
        XCTAssertEqual(result.stderr, "", "fsync should produce no stderr on success")
    }

    func testFsyncNoOutput() {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("fsync-test-\(UUID().uuidString).txt")
        let testData = "test\n".data(using: .utf8)!

        try? testData.write(to: tempFile)
        defer { try? FileManager.default.removeItem(at: tempFile) }

        let result = runCommand("fsync", [tempFile.path])

        XCTAssertTrue(result.stdout.isEmpty, "fsync should not output to stdout")
        XCTAssertTrue(result.stderr.isEmpty, "fsync should not output to stderr on success")
    }

    func testFsyncSuccessExitCode() {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("fsync-test-\(UUID().uuidString).txt")
        let testData = "data\n".data(using: .utf8)!

        try? testData.write(to: tempFile)
        defer { try? FileManager.default.removeItem(at: tempFile) }

        let result = runCommand("fsync", [tempFile.path])

        XCTAssertEqual(result.exitCode, 0, "fsync should exit with code 0 on success")
    }

    // MARK: - Multiple Files

    func testFsyncMultipleFiles() {
        let tempFile1 = FileManager.default.temporaryDirectory
            .appendingPathComponent("fsync-test-\(UUID().uuidString)-1.txt")
        let tempFile2 = FileManager.default.temporaryDirectory
            .appendingPathComponent("fsync-test-\(UUID().uuidString)-2.txt")
        let tempFile3 = FileManager.default.temporaryDirectory
            .appendingPathComponent("fsync-test-\(UUID().uuidString)-3.txt")

        try? "data1\n".data(using: .utf8)!.write(to: tempFile1)
        try? "data2\n".data(using: .utf8)!.write(to: tempFile2)
        try? "data3\n".data(using: .utf8)!.write(to: tempFile3)

        defer {
            try? FileManager.default.removeItem(at: tempFile1)
            try? FileManager.default.removeItem(at: tempFile2)
            try? FileManager.default.removeItem(at: tempFile3)
        }

        let result = runCommand("fsync", [tempFile1.path, tempFile2.path, tempFile3.path])

        XCTAssertEqual(result.exitCode, 0, "fsync should succeed on all files")
        XCTAssertEqual(result.stdout, "", "fsync should produce no output")
        XCTAssertEqual(result.stderr, "", "fsync should produce no errors")
    }

    func testFsyncTwoFiles() {
        let tempFile1 = FileManager.default.temporaryDirectory
            .appendingPathComponent("fsync-test-\(UUID().uuidString)-1.txt")
        let tempFile2 = FileManager.default.temporaryDirectory
            .appendingPathComponent("fsync-test-\(UUID().uuidString)-2.txt")

        try? "file1\n".data(using: .utf8)!.write(to: tempFile1)
        try? "file2\n".data(using: .utf8)!.write(to: tempFile2)

        defer {
            try? FileManager.default.removeItem(at: tempFile1)
            try? FileManager.default.removeItem(at: tempFile2)
        }

        let result = runCommand("fsync", [tempFile1.path, tempFile2.path])

        XCTAssertEqual(result.exitCode, 0, "fsync should sync multiple files")
    }

    // MARK: - Error Handling

    func testFsyncNonexistentFile() {
        let nonexistentPath = "/tmp/this-file-does-not-exist-\(UUID().uuidString)"

        let result = runCommand("fsync", [nonexistentPath])

        XCTAssertNotEqual(result.exitCode, 0, "fsync should fail for nonexistent file")
        XCTAssertFalse(result.stderr.isEmpty, "fsync should output error for nonexistent file")
        XCTAssertTrue(result.stderr.contains(nonexistentPath), "error should mention the file path")
    }

    func testFsyncNoArguments() {
        let result = runCommand("fsync", [])

        XCTAssertNotEqual(result.exitCode, 0, "fsync should fail with no arguments")
        XCTAssertFalse(result.stderr.isEmpty, "fsync should output error message")
        XCTAssertTrue(result.stderr.contains("missing"), "error should mention missing operand")
    }

    func testFsyncDirectory() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("fsync-dir-\(UUID().uuidString)")

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let result = runCommand("fsync", [tempDir.path])

        // fsync on directories typically fails
        if result.exitCode != 0 {
            XCTAssertFalse(result.stderr.isEmpty, "fsync on directory should produce error message")
        }
    }

    func testFsyncPermissionDenied() {
        // Create a test file and remove read permissions
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("fsync-test-\(UUID().uuidString).txt")

        try? "data\n".data(using: .utf8)!.write(to: tempFile)
        defer { try? FileManager.default.removeItem(at: tempFile) }

        // Remove read and write permissions
        try? FileManager.default.setAttributes(
            [.protectionKey: FileProtectionType.none.rawValue],
            ofItemAtPath: tempFile.path
        )
        try? FileManager.default.setAttributes(
            [.posixPermissions: 0o000],
            ofItemAtPath: tempFile.path
        )

        let result = runCommand("fsync", [tempFile.path])

        // Permission denied should fail
        if result.exitCode != 0 {
            XCTAssertFalse(result.stderr.isEmpty, "fsync should error on permission denied")
        }

        // Restore permissions for cleanup
        try? FileManager.default.setAttributes(
            [.posixPermissions: 0o644],
            ofItemAtPath: tempFile.path
        )
    }

    // MARK: - After Write Operations

    func testFsyncAfterWrite() {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("fsync-test-\(UUID().uuidString).txt")

        defer { try? FileManager.default.removeItem(at: tempFile) }

        // Create, write, then fsync
        try? "initial content\n".data(using: .utf8)!.write(to: tempFile)

        let result = runCommand("fsync", [tempFile.path])

        XCTAssertEqual(result.exitCode, 0, "fsync should succeed after write")
    }

    func testFsyncAfterCreate() {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("fsync-test-\(UUID().uuidString).txt")

        defer { try? FileManager.default.removeItem(at: tempFile) }

        // Create file
        FileManager.default.createFile(atPath: tempFile.path, contents: nil)

        let result = runCommand("fsync", [tempFile.path])

        XCTAssertEqual(result.exitCode, 0, "fsync should succeed on newly created file")
    }

    func testFsyncAfterMultipleWrites() {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("fsync-test-\(UUID().uuidString).txt")

        defer { try? FileManager.default.removeItem(at: tempFile) }

        // Write multiple times
        try? "first\n".data(using: .utf8)!.write(to: tempFile)
        try? "first\nsecond\n".data(using: .utf8)!.write(to: tempFile)
        try? "first\nsecond\nthird\n".data(using: .utf8)!.write(to: tempFile)

        let result = runCommand("fsync", [tempFile.path])

        XCTAssertEqual(result.exitCode, 0, "fsync should sync all accumulated changes")
    }

    // MARK: - Empty File

    func testFsyncEmptyFile() {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("fsync-test-\(UUID().uuidString).txt")

        // Create empty file
        FileManager.default.createFile(atPath: tempFile.path, contents: Data())

        defer { try? FileManager.default.removeItem(at: tempFile) }

        let result = runCommand("fsync", [tempFile.path])

        XCTAssertEqual(result.exitCode, 0, "fsync should work on empty files")
        XCTAssertEqual(result.stdout, "", "fsync should produce no output")
    }

    // MARK: - No stdin

    func testFsyncIgnoresStdin() {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("fsync-test-\(UUID().uuidString).txt")

        try? "data\n".data(using: .utf8)!.write(to: tempFile)
        defer { try? FileManager.default.removeItem(at: tempFile) }

        let result = runCommandWithInput("fsync", [tempFile.path], input: "this should be ignored\n")

        XCTAssertEqual(result.exitCode, 0, "fsync should ignore stdin")
        XCTAssertEqual(result.stdout, "", "fsync should not output stdin")
    }

    // MARK: - Consistency

    func testFsyncConsistency() {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("fsync-test-\(UUID().uuidString).txt")

        try? "data\n".data(using: .utf8)!.write(to: tempFile)
        defer { try? FileManager.default.removeItem(at: tempFile) }

        // Call fsync multiple times on same file
        let results = (0..<5).map { _ in runCommand("fsync", [tempFile.path]) }

        XCTAssertTrue(results.allSatisfy { $0.exitCode == 0 },
                     "Multiple fsync calls should all succeed")
        XCTAssertTrue(results.allSatisfy { $0.stdout.isEmpty },
                     "All fsync calls should have no output")
    }

    func testFsyncMultipleFsyncCalls() {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("fsync-test-\(UUID().uuidString).txt")

        try? "data\n".data(using: .utf8)!.write(to: tempFile)
        defer { try? FileManager.default.removeItem(at: tempFile) }

        // Rapid successive fsync calls
        for _ in 0..<10 {
            let result = runCommand("fsync", [tempFile.path])
            XCTAssertEqual(result.exitCode, 0, "repeated fsync should always succeed")
        }
    }

    // MARK: - Partial Success (Mixed Files)

    func testFsyncPartialSuccess() {
        let goodFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("fsync-test-good-\(UUID().uuidString).txt")
        let badFile = "/tmp/nonexistent-\(UUID().uuidString)"

        try? "data\n".data(using: .utf8)!.write(to: goodFile)
        defer { try? FileManager.default.removeItem(at: goodFile) }

        let result = runCommand("fsync", [goodFile.path, badFile])

        // Should fail overall due to bad file
        XCTAssertNotEqual(result.exitCode, 0, "fsync should fail if any file fails")
        XCTAssertFalse(result.stderr.isEmpty, "fsync should report error for bad file")
    }

    func testFsyncLargeFile() {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("fsync-test-large-\(UUID().uuidString).txt")

        // Create a larger file (1 MB)
        let largeData = Data(count: 1_000_000)
        try? largeData.write(to: tempFile)

        defer { try? FileManager.default.removeItem(at: tempFile) }

        let result = runCommand("fsync", [tempFile.path])

        XCTAssertEqual(result.exitCode, 0, "fsync should work on larger files")
    }

    func testFsyncBinaryFile() {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("fsync-test-binary-\(UUID().uuidString).bin")

        // Create binary file with random data
        let binaryData = Data((0..<256).map { UInt8($0) })
        try? binaryData.write(to: tempFile)

        defer { try? FileManager.default.removeItem(at: tempFile) }

        let result = runCommand("fsync", [tempFile.path])

        XCTAssertEqual(result.exitCode, 0, "fsync should work on binary files")
    }
}
