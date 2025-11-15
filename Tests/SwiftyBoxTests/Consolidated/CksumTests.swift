import XCTest
@testable import swiftybox
import Foundation

/// Tests for the `cksum` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: POSIX cksum (CRC-32 + byte count)
/// - Output format: <CRC> <byte-count> <filename>
/// - Algorithm: POSIX CRC-32 (different from zip/gzip CRC-32)
///
/// Resources:
/// - POSIX: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/cksum.html
/// - GNU: https://www.gnu.org/software/coreutils/manual/html_node/cksum-invocation.html

final class CksumTests: XCTestCase {

    private func createTempFile(content: String) -> String {
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent(UUID().uuidString)
        try? content.write(to: tempFile, atomically: true, encoding: .utf8)
        return tempFile.path
    }

    // MARK: - Basic Tests

    func testCksumBasic() {
        let tempFile = createTempFile(content: "test\n")
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("cksum", [tempFile])

        XCTAssertEqual(result.exitCode, 0, "cksum should succeed")

        // Output: <CRC> <bytes> <filename>
        let parts = result.stdout.split(separator: " ", omittingEmptySubsequences: true)
        XCTAssertEqual(parts.count, 3, "Should have CRC, byte count, and filename")
        XCTAssertEqual(parts[1], "5", "Should show 5 bytes for 'test\\n'")
    }

    func testCksumEmptyFile() {
        let tempFile = createTempFile(content: "")
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("cksum", [tempFile])
        XCTAssertEqual(result.exitCode, 0)

        let parts = result.stdout.split(separator: " ", omittingEmptySubsequences: true)
        XCTAssertEqual(parts[1], "0", "Empty file should show 0 bytes")
    }

    func testCksumConsistency() {
        let content = "consistent\n"
        let file1 = createTempFile(content: content)
        let file2 = createTempFile(content: content)
        defer {
            try? FileManager.default.removeItem(atPath: file1)
            try? FileManager.default.removeItem(atPath: file2)
        }

        let result1 = runCommand("cksum", [file1])
        let result2 = runCommand("cksum", [file2])

        let crc1 = result1.stdout.split(separator: " ")[0]
        let crc2 = result2.stdout.split(separator: " ")[0]
        XCTAssertEqual(crc1, crc2, "Same content should produce same CRC")
    }

    func testCksumMultipleFiles() {
        let file1 = createTempFile(content: "file1\n")
        let file2 = createTempFile(content: "file2\n")
        defer {
            try? FileManager.default.removeItem(atPath: file1)
            try? FileManager.default.removeItem(atPath: file2)
        }

        let result = runCommand("cksum", [file1, file2])
        XCTAssertEqual(result.exitCode, 0)

        let lines = result.stdout.split(separator: "\n")
        XCTAssertEqual(lines.count, 2, "Should output two lines")
    }

    func testCksumStdin() {
        let input = "test input\n"
        let result = runCommandWithInput("cksum", [], input: input)

        XCTAssertEqual(result.exitCode, 0)
        XCTAssertTrue(result.stdout.contains("11"), "Should show 11 bytes")
    }

    func testCksumNonexistentFile() {
        let result = runCommand("cksum", ["/tmp/nonexistent-\(UUID().uuidString)"])
        XCTAssertNotEqual(result.exitCode, 0)
        XCTAssertTrue(result.stderr.contains("No such file") || result.stderr.contains("not found"))
    }

    // TODO: Known CRC test vectors for validation
    // Empty: CRC=4294967295 (0xFFFFFFFF), bytes=0
}
