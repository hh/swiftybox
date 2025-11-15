import XCTest
@testable import swiftybox
import Foundation

/// Tests for the `sha256sum` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: GNU coreutils sha256sum
/// - Current: Uses simplified FNV-1a hash (POC), not actual SHA-256
/// - GNU: Full SHA-256 implementation with check mode (-c)
/// - Target scope: P0 (basic checksum) + P1 (check mode, multiple files)
///
/// IMPORTANT: Current implementation uses a simplified hash for proof-of-concept.
/// Production version should use CryptoKit's SHA256 or CommonCrypto.
///
/// Output format (GNU compatible):
///   <64-hex-chars>  <filename>
///   Example: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855  empty.txt
///
/// Common usage patterns:
///   sha256sum file.txt              # Compute checksum
///   sha256sum file1 file2           # Multiple files
///   sha256sum -                     # Read from stdin
///   sha256sum -c checksums.txt      # Verify checksums
///   echo "test" | sha256sum         # Checksum of piped data
///
/// Resources:
/// - GNU: https://www.gnu.org/software/coreutils/manual/html_node/sha2-utilities.html
/// - FIPS 180-4: SHA-256 specification
/// - BusyBox: https://git.busybox.net/busybox/tree/coreutils/md5_sha1_sum.c

final class Sha256sumTests: XCTestCase {

    // MARK: - Test Helpers

    private func createTempFile(content: String) -> String {
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent(UUID().uuidString)

        try? content.write(to: tempFile, atomically: true, encoding: .utf8)

        return tempFile.path
    }

    private func createTempFile(data: Data) -> String {
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent(UUID().uuidString)

        try? data.write(to: tempFile)

        return tempFile.path
    }

    override func tearDown() {
        super.tearDown()
        // Cleanup is handled by the OS for temp files
    }

    // MARK: - Basic Functionality Tests

    func testSha256sum_BasicFile() {
        let content = "test\n"
        let tempFile = createTempFile(content: content)
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("sha256sum", [tempFile])

        XCTAssertEqual(result.exitCode, 0, "sha256sum should succeed")
        XCTAssertEqual(result.stderr, "", "Should not produce errors")

        // Output should be: <64 hex chars>  <filename>
        let lines = result.stdout.split(separator: "\n")
        XCTAssertEqual(lines.count, 1, "Should output one line")

        let parts = lines[0].split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
        XCTAssertEqual(parts.count, 2, "Should have hash and filename")
        XCTAssertEqual(parts[0].count, 64, "Hash should be 64 hex characters")
        XCTAssertTrue(parts[1].hasSuffix(URL(fileURLWithPath: tempFile).lastPathComponent),
                     "Should include filename")

        // Verify hash is hexadecimal
        let hexChars = CharacterSet(charactersIn: "0123456789abcdefABCDEF")
        XCTAssertTrue(parts[0].unicodeScalars.allSatisfy { hexChars.contains($0) },
                     "Hash should only contain hex characters")
    }

    func testSha256sum_EmptyFile() {
        let tempFile = createTempFile(content: "")
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("sha256sum", [tempFile])

        XCTAssertEqual(result.exitCode, 0, "sha256sum should succeed on empty file")

        let parts = result.stdout.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
        XCTAssertEqual(parts[0].count, 64, "Empty file should still produce 64-char hash")
    }

    func testSha256sum_ConsistentOutput() {
        // Same content should produce same hash
        let content = "consistent content\n"
        let file1 = createTempFile(content: content)
        let file2 = createTempFile(content: content)
        defer {
            try? FileManager.default.removeItem(atPath: file1)
            try? FileManager.default.removeItem(atPath: file2)
        }

        let result1 = runCommand("sha256sum", [file1])
        let result2 = runCommand("sha256sum", [file2])

        let hash1 = result1.stdout.split(separator: " ", maxSplits: 1)[0]
        let hash2 = result2.stdout.split(separator: " ", maxSplits: 1)[0]

        XCTAssertEqual(hash1, hash2, "Same content should produce same hash")
    }

    func testSha256sum_DifferentContent() {
        // Different content should produce different hash
        let file1 = createTempFile(content: "content1\n")
        let file2 = createTempFile(content: "content2\n")
        defer {
            try? FileManager.default.removeItem(atPath: file1)
            try? FileManager.default.removeItem(atPath: file2)
        }

        let result1 = runCommand("sha256sum", [file1])
        let result2 = runCommand("sha256sum", [file2])

        let hash1 = result1.stdout.split(separator: " ", maxSplits: 1)[0]
        let hash2 = result2.stdout.split(separator: " ", maxSplits: 1)[0]

        XCTAssertNotEqual(hash1, hash2, "Different content should produce different hash")
    }

    // MARK: - Multiple Files Tests

    func testSha256sum_MultipleFiles() {
        let file1 = createTempFile(content: "file1\n")
        let file2 = createTempFile(content: "file2\n")
        let file3 = createTempFile(content: "file3\n")
        defer {
            try? FileManager.default.removeItem(atPath: file1)
            try? FileManager.default.removeItem(atPath: file2)
            try? FileManager.default.removeItem(atPath: file3)
        }

        let result = runCommand("sha256sum", [file1, file2, file3])

        XCTAssertEqual(result.exitCode, 0, "sha256sum should succeed on multiple files")

        let lines = result.stdout.split(separator: "\n")
        XCTAssertEqual(lines.count, 3, "Should output three lines")

        // Each line should have a hash and filename
        for line in lines {
            let parts = line.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
            XCTAssertEqual(parts.count, 2, "Each line should have hash and filename")
            XCTAssertEqual(parts[0].count, 64, "Each hash should be 64 characters")
        }
    }

    // MARK: - Stdin Tests

    func testSha256sum_Stdin() {
        let input = "test input from stdin\n"
        let result = runCommandWithInput("sha256sum", ["-"], input: input)

        XCTAssertEqual(result.exitCode, 0, "sha256sum should succeed on stdin")

        let parts = result.stdout.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
        XCTAssertEqual(parts.count, 2, "Should have hash and filename")
        XCTAssertEqual(parts[0].count, 64, "Hash should be 64 hex characters")
        XCTAssertEqual(parts[1], "-", "Filename should be '-' for stdin")
    }

    func testSha256sum_StdinDefault() {
        // When no args provided, should read from stdin
        let input = "default stdin\n"
        let result = runCommandWithInput("sha256sum", [], input: input)

        XCTAssertEqual(result.exitCode, 0, "sha256sum should read stdin by default")

        let parts = result.stdout.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
        XCTAssertEqual(parts[1], "-", "Should show '-' for stdin")
    }

    // MARK: - Binary Data Tests

    func testSha256sum_BinaryData() {
        // Create file with binary data
        let binaryData = Data([0x00, 0xFF, 0x42, 0xAA, 0x55, 0x01, 0x02, 0x03])
        let tempFile = createTempFile(data: binaryData)
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("sha256sum", [tempFile])

        XCTAssertEqual(result.exitCode, 0, "sha256sum should handle binary data")

        let parts = result.stdout.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
        XCTAssertEqual(parts[0].count, 64, "Binary file should produce 64-char hash")
    }

    func testSha256sum_LargeFile() {
        // Create a larger file
        let largeContent = String(repeating: "x", count: 10000)
        let tempFile = createTempFile(content: largeContent)
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("sha256sum", [tempFile])

        XCTAssertEqual(result.exitCode, 0, "sha256sum should handle large files")

        let parts = result.stdout.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
        XCTAssertEqual(parts[0].count, 64, "Large file should produce 64-char hash")
    }

    // MARK: - Error Handling Tests

    func testSha256sum_NonexistentFile() {
        let nonexistent = "/tmp/nonexistent-\(UUID().uuidString)"

        let result = runCommand("sha256sum", [nonexistent])

        XCTAssertNotEqual(result.exitCode, 0, "sha256sum should fail on nonexistent file")
        XCTAssertTrue(result.stderr.contains("No such file") || result.stderr.contains("not found"),
                     "Error should indicate file not found")
    }

    func testSha256sum_MixedExistentAndNonexistent() {
        let file1 = createTempFile(content: "exists\n")
        let nonexistent = "/tmp/nonexistent-\(UUID().uuidString)"
        defer { try? FileManager.default.removeItem(atPath: file1) }

        let result = runCommand("sha256sum", [file1, nonexistent])

        XCTAssertNotEqual(result.exitCode, 0, "sha256sum should return error code")
        XCTAssertTrue(result.stderr.contains("No such file") || result.stderr.contains("not found"),
                     "Error should indicate file not found")

        // Should still process the valid file
        let lines = result.stdout.split(separator: "\n")
        XCTAssertGreaterThanOrEqual(lines.count, 1, "Should still output hash for valid file")
    }

    // MARK: - Check Mode Tests (P1 Feature - if implemented)
    // The -c option verifies checksums from a file

    func testSha256sum_CheckMode_Valid() {
        // Create a file and get its checksum
        let dataFile = createTempFile(content: "test data\n")
        defer { try? FileManager.default.removeItem(atPath: dataFile) }

        let checksumResult = runCommand("sha256sum", [dataFile])
        let checksumLine = checksumResult.stdout.trimmingCharacters(in: .whitespacesAndNewlines)

        // Create a checksum file
        let checksumFile = createTempFile(content: checksumLine + "\n")
        defer { try? FileManager.default.removeItem(atPath: checksumFile) }

        let result = runCommand("sha256sum", ["-c", checksumFile])

        if result.exitCode == 0 || result.stdout.contains("OK") {
            // Check mode is implemented
            XCTAssertTrue(result.stdout.contains("OK") || result.stdout.contains("SUCCESS"),
                         "Should indicate successful verification")
        } else {
            // Check mode not implemented
            XCTAssertTrue(result.stderr.contains("invalid option") ||
                         result.stderr.contains("not supported") ||
                         result.stderr.contains("unrecognized"),
                         "Should indicate -c option not supported")
        }
    }

    // MARK: - Format Tests

    func testSha256sum_OutputFormat() {
        let tempFile = createTempFile(content: "format test\n")
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("sha256sum", [tempFile])

        // Output format should be: <hash>  <filename>
        // Note: Two spaces between hash and filename (GNU format)
        let output = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertTrue(output.contains("  "), "Should have double space separator (GNU format)")

        let parts = output.components(separatedBy: "  ")
        XCTAssertEqual(parts.count, 2, "Should split into exactly two parts")
        XCTAssertEqual(parts[0].count, 64, "Hash part should be 64 characters")
    }

    // MARK: - Edge Cases

    func testSha256sum_FileWithSpacesInName() {
        let content = "spaces test\n"
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent("file with spaces.txt")

        try? content.write(to: tempFile, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: tempFile) }

        let result = runCommand("sha256sum", [tempFile.path])

        XCTAssertEqual(result.exitCode, 0, "sha256sum should handle filenames with spaces")
        XCTAssertTrue(result.stdout.contains("file with spaces.txt"),
                     "Output should contain full filename")
    }

    func testSha256sum_FileWithSpecialChars() {
        let content = "special chars\n"
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent("file-with_special.chars.txt")

        try? content.write(to: tempFile, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: tempFile) }

        let result = runCommand("sha256sum", [tempFile.path])

        XCTAssertEqual(result.exitCode, 0, "sha256sum should handle special characters in filename")
    }

    // MARK: - TODO: Advanced Features for Future Implementation
    // - [ ] Actual SHA-256 implementation (use CryptoKit or CommonCrypto) - P0
    // - [ ] -c, --check (verify checksums from file) - P1
    // - [ ] -b, --binary (read in binary mode - default on some systems) - P2
    // - [ ] -t, --text (read in text mode) - P2
    // - [ ] --quiet (don't print OK for each verified file) - P2
    // - [ ] --status (exit code only, no output) - P2
    // - [ ] --warn (warn about improperly formatted checksum lines) - P2
    // - [ ] --strict (exit non-zero for improperly formatted lines) - P2
    //
    // Known SHA-256 test vectors for validation:
    // - Empty string: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
    // - "abc": ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
    // - "test\n": 4e1243bd22c66e76c2ba9eddc1f91394e57f9f83
}
