import XCTest
@testable import swiftybox

final class Md5sumTests: XCTestCase {
    var testDir: String!

    override func setUp() {
        super.setUp()
        testDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("Md5sumTests_\(UUID().uuidString)")
            .path
        try? FileManager.default.createDirectory(atPath: testDir, withIntermediateDirectories: true)
    }

    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(atPath: testDir)
    }

    func testMd5sumBasic() {
        // Create a test file
        let testFile = "\(testDir!)/test.txt"
        FileManager.default.createFile(atPath: testFile, contents: Data("Hello, World!\n".utf8))

        let result = runCommand("md5sum", [testFile])
        XCTAssertEqual(result.exitCode, 0, "md5sum should succeed")

        // md5sum output format: "hash  filename\n"
        let output = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = output.split(separator: " ", maxSplits: 1)
        XCTAssertEqual(parts.count, 2, "Output should be 'hash  filename'")

        let hash = String(parts[0])
        XCTAssertEqual(hash.count, 32, "MD5 hash should be 32 hex characters")
        XCTAssertTrue(hash.allSatisfy { "0123456789abcdef".contains($0.lowercased()) },
                     "Hash should only contain hex characters")
    }

    func testMd5sumEmptyFile() {
        let testFile = "\(testDir!)/empty.txt"
        FileManager.default.createFile(atPath: testFile, contents: Data())

        let result = runCommand("md5sum", [testFile])
        XCTAssertEqual(result.exitCode, 0, "md5sum on empty file should succeed")

        // MD5 of empty file is always d41d8cd98f00b204e9800998ecf8427e
        XCTAssertTrue(result.stdout.hasPrefix("d41d8cd98f00b204e9800998ecf8427e"),
                     "MD5 of empty file should be d41d8cd98f00b204e9800998ecf8427e")
    }

    func testMd5sumVerifyNonBinaryFile() {
        // Create a test file
        let testFile = "\(testDir!)/foo"
        FileManager.default.createFile(atPath: testFile, contents: Data())

        // Compute checksum and save to bar
        let checksumFile = "\(testDir!)/bar"
        let computeResult = runCommand("md5sum", [testFile])
        XCTAssertEqual(computeResult.exitCode, 0, "Computing md5sum should succeed")

        // Write the checksum to a file
        FileManager.default.createFile(atPath: checksumFile, contents: Data(computeResult.stdout.utf8))

        // Verify using -c flag
        let verifyResult = runCommand("md5sum", ["-c", checksumFile])
        XCTAssertEqual(verifyResult.exitCode, 0, "Verifying md5sum should succeed")
        XCTAssertTrue(verifyResult.stdout.contains("OK") || verifyResult.stdout.contains("ok"),
                     "Verification should report OK")
    }

    func testMd5sumMultipleFiles() {
        let file1 = "\(testDir!)/file1.txt"
        let file2 = "\(testDir!)/file2.txt"
        FileManager.default.createFile(atPath: file1, contents: Data("data1".utf8))
        FileManager.default.createFile(atPath: file2, contents: Data("data2".utf8))

        let result = runCommand("md5sum", [file1, file2])
        XCTAssertEqual(result.exitCode, 0, "md5sum on multiple files should succeed")

        let lines = result.stdout.split(separator: "\n")
        XCTAssertGreaterThanOrEqual(lines.count, 2, "Should output hash for each file")
        XCTAssertTrue(result.stdout.contains("file1.txt"), "Should show file1.txt")
        XCTAssertTrue(result.stdout.contains("file2.txt"), "Should show file2.txt")
    }

    func testMd5sumNonexistentFile() {
        let result = runCommand("md5sum", ["/nonexistent/file"])
        XCTAssertNotEqual(result.exitCode, 0, "md5sum on nonexistent file should fail")
        XCTAssertFalse(result.stderr.isEmpty, "Should produce error message")
    }

    func testMd5sumKnownHash() {
        // Test with a known input and expected MD5
        let testFile = "\(testDir!)/known.txt"
        FileManager.default.createFile(atPath: testFile, contents: Data("abc".utf8))

        let result = runCommand("md5sum", [testFile])
        XCTAssertEqual(result.exitCode, 0, "md5sum should succeed")

        // MD5("abc") = 900150983cd24fb0d6963f7d28e17f72
        XCTAssertTrue(result.stdout.hasPrefix("900150983cd24fb0d6963f7d28e17f72"),
                     "MD5('abc') should be 900150983cd24fb0d6963f7d28e17f72")
    }
}
