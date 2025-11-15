import XCTest
@testable import swiftybox

final class HostidTests: XCTestCase {
    func testHostidWorks() {
        let result = runCommand("hostid", [])
        XCTAssertEqual(result.exitCode, 0, "hostid should succeed")

        // Should produce a hex number (8 hex digits typically)
        let output = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertFalse(output.isEmpty, "hostid should produce output")

        // Check that output is valid hex (only 0-9, a-f characters)
        let hexCharacters = CharacterSet(charactersIn: "0123456789abcdef")
        let outputCharacters = CharacterSet(charactersIn: output.lowercased())
        XCTAssertTrue(outputCharacters.isSubset(of: hexCharacters),
                     "hostid output should only contain hex digits, got: \(output)")
    }
}
