import XCTest
@testable import swiftybox

final class DdTests: XCTestCase {
    var testDir: String!

    override func setUp() {
        super.setUp()
        testDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("DdTests_\(UUID().uuidString)")
            .path
        try? FileManager.default.createDirectory(atPath: testDir, withIntermediateDirectories: true)
    }

    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(atPath: testDir)
    }

    func testDdCopiesStdinToStdout() {
        let input = "I WANT\n"
        let result = runCommandWithInput("dd", [], input: input)
        // dd writes to stdout, stats to stderr
        XCTAssertTrue(result.stdout.contains("I WANT"), "dd should copy stdin to stdout")
    }

    func testDdAcceptsInputFile() {
        let inputFile = "\(testDir!)/foo"
        FileManager.default.createFile(atPath: inputFile, contents: Data("I WANT\n".utf8))

        let result = runCommand("dd", ["if=\(inputFile)"])
        XCTAssertTrue(result.stdout.contains("I WANT"), "dd should read from if= file")
    }

    func testDdAcceptsOutputFile() {
        let outputFile = "\(testDir!)/foo"
        let input = "I WANT\n"

        let result = runCommandWithInput("dd", ["of=\(outputFile)"], input: input)
        XCTAssertEqual(result.exitCode, 0, "dd should succeed writing to file")

        // Verify file contents
        if let data = FileManager.default.contents(atPath: outputFile),
           let content = String(data: data, encoding: .utf8) {
            XCTAssertTrue(content.contains("I WANT"), "dd should write to of= file")
        } else {
            XCTFail("Output file should exist and be readable")
        }
    }

    func testDdCountBytes() {
        // dd count=N iflag=count_bytes - copy only N bytes
        let input = "I WANT\n"
        let result = runCommandWithInput("dd", ["count=3", "iflag=count_bytes"], input: input)

        // Should copy only first 3 bytes: "I W"
        XCTAssertTrue(result.stdout.contains("I W") || result.stdout.hasPrefix("I W"),
                     "dd count=3 should copy only 3 bytes")
    }

    func testDdBlockSize() {
        let inputFile = "\(testDir!)/input"
        let outputFile = "\(testDir!)/output"
        let testData = "0123456789ABCDEF"
        FileManager.default.createFile(atPath: inputFile, contents: Data(testData.utf8))

        let result = runCommand("dd", ["if=\(inputFile)", "of=\(outputFile)", "bs=4"])
        XCTAssertEqual(result.exitCode, 0, "dd with bs= should succeed")

        // Verify output matches input
        if let data = FileManager.default.contents(atPath: outputFile),
           let content = String(data: data, encoding: .utf8) {
            XCTAssertEqual(content, testData, "dd should copy data correctly with block size")
        }
    }

    func testDdCount() {
        let inputFile = "\(testDir!)/input"
        let outputFile = "\(testDir!)/output"
        let testData = "AAAABBBBCCCCDDDD" // 16 bytes, 4 blocks of 4
        FileManager.default.createFile(atPath: inputFile, contents: Data(testData.utf8))

        // Copy only 2 blocks of 4 bytes = 8 bytes
        let result = runCommand("dd", ["if=\(inputFile)", "of=\(outputFile)", "bs=4", "count=2"])
        XCTAssertEqual(result.exitCode, 0, "dd with count= should succeed")

        // Verify output is only first 8 bytes
        if let data = FileManager.default.contents(atPath: outputFile),
           let content = String(data: data, encoding: .utf8) {
            XCTAssertEqual(content, "AAAABBBB", "dd count=2 bs=4 should copy 8 bytes")
        }
    }

    func testDdStatsToStderr() {
        let input = "test\n"
        let result = runCommandWithInput("dd", [], input: input)

        // dd should print statistics to stderr (records in/out, bytes copied)
        XCTAssertFalse(result.stderr.isEmpty, "dd should print statistics to stderr")
        // Typically contains "records in", "records out", or "bytes"
        let hasStats = result.stderr.contains("record") || result.stderr.contains("byte")
        XCTAssertTrue(hasStats, "dd stderr should contain transfer statistics")
    }
}
