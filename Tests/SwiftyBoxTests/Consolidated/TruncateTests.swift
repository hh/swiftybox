// TruncateTests.swift
// ============================================================================
// Tests for truncate command functionality
// ============================================================================
// Reference: GNU coreutils truncate
// Functionality: Shrink or extend size of file
// Options: -s SIZE (set size), -c (no create)
// Size formats: 123, +123, -123, 1K, 1M, 1G
// ============================================================================

import XCTest
import Foundation

final class TruncateTests: XCTestCase {
    var swiftyboxPath: String {
        let cwd = FileManager.default.currentDirectoryPath
        return "\(cwd)/.build/debug/swiftybox"
    }

    var testDir: String {
        return FileManager.default.temporaryDirectory.appendingPathComponent("truncate-test-\(UUID().uuidString)").path
    }

    override func setUp() {
        super.setUp()
        try? FileManager.default.createDirectory(atPath: testDir, withIntermediateDirectories: true)
    }

    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(atPath: testDir)
    }

    // MARK: - Helper Functions

    /// Get file size in bytes
    private func getFileSize(_ path: String) -> Int64? {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: path) else {
            return nil
        }
        return attrs[.size] as? Int64
    }

    /// Create a test file with specific size
    private func createTestFile(_ path: String, size: Int) {
        let data = Data(repeating: 0x41, count: size) // 'A' characters
        FileManager.default.createFile(atPath: path, contents: data)
    }

    // MARK: - Test 1: Truncate to specific size (smaller)
    // P0: Basic truncate functionality
    func testTruncate_shrinkFile() {
        let filePath = testDir + "/shrink.txt"
        createTestFile(filePath, size: 1000)

        // Verify initial size
        XCTAssertEqual(getFileSize(filePath), 1000, "Initial file size should be 1000 bytes")

        // Truncate to 500 bytes
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["truncate", "-s", "500", filePath]
        try? task.run()
        task.waitUntilExit()

        XCTAssertEqual(task.terminationStatus, 0, "truncate should succeed")
        XCTAssertEqual(getFileSize(filePath), 500, "File should be truncated to 500 bytes")
    }

    // MARK: - Test 2: Truncate to zero (empty file)
    // P0: Basic truncate functionality
    func testTruncate_toZero() {
        let filePath = testDir + "/empty.txt"
        createTestFile(filePath, size: 500)

        XCTAssertEqual(getFileSize(filePath), 500, "Initial file size should be 500 bytes")

        // Truncate to 0
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["truncate", "-s", "0", filePath]
        try? task.run()
        task.waitUntilExit()

        XCTAssertEqual(task.terminationStatus, 0, "truncate to 0 should succeed")
        XCTAssertEqual(getFileSize(filePath), 0, "File should be empty (0 bytes)")

        // Verify file is actually empty
        if let data = FileManager.default.contents(atPath: filePath) {
            XCTAssertEqual(data.count, 0, "File contents should be empty")
        } else {
            XCTFail("File should exist")
        }
    }

    // MARK: - Test 3: Extend file (increase size with nulls)
    // P0: Basic truncate functionality
    func testTruncate_extendFile() {
        let filePath = testDir + "/extend.txt"
        let originalContent = "hello"
        try? originalContent.write(toFile: filePath, atomically: true, encoding: .utf8)

        XCTAssertEqual(getFileSize(filePath), 5, "Initial file size should be 5 bytes")

        // Extend to 1000 bytes
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["truncate", "-s", "1000", filePath]
        try? task.run()
        task.waitUntilExit()

        XCTAssertEqual(task.terminationStatus, 0, "truncate extend should succeed")
        XCTAssertEqual(getFileSize(filePath), 1000, "File should be extended to 1000 bytes")

        // Verify original content is preserved
        if let data = FileManager.default.contents(atPath: filePath),
           let content = String(data: data, encoding: .utf8) {
            XCTAssertTrue(content.hasPrefix("hello"), "Original content should be preserved")
            XCTAssertEqual(data.count, 1000, "Extended file should have null padding")
        } else {
            XCTFail("File should be readable")
        }
    }

    // MARK: - Test 4: Relative shrink (negative offset)
    // P1: Size formats - relative sizes
    func testTruncate_relativeShrink() {
        let filePath = testDir + "/relative-shrink.txt"
        createTestFile(filePath, size: 1000)

        XCTAssertEqual(getFileSize(filePath), 1000, "Initial file size should be 1000 bytes")

        // Shrink by 200 bytes (1000 - 200 = 800)
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["truncate", "-s", "-200", filePath]
        try? task.run()
        task.waitUntilExit()

        XCTAssertEqual(task.terminationStatus, 0, "relative shrink should succeed")
        XCTAssertEqual(getFileSize(filePath), 800, "File should be shrunk to 800 bytes")
    }

    // MARK: - Test 5: Relative extend (positive offset)
    // P1: Size formats - relative sizes
    func testTruncate_relativeExtend() {
        let filePath = testDir + "/relative-extend.txt"
        createTestFile(filePath, size: 500)

        XCTAssertEqual(getFileSize(filePath), 500, "Initial file size should be 500 bytes")

        // Extend by 300 bytes (500 + 300 = 800)
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["truncate", "-s", "+300", filePath]
        try? task.run()
        task.waitUntilExit()

        XCTAssertEqual(task.terminationStatus, 0, "relative extend should succeed")
        XCTAssertEqual(getFileSize(filePath), 800, "File should be extended to 800 bytes")
    }

    // MARK: - Test 6: Size format - Kilobytes (K)
    // P1: Size formats - binary suffixes
    func testTruncate_sizeFormatKilobytes() {
        let filePath = testDir + "/1k.txt"
        createTestFile(filePath, size: 100)

        // Truncate to 1K (1024 bytes)
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["truncate", "-s", "1K", filePath]
        try? task.run()
        task.waitUntilExit()

        XCTAssertEqual(task.terminationStatus, 0, "truncate with K suffix should succeed")
        XCTAssertEqual(getFileSize(filePath), 1024, "File should be 1K (1024 bytes)")
    }

    // MARK: - Test 7: Size format - Megabytes (M)
    // P1: Size formats - binary suffixes
    func testTruncate_sizeFormatMegabytes() {
        let filePath = testDir + "/1m.txt"
        createTestFile(filePath, size: 100)

        // Truncate to 1M (1048576 bytes)
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["truncate", "-s", "1M", filePath]
        try? task.run()
        task.waitUntilExit()

        XCTAssertEqual(task.terminationStatus, 0, "truncate with M suffix should succeed")
        XCTAssertEqual(getFileSize(filePath), 1048576, "File should be 1M (1048576 bytes)")
    }

    // MARK: - Test 8: Size format - Gigabytes (G)
    // P1: Size formats - binary suffixes
    // Note: This test creates a sparse file, not filling actual disk space
    func testTruncate_sizeFormatGigabytes() {
        let filePath = testDir + "/1g.txt"
        createTestFile(filePath, size: 100)

        // Truncate to 1G (1073741824 bytes) - sparse file
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["truncate", "-s", "1G", filePath]
        try? task.run()
        task.waitUntilExit()

        XCTAssertEqual(task.terminationStatus, 0, "truncate with G suffix should succeed")
        XCTAssertEqual(getFileSize(filePath), 1073741824, "File should be 1G (1073741824 bytes)")
    }

    // MARK: - Test 9: Create new file with -s
    // P0: Basic truncate functionality
    func testTruncate_createNewFile() {
        let filePath = testDir + "/newfile.txt"

        // Ensure file doesn't exist
        XCTAssertFalse(FileManager.default.fileExists(atPath: filePath), "File should not exist initially")

        // Truncate to 100 bytes (should create file)
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["truncate", "-s", "100", filePath]
        try? task.run()
        task.waitUntilExit()

        XCTAssertEqual(task.terminationStatus, 0, "truncate should succeed")
        XCTAssertTrue(FileManager.default.fileExists(atPath: filePath), "File should be created")
        XCTAssertEqual(getFileSize(filePath), 100, "New file should be 100 bytes")
    }

    // MARK: - Test 10: -c option (no create)
    // P0: Basic truncate functionality with options
    func testTruncate_noCreateOption() {
        let filePath = testDir + "/no-create.txt"

        // Ensure file doesn't exist
        XCTAssertFalse(FileManager.default.fileExists(atPath: filePath), "File should not exist initially")

        // Try to truncate with -c (no-create)
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["truncate", "-c", "-s", "100", filePath]
        try? task.run()
        task.waitUntilExit()

        // Should succeed but not create file
        XCTAssertEqual(task.terminationStatus, 0, "truncate -c should succeed")
        XCTAssertFalse(FileManager.default.fileExists(atPath: filePath), "File should NOT be created with -c")
    }

    // MARK: - Test 11: Multiple files
    // P0: Basic truncate functionality
    func testTruncate_multipleFiles() {
        let file1 = testDir + "/multi1.txt"
        let file2 = testDir + "/multi2.txt"
        let file3 = testDir + "/multi3.txt"

        createTestFile(file1, size: 500)
        createTestFile(file2, size: 600)
        createTestFile(file3, size: 700)

        // Truncate all to 300 bytes
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["truncate", "-s", "300", file1, file2, file3]
        try? task.run()
        task.waitUntilExit()

        XCTAssertEqual(task.terminationStatus, 0, "truncate multiple files should succeed")
        XCTAssertEqual(getFileSize(file1), 300, "File 1 should be 300 bytes")
        XCTAssertEqual(getFileSize(file2), 300, "File 2 should be 300 bytes")
        XCTAssertEqual(getFileSize(file3), 300, "File 3 should be 300 bytes")
    }

    // MARK: - Test 12: Error handling - missing -s option
    // Error handling
    func testTruncate_missingSize() {
        let filePath = testDir + "/missing-size.txt"
        createTestFile(filePath, size: 100)

        // Try to truncate without -s
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["truncate", filePath]
        try? task.run()
        task.waitUntilExit()

        // Should fail
        XCTAssertNotEqual(task.terminationStatus, 0, "truncate without -s should fail")
    }

    // MARK: - Test 13: Error handling - invalid size format
    // Error handling
    func testTruncate_invalidSizeFormat() {
        let filePath = testDir + "/invalid-size.txt"
        createTestFile(filePath, size: 100)

        // Try invalid size
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["truncate", "-s", "notanumber", filePath]
        try? task.run()
        task.waitUntilExit()

        // Should fail
        XCTAssertNotEqual(task.terminationStatus, 0, "truncate with invalid size should fail")
    }

    // MARK: - Test 14: Error handling - nonexistent file without -c
    // Error handling
    func testTruncate_nonexistentFile() {
        let filePath = testDir + "/does-not-exist.txt"

        // This should succeed (create file) as we're not using -c
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["truncate", "-s", "100", filePath]
        try? task.run()
        task.waitUntilExit()

        XCTAssertEqual(task.terminationStatus, 0, "truncate on nonexistent file should create it")
        XCTAssertTrue(FileManager.default.fileExists(atPath: filePath), "File should be created")
    }

    // MARK: - Test 15: Edge case - combined options -c -s
    // P0: Basic truncate functionality with options
    func testTruncate_combinedOptions() {
        let filePath = testDir + "/combined.txt"
        createTestFile(filePath, size: 500)

        // Truncate existing file with -c and -s
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["truncate", "-c", "-s", "250", filePath]
        try? task.run()
        task.waitUntilExit()

        XCTAssertEqual(task.terminationStatus, 0, "truncate with -c -s on existing file should succeed")
        XCTAssertEqual(getFileSize(filePath), 250, "File should be truncated to 250 bytes")
    }
}
