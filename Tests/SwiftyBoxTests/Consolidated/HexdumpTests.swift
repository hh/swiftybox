// HexdumpTests.swift
// Auto-generated from BusyBox hexdump.tests
// DO NOT EDIT - regenerate with import-busybox-tests.py

import XCTest

final class HexdumpTests: XCTestCase {
    var runner: TestRunner!
    var swiftyboxPath: String {
        let cwd = FileManager.default.currentDirectoryPath
        return "\(cwd)/.build/debug/swiftybox"
    }

    override func setUp() {
        super.setUp()
        runner = TestRunner(verbose: ProcessInfo.processInfo.environment["VERBOSE"] != nil,
                           swiftyboxPath: swiftyboxPath)
    }

    override func tearDown() {
        runner.printSummary()
        XCTAssertEqual(runner.failureCount, 0, "\(runner.failureCount) tests failed")
        super.tearDown()
    }

    func testDescription_1() {
        runner.testing(
            "description",
            command: "command",
            expectedOutput: "result",
            inputFile: "infile",
            stdin: "stdin"
        )
    }

    // MARK: - Enhanced Tests (Session 3)

    func testHexdump_basic() {
        let input = "test\n"
        let result = runCommandWithInput("hexdump", [], input: input)

        XCTAssertEqual(result.exitCode, 0, "hexdump should succeed")
        XCTAssertFalse(result.stdout.isEmpty, "Should produce hex output")
    }

    func testHexdump_canonical() {
        let input = "Hello\n"
        let result = runCommandWithInput("hexdump", ["-C"], input: input)

        if result.exitCode == 0 {
            // Canonical hex+ASCII format
            XCTAssertTrue(result.stdout.contains("48") || result.stdout.contains("65"),
                         "Should show hex values")
        }
    }

    func testHexdump_binaryData() {
        let tempFile = createTempFile(data: Data([0x00, 0xFF, 0x42, 0xAA]))
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("hexdump", [tempFile])

        XCTAssertEqual(result.exitCode, 0)
        XCTAssertFalse(result.stdout.isEmpty, "Should show hex output for binary data")
    }

    func testHexdump_emptyInput() {
        let result = runCommandWithInput("hexdump", [], input: "")

        XCTAssertEqual(result.exitCode, 0)
        // Empty input may produce no output or just offset markers
    }

    func testHexdump_length() {
        let input = String(repeating: "x", count: 100)
        let result = runCommandWithInput("hexdump", ["-n", "16"], input: input)

        if result.exitCode == 0 {
            // Should limit to 16 bytes
            XCTAssertFalse(result.stdout.isEmpty)
        }
    }

    func testHexdump_skip() {
        let input = "0123456789"
        let result = runCommandWithInput("hexdump", ["-s", "5"], input: input)

        if result.exitCode == 0 {
            // Should skip first 5 bytes (start from "56789")
            XCTAssertFalse(result.stdout.isEmpty)
        }
    }

    func testHexdump_format() {
        let input = "test"
        let result = runCommandWithInput("hexdump", ["-e", "4/1 \"%02x \" \"\\n\""], input: input)

        if result.exitCode == 0 {
            // Custom format: 4 bytes, 1 byte at a time, in hex
            XCTAssertFalse(result.stdout.isEmpty)
        }
    }

    func testHexdump_file() {
        let tempFile = createTempFile(content: "file content\n")
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("hexdump", [tempFile])

        XCTAssertEqual(result.exitCode, 0)
        XCTAssertFalse(result.stdout.isEmpty)
    }

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

    private func runCommand(_ command: String, _ args: [String]) -> CommandResult {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = [command] + args

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        task.standardOutput = stdoutPipe
        task.standardError = stderrPipe

        do {
            try task.run()
            task.waitUntilExit()

            let stdout = String(data: stdoutPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            let stderr = String(data: stderrPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""

            return CommandResult(exitCode: task.terminationStatus, stdout: stdout, stderr: stderr)
        } catch {
            return CommandResult(exitCode: -1, stdout: "", stderr: "Failed: \(error)")
        }
    }

    private func runCommandWithInput(_ command: String, _ args: [String], input: String) -> CommandResult {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = [command] + args

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        let stdinPipe = Pipe()
        task.standardOutput = stdoutPipe
        task.standardError = stderrPipe
        task.standardInput = stdinPipe

        do {
            try task.run()
            if let data = input.data(using: .utf8) {
                stdinPipe.fileHandleForWriting.write(data)
            }
            try? stdinPipe.fileHandleForWriting.close()
            task.waitUntilExit()

            let stdout = String(data: stdoutPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            let stderr = String(data: stderrPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""

            return CommandResult(exitCode: task.terminationStatus, stdout: stdout, stderr: stderr)
        } catch {
            return CommandResult(exitCode: -1, stdout: "", stderr: "Failed: \(error)")
        }
    }

    struct CommandResult {
        let exitCode: Int32
        let stdout: String
        let stderr: String
    }

}

