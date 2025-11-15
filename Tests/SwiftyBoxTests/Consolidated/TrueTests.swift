import XCTest
@testable import swiftybox

final class TrueTests: XCTestCase {
    func testTrueReturnsSuccess() {
        let result = runCommand("true", [])
        XCTAssertEqual(result.exitCode, 0, "true should exit with status 0")
    }

    func testTrueIsSilent() {
        let result = runCommand("true", [])
        XCTAssertEqual(result.stdout, "", "true should produce no stdout")
        XCTAssertEqual(result.stderr, "", "true should produce no stderr")
    }
}
