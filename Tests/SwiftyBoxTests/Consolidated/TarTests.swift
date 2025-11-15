import XCTest
@testable import swiftybox

final class TarTests: XCTestCase {
    var testDir: String!

    override func setUp() {
        super.setUp()
        testDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("TarTests_\(UUID().uuidString)")
            .path
        try? FileManager.default.createDirectory(atPath: testDir, withIntermediateDirectories: true)
    }

    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(atPath: testDir)
    }

    func testTarCreate() {
        let testFile = "\(testDir!)/test.txt"
        let tarFile = "\(testDir!)/archive.tar"
        FileManager.default.createFile(atPath: testFile, contents: Data("test".utf8))

        let result = runCommand("tar", ["-cf", tarFile, testFile])
        XCTAssertEqual(result.exitCode, 0, "tar -cf should succeed")
        XCTAssertTrue(FileManager.default.fileExists(atPath: tarFile),
                     "tar should create archive file")
    }

    func testTarExtract() {
        // Will be implemented when tar is added
        XCTAssertTrue(true, "tar extract test placeholder")
    }

    func testTarList() {
        // Will be implemented when tar is added
        XCTAssertTrue(true, "tar list test placeholder")
    }
}
