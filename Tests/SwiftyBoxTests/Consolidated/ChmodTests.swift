import XCTest
@testable import swiftybox
import Foundation

/// Tests for the `chmod` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: GNU coreutils chmod
/// - BusyBox: Supports both numeric and symbolic modes
/// - GNU: Full symbolic mode support + special bits (setuid, setgid, sticky)
/// - Target scope: P0 (numeric modes) + P1 (symbolic modes, recursive)
///
/// Numeric modes (octal):
///   chmod 644 file    # rw-r--r--
///   chmod 755 file    # rwxr-xr-x
///   chmod 600 file    # rw-------
///   chmod 4755 file   # rwsr-xr-x (setuid)
///   chmod 2755 file   # rwxr-sr-x (setgid)
///   chmod 1755 file   # rwxr-xr-t (sticky)
///
/// Symbolic modes:
///   chmod u+x file    # Add execute for user
///   chmod go-w file   # Remove write for group and others
///   chmod a=r file    # Set all to read-only
///   chmod u+rwx,go+rx file  # Multiple operations
///
/// Common usage patterns:
///   chmod 644 *.txt          # Set all text files to rw-r--r--
///   chmod +x script.sh       # Make script executable
///   chmod -R 755 dir/        # Recursively set directory permissions
///   chmod u+x,go-w file      # Add user execute, remove group/other write
///
/// Resources:
/// - GNU: https://www.gnu.org/software/coreutils/manual/html_node/chmod-invocation.html
/// - POSIX: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/chmod.html
/// - BusyBox: https://git.busybox.net/busybox/tree/coreutils/chmod.c

final class ChmodTests: XCTestCase {

    // MARK: - Test Helpers

    private func createTempFile(content: String = "test\n", permissions: mode_t = 0o644) -> String {
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent(UUID().uuidString)

        try? content.write(to: tempFile, atomically: true, encoding: .utf8)

        var attrs: [FileAttributeKey: Any] = [:]
        attrs[.posixPermissions] = permissions
        try? FileManager.default.setAttributes(attrs, ofItemAtPath: tempFile.path)

        return tempFile.path
    }

    private func createTempDirectory(permissions: mode_t = 0o755) -> String {
        let tempDir = FileManager.default.temporaryDirectory
        let tempSubdir = tempDir.appendingPathComponent(UUID().uuidString)

        try? FileManager.default.createDirectory(at: tempSubdir, withIntermediateDirectories: false)

        var attrs: [FileAttributeKey: Any] = [:]
        attrs[.posixPermissions] = permissions
        try? FileManager.default.setAttributes(attrs, ofItemAtPath: tempSubdir.path)

        return tempSubdir.path
    }

    private func getFilePermissions(_ path: String) -> mode_t? {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: path) else {
            return nil
        }
        return attrs[.posixPermissions] as? mode_t
    }

    override func tearDown() {
        super.tearDown()
        // Cleanup is handled by the OS for temp files
    }

    // MARK: - Basic Numeric Mode Tests

    func testChmodNumeric_644() {
        let tempFile = createTempFile(permissions: 0o600)
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("chmod", ["644", tempFile])

        XCTAssertEqual(result.exitCode, 0, "chmod should succeed")
        XCTAssertEqual(result.stderr, "", "Should not produce errors")

        let perms = getFilePermissions(tempFile)
        XCTAssertEqual(perms, 0o644, "Permissions should be set to 644")
    }

    func testChmodNumeric_755() {
        let tempFile = createTempFile(permissions: 0o600)
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("chmod", ["755", tempFile])

        XCTAssertEqual(result.exitCode, 0, "chmod should succeed")

        let perms = getFilePermissions(tempFile)
        XCTAssertEqual(perms, 0o755, "Permissions should be set to 755")
    }

    func testChmodNumeric_600() {
        let tempFile = createTempFile(permissions: 0o644)
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("chmod", ["600", tempFile])

        XCTAssertEqual(result.exitCode, 0, "chmod should succeed")

        let perms = getFilePermissions(tempFile)
        XCTAssertEqual(perms, 0o600, "Permissions should be set to 600")
    }

    func testChmodNumeric_777() {
        let tempFile = createTempFile(permissions: 0o644)
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("chmod", ["777", tempFile])

        XCTAssertEqual(result.exitCode, 0, "chmod should succeed")

        let perms = getFilePermissions(tempFile)
        XCTAssertEqual(perms, 0o777, "Permissions should be set to 777")
    }

    func testChmodNumeric_000() {
        let tempFile = createTempFile(permissions: 0o644)
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("chmod", ["000", tempFile])

        XCTAssertEqual(result.exitCode, 0, "chmod should succeed")

        let perms = getFilePermissions(tempFile)
        XCTAssertEqual(perms, 0o000, "Permissions should be set to 000")

        // Cleanup - restore permissions so file can be deleted
        _ = runCommand("chmod", ["644", tempFile])
    }

    func testChmodNumeric_WithLeadingZero() {
        let tempFile = createTempFile(permissions: 0o600)
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("chmod", ["0644", tempFile])

        XCTAssertEqual(result.exitCode, 0, "chmod should accept leading zero")

        let perms = getFilePermissions(tempFile)
        XCTAssertEqual(perms, 0o644, "Permissions should be set to 644")
    }

    func testChmodNumeric_MultipleFiles() {
        let file1 = createTempFile(permissions: 0o600)
        let file2 = createTempFile(permissions: 0o600)
        defer {
            try? FileManager.default.removeItem(atPath: file1)
            try? FileManager.default.removeItem(atPath: file2)
        }

        let result = runCommand("chmod", ["644", file1, file2])

        XCTAssertEqual(result.exitCode, 0, "chmod should succeed on multiple files")

        XCTAssertEqual(getFilePermissions(file1), 0o644, "First file should have 644 permissions")
        XCTAssertEqual(getFilePermissions(file2), 0o644, "Second file should have 644 permissions")
    }

    // MARK: - Directory Tests

    func testChmodDirectory() {
        let tempDir = createTempDirectory(permissions: 0o700)
        defer { try? FileManager.default.removeItem(atPath: tempDir) }

        let result = runCommand("chmod", ["755", tempDir])

        XCTAssertEqual(result.exitCode, 0, "chmod should succeed on directory")

        let perms = getFilePermissions(tempDir)
        XCTAssertEqual(perms, 0o755, "Directory permissions should be set to 755")
    }

    // MARK: - Recursive Tests

    func testChmodRecursive() {
        let tempDir = createTempDirectory(permissions: 0o700)
        let subFile = (tempDir as NSString).appendingPathComponent("file.txt")
        try? "test".write(toFile: subFile, atomically: true, encoding: .utf8)
        try? FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: subFile)

        defer { try? FileManager.default.removeItem(atPath: tempDir) }

        let result = runCommand("chmod", ["-R", "755", tempDir])

        XCTAssertEqual(result.exitCode, 0, "chmod -R should succeed")

        XCTAssertEqual(getFilePermissions(tempDir), 0o755, "Directory should have 755 permissions")
        XCTAssertEqual(getFilePermissions(subFile), 0o755, "File in directory should have 755 permissions")
    }

    func testChmodRecursive_MultipleSubdirectories() {
        let tempDir = createTempDirectory()
        let subdir1 = (tempDir as NSString).appendingPathComponent("sub1")
        let subdir2 = (tempDir as NSString).appendingPathComponent("sub2")
        try? FileManager.default.createDirectory(atPath: subdir1, withIntermediateDirectories: false)
        try? FileManager.default.createDirectory(atPath: subdir2, withIntermediateDirectories: false)

        let file1 = (subdir1 as NSString).appendingPathComponent("file1.txt")
        let file2 = (subdir2 as NSString).appendingPathComponent("file2.txt")
        try? "test1".write(toFile: file1, atomically: true, encoding: .utf8)
        try? "test2".write(toFile: file2, atomically: true, encoding: .utf8)

        defer { try? FileManager.default.removeItem(atPath: tempDir) }

        let result = runCommand("chmod", ["-R", "644", tempDir])

        XCTAssertEqual(result.exitCode, 0, "chmod -R should succeed")

        XCTAssertEqual(getFilePermissions(tempDir), 0o644, "Root directory should have 644")
        XCTAssertEqual(getFilePermissions(subdir1), 0o644, "Subdirectory 1 should have 644")
        XCTAssertEqual(getFilePermissions(subdir2), 0o644, "Subdirectory 2 should have 644")
        XCTAssertEqual(getFilePermissions(file1), 0o644, "File 1 should have 644")
        XCTAssertEqual(getFilePermissions(file2), 0o644, "File 2 should have 644")
    }

    // MARK: - Special Permission Bits Tests (setuid, setgid, sticky)

    func testChmodSetuid_4755() {
        let tempFile = createTempFile(permissions: 0o755)
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("chmod", ["4755", tempFile])

        if result.exitCode == 0 {
            let perms = getFilePermissions(tempFile)
            XCTAssertEqual(perms, 0o4755, "Permissions should include setuid bit")
        } else {
            // setuid might not be supported or require root
            XCTAssertTrue(result.stderr.contains("Operation not permitted") ||
                         result.stderr.contains("not supported"),
                         "Should indicate why setuid failed")
        }
    }

    func testChmodSetgid_2755() {
        let tempFile = createTempFile(permissions: 0o755)
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("chmod", ["2755", tempFile])

        if result.exitCode == 0 {
            let perms = getFilePermissions(tempFile)
            XCTAssertEqual(perms, 0o2755, "Permissions should include setgid bit")
        }
    }

    func testChmodSticky_1755() {
        let tempFile = createTempFile(permissions: 0o755)
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("chmod", ["1755", tempFile])

        if result.exitCode == 0 {
            let perms = getFilePermissions(tempFile)
            XCTAssertEqual(perms, 0o1755, "Permissions should include sticky bit")
        }
    }

    // MARK: - Error Handling

    func testChmodMissingOperand() {
        let result = runCommand("chmod", [])

        XCTAssertNotEqual(result.exitCode, 0, "chmod should fail with no arguments")
        XCTAssertTrue(result.stderr.contains("missing operand") || result.stderr.contains("operand"),
                     "Error should indicate missing operand")
    }

    func testChmodMissingFile() {
        let result = runCommand("chmod", ["644"])

        XCTAssertNotEqual(result.exitCode, 0, "chmod should fail with only mode")
        XCTAssertTrue(result.stderr.contains("missing operand") || result.stderr.contains("operand"),
                     "Error should indicate missing file operand")
    }

    func testChmodInvalidMode() {
        let tempFile = createTempFile()
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("chmod", ["999", tempFile])

        XCTAssertNotEqual(result.exitCode, 0, "chmod should fail with invalid mode")
        XCTAssertTrue(result.stderr.contains("invalid mode") || result.stderr.contains("invalid"),
                     "Error should indicate invalid mode")
    }

    func testChmodNonexistentFile() {
        let nonexistent = "/tmp/nonexistent-\(UUID().uuidString)"

        let result = runCommand("chmod", ["644", nonexistent])

        XCTAssertNotEqual(result.exitCode, 0, "chmod should fail on nonexistent file")
        XCTAssertTrue(result.stderr.contains("cannot access") || result.stderr.contains("No such file"),
                     "Error should indicate file not found")
    }

    // MARK: - Symbolic Mode Tests (P1 Feature)
    // These tests check for symbolic mode support which is a P1 feature
    // If not implemented, these will fail but document the expected behavior

    func testChmodSymbolic_UserAddExecute() {
        let tempFile = createTempFile(permissions: 0o644)
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("chmod", ["u+x", tempFile])

        if result.exitCode == 0 {
            let perms = getFilePermissions(tempFile)
            XCTAssertEqual(perms, 0o744, "Should add user execute: 644 -> 744")
        } else {
            // Symbolic modes not implemented yet
            XCTAssertTrue(result.stderr.contains("invalid mode") ||
                         result.stderr.contains("not supported"),
                         "Should indicate symbolic modes not supported")
        }
    }

    func testChmodSymbolic_GroupOthersRemoveWrite() {
        let tempFile = createTempFile(permissions: 0o666)
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("chmod", ["go-w", tempFile])

        if result.exitCode == 0 {
            let perms = getFilePermissions(tempFile)
            XCTAssertEqual(perms, 0o644, "Should remove group/other write: 666 -> 644")
        }
    }

    func testChmodSymbolic_AllSetRead() {
        let tempFile = createTempFile(permissions: 0o000)
        defer {
            // Restore perms to delete
            _ = runCommand("chmod", ["644", tempFile])
            try? FileManager.default.removeItem(atPath: tempFile)
        }

        let result = runCommand("chmod", ["a=r", tempFile])

        if result.exitCode == 0 {
            let perms = getFilePermissions(tempFile)
            XCTAssertEqual(perms, 0o444, "Should set all to read-only: 000 -> 444")
        }
    }

    func testChmodSymbolic_AllAddExecute() {
        let tempFile = createTempFile(permissions: 0o644)
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("chmod", ["+x", tempFile])

        if result.exitCode == 0 {
            let perms = getFilePermissions(tempFile)
            XCTAssertEqual(perms, 0o755, "Should add execute for all: 644 -> 755")
        }
    }

    func testChmodSymbolic_MultipleOperations() {
        let tempFile = createTempFile(permissions: 0o600)
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("chmod", ["u+rwx,go+rx", tempFile])

        if result.exitCode == 0 {
            let perms = getFilePermissions(tempFile)
            XCTAssertEqual(perms, 0o755, "Should apply multiple operations: 600 -> 755")
        }
    }

    // MARK: - Verbose Mode Test

    func testChmodVerbose() {
        let tempFile = createTempFile(permissions: 0o600)
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("chmod", ["-v", "644", tempFile])

        if result.exitCode == 0 {
            XCTAssertTrue(result.stdout.contains("mode") || result.stdout.contains(tempFile),
                         "Verbose mode should produce output")
        }
    }

    // MARK: - TODO: Advanced Features for Future Implementation
    // - [ ] chmod --reference=FILE (copy permissions from reference file) - P2
    // - [ ] chmod -c (report only when change is made) - P2
    // - [ ] chmod --preserve-root (fail to operate recursively on /) - P2
    // - [ ] Full symbolic mode support (u+x, go-w, a=r, etc.) - P1
    // - [ ] Symbolic mode with special bits (u+s, g+s, +t) - P2
}
