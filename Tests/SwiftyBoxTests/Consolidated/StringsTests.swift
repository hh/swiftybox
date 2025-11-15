import XCTest
@testable import swiftybox

final class StringsTests: XCTestCase {
    var testDir: String!

    override func setUp() {
        super.setUp()
        testDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("StringsTests_\(UUID().uuidString)")
            .path
        try? FileManager.default.createDirectory(atPath: testDir, withIntermediateDirectories: true)
    }

    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(atPath: testDir)
    }

    func testStringsBasic() {
        // Create a binary file with some printable strings mixed with binary data
        let testFile = "\(testDir!)/binary.dat"
        var data = Data()
        data.append(contentsOf: [0x00, 0x01, 0x02, 0x03]) // Binary junk
        data.append(contentsOf: "Hello World".utf8) // Printable string
        data.append(contentsOf: [0xFF, 0xFE, 0xFD]) // More binary
        data.append(contentsOf: "Testing123".utf8) // Another string
        data.append(contentsOf: [0x00, 0x00]) // Null bytes
        FileManager.default.createFile(atPath: testFile, contents: data)

        let result = runCommand("strings", [testFile])
        XCTAssertEqual(result.exitCode, 0, "strings should succeed")
        XCTAssertTrue(result.stdout.contains("Hello World") || result.stdout.contains("Testing123"),
                     "strings should extract printable strings")
    }

    func testStringsWithAllOption() {
        // strings -a scans entire file
        let testFile = "\(testDir!)/test.dat"
        let data = Data("embedded string here".utf8)
        FileManager.default.createFile(atPath: testFile, contents: data)

        let result = runCommand("strings", ["-a", testFile])
        XCTAssertEqual(result.exitCode, 0, "strings -a should succeed")
        XCTAssertTrue(result.stdout.contains("embedded string"),
                     "strings should find embedded strings")
    }

    func testStringsWithFilenameOption() {
        // strings -f shows filename before each string
        let testFile = "\(testDir!)/named.txt"
        FileManager.default.createFile(atPath: testFile, contents: Data("test string".utf8))

        let result = runCommand("strings", ["-f", testFile])
        XCTAssertEqual(result.exitCode, 0, "strings -f should succeed")
        // Output format: filename: string
        XCTAssertTrue(result.stdout.contains(testFile.split(separator: "/").last ?? ""),
                     "strings -f should include filename in output")
    }

    func testStringsEmptyFile() {
        let testFile = "\(testDir!)/empty.dat"
        FileManager.default.createFile(atPath: testFile, contents: Data())

        let result = runCommand("strings", [testFile])
        XCTAssertEqual(result.exitCode, 0, "strings on empty file should succeed")
        XCTAssertTrue(result.stdout.isEmpty, "strings on empty file should produce no output")
    }

    func testStringsBinaryFile() {
        // File with only binary data (no printable strings >= 4 chars)
        let testFile = "\(testDir!)/binary.dat"
        let data = Data([0x00, 0x01, 0xFF, 0xFE, 0x12, 0x34])
        FileManager.default.createFile(atPath: testFile, contents: data)

        let result = runCommand("strings", [testFile])
        XCTAssertEqual(result.exitCode, 0, "strings should succeed even with no strings found")
        // May or may not produce output depending on minimum string length
    }

    func testStringsTextFile() {
        // Plain text file should output the text
        let testFile = "\(testDir!)/text.txt"
        let content = "This is a plain text file\nWith multiple lines\nAll readable\n"
        FileManager.default.createFile(atPath: testFile, contents: Data(content.utf8))

        let result = runCommand("strings", [testFile])
        XCTAssertEqual(result.exitCode, 0, "strings on text file should succeed")
        // Should contain the text (or portions of it depending on min length)
        XCTAssertFalse(result.stdout.isEmpty, "strings should extract text from plain text file")
    }
}
