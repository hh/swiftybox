// SyncTests.swift
// Comprehensive tests for the sync command

import XCTest
@testable import swiftybox

/// Tests for the `sync` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: GNU coreutils sync
/// - POSIX: sync() system call - flush filesystem buffers to disk
/// - BusyBox: Simple wrapper around sync() syscall
/// - GNU: Supports -f (sync specific files), -d (data only)
/// - Common usage: sync (no arguments, syncs all filesystems)
/// - Target scope: P0 (basic sync) + P1 (file-specific sync if supported)
///
/// Key behaviors to test:
/// - Calls sync() to flush all filesystem buffers
/// - Exit code 0 on success
/// - No output expected (silent operation)
/// - Actual syncing is hard to test (kernel operation)
/// - Can test interface and exit codes
///
/// Resources:
/// - GNU: https://www.gnu.org/software/coreutils/manual/html_node/sync-invocation.html
/// - POSIX: sync() system call
/// - Man page: sync(1), sync(2)

final class SyncTests: XCTestCase {

    // MARK: - Basic Functionality

    func testBasicSync() {
        let result = runCommand("sync", [])

        XCTAssertEqual(result.exitCode, 0, "sync should exit with 0")
        XCTAssertEqual(result.stdout, "", "sync should produce no output")
        XCTAssertEqual(result.stderr, "", "sync should produce no stderr")
    }

    func testNoOutput() {
        let result = runCommand("sync", [])

        XCTAssertTrue(result.stdout.isEmpty, "sync should not output to stdout")
        XCTAssertTrue(result.stderr.isEmpty, "sync should not output to stderr")
    }

    func testSuccessExitCode() {
        let result = runCommand("sync", [])

        XCTAssertEqual(result.exitCode, 0, "sync should always succeed")
    }

    // MARK: - Multiple Calls

    func testMultipleSyncCalls() {
        // Can call sync multiple times
        for _ in 0..<3 {
            let result = runCommand("sync", [])
            XCTAssertEqual(result.exitCode, 0, "All sync calls should succeed")
        }
    }

    func testRapidSync() {
        // Rapid successive sync calls should all work
        let results = (0..<10).map { _ in runCommand("sync", []) }

        XCTAssertTrue(results.allSatisfy { $0.exitCode == 0 },
                     "All rapid sync calls should succeed")
    }

    // MARK: - Arguments (GNU extensions)

    func testSyncWithNoArgs() {
        // POSIX sync takes no arguments
        let result = runCommand("sync", [])
        XCTAssertEqual(result.exitCode, 0, "sync with no args should work")
    }

    func testSyncIgnoresStdin() {
        let result = runCommandWithInput("sync", [], input: "ignored\n")

        XCTAssertEqual(result.exitCode, 0, "sync should ignore stdin")
        XCTAssertTrue(result.stdout.isEmpty, "sync should not output")
    }

    // MARK: - File Sync (GNU Extension)

    func testSyncSpecificFile() {
        // GNU sync supports syncing specific files with -f
        // Create a test file
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        let testData = "test data\n".data(using: .utf8)!

        try? testData.write(to: tempFile)

        defer {
            try? FileManager.default.removeItem(at: tempFile)
        }

        // Try to sync the specific file (if implementation supports it)
        let result = runCommand("sync", [tempFile.path])

        // Either succeeds (supports -f) or fails (basic POSIX sync only)
        if result.exitCode == 0 {
            XCTAssertTrue(result.stderr.isEmpty,
                         "If sync file succeeds, should have no stderr")
        }
        // Note: We don't fail the test if this isn't supported
    }

    // MARK: - Error Handling

    func testSyncWithInvalidArguments() {
        // Some implementations ignore extra arguments
        let result = runCommand("sync", ["--invalid-option"])

        // Either fails (strict) or succeeds (permissive)
        // Both are acceptable behaviors
        if result.exitCode != 0 {
            XCTAssertFalse(result.stderr.isEmpty,
                          "If sync fails, should output error message")
        }
    }

    // MARK: - Consistency

    func testConsistentBehavior() {
        let results = (0..<5).map { _ in runCommand("sync", []) }

        // All should behave identically
        XCTAssertTrue(results.allSatisfy { $0.exitCode == 0 },
                     "All syncs should succeed")
        XCTAssertTrue(results.allSatisfy { $0.stdout.isEmpty },
                     "All syncs should have no output")
    }

    // MARK: - Performance

    func testSyncCompletes() {
        // Sync should complete in reasonable time
        let start = Date()
        let result = runCommand("sync", [])
        let duration = Date().timeIntervalSince(start)

        XCTAssertEqual(result.exitCode, 0, "sync should succeed")
        XCTAssertLessThan(duration, 10.0,
                         "sync should complete within 10 seconds")
    }

    func testSyncDoesNotHang() {
        // Multiple syncs should not hang
        let start = Date()
        for _ in 0..<5 {
            _ = runCommand("sync", [])
        }
        let duration = Date().timeIntervalSince(start)

        XCTAssertLessThan(duration, 30.0,
                         "Multiple syncs should complete within 30 seconds")
    }
}
