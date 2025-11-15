// ExpandTests.swift
// Auto-generated from BusyBox expand.tests
// DO NOT EDIT - regenerate with import-busybox-tests.py

import XCTest

final class ExpandTests: XCTestCase {
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

    func testExpand_2() {
        runner.testing(
            "expand",
            command: "expand",
            expectedOutput: "        12345678        12345678\n",
            stdin: "\t12345678\t12345678\n"
        )
    }

    func testExpandWithUnicodeCharacher0x394_3() {
        runner.testing(
            "expand with unicode characher 0x394",
            command: "expand",
            expectedOutput: "Δ       12345ΔΔΔ        12345678\n",
            stdin: "Δ\t12345ΔΔΔ\t12345678\n"
        )
    }

    // MARK: - Enhanced Tests (Session 3)

    func testExpand_multipleTabs() {
        let input = "\t\t\t\n"
        let result = runCommandWithInput("expand", [], input: input)

        XCTAssertEqual(result.exitCode, 0, "expand should handle multiple tabs")
        XCTAssertEqual(result.stdout, "                        \n", "Three tabs should expand to 24 spaces")
    }

    func testExpand_customTabStop() {
        let input = "\ttest\n"
        let result = runCommandWithInput("expand", ["-t", "4"], input: input)

        if result.exitCode == 0 {
            XCTAssertEqual(result.stdout, "    test\n", "Tab should expand to 4 spaces with -t 4")
        }
    }

    func testExpand_noTabs() {
        let input = "no tabs here\n"
        let result = runCommandWithInput("expand", [], input: input)

        XCTAssertEqual(result.exitCode, 0)
        XCTAssertEqual(result.stdout, input, "Input without tabs should remain unchanged")
    }

    func testExpand_mixedContent() {
        let input = "start\tmiddle\tend\n"
        let result = runCommandWithInput("expand", [], input: input)

        XCTAssertEqual(result.exitCode, 0)
        XCTAssertTrue(result.stdout.contains("start"), "Should contain original content")
        XCTAssertFalse(result.stdout.contains("\t"), "Should not contain tabs")
    }

    func testExpand_emptyInput() {
        let result = runCommandWithInput("expand", [], input: "")

        XCTAssertEqual(result.exitCode, 0)
        XCTAssertEqual(result.stdout, "", "Empty input should produce empty output")
    }

    func testExpand_file() {
        let tempFile = createTempFile(content: "\tindented\n")
        defer { try? FileManager.default.removeItem(atPath: tempFile) }

        let result = runCommand("expand", [tempFile])

        XCTAssertEqual(result.exitCode, 0)
        XCTAssertFalse(result.stdout.contains("\t"), "File tabs should be expanded")
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

