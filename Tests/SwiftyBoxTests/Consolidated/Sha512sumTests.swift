import XCTest
@testable import swiftybox
import Foundation

/// Tests for the `sha512sum` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: GNU coreutils sha512sum
/// - Similar to sha256sum but with 128 hex character output
/// - Current: Likely uses simplified hash (POC), not actual SHA-512
///
/// Resources:
/// - GNU: https://www.gnu.org/software/coreutils/manual/html_node/sha2-utilities.html
/// - FIPS 180-4: SHA-512 specification

final class Sha512sumTests: XCTestCase {

    private func createTempFile(content: String) -> String {
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent(UUID().uuidString)
        try? content.write(to: tempFile, atomically: true, encoding: .utf8)
        return tempFile.path
    }

    func testSha512sumBasic() {
        let tempFile = createTempFile(content: "test\n")
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("sha512sum", [tempFile])

        XCTAssertEqual(result.exitCode, 0, "sha512sum should succeed")

        let parts = result.stdout.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
        XCTAssertEqual(parts.count, 2, "Should have hash and filename")

        // SHA-512 produces 128 hex characters (512 bits / 4 bits per hex char)
        XCTAssertEqual(parts[0].count, 128, "Hash should be 128 hex characters")
    }

    func testSha512sumEmptyFile() {
        let tempFile = createTempFile(content: "")
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("sha512sum", [tempFile])
        XCTAssertEqual(result.exitCode, 0)

        let parts = result.stdout.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
        XCTAssertEqual(parts[0].count, 128, "Empty file should produce 128-char hash")
    }

    func testSha512sumConsistency() {
        let content = "consistent content\n"
        let file1 = createTempFile(content: content)
        let file2 = createTempFile(content: content)
        defer {
            try? FileManager.default.removeItem(atPath: file1)
            try? FileManager.default.removeItem(atPath: file2)
        }

        let result1 = runCommand("sha512sum", [file1])
        let result2 = runCommand("sha512sum", [file2])

        let hash1 = result1.stdout.split(separator: " ", maxSplits: 1)[0]
        let hash2 = result2.stdout.split(separator: " ", maxSplits: 1)[0]
        XCTAssertEqual(hash1, hash2, "Same content should produce same hash")
    }

    func testSha512sumDifferentContent() {
        let file1 = createTempFile(content: "content1\n")
        let file2 = createTempFile(content: "content2\n")
        defer {
            try? FileManager.default.removeItem(atPath: file1)
            try? FileManager.default.removeItem(atPath: file2)
        }

        let result1 = runCommand("sha512sum", [file1])
        let result2 = runCommand("sha512sum", [file2])

        let hash1 = result1.stdout.split(separator: " ", maxSplits: 1)[0]
        let hash2 = result2.stdout.split(separator: " ", maxSplits: 1)[0]
        XCTAssertNotEqual(hash1, hash2, "Different content should produce different hash")
    }

    func testSha512sumMultipleFiles() {
        let file1 = createTempFile(content: "file1\n")
        let file2 = createTempFile(content: "file2\n")
        defer {
            try? FileManager.default.removeItem(atPath: file1)
            try? FileManager.default.removeItem(atPath: file2)
        }

        let result = runCommand("sha512sum", [file1, file2])
        XCTAssertEqual(result.exitCode, 0)

        let lines = result.stdout.split(separator: "\n")
        XCTAssertEqual(lines.count, 2, "Should output two lines")
    }

    func testSha512sumStdin() {
        let input = "stdin test\n"
        let result = runCommandWithInput("sha512sum", ["-"], input: input)

        XCTAssertEqual(result.exitCode, 0)

        // Split on newlines first, then parse the first line
        let lines = result.stdout.split(separator: "\n")
        XCTAssertGreaterThan(lines.count, 0, "Should have output")

        let parts = lines[0].split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
        XCTAssertEqual(parts[1], "-", "Should show '-' for stdin")
    }

    func testSha512sumNonexistentFile() {
        let result = runCommand("sha512sum", ["/tmp/nonexistent-\(UUID().uuidString)"])
        XCTAssertNotEqual(result.exitCode, 0)
        XCTAssertTrue(result.stderr.contains("No such file") || result.stderr.contains("not found"))
    }

    func testSha512sumOutputFormat() {
        let tempFile = createTempFile(content: "format test\n")
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("sha512sum", [tempFile])

        // GNU format: <hash>  <filename> (two spaces)
        XCTAssertTrue(result.stdout.contains("  "), "Should have double space separator")
    }

    // TODO: Known SHA-512 test vector
    // Empty string: cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e
}
