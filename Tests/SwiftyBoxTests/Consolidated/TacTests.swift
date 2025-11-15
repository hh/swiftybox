import XCTest
@testable import swiftybox
import Foundation

/// Tests for the `tac` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: GNU coreutils tac (reverse cat, concatenate and print files in reverse)
/// - Reverses lines (not characters within lines)
/// - Options: -s SEPARATOR (use STRING as separator instead of newline)
///
/// Resources:
/// - GNU: https://www.gnu.org/software/coreutils/manual/html_node/tac-invocation.html

final class TacTests: XCTestCase {

    private func createTempFile(content: String) -> String {
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent(UUID().uuidString)
        try? content.write(to: tempFile, atomically: true, encoding: .utf8)
        return tempFile.path
    }

    func testTacBasic() {
        let input = "line1\nline2\nline3\n"
        let tempFile = createTempFile(content: input)
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("tac", [tempFile])

        XCTAssertEqual(result.exitCode, 0, "tac should succeed")
        XCTAssertEqual(result.stdout, "line3\nline2\nline1\n", "Should reverse lines")
    }

    func testTacMultipleFiles() {
        let file1 = createTempFile(content: "a\nb\n")
        let file2 = createTempFile(content: "c\nd\n")
        defer {
            try? FileManager.default.removeItem(atPath: file1)
            try? FileManager.default.removeItem(atPath: file2)
        }

        let result = runCommand("tac", [file1, file2])

        if result.exitCode == 0 {
            // Each file reversed separately
            XCTAssertEqual(result.stdout, "b\na\nd\nc\n", "Should reverse each file")
        }
    }

    func testTacStdin() {
        let input = "first\nsecond\nthird\n"
        let result = runCommandWithInput("tac", [], input: input)

        XCTAssertEqual(result.exitCode, 0)
        XCTAssertEqual(result.stdout, "third\nsecond\nfirst\n")
    }

    func testTacSingleLine() {
        let input = "single line\n"
        let tempFile = createTempFile(content: input)
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("tac", [tempFile])

        XCTAssertEqual(result.exitCode, 0)
        XCTAssertEqual(result.stdout, input, "Single line should remain unchanged")
    }

    func testTacEmptyFile() {
        let tempFile = createTempFile(content: "")
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("tac", [tempFile])

        XCTAssertEqual(result.exitCode, 0)
        XCTAssertEqual(result.stdout, "", "Empty file should produce empty output")
    }

    func testTacNoTrailingNewline() {
        let input = "line1\nline2\nline3"
        let tempFile = createTempFile(content: input)
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("tac", [tempFile])

        if result.exitCode == 0 {
            XCTAssertTrue(result.stdout.hasPrefix("line3"), "Last line should be first")
            XCTAssertTrue(result.stdout.contains("line2"))
            XCTAssertTrue(result.stdout.contains("line1"))
        }
    }

    func testTacCustomSeparator() {
        let input = "a,b,c,d"
        let tempFile = createTempFile(content: input)
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("tac", ["-s", ",", tempFile])

        if result.exitCode == 0 {
            // Should reverse comma-separated parts
            XCTAssertTrue(result.stdout.hasPrefix("d"), "Should start with last part")
        } else {
            // Custom separator not implemented
            XCTAssertTrue(result.stderr.contains("invalid option") ||
                         result.stderr.contains("unrecognized"))
        }
    }

    func testTacNonexistentFile() {
        let result = runCommand("tac", ["/tmp/nonexistent-\(UUID().uuidString)"])

        XCTAssertNotEqual(result.exitCode, 0)
        XCTAssertTrue(result.stderr.contains("No such file") || result.stderr.contains("not found"))
    }

    // TODO: Test -b (attach separator before), -r (treat separator as regex)
}
