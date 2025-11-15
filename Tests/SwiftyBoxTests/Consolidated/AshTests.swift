// AshTests.swift
// Tests for ASH shell integration with Swift commands
// Verifies that ASH properly calls Swift NOFORK implementations

import XCTest
import Foundation

final class AshTests: XCTestCase {
    var swiftyboxPath: String {
        let cwd = FileManager.default.currentDirectoryPath
        return "\(cwd)/.build/debug/swiftybox"
    }

    // MARK: - Helper Methods

    /// Run shell command via ASH
    func runShell(_ command: String) -> (output: String, exitCode: Int32) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["sh", "-c", command]

        let stdout = Pipe()
        let stderr = Pipe()
        task.standardOutput = stdout
        task.standardError = stderr

        try? task.run()
        task.waitUntilExit()

        let outputData = stdout.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8) ?? ""

        return (output, task.terminationStatus)
    }

    // MARK: - Swift NOFORK Command Tests

    func testASH_callsSwiftEcho() {
        let result = runShell("echo 'Hello from Swift'")
        XCTAssertEqual(result.exitCode, 0, "Shell should execute successfully")
        XCTAssertTrue(result.output.contains("Hello from Swift"),
                     "ASH should call Swift echo implementation")
    }

    func testASH_callsSwiftPwd() {
        let result = runShell("pwd")
        XCTAssertEqual(result.exitCode, 0, "Shell should execute successfully")
        XCTAssertFalse(result.output.isEmpty, "PWD should return current directory")
    }

    func testASH_callsSwiftTrue() {
        let result = runShell("true")
        XCTAssertEqual(result.exitCode, 0, "Swift true should return 0")
    }

    func testASH_callsSwiftFalse() {
        let result = runShell("false")
        XCTAssertEqual(result.exitCode, 1, "Swift false should return 1")
    }

    func testASH_callsSwiftTest() {
        let result = runShell("test 1 -eq 1")
        XCTAssertEqual(result.exitCode, 0, "Swift test should evaluate true")

        let result2 = runShell("test 1 -eq 2")
        XCTAssertEqual(result2.exitCode, 1, "Swift test should evaluate false")
    }

    // MARK: - Pipe Tests (Critical for ASH Integration)

    func testASH_pipeToSwiftCommand() {
        let result = runShell("echo hello | cat")
        XCTAssertEqual(result.exitCode, 0, "Pipe should work")
        XCTAssertTrue(result.output.contains("hello"), "Pipe should pass data")
    }

    func testASH_pipeChain() {
        let result = runShell("echo -e 'line1\\nline2\\nline3' | wc -l")
        XCTAssertEqual(result.exitCode, 0, "Pipe chain should work")
        XCTAssertTrue(result.output.contains("3"), "WC should count 3 lines")
    }

    func testASH_pipeWithSort() {
        let result = runShell("printf '3\\n1\\n2\\n' | sort")
        XCTAssertEqual(result.exitCode, 0, "Sort pipe should work")
        XCTAssertTrue(result.output.hasPrefix("1"), "Sort should order correctly")
    }

    // MARK: - Command Chaining Tests

    func testASH_commandChainWithSemicolon() {
        let result = runShell("echo first; echo second; echo third")
        XCTAssertEqual(result.exitCode, 0, "Command chain should execute")
        XCTAssertTrue(result.output.contains("first"), "Should contain first")
        XCTAssertTrue(result.output.contains("second"), "Should contain second")
        XCTAssertTrue(result.output.contains("third"), "Should contain third")
    }

    func testASH_commandChainWithAND() {
        let result = runShell("true && echo success")
        XCTAssertEqual(result.exitCode, 0, "AND chain should work")
        XCTAssertTrue(result.output.contains("success"), "Should execute second command")

        let result2 = runShell("false && echo fail")
        XCTAssertEqual(result2.exitCode, 1, "AND should stop on failure")
        XCTAssertFalse(result2.output.contains("fail"), "Should not execute second command")
    }

    func testASH_commandChainWithOR() {
        let result = runShell("false || echo fallback")
        XCTAssertEqual(result.exitCode, 0, "OR chain should work")
        XCTAssertTrue(result.output.contains("fallback"), "Should execute fallback")

        let result2 = runShell("true || echo skip")
        XCTAssertEqual(result2.exitCode, 0, "OR should short-circuit on success")
        XCTAssertFalse(result2.output.contains("skip"), "Should skip second command")
    }

    // MARK: - Redirect Tests

    func testASH_redirectOutput() {
        let result = runShell("echo 'test data' > /tmp/ash-test.txt && cat /tmp/ash-test.txt")
        XCTAssertEqual(result.exitCode, 0, "Redirect should work")
        XCTAssertTrue(result.output.contains("test data"), "Data should be written and read")
    }

    func testASH_appendOutput() {
        let result = runShell("echo 'line1' > /tmp/ash-append.txt && echo 'line2' >> /tmp/ash-append.txt && cat /tmp/ash-append.txt")
        XCTAssertEqual(result.exitCode, 0, "Append should work")
        XCTAssertTrue(result.output.contains("line1"), "Should contain first line")
        XCTAssertTrue(result.output.contains("line2"), "Should contain second line")
    }

    // MARK: - Variable Tests

    func testASH_environmentVariables() {
        let result = runShell("VAR=hello; echo $VAR")
        XCTAssertEqual(result.exitCode, 0, "Variable assignment should work")
        XCTAssertTrue(result.output.contains("hello"), "Variable should be accessible")
    }

    func testASH_exportVariables() {
        let result = runShell("export TEST_VAR=value; printenv TEST_VAR")
        XCTAssertEqual(result.exitCode, 0, "Export should work")
        XCTAssertTrue(result.output.contains("value"), "Exported variable should be accessible")
    }

    // MARK: - Control Flow Tests

    func testASH_ifStatement() {
        let result = runShell("if true; then echo yes; fi")
        XCTAssertEqual(result.exitCode, 0, "If statement should work")
        XCTAssertTrue(result.output.contains("yes"), "Then branch should execute")
    }

    func testASH_ifElseStatement() {
        let result = runShell("if false; then echo no; else echo yes; fi")
        XCTAssertEqual(result.exitCode, 0, "If-else should work")
        XCTAssertTrue(result.output.contains("yes"), "Else branch should execute")
    }

    func testASH_forLoop() {
        let result = runShell("for i in 1 2 3; do echo $i; done")
        XCTAssertEqual(result.exitCode, 0, "For loop should work")
        XCTAssertTrue(result.output.contains("1"), "Should iterate value 1")
        XCTAssertTrue(result.output.contains("2"), "Should iterate value 2")
        XCTAssertTrue(result.output.contains("3"), "Should iterate value 3")
    }

    func testASH_whileLoop() {
        let result = runShell("i=1; while test $i -le 3; do echo $i; i=$((i+1)); done")
        XCTAssertEqual(result.exitCode, 0, "While loop should work")
        XCTAssertTrue(result.output.contains("1"), "Loop should run iteration 1")
        XCTAssertTrue(result.output.contains("2"), "Loop should run iteration 2")
        XCTAssertTrue(result.output.contains("3"), "Loop should run iteration 3")
    }

    // MARK: - Swift vs BusyBox Performance Test

    func testASH_swiftNOFORKPerformance() {
        // Test that Swift NOFORK commands are being called (no fork overhead)
        let start = Date()
        _ = runShell("echo test > /dev/null")
        let swiftTime = Date().timeIntervalSince(start)

        // Swift NOFORK should be extremely fast (< 1ms typically)
        // This is a sanity check, not a precise benchmark
        XCTAssertLessThan(swiftTime, 0.1, "Swift NOFORK should be very fast")
    }

    // MARK: - Edge Cases

    func testASH_emptyCommand() {
        let result = runShell("")
        XCTAssertEqual(result.exitCode, 0, "Empty command should succeed")
    }

    func testASH_commentOnly() {
        let result = runShell("# This is a comment")
        XCTAssertEqual(result.exitCode, 0, "Comment should be ignored")
    }

    func testASH_multilineScript() {
        let script = """
        echo line1
        echo line2
        echo line3
        """
        let result = runShell(script)
        XCTAssertEqual(result.exitCode, 0, "Multiline script should work")
        XCTAssertTrue(result.output.contains("line1"), "Should execute line 1")
        XCTAssertTrue(result.output.contains("line2"), "Should execute line 2")
        XCTAssertTrue(result.output.contains("line3"), "Should execute line 3")
    }

    // MARK: - Complex Real-World Scenarios

    func testASH_findAndProcess() {
        // Create test files
        _ = runShell("mkdir -p /tmp/ash-test && echo data1 > /tmp/ash-test/file1.txt && echo data2 > /tmp/ash-test/file2.txt")

        let result = runShell("ls /tmp/ash-test/*.txt | wc -l")
        XCTAssertEqual(result.exitCode, 0, "Find and count should work")
        XCTAssertTrue(result.output.contains("2"), "Should find 2 files")
    }

    func testASH_errorHandling() {
        let result = runShell("false || echo recovered")
        XCTAssertEqual(result.exitCode, 0, "Error recovery should work")
        XCTAssertTrue(result.output.contains("recovered"), "Should execute recovery command")
    }

    func testASH_commandSubstitution() {
        let result = runShell("echo \"Result: $(echo nested)\"")
        XCTAssertEqual(result.exitCode, 0, "Command substitution should work")
        XCTAssertTrue(result.output.contains("nested"), "Should substitute command output")
    }
}
