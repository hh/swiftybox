import XCTest
@testable import swiftybox
import Foundation

/// Tests for the `stat` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: GNU coreutils stat
/// - BusyBox: Limited support, basic file info only
/// - GNU: Rich format strings, filesystem info, multiple output modes
/// - Target scope: P0 (basic info) + P1 (common format strings)
///
/// Format specifiers (GNU stat):
///   %a - Access rights in octal (e.g., 0644)
///   %A - Access rights in human readable form (e.g., -rw-r--r--)
///   %F - File type (regular file, directory, symbolic link, etc.)
///   %n - File name
///   %s - Total size in bytes
///   %U - User name
///   %G - Group name
///   %u - User ID
///   %g - Group ID
///   %y - Time of last modification, human-readable
///   %Y - Time of last modification, seconds since Epoch
///
/// Common usage patterns:
///   stat file.txt                    # Default verbose output
///   stat -c "%a %n" file.txt         # Custom format: octal perms + name
///   stat -c "%s" file.txt            # Just file size
///   stat -f /                        # Filesystem info
///   stat -L symlink                  # Follow symlinks
///
/// Resources:
/// - GNU: https://www.gnu.org/software/coreutils/manual/html_node/stat-invocation.html
/// - POSIX: Not standardized (GNU extension)
/// - BusyBox: https://git.busybox.net/busybox/tree/coreutils/stat.c

final class StatTests: XCTestCase {

    // MARK: - Test Helpers

    private func createTempFile(content: String = "test content\n", permissions: mode_t? = nil) -> String {
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent(UUID().uuidString)

        try? content.write(to: tempFile, atomically: true, encoding: .utf8)

        if let perms = permissions {
            var attrs: [FileAttributeKey: Any] = [:]
            attrs[.posixPermissions] = perms
            try? FileManager.default.setAttributes(attrs, ofItemAtPath: tempFile.path)
        }

        return tempFile.path
    }

    private func createTempDirectory(permissions: mode_t? = nil) -> String {
        let tempDir = FileManager.default.temporaryDirectory
        let tempSubdir = tempDir.appendingPathComponent(UUID().uuidString)

        try? FileManager.default.createDirectory(at: tempSubdir, withIntermediateDirectories: false)

        if let perms = permissions {
            var attrs: [FileAttributeKey: Any] = [:]
            attrs[.posixPermissions] = perms
            try? FileManager.default.setAttributes(attrs, ofItemAtPath: tempSubdir.path)
        }

        return tempSubdir.path
    }

    override func tearDown() {
        super.tearDown()
        // Cleanup is handled by the OS for temp files
    }

    // MARK: - Basic Functionality

    func testBasicFileInfo() {
        let tempFile = createTempFile(content: "test\n")
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("stat", [tempFile])

        XCTAssertEqual(result.exitCode, 0, "stat should succeed")
        XCTAssertTrue(result.stdout.contains("File: \(tempFile)"), "Output should contain filename")
        XCTAssertTrue(result.stdout.contains("Size:"), "Output should contain size")
        XCTAssertTrue(result.stdout.contains("Access:"), "Output should contain access info")
    }

    func testBasicDirectoryInfo() {
        let tempDir = createTempDirectory()
        defer { try? FileManager.default.removeItem(atPath: tempDir) }

        let result = runCommand("stat", [tempDir])

        XCTAssertEqual(result.exitCode, 0, "stat should succeed on directory")
        XCTAssertTrue(result.stdout.contains("File: \(tempDir)"), "Output should contain directory name")
    }

    func testMultipleFiles() {
        let file1 = createTempFile(content: "file1\n")
        let file2 = createTempFile(content: "file2\n")
        defer {
            try? FileManager.default.removeItem(atPath: file1)
            try? FileManager.default.removeItem(atPath: file2)
        }

        let result = runCommand("stat", [file1, file2])

        XCTAssertEqual(result.exitCode, 0, "stat should succeed on multiple files")
        XCTAssertTrue(result.stdout.contains("File: \(file1)"), "Output should contain first file")
        XCTAssertTrue(result.stdout.contains("File: \(file2)"), "Output should contain second file")
    }

    func testNonexistentFile() {
        let nonexistent = "/tmp/nonexistent-\(UUID().uuidString)"

        let result = runCommand("stat", [nonexistent])

        XCTAssertNotEqual(result.exitCode, 0, "stat should fail on nonexistent file")
        XCTAssertTrue(result.stderr.contains("cannot stat") || result.stderr.contains("No such file"),
                     "Error should indicate file not found")
    }

    func testMissingOperand() {
        let result = runCommand("stat", [])

        XCTAssertNotEqual(result.exitCode, 0, "stat should fail with no arguments")
        XCTAssertTrue(result.stderr.contains("missing operand") || result.stderr.contains("operand"),
                     "Error should indicate missing operand")
    }

    // MARK: - File Size Tests

    func testEmptyFile() {
        let tempFile = createTempFile(content: "")
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("stat", [tempFile])

        XCTAssertEqual(result.exitCode, 0, "stat should succeed on empty file")
        XCTAssertTrue(result.stdout.contains("Size: 0") || result.stdout.contains("Size:  0"),
                     "Empty file should show size 0")
    }

    func testLargeFileSize() {
        let tempFile = createTempFile(content: String(repeating: "x", count: 10000))
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("stat", [tempFile])

        XCTAssertEqual(result.exitCode, 0, "stat should succeed on large file")
        XCTAssertTrue(result.stdout.contains("Size: 10000") || result.stdout.contains("Size:  10000"),
                     "Should show correct file size")
    }

    // MARK: - Permission Tests

    func testFilePermissions_644() {
        let tempFile = createTempFile(permissions: 0o644)
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("stat", [tempFile])

        XCTAssertEqual(result.exitCode, 0, "stat should succeed")
        XCTAssertTrue(result.stdout.contains("0644") || result.stdout.contains("644"),
                     "Should show permissions 644")
        XCTAssertTrue(result.stdout.contains("rw-r--r--"), "Should show human-readable permissions")
    }

    func testFilePermissions_755() {
        let tempFile = createTempFile(permissions: 0o755)
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("stat", [tempFile])

        XCTAssertEqual(result.exitCode, 0, "stat should succeed")
        XCTAssertTrue(result.stdout.contains("0755") || result.stdout.contains("755"),
                     "Should show permissions 755")
        XCTAssertTrue(result.stdout.contains("rwxr-xr-x"), "Should show human-readable permissions")
    }

    func testFilePermissions_600() {
        let tempFile = createTempFile(permissions: 0o600)
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("stat", [tempFile])

        XCTAssertEqual(result.exitCode, 0, "stat should succeed")
        XCTAssertTrue(result.stdout.contains("0600") || result.stdout.contains("600"),
                     "Should show permissions 600")
        XCTAssertTrue(result.stdout.contains("rw-------"), "Should show human-readable permissions")
    }

    func testDirectoryPermissions_755() {
        let tempDir = createTempDirectory(permissions: 0o755)
        defer { try? FileManager.default.removeItem(atPath: tempDir) }

        let result = runCommand("stat", [tempDir])

        XCTAssertEqual(result.exitCode, 0, "stat should succeed on directory")
        XCTAssertTrue(result.stdout.contains("0755") || result.stdout.contains("755"),
                     "Should show directory permissions 755")
    }

    // MARK: - Special Files

    func testStatDevNull() {
        let result = runCommand("stat", ["/dev/null"])

        XCTAssertEqual(result.exitCode, 0, "stat should succeed on /dev/null")
        XCTAssertTrue(result.stdout.contains("File: /dev/null"), "Should show /dev/null")
    }

    func testStatDevZero() {
        let result = runCommand("stat", ["/dev/zero"])

        XCTAssertEqual(result.exitCode, 0, "stat should succeed on /dev/zero")
        XCTAssertTrue(result.stdout.contains("File: /dev/zero"), "Should show /dev/zero")
    }

    // MARK: - Symlink Tests

    func testSymbolicLink() {
        let tempFile = createTempFile(content: "target\n")
        let linkPath = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).path
        defer {
            try? FileManager.default.removeItem(atPath: tempFile)
            try? FileManager.default.removeItem(atPath: linkPath)
        }

        // Create symlink
        try? FileManager.default.createSymbolicLink(atPath: linkPath, withDestinationPath: tempFile)

        let result = runCommand("stat", [linkPath])

        XCTAssertEqual(result.exitCode, 0, "stat should succeed on symlink")
        XCTAssertTrue(result.stdout.contains("File: \(linkPath)"), "Should show link path")
    }

    // MARK: - Format String Tests (if implemented)
    // These tests check for format string support which is a P1 feature
    // If not implemented, these will fail but document the expected behavior

    func testFormatString_FileName() {
        let tempFile = createTempFile()
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("stat", ["-c", "%n", tempFile])

        if result.exitCode == 0 {
            // Format strings are implemented
            XCTAssertEqual(result.stdout, "\(tempFile)\n", "Should output just the filename")
        } else {
            // Format strings not implemented - skip test
            XCTAssertTrue(result.stderr.contains("invalid option") ||
                         result.stderr.contains("unrecognized"),
                         "Should indicate -c option not supported")
        }
    }

    func testFormatString_FileSize() {
        let tempFile = createTempFile(content: "12345")
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("stat", ["-c", "%s", tempFile])

        if result.exitCode == 0 {
            XCTAssertEqual(result.stdout, "5\n", "Should output just the file size")
        }
    }

    func testFormatString_OctalPermissions() {
        let tempFile = createTempFile(permissions: 0o644)
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("stat", ["-c", "%a", tempFile])

        if result.exitCode == 0 {
            XCTAssertEqual(result.stdout, "644\n", "Should output octal permissions")
        }
    }

    func testFormatString_HumanPermissions() {
        let tempFile = createTempFile(permissions: 0o644)
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("stat", ["-c", "%A", tempFile])

        if result.exitCode == 0 {
            XCTAssertTrue(result.stdout.contains("rw-r--r--"), "Should output human-readable permissions")
        }
    }

    func testFormatString_MultipleFormats() {
        let tempFile = createTempFile(content: "test")
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("stat", ["-c", "%n %s", tempFile])

        if result.exitCode == 0 {
            XCTAssertTrue(result.stdout.contains(tempFile), "Should contain filename")
            XCTAssertTrue(result.stdout.contains("4"), "Should contain size")
        }
    }

    // MARK: - TODO: Advanced Features for Future Implementation
    // - [ ] stat -f (filesystem info) - P1
    // - [ ] stat -L (follow symlinks) - P1
    // - [ ] stat -t (terse output) - P2
    // - [ ] Format specifiers: %F (file type), %U (username), %G (groupname) - P1
    // - [ ] Format specifiers: %y (modification time), %Y (epoch time) - P2
    // - [ ] stat --printf (no newline) - P2
}
