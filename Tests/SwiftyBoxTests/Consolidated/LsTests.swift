import XCTest
@testable import swiftybox

final class LsTests: XCTestCase {
    var testDir: String!

    override func setUp() {
        super.setUp()
        testDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("LsTests_\(UUID().uuidString)")
            .path
        try? FileManager.default.createDirectory(atPath: testDir, withIntermediateDirectories: true)
    }

    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(atPath: testDir)
    }

    // MARK: - Basic ls Tests

    func testLsOneColumnFormat() {
        // Create test files
        FileManager.default.createFile(atPath: "\(testDir!)/file1.txt", contents: nil)
        FileManager.default.createFile(atPath: "\(testDir!)/file2.txt", contents: nil)
        FileManager.default.createFile(atPath: "\(testDir!)/file3.txt", contents: nil)

        let result = runCommand("ls", ["-1", testDir!])
        XCTAssertEqual(result.exitCode, 0, "ls -1 should succeed")

        let lines = result.stdout.split(separator: "\n").map(String.init)
        XCTAssertTrue(lines.contains("file1.txt"), "Should list file1.txt")
        XCTAssertTrue(lines.contains("file2.txt"), "Should list file2.txt")
        XCTAssertTrue(lines.contains("file3.txt"), "Should list file3.txt")
        XCTAssertGreaterThanOrEqual(lines.count, 3, "Should have at least 3 files")
    }

    func testLsLongFormat() {
        // Create a test file
        FileManager.default.createFile(atPath: "\(testDir!)/testfile.txt", contents: Data("test".utf8))

        let result = runCommand("ls", ["-l", testDir!])
        XCTAssertEqual(result.exitCode, 0, "ls -l should succeed")

        // Check that output contains file permissions and filename
        XCTAssertTrue(result.stdout.contains("testfile.txt"), "Should show filename")
        // Long format should show permissions (starts with - or d)
        let lines = result.stdout.split(separator: "\n")
        let hasPermissions = lines.contains { line in
            line.hasPrefix("-") || line.hasPrefix("d")
        }
        XCTAssertTrue(hasPermissions, "Long format should show file permissions")
    }

    func testLsHumanReadable() {
        // Create a test file
        let data = Data(repeating: 0, count: 2048) // 2KB file
        FileManager.default.createFile(atPath: "\(testDir!)/largefile.txt", contents: data)

        let result = runCommand("ls", ["-h", testDir!])
        XCTAssertEqual(result.exitCode, 0, "ls -h should succeed")
        XCTAssertTrue(result.stdout.contains("largefile.txt"), "Should list the file")
    }

    func testLsWithSizeOption() {
        // Create a test file
        FileManager.default.createFile(atPath: "\(testDir!)/file.txt", contents: Data("data".utf8))

        let result = runCommand("ls", ["-1s", testDir!])
        XCTAssertEqual(result.exitCode, 0, "ls -1s should succeed")

        // Output should contain the filename
        XCTAssertTrue(result.stdout.contains("file.txt"), "Should list the file")
        // With -s option, each line should start with a number (the size in blocks)
        let lines = result.stdout.split(separator: "\n")
        let hasSizes = lines.contains { line in
            let parts = line.split(separator: " ")
            return parts.count >= 2 && Int(parts[0]) != nil
        }
        XCTAssertTrue(hasSizes, "Output with -s should show block sizes")
    }

    func testLsEmptyDirectory() {
        let emptyDir = "\(testDir!)/empty"
        try? FileManager.default.createDirectory(atPath: emptyDir, withIntermediateDirectories: true)

        let result = runCommand("ls", [emptyDir])
        XCTAssertEqual(result.exitCode, 0, "ls on empty directory should succeed")
        XCTAssertTrue(result.stdout.isEmpty || result.stdout == "\n",
                     "ls on empty directory should produce minimal output")
    }

    func testLsNonexistentDirectory() {
        let result = runCommand("ls", ["/nonexistent/directory/that/does/not/exist"])
        XCTAssertNotEqual(result.exitCode, 0, "ls on nonexistent directory should fail")
        XCTAssertFalse(result.stderr.isEmpty, "Should produce error message")
    }

    func testLsSortedOutput() {
        // Create files in non-alphabetical order
        FileManager.default.createFile(atPath: "\(testDir!)/zebra.txt", contents: nil)
        FileManager.default.createFile(atPath: "\(testDir!)/apple.txt", contents: nil)
        FileManager.default.createFile(atPath: "\(testDir!)/monkey.txt", contents: nil)

        let result = runCommand("ls", ["-1", testDir!])
        XCTAssertEqual(result.exitCode, 0, "ls should succeed")

        let lines = result.stdout.split(separator: "\n").map(String.init).filter { !$0.isEmpty }
        let relevantLines = lines.filter { $0.hasSuffix(".txt") }

        // Files should appear in sorted order
        let appleIndex = relevantLines.firstIndex(of: "apple.txt")
        let monkeyIndex = relevantLines.firstIndex(of: "monkey.txt")
        let zebraIndex = relevantLines.firstIndex(of: "zebra.txt")

        XCTAssertNotNil(appleIndex, "Should list apple.txt")
        XCTAssertNotNil(monkeyIndex, "Should list monkey.txt")
        XCTAssertNotNil(zebraIndex, "Should list zebra.txt")

        if let a = appleIndex, let m = monkeyIndex, let z = zebraIndex {
            XCTAssertTrue(a < m && m < z, "Files should be sorted alphabetically")
        }
    }
}
