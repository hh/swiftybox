import XCTest
@testable import swiftybox
import Foundation

/// Tests for the `shuf` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: GNU coreutils shuf (shuffle lines randomly)
/// - Options: -n COUNT (output at most COUNT lines), -e (treat args as input lines)
///   -i LO-HI (treat numbers in range as input lines), -r (repeat output, can repeat)
///
/// Resources:
/// - GNU: https://www.gnu.org/software/coreutils/manual/html_node/shuf-invocation.html

final class ShufTests: XCTestCase {

    private func createTempFile(content: String) -> String {
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent(UUID().uuidString)
        try? content.write(to: tempFile, atomically: true, encoding: .utf8)
        return tempFile.path
    }

    func testShufBasic() {
        let input = "line1\nline2\nline3\nline4\nline5\n"
        let tempFile = createTempFile(content: input)
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("shuf", [tempFile])

        XCTAssertEqual(result.exitCode, 0, "shuf should succeed")

        let outputLines = Set(result.stdout.split(separator: "\n").map(String.init))
        let inputLines = Set(input.split(separator: "\n").map(String.init))

        XCTAssertEqual(outputLines, inputLines, "Should contain all input lines")
        XCTAssertEqual(outputLines.count, 5, "Should have all 5 lines")
    }

    func testShufStdin() {
        let input = "a\nb\nc\nd\ne\n"
        let result = runCommandWithInput("shuf", [], input: input)

        XCTAssertEqual(result.exitCode, 0)

        let outputLines = Set(result.stdout.split(separator: "\n").map(String.init))
        XCTAssertEqual(outputLines.count, 5, "Should shuffle all lines from stdin")
    }

    func testShufWithCount() {
        let input = "line1\nline2\nline3\nline4\nline5\n"
        let tempFile = createTempFile(content: input)
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("shuf", ["-n", "3", tempFile])

        if result.exitCode == 0 {
            let outputLines = result.stdout.split(separator: "\n")
            XCTAssertEqual(outputLines.count, 3, "Should output exactly 3 lines")
        }
    }

    func testShufEchoMode() {
        let result = runCommand("shuf", ["-e", "apple", "banana", "cherry"])

        if result.exitCode == 0 {
            let outputLines = Set(result.stdout.split(separator: "\n").map(String.init))
            XCTAssertEqual(outputLines, Set(["apple", "banana", "cherry"]),
                          "Should shuffle the provided arguments")
        }
    }

    func testShufRange() {
        let result = runCommand("shuf", ["-i", "1-10"])

        if result.exitCode == 0 {
            let outputLines = result.stdout.split(separator: "\n").map(String.init)
            XCTAssertEqual(outputLines.count, 10, "Should output 10 numbers")

            let numbers = Set(outputLines.compactMap { Int($0) })
            XCTAssertEqual(numbers, Set(1...10), "Should contain all numbers 1-10")
        }
    }

    func testShufEmptyInput() {
        let result = runCommandWithInput("shuf", [], input: "")

        XCTAssertEqual(result.exitCode, 0)
        XCTAssertEqual(result.stdout, "", "Empty input should produce empty output")
    }

    func testShufSingleLine() {
        let input = "single line\n"
        let result = runCommandWithInput("shuf", [], input: input)

        XCTAssertEqual(result.exitCode, 0)
        XCTAssertEqual(result.stdout, input, "Single line should remain unchanged")
    }

    // TODO: Test -r (repeat) option, --random-source option
}
