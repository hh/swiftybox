import XCTest
@testable import swiftybox

final class XargsTests: XCTestCase {
    func testXargsBasic() {
        let input = "arg1\narg2\narg3\n"
        let result = runCommandWithInput("xargs", ["echo"], input: input)
        XCTAssertEqual(result.exitCode, 0, "xargs should succeed")
        XCTAssertTrue(result.stdout.contains("arg1") && result.stdout.contains("arg2"),
                     "xargs should pass arguments to command")
    }

    func testXargsWithN() {
        let input = "a\nb\nc\nd\n"
        let result = runCommandWithInput("xargs", ["-n", "2", "echo"], input: input)
        XCTAssertEqual(result.exitCode, 0, "xargs -n should succeed")
        // Should group inputs in pairs
    }

    func testXargsEmpty() {
        let result = runCommandWithInput("xargs", ["echo"], input: "")
        XCTAssertEqual(result.exitCode, 0, "xargs with empty input should succeed")
    }
}
