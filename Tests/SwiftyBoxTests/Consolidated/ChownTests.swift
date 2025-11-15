import XCTest
@testable import swiftybox
import Foundation

/// Tests for the `chown` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: GNU coreutils chown
/// - BusyBox: Basic user:group changing with -R
/// - GNU: Full support for user, group, numeric IDs, recursive, symlink handling
/// - Target scope: P0 (basic ownership change) + P1 (recursive, common options)
///
/// NOTE: Many chown operations require root/sudo privileges. Tests that require
/// elevated privileges will be skipped or will test error handling instead.
///
/// Usage patterns:
///   chown user file              # Change owner to user
///   chown user:group file        # Change owner and group
///   chown :group file            # Change only group (same as chgrp)
///   chown 1000:1000 file         # Change using numeric UID:GID
///   chown -R user:group dir/     # Recursive change
///
/// Resources:
/// - GNU: https://www.gnu.org/software/coreutils/manual/html_node/chown-invocation.html
/// - POSIX: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/chown.html
/// - BusyBox: https://git.busybox.net/busybox/tree/coreutils/chown.c

final class ChownTests: XCTestCase {

    // MARK: - Test Helpers

    private func createTempFile(content: String = "test\n") -> String {
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent(UUID().uuidString)

        try? content.write(to: tempFile, atomically: true, encoding: .utf8)

        return tempFile.path
    }

    private func createTempDirectory() -> String {
        let tempDir = FileManager.default.temporaryDirectory
        let tempSubdir = tempDir.appendingPathComponent(UUID().uuidString)

        try? FileManager.default.createDirectory(at: tempSubdir, withIntermediateDirectories: false)

        return tempSubdir.path
    }

    private func getFileOwner(_ path: String) -> (uid: uid_t, gid: gid_t)? {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: path) else {
            return nil
        }
        let uid = attrs[.ownerAccountID] as? uid_t ?? 0
        let gid = attrs[.groupOwnerAccountID] as? gid_t ?? 0
        return (uid, gid)
    }

    private func getCurrentUID() -> uid_t {
        return getuid()
    }

    private func getCurrentGID() -> gid_t {
        return getgid()
    }

    private func getCurrentUsername() -> String {
        return String(cString: getpwuid(getuid())!.pointee.pw_name)
    }

    private func getCurrentGroupname() -> String {
        return String(cString: getgrgid(getgid())!.pointee.gr_name)
    }

    private func isRoot() -> Bool {
        return getuid() == 0
    }

    override func tearDown() {
        super.tearDown()
        // Cleanup is handled by the OS for temp files
    }

    // MARK: - Basic Functionality Tests

    func testChownBasicSyntax_CurrentUser() {
        let tempFile = createTempFile()
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let currentUser = getCurrentUsername()
        let result = runCommand("chown", [currentUser, tempFile])

        // Should succeed since we're changing to ourselves
        XCTAssertEqual(result.exitCode, 0, "chown to current user should succeed")
        XCTAssertEqual(result.stderr, "", "Should not produce errors")

        let owner = getFileOwner(tempFile)
        XCTAssertEqual(owner?.uid, getCurrentUID(), "File should be owned by current user")
    }

    func testChownWithGroup_CurrentUserAndGroup() {
        let tempFile = createTempFile()
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let currentUser = getCurrentUsername()
        let currentGroup = getCurrentGroupname()
        let result = runCommand("chown", ["\(currentUser):\(currentGroup)", tempFile])

        XCTAssertEqual(result.exitCode, 0, "chown user:group to current user:group should succeed")

        let owner = getFileOwner(tempFile)
        XCTAssertEqual(owner?.uid, getCurrentUID(), "File should be owned by current user")
        XCTAssertEqual(owner?.gid, getCurrentGID(), "File should be in current group")
    }

    func testChownNumericUID() {
        let tempFile = createTempFile()
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let currentUID = getCurrentUID()
        let result = runCommand("chown", ["\(currentUID)", tempFile])

        XCTAssertEqual(result.exitCode, 0, "chown with numeric UID should succeed")

        let owner = getFileOwner(tempFile)
        XCTAssertEqual(owner?.uid, currentUID, "File should have specified UID")
    }

    func testChownNumericUIDAndGID() {
        let tempFile = createTempFile()
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let currentUID = getCurrentUID()
        let currentGID = getCurrentGID()
        let result = runCommand("chown", ["\(currentUID):\(currentGID)", tempFile])

        XCTAssertEqual(result.exitCode, 0, "chown with numeric UID:GID should succeed")

        let owner = getFileOwner(tempFile)
        XCTAssertEqual(owner?.uid, currentUID, "File should have specified UID")
        XCTAssertEqual(owner?.gid, currentGID, "File should have specified GID")
    }

    func testChownMultipleFiles() {
        let file1 = createTempFile()
        let file2 = createTempFile()
        defer {
            try? FileManager.default.removeItem(atPath: file1)
            try? FileManager.default.removeItem(atPath: file2)
        }

        let currentUser = getCurrentUsername()
        let result = runCommand("chown", [currentUser, file1, file2])

        XCTAssertEqual(result.exitCode, 0, "chown should succeed on multiple files")

        let owner1 = getFileOwner(file1)
        let owner2 = getFileOwner(file2)
        XCTAssertEqual(owner1?.uid, getCurrentUID(), "First file should be owned by current user")
        XCTAssertEqual(owner2?.uid, getCurrentUID(), "Second file should be owned by current user")
    }

    func testChownDirectory() {
        let tempDir = createTempDirectory()
        defer { try? FileManager.default.removeItem(atPath: tempDir) }

        let currentUser = getCurrentUsername()
        let result = runCommand("chown", [currentUser, tempDir])

        XCTAssertEqual(result.exitCode, 0, "chown should succeed on directory")

        let owner = getFileOwner(tempDir)
        XCTAssertEqual(owner?.uid, getCurrentUID(), "Directory should be owned by current user")
    }

    // MARK: - Group-Only Change Tests (using :group syntax)

    func testChownGroupOnly() {
        let tempFile = createTempFile()
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let currentGroup = getCurrentGroupname()
        let result = runCommand("chown", [":\(currentGroup)", tempFile])

        if result.exitCode == 0 {
            // :group syntax is supported
            let owner = getFileOwner(tempFile)
            XCTAssertEqual(owner?.gid, getCurrentGID(), "File group should be changed")
        } else {
            // :group syntax might not be implemented
            XCTAssertTrue(result.stderr.contains("invalid") ||
                         result.stderr.contains("not supported"),
                         "Should indicate :group syntax issue")
        }
    }

    // MARK: - Recursive Tests

    func testChownRecursive() {
        let tempDir = createTempDirectory()
        let subFile = (tempDir as NSString).appendingPathComponent("file.txt")
        try? "test".write(toFile: subFile, atomically: true, encoding: .utf8)

        defer { try? FileManager.default.removeItem(atPath: tempDir) }

        let currentUser = getCurrentUsername()
        let result = runCommand("chown", ["-R", currentUser, tempDir])

        XCTAssertEqual(result.exitCode, 0, "chown -R should succeed")

        let dirOwner = getFileOwner(tempDir)
        let fileOwner = getFileOwner(subFile)

        XCTAssertEqual(dirOwner?.uid, getCurrentUID(), "Directory should be owned by current user")
        XCTAssertEqual(fileOwner?.uid, getCurrentUID(), "File in directory should be owned by current user")
    }

    func testChownRecursive_MultipleSubdirectories() {
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

        let currentUser = getCurrentUsername()
        let currentGroup = getCurrentGroupname()
        let result = runCommand("chown", ["-R", "\(currentUser):\(currentGroup)", tempDir])

        XCTAssertEqual(result.exitCode, 0, "chown -R should succeed on nested directories")

        XCTAssertEqual(getFileOwner(tempDir)?.uid, getCurrentUID(), "Root should be owned by user")
        XCTAssertEqual(getFileOwner(subdir1)?.uid, getCurrentUID(), "Subdir1 should be owned by user")
        XCTAssertEqual(getFileOwner(subdir2)?.uid, getCurrentUID(), "Subdir2 should be owned by user")
        XCTAssertEqual(getFileOwner(file1)?.uid, getCurrentUID(), "File1 should be owned by user")
        XCTAssertEqual(getFileOwner(file2)?.uid, getCurrentUID(), "File2 should be owned by user")
    }

    // MARK: - Error Handling Tests

    func testChownMissingOperand() {
        let result = runCommand("chown", [])

        XCTAssertNotEqual(result.exitCode, 0, "chown should fail with no arguments")
        XCTAssertTrue(result.stderr.contains("missing operand") || result.stderr.contains("operand"),
                     "Error should indicate missing operand")
    }

    func testChownMissingFile() {
        let result = runCommand("chown", ["root"])

        XCTAssertNotEqual(result.exitCode, 0, "chown should fail with only owner")
        XCTAssertTrue(result.stderr.contains("missing operand") || result.stderr.contains("operand"),
                     "Error should indicate missing file operand")
    }

    func testChownNonexistentFile() {
        let nonexistent = "/tmp/nonexistent-\(UUID().uuidString)"
        let currentUser = getCurrentUsername()

        let result = runCommand("chown", [currentUser, nonexistent])

        XCTAssertNotEqual(result.exitCode, 0, "chown should fail on nonexistent file")
        XCTAssertTrue(result.stderr.contains("cannot access") || result.stderr.contains("No such file"),
                     "Error should indicate file not found")
    }

    func testChownInvalidUser() {
        let tempFile = createTempFile()
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let invalidUser = "nonexistent_user_\(UUID().uuidString)"
        let result = runCommand("chown", [invalidUser, tempFile])

        XCTAssertNotEqual(result.exitCode, 0, "chown should fail with invalid user")
        XCTAssertTrue(result.stderr.contains("invalid user") || result.stderr.contains("invalid"),
                     "Error should indicate invalid user")
    }

    func testChownInvalidGroup() {
        let tempFile = createTempFile()
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let currentUser = getCurrentUsername()
        let invalidGroup = "nonexistent_group_\(UUID().uuidString)"
        let result = runCommand("chown", ["\(currentUser):\(invalidGroup)", tempFile])

        XCTAssertNotEqual(result.exitCode, 0, "chown should fail with invalid group")
        XCTAssertTrue(result.stderr.contains("invalid group") || result.stderr.contains("invalid"),
                     "Error should indicate invalid group")
    }

    // MARK: - Permission Tests (Most will fail without root)

    func testChownToOtherUser_RequiresRoot() {
        // This test documents behavior when trying to chown to another user
        // It will fail unless running as root
        let tempFile = createTempFile()
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("chown", ["root", tempFile])

        if isRoot() {
            XCTAssertEqual(result.exitCode, 0, "Root should be able to chown to any user")
        } else {
            XCTAssertNotEqual(result.exitCode, 0, "Non-root cannot chown to another user")
            XCTAssertTrue(result.stderr.contains("Operation not permitted") ||
                         result.stderr.contains("Permission denied") ||
                         result.stderr.contains("invalid user"),
                         "Should indicate permission issue or invalid user")
        }
    }

    // MARK: - Verbose Mode Test

    func testChownVerbose() {
        let tempFile = createTempFile()
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let currentUser = getCurrentUsername()
        let result = runCommand("chown", ["-v", currentUser, tempFile])

        if result.exitCode == 0 {
            XCTAssertTrue(result.stdout.contains("ownership") || result.stdout.contains(tempFile),
                         "Verbose mode should produce output")
        }
    }

    // MARK: - Dot Separator Test (alternative to colon)

    func testChownDotSeparator() {
        let tempFile = createTempFile()
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let currentUser = getCurrentUsername()
        let currentGroup = getCurrentGroupname()
        let result = runCommand("chown", ["\(currentUser).\(currentGroup)", tempFile])

        if result.exitCode == 0 {
            // Dot separator is supported
            let owner = getFileOwner(tempFile)
            XCTAssertEqual(owner?.uid, getCurrentUID(), "User should be set")
            XCTAssertEqual(owner?.gid, getCurrentGID(), "Group should be set")
        } else {
            // Dot separator might not be implemented
            XCTAssertTrue(result.stderr.contains("invalid") ||
                         result.stderr.contains("not supported"),
                         "Should indicate dot separator issue")
        }
    }

    // MARK: - TODO: Advanced Features for Future Implementation
    // - [ ] chown --reference=FILE (copy ownership from reference file) - P2
    // - [ ] chown -h (don't dereference symlinks) - P1
    // - [ ] chown --from=CURRENT_OWNER (change only if current owner matches) - P2
    // - [ ] chown --preserve-root (fail to operate recursively on /) - P2
    // - [ ] chown -c (report only when change is made) - P2
}
