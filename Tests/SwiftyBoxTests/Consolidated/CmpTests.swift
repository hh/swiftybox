import XCTest
@testable import swiftybox

final class CmpTests: XCTestCase {
    var testDir: String!

    override func setUp() {
        super.setUp()
        testDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("CmpTests_\(UUID().uuidString)")
            .path
        try? FileManager.default.createDirectory(atPath: testDir, withIntermediateDirectories: true)
    }

    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(atPath: testDir)
    }

    func testCmpDetectsDifference() {
        let file1 = "\(testDir!)/foo"
        let file2 = "\(testDir!)/bar"
        FileManager.default.createFile(atPath: file1, contents: Data("foo\n".utf8))
        FileManager.default.createFile(atPath: file2, contents: Data("bar\n".utf8))

        let result = runCommand("cmp", ["-s", file1, file2])
        XCTAssertNotEqual(result.exitCode, 0, "cmp should detect difference and return non-zero")
    }

    func testCmpIdenticalFiles() {
        let file1 = "\(testDir!)/file1.txt"
        let file2 = "\(testDir!)/file2.txt"
        let content = "identical content\n"
        FileManager.default.createFile(atPath: file1, contents: Data(content.utf8))
        FileManager.default.createFile(atPath: file2, contents: Data(content.utf8))

        let result = runCommand("cmp", ["-s", file1, file2])
        XCTAssertEqual(result.exitCode, 0, "cmp should return 0 for identical files")
    }

    func testCmpWithoutSilentFlag() {
        let file1 = "\(testDir!)/file1.txt"
        let file2 = "\(testDir!)/file2.txt"
        FileManager.default.createFile(atPath: file1, contents: Data("hello\n".utf8))
        FileManager.default.createFile(atPath: file2, contents: Data("world\n".utf8))

        let result = runCommand("cmp", [file1, file2])
        XCTAssertNotEqual(result.exitCode, 0, "cmp should fail on different files")
        XCTAssertFalse(result.stdout.isEmpty || result.stderr.isEmpty,
                      "cmp should produce output showing difference location")
    }

    func testCmpDifferentLengths() {
        let file1 = "\(testDir!)/short.txt"
        let file2 = "\(testDir!)/long.txt"
        FileManager.default.createFile(atPath: file1, contents: Data("short".utf8))
        FileManager.default.createFile(atPath: file2, contents: Data("short and long".utf8))

        let result = runCommand("cmp", [file1, file2])
        XCTAssertNotEqual(result.exitCode, 0, "cmp should detect different file lengths")
    }
}
