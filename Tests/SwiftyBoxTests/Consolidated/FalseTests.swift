import XCTest
@testable import swiftybox

final class FalseTests: XCTestCase {
    func testFalseReturnsFailure() {
        let result = runCommand("false", [])
        XCTAssertEqual(result.exitCode, 1, "false should exit with status 1")
    }

    func testFalseIsSilent() {
        let result = runCommand("false", [])
        XCTAssertEqual(result.stdout, "", "false should produce no stdout")
        XCTAssertEqual(result.stderr, "", "false should produce no stderr")
    }
}
