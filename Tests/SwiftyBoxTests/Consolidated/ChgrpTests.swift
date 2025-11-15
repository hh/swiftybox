import XCTest
@testable import swiftybox
import Foundation

/// Tests for the `chgrp` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: GNU coreutils chgrp
/// - Essentially `chown :group`, specialized for group changes only
/// - Target scope: P0 (basic group change) + P1 (recursive)
///
/// Common usage patterns:
///   chgrp group file          # Change group
///   chgrp -R group dir/       # Recursive change
///   chgrp 1000 file           # Change using numeric GID
///
/// Resources:
/// - GNU: https://www.gnu.org/software/coreutils/manual/html_node/chgrp-invocation.html
/// - POSIX: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/chgrp.html

final class ChgrpTests: XCTestCase {

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

    private func getFileGroup(_ path: String) -> gid_t? {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: path) else { return nil }
        return attrs[.groupOwnerAccountID] as? gid_t
    }

    private func getCurrentGID() -> gid_t {
        return getgid()
    }

    private func getCurrentGroupname() -> String {
        return String(cString: getgrgid(getgid())!.pointee.gr_name)
    }

    // MARK: - Basic Tests

    func testChgrpBasic() {
        let tempFile = createTempFile()
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let currentGroup = getCurrentGroupname()
        let result = runCommand("chgrp", [currentGroup, tempFile])

        XCTAssertEqual(result.exitCode, 0, "chgrp should succeed")
        XCTAssertEqual(getFileGroup(tempFile), getCurrentGID(), "Group should be changed")
    }

    func testChgrpNumericGID() {
        let tempFile = createTempFile()
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let currentGID = getCurrentGID()
        let result = runCommand("chgrp", ["\(currentGID)", tempFile])

        XCTAssertEqual(result.exitCode, 0, "chgrp with numeric GID should succeed")
        XCTAssertEqual(getFileGroup(tempFile), currentGID, "Group should be set")
    }

    func testChgrpMultipleFiles() {
        let file1 = createTempFile()
        let file2 = createTempFile()
        defer {
            try? FileManager.default.removeItem(atPath: file1)
            try? FileManager.default.removeItem(atPath: file2)
        }

        let currentGroup = getCurrentGroupname()
        let result = runCommand("chgrp", [currentGroup, file1, file2])

        XCTAssertEqual(result.exitCode, 0, "chgrp should succeed on multiple files")
        XCTAssertEqual(getFileGroup(file1), getCurrentGID())
        XCTAssertEqual(getFileGroup(file2), getCurrentGID())
    }

    func testChgrpDirectory() {
        let tempDir = createTempDirectory()
        defer { try? FileManager.default.removeItem(atPath: tempDir) }

        let currentGroup = getCurrentGroupname()
        let result = runCommand("chgrp", [currentGroup, tempDir])

        XCTAssertEqual(result.exitCode, 0, "chgrp should succeed on directory")
        XCTAssertEqual(getFileGroup(tempDir), getCurrentGID())
    }

    func testChgrpRecursive() {
        let tempDir = createTempDirectory()
        let subFile = (tempDir as NSString).appendingPathComponent("file.txt")
        try? "test".write(toFile: subFile, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(atPath: tempDir) }

        let currentGroup = getCurrentGroupname()
        let result = runCommand("chgrp", ["-R", currentGroup, tempDir])

        XCTAssertEqual(result.exitCode, 0, "chgrp -R should succeed")
        XCTAssertEqual(getFileGroup(tempDir), getCurrentGID())
        XCTAssertEqual(getFileGroup(subFile), getCurrentGID())
    }

    // MARK: - Error Tests

    func testChgrpMissingOperand() {
        let result = runCommand("chgrp", [])
        XCTAssertNotEqual(result.exitCode, 0, "chgrp should fail with no arguments")
        XCTAssertTrue(result.stderr.contains("missing operand") || result.stderr.contains("operand"))
    }

    func testChgrpMissingFile() {
        let result = runCommand("chgrp", ["root"])
        XCTAssertNotEqual(result.exitCode, 0, "chgrp should fail with only group")
        XCTAssertTrue(result.stderr.contains("missing operand") || result.stderr.contains("operand"))
    }

    func testChgrpNonexistentFile() {
        let nonexistent = "/tmp/nonexistent-\(UUID().uuidString)"
        let currentGroup = getCurrentGroupname()
        let result = runCommand("chgrp", [currentGroup, nonexistent])

        XCTAssertNotEqual(result.exitCode, 0, "chgrp should fail on nonexistent file")
        XCTAssertTrue(result.stderr.contains("cannot access") || result.stderr.contains("No such file"))
    }

    func testChgrpInvalidGroup() {
        let tempFile = createTempFile()
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let invalidGroup = "nonexistent_group_\(UUID().uuidString)"
        let result = runCommand("chgrp", [invalidGroup, tempFile])

        XCTAssertNotEqual(result.exitCode, 0, "chgrp should fail with invalid group")
        XCTAssertTrue(result.stderr.contains("invalid group") || result.stderr.contains("invalid"))
    }

    // MARK: - TODO: Advanced Features
    // - [ ] chgrp --reference=FILE - P2
    // - [ ] chgrp -h (no dereference symlinks) - P1
    // - [ ] chgrp -c (report only changes) - P2
    // - [ ] chgrp -v (verbose) - P2
}
