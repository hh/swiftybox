import XCTest
@testable import swiftybox

final class FindTests: XCTestCase {
    var testDir: String!

    override func setUp() {
        super.setUp()
        testDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("FindTests_\(UUID().uuidString)")
            .path
        try? FileManager.default.createDirectory(atPath: testDir, withIntermediateDirectories: true)
    }

    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(atPath: testDir)
    }

    func testFindBasic() {
        // Create test file structure
        FileManager.default.createFile(atPath: "\(testDir!)/file1.txt", contents: nil)
        FileManager.default.createFile(atPath: "\(testDir!)/file2.txt", contents: nil)

        let result = runCommand("find", [testDir!])
        XCTAssertEqual(result.exitCode, 0, "find should succeed")
        XCTAssertTrue(result.stdout.contains("file1.txt") || result.stdout.contains("file2.txt"),
                     "find should list files")
    }

    func testFindByName() {
        FileManager.default.createFile(atPath: "\(testDir!)/target.txt", contents: nil)
        FileManager.default.createFile(atPath: "\(testDir!)/other.txt", contents: nil)

        let result = runCommand("find", [testDir!, "-name", "target.txt"])
        XCTAssertEqual(result.exitCode, 0, "find -name should succeed")
        XCTAssertTrue(result.stdout.contains("target.txt"), "find should find target file")
    }

    func testFindByType() {
        try? FileManager.default.createDirectory(atPath: "\(testDir!)/subdir", withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: "\(testDir!)/file.txt", contents: nil)

        let result = runCommand("find", [testDir!, "-type", "f"])
        XCTAssertEqual(result.exitCode, 0, "find -type f should succeed")
        XCTAssertTrue(result.stdout.contains("file.txt"), "find should find files")
    }
}
