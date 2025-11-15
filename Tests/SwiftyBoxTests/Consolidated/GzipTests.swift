import XCTest
@testable import swiftybox

final class GzipTests: XCTestCase {
    var testDir: String!

    override func setUp() {
        super.setUp()
        testDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("GzipTests_\(UUID().uuidString)")
            .path
        try? FileManager.default.createDirectory(atPath: testDir, withIntermediateDirectories: true)
    }

    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(atPath: testDir)
    }

    func testGzipBasic() {
        let testFile = "\(testDir!)/test.txt"
        FileManager.default.createFile(atPath: testFile, contents: Data("Hello, World!\n".utf8))

        let result = runCommand("gzip", [testFile])
        XCTAssertEqual(result.exitCode, 0, "gzip should succeed")

        // Should create test.txt.gz
        XCTAssertTrue(FileManager.default.fileExists(atPath: "\(testFile).gz"),
                     "gzip should create .gz file")
    }

    func testGzipToStdout() {
        let testFile = "\(testDir!)/test.txt"
        FileManager.default.createFile(atPath: testFile, contents: Data("test data\n".utf8))

        let result = runCommand("gzip", ["-c", testFile])
        XCTAssertEqual(result.exitCode, 0, "gzip -c should succeed")
        XCTAssertFalse(result.stdout.isEmpty, "gzip -c should output to stdout")
    }
}
