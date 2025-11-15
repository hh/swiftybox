// RealpathTests.swift
// Tests for the `realpath` command - print resolved absolute path

import XCTest
@testable import swiftybox

/// Tests for the `realpath` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: GNU coreutils realpath
/// - Resolves symbolic links and canonicalizes paths
/// - Options: -e (require exists, default), -m (allow missing)
/// - Returns absolute path with symlinks resolved
///
/// Resources:
/// - GNU: https://www.gnu.org/software/coreutils/manual/html_node/realpath-invocation.html

final class RealpathTests: XCTestCase {

    // MARK: - Helper Functions

    func createTempFile() -> String {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        FileManager.default.createFile(atPath: tempFile.path, contents: Data())
        return tempFile.path
    }

    func createTempDir() -> String {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        return tempDir.path
    }

    func cleanup(_ paths: String...) {
        for path in paths {
            try? FileManager.default.removeItem(atPath: path)
        }
    }

    // MARK: - Basic Functionality

    func testRealFile() {
        let file = createTempFile()
        defer { cleanup(file) }

        let result = RealpathCommand.main(["realpath", file])
        XCTAssertEqual(result, 0)
    }

    func testRealDirectory() {
        let dir = createTempDir()
        defer { cleanup(dir) }

        let result = RealpathCommand.main(["realpath", dir])
        XCTAssertEqual(result, 0)
    }

    func testCurrentDirectory() {
        let result = RealpathCommand.main(["realpath", "."])
        XCTAssertEqual(result, 0)
    }

    func testParentDirectory() {
        let result = RealpathCommand.main(["realpath", ".."])
        XCTAssertEqual(result, 0)
    }

    func testRootDirectory() {
        let result = RealpathCommand.main(["realpath", "/"])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Symlinks

    func testSymlinkToFile() {
        let file = createTempFile()
        let link = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString).path
        try? FileManager.default.createSymbolicLink(atPath: link, withDestinationPath: file)
        defer { cleanup(file, link) }

        let result = RealpathCommand.main(["realpath", link])
        XCTAssertEqual(result, 0)
    }

    func testSymlinkToDirectory() {
        let dir = createTempDir()
        let link = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString).path
        try? FileManager.default.createSymbolicLink(atPath: link, withDestinationPath: dir)
        defer { cleanup(dir, link) }

        let result = RealpathCommand.main(["realpath", link])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Path Resolution

    func testDotSlashPrefix() {
        let file = createTempFile()
        defer { cleanup(file) }

        // Create a relative path with ./
        let basename = URL(fileURLWithPath: file).lastPathComponent
        let oldDir = FileManager.default.currentDirectoryPath
        FileManager.default.changeCurrentDirectoryPath(URL(fileURLWithPath: file).deletingLastPathComponent().path)
        defer { FileManager.default.changeCurrentDirectoryPath(oldDir) }

        let result = RealpathCommand.main(["realpath", "./\(basename)"])
        XCTAssertEqual(result, 0)
    }

    func testRelativePath() {
        let dir = createTempDir()
        let file = dir + "/test.txt"
        FileManager.default.createFile(atPath: file, contents: Data())
        defer { cleanup(dir) }

        let basename = URL(fileURLWithPath: dir).lastPathComponent
        let oldDir = FileManager.default.currentDirectoryPath
        FileManager.default.changeCurrentDirectoryPath(URL(fileURLWithPath: dir).deletingLastPathComponent().path)
        defer { FileManager.default.changeCurrentDirectoryPath(oldDir) }

        let result = RealpathCommand.main(["realpath", "\(basename)/test.txt"])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Non-existent Paths (default -e behavior)

    func testNonExistentFileDefaultMode() {
        let result = RealpathCommand.main(["realpath", "/nonexistent/file"])
        XCTAssertNotEqual(result, 0)  // Should fail in default mode
    }

    func testNonExistentFileExplicitE() {
        let result = RealpathCommand.main(["realpath", "-e", "/nonexistent/file"])
        XCTAssertNotEqual(result, 0)  // Should fail with -e
    }

    // MARK: - Allow Missing (-m)

    func testNonExistentFileWithM() {
        let result = RealpathCommand.main(["realpath", "-m", "/nonexistent/file"])
        XCTAssertEqual(result, 0)  // Should succeed with -m
    }

    func testNonExistentPathWithM() {
        let result = RealpathCommand.main(["realpath", "-m", "/some/path/that/does/not/exist"])
        XCTAssertEqual(result, 0)
    }

    func testRelativeNonExistentWithM() {
        let result = RealpathCommand.main(["realpath", "-m", "nonexistent"])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Multiple Files

    func testMultipleFiles() {
        let file1 = createTempFile()
        let file2 = createTempFile()
        defer { cleanup(file1, file2) }

        let result = RealpathCommand.main(["realpath", file1, file2])
        XCTAssertEqual(result, 0)
    }

    func testMultipleFilesOneMissing() {
        let file1 = createTempFile()
        defer { cleanup(file1) }

        let result = RealpathCommand.main(["realpath", file1, "/nonexistent"])
        XCTAssertNotEqual(result, 0)  // Should fail (partial failure)
    }

    func testMultipleFilesWithM() {
        let file = createTempFile()
        defer { cleanup(file) }

        let result = RealpathCommand.main(["realpath", "-m", file, "/nonexistent"])
        XCTAssertEqual(result, 0)  // Should succeed with -m
    }

    // MARK: - Path Normalization

    func testDoubleSlash() {
        let result = RealpathCommand.main(["realpath", "-m", "//usr//bin"])
        XCTAssertEqual(result, 0)
    }

    func testTrailingSlash() {
        let dir = createTempDir()
        defer { cleanup(dir) }

        let result = RealpathCommand.main(["realpath", dir + "/"])
        XCTAssertEqual(result, 0)
    }

    func testDotDotInPath() {
        let result = RealpathCommand.main(["realpath", "-m", "/usr/bin/../lib"])
        XCTAssertEqual(result, 0)
    }

    func testComplexPath() {
        let result = RealpathCommand.main(["realpath", "-m", "/./usr/./bin/../bin/./"])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Error Handling

    func testNoArguments() {
        let result = RealpathCommand.main(["realpath"])
        XCTAssertNotEqual(result, 0)
    }

    func testEmptyString() {
        let result = RealpathCommand.main(["realpath", ""])
        XCTAssertNotEqual(result, 0)
    }

    // MARK: - Edge Cases

    func testHome() {
        // ~ expansion might not work, but let's test with actual home
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let result = RealpathCommand.main(["realpath", home])
        XCTAssertEqual(result, 0)
    }

    func testTmp() {
        let result = RealpathCommand.main(["realpath", "/tmp"])
        XCTAssertEqual(result, 0)
    }

    func testAbsolutePath() {
        let file = createTempFile()
        defer { cleanup(file) }

        // File is already absolute
        let result = RealpathCommand.main(["realpath", file])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Realistic Use Cases

    func testResolveSymlinkChain() {
        let file = createTempFile()
        let link1 = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString).path
        let link2 = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString).path

        try? FileManager.default.createSymbolicLink(atPath: link1, withDestinationPath: file)
        try? FileManager.default.createSymbolicLink(atPath: link2, withDestinationPath: link1)
        defer { cleanup(file, link1, link2) }

        let result = RealpathCommand.main(["realpath", link2])
        XCTAssertEqual(result, 0)
    }

    func testCanonicalizeRelativePath() {
        let dir = createTempDir()
        let subdir = dir + "/sub"
        try? FileManager.default.createDirectory(atPath: subdir, withIntermediateDirectories: true)
        let file = subdir + "/file.txt"
        FileManager.default.createFile(atPath: file, contents: Data())
        defer { cleanup(dir) }

        let oldDir = FileManager.default.currentDirectoryPath
        FileManager.default.changeCurrentDirectoryPath(subdir)
        defer { FileManager.default.changeCurrentDirectoryPath(oldDir) }

        let result = RealpathCommand.main(["realpath", "../sub/file.txt"])
        XCTAssertEqual(result, 0)
    }
}
