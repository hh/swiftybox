// ReadlinkTests.swift
// Tests for the `readlink` command - print value of a symbolic link

import XCTest
@testable import swiftybox

/// Tests for the `readlink` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: GNU coreutils readlink
/// - Prints the target of a symbolic link
/// - Options: -f (canonicalize, follow all symlinks), -n (no newline)
/// - For non-symlinks, behaves differently based on options
///
/// Resources:
/// - GNU: https://www.gnu.org/software/coreutils/manual/html_node/readlink-invocation.html

final class ReadlinkTests: XCTestCase {

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

    func testSymbolicLink() {
        let file = createTempFile()
        let link = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString).path
        try? FileManager.default.createSymbolicLink(atPath: link, withDestinationPath: file)
        defer { cleanup(file, link) }

        let result = ReadlinkCommand.main(["readlink", link])
        XCTAssertEqual(result, 0)
    }

    func testSymbolicLinkToDirectory() {
        let dir = createTempDir()
        let link = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString).path
        try? FileManager.default.createSymbolicLink(atPath: link, withDestinationPath: dir)
        defer { cleanup(dir, link) }

        let result = ReadlinkCommand.main(["readlink", link])
        XCTAssertEqual(result, 0)
    }

    func testRelativeSymlink() {
        let dir = createTempDir()
        let file = dir + "/target"
        FileManager.default.createFile(atPath: file, contents: Data())
        let link = dir + "/link"
        try? FileManager.default.createSymbolicLink(atPath: link, withDestinationPath: "target")
        defer { cleanup(dir) }

        let result = ReadlinkCommand.main(["readlink", link])
        XCTAssertEqual(result, 0)
    }

    func testAbsoluteSymlink() {
        let file = createTempFile()
        let link = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString).path
        try? FileManager.default.createSymbolicLink(atPath: link, withDestinationPath: file)
        defer { cleanup(file, link) }

        let result = ReadlinkCommand.main(["readlink", link])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Non-Symlinks

    func testRegularFile() {
        let file = createTempFile()
        defer { cleanup(file) }

        // readlink on non-symlink should fail
        let result = ReadlinkCommand.main(["readlink", file])
        XCTAssertNotEqual(result, 0)
    }

    func testDirectory() {
        let dir = createTempDir()
        defer { cleanup(dir) }

        // readlink on directory should fail
        let result = ReadlinkCommand.main(["readlink", dir])
        XCTAssertNotEqual(result, 0)
    }

    // MARK: - Canonicalize Option (-f)

    func testCanonicalizeSymlink() {
        let file = createTempFile()
        let link = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString).path
        try? FileManager.default.createSymbolicLink(atPath: link, withDestinationPath: file)
        defer { cleanup(file, link) }

        let result = ReadlinkCommand.main(["readlink", "-f", link])
        XCTAssertEqual(result, 0)
    }

    func testCanonicalizeRegularFile() {
        let file = createTempFile()
        defer { cleanup(file) }

        // With -f, regular files should work
        let result = ReadlinkCommand.main(["readlink", "-f", file])
        XCTAssertEqual(result, 0)
    }

    func testCanonicalizeSymlinkChain() {
        let file = createTempFile()
        let link1 = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString).path
        let link2 = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString).path

        try? FileManager.default.createSymbolicLink(atPath: link1, withDestinationPath: file)
        try? FileManager.default.createSymbolicLink(atPath: link2, withDestinationPath: link1)
        defer { cleanup(file, link1, link2) }

        let result = ReadlinkCommand.main(["readlink", "-f", link2])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Multiple Links

    func testMultipleSymlinks() {
        let file1 = createTempFile()
        let file2 = createTempFile()
        let link1 = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString).path
        let link2 = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString).path

        try? FileManager.default.createSymbolicLink(atPath: link1, withDestinationPath: file1)
        try? FileManager.default.createSymbolicLink(atPath: link2, withDestinationPath: file2)
        defer { cleanup(file1, file2, link1, link2) }

        let result = ReadlinkCommand.main(["readlink", link1, link2])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Broken Links

    func testBrokenSymlink() {
        let link = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString).path
        try? FileManager.default.createSymbolicLink(atPath: link, withDestinationPath: "/nonexistent/target")
        defer { cleanup(link) }

        // readlink should still show the link target even if broken
        let result = ReadlinkCommand.main(["readlink", link])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Error Handling

    func testNoArguments() {
        let result = ReadlinkCommand.main(["readlink"])
        XCTAssertNotEqual(result, 0)
    }

    func testNonExistentFile() {
        let result = ReadlinkCommand.main(["readlink", "/nonexistent/file"])
        XCTAssertNotEqual(result, 0)
    }

    // MARK: - Edge Cases

    func testCurrentDirectoryWithF() {
        // . with -f should resolve to absolute path
        let result = ReadlinkCommand.main(["readlink", "-f", "."])
        XCTAssertEqual(result, 0)
    }

    func testRootDirectoryWithF() {
        // / with -f should work
        let result = ReadlinkCommand.main(["readlink", "-f", "/"])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Realistic Use Cases

    func testResolveRelativeLink() {
        let dir = createTempDir()
        let target = dir + "/target.txt"
        let link = dir + "/link.txt"

        FileManager.default.createFile(atPath: target, contents: Data())
        try? FileManager.default.createSymbolicLink(atPath: link, withDestinationPath: "target.txt")
        defer { cleanup(dir) }

        let result = ReadlinkCommand.main(["readlink", link])
        XCTAssertEqual(result, 0)
    }

    func testResolveToAbsolutePath() {
        let file = createTempFile()
        let link = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString).path
        try? FileManager.default.createSymbolicLink(atPath: link, withDestinationPath: file)
        defer { cleanup(file, link) }

        let result = ReadlinkCommand.main(["readlink", "-f", link])
        XCTAssertEqual(result, 0)
    }
}
