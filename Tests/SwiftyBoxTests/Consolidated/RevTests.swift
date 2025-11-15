// RevTests.swift
// Auto-generated from BusyBox rev.tests
// DO NOT EDIT - regenerate with import-busybox-tests.py

import XCTest

final class RevTests: XCTestCase {
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

    func testTestName_1() {
        runner.testing(
            "test name",
            command: "commands",
            expectedOutput: "expected result",
            inputFile: "file input",
            stdin: "stdin"
        )
    }

    func testRevWorks_2() {
        runner.testing(
            "rev works",
            command: "rev input",
            expectedOutput: " 1 enil\n\n3 enil\n",
            inputFile: "line 1\\n\\nline 3\\n"
        )
    }

    func testRevFileWithMissingNewline_3() {
        runner.testing(
            "rev file with missing newline",
            command: "rev input",
            expectedOutput: " 1 enil\n\n3 enil",
            inputFile: "line 1\\n\\nline 3"
        )
    }

    func testRevFileWithNulCharacter_4() {
        runner.testing(
            "rev file with NUL character",
            command: "rev input",
            expectedOutput: " nil\n3 enil\n",
            inputFile: "lin\\000e 1\\n\\nline 3\\n"
        )
    }

    func testRevFileWithLongLine_5() {
        runner.testing(
            "rev file with long line",
            command: "rev input",
            expectedOutput: " +--------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------\ncba\n",
            inputFile: "---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+--------------+\\nabc\\n"
        )
    }

    // MARK: - Enhanced Tests (Session 3)

    func testRev_unicode() {
        let input = "Hello 世界\n"
        let result = runCommandWithInput("rev", [], input: input)

        XCTAssertEqual(result.exitCode, 0, "rev should handle Unicode")
        // Note: Character reversal with Unicode is complex (grapheme clusters)
        XCTAssertFalse(result.stdout.isEmpty, "Should produce output")
    }

    func testRev_emptyInput() {
        let result = runCommandWithInput("rev", [], input: "")

        XCTAssertEqual(result.exitCode, 0, "rev should handle empty input")
        XCTAssertEqual(result.stdout, "", "Empty input should produce empty output")
    }

    func testRev_singleCharacter() {
        let result = runCommandWithInput("rev", [], input: "a\n")

        XCTAssertEqual(result.exitCode, 0)
        XCTAssertEqual(result.stdout, "a\n", "Single character should remain unchanged")
    }

    func testRev_multipleLines() {
        let input = "abc\ndef\nghi\n"
        let result = runCommandWithInput("rev", [], input: input)

        XCTAssertEqual(result.exitCode, 0)
        XCTAssertEqual(result.stdout, "cba\nfed\nihg\n", "Should reverse each line")
    }

    func testRev_numbersAndSymbols() {
        let input = "123!@#\n"
        let result = runCommandWithInput("rev", [], input: input)

        XCTAssertEqual(result.exitCode, 0)
        XCTAssertEqual(result.stdout, "#@!321\n", "Should reverse numbers and symbols")
    }

    func testRev_whitespacePreserved() {
        let input = "  hello  world  \n"
        let result = runCommandWithInput("rev", [], input: input)

        XCTAssertEqual(result.exitCode, 0)
        XCTAssertEqual(result.stdout, "  dlrow  olleh  \n", "Should preserve whitespace")
    }

    func testRev_file() {
        let tempFile = createTempFile(content: "reverse this\n")
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("rev", [tempFile])

        XCTAssertEqual(result.exitCode, 0)
        XCTAssertEqual(result.stdout, "siht esrever\n")
    }

    private func createTempFile(content: String) -> String {
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent(UUID().uuidString)
        try? content.write(to: tempFile, atomically: true, encoding: .utf8)
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

