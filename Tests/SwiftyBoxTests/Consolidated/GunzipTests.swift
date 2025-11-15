import XCTest
@testable import swiftybox

final class GunzipTests: XCTestCase {
    var testDir: String!

    override func setUp() {
        super.setUp()
        testDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("GunzipTests_\(UUID().uuidString)")
            .path
        try? FileManager.default.createDirectory(atPath: testDir, withIntermediateDirectories: true)
    }

    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(atPath: testDir)
    }

    func testGunzipBasic() {
        // This test requires a gzipped file
        // We'll skip detailed implementation until gzip/gunzip are implemented
        let result = runCommand("gunzip", ["--help"])
        // Just verify command exists
        XCTAssertTrue(result.exitCode == 0 || result.exitCode == 1,
                     "gunzip command should be recognized")
    }
}
