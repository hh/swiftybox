// TestRunner.swift
// BusyBox-compatible test runner for SwiftyλBox

import Foundation

/// Result of a test execution
public struct TestResult {
    let name: String
    let passed: Bool
    let expected: String
    let actual: String
    let exitCode: Int32

    var description: String {
        if passed {
            return "PASS: \(name)"
        } else {
            return """
            FAIL: \(name)
            Expected output:
            \(expected)
            Actual output:
            \(actual)
            Exit code: \(exitCode)
            """
        }
    }
}

/// BusyBox-compatible test runner
public class TestRunner {
    private var failCount = 0
    private var passCount = 0
    private let verbose: Bool
    private let swiftyboxPath: String

    public init(verbose: Bool = false, swiftyboxPath: String) {
        self.verbose = verbose
        self.swiftyboxPath = swiftyboxPath
    }

    /// Run a test in BusyBox testing.sh format
    /// - Parameters:
    ///   - name: Test description
    ///   - command: Command to execute (will replace 'busybox' with swiftybox path)
    ///   - expectedOutput: Expected stdout
    ///   - inputFile: Data to write to 'input' file (optional)
    ///   - stdin: Data to pipe to stdin (optional)
    /// - Returns: TestResult
    @discardableResult
    public func testing(
        _ name: String,
        command: String,
        expectedOutput: String,
        inputFile: String = "",
        stdin: String = ""
    ) -> TestResult {
        // Replace 'busybox' with swiftybox path in command
        let actualCommand = command
            .replacingOccurrences(of: "busybox ", with: "\(swiftyboxPath) ")
            .replacingOccurrences(of: "`which busybox`", with: swiftyboxPath)

        // Create temporary directory for test execution
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("swiftybox-test-\(UUID().uuidString)")

        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }

        do {
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

            // Write input file if provided
            if !inputFile.isEmpty {
                let inputPath = tempDir.appendingPathComponent("input")
                try inputFile.data(using: .utf8)?.write(to: inputPath)
            }

            // Execute command
            let result = executeCommand(
                actualCommand,
                stdin: stdin,
                workingDirectory: tempDir.path
            )

            // Compare output
            let passed = result.stdout == expectedOutput && result.exitCode == 0

            if passed {
                passCount += 1
            } else {
                failCount += 1
            }

            let testResult = TestResult(
                name: name,
                passed: passed,
                expected: expectedOutput,
                actual: result.stdout,
                exitCode: result.exitCode
            )

            print(testResult.description)
            if verbose && !passed {
                printDiff(expected: expectedOutput, actual: result.stdout)
            }

            return testResult

        } catch {
            failCount += 1
            let testResult = TestResult(
                name: name,
                passed: false,
                expected: expectedOutput,
                actual: "ERROR: \(error)",
                exitCode: -1
            )
            print(testResult.description)
            return testResult
        }
    }

    /// Execute a shell command and capture output
    private func executeCommand(
        _ command: String,
        stdin: String,
        workingDirectory: String
    ) -> (stdout: String, stderr: String, exitCode: Int32) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/sh")
        task.arguments = ["-c", command]
        task.currentDirectoryURL = URL(fileURLWithPath: workingDirectory)

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        let stdinPipe = Pipe()

        task.standardOutput = stdoutPipe
        task.standardError = stderrPipe
        task.standardInput = stdinPipe

        do {
            try task.run()

            // Write stdin
            if !stdin.isEmpty {
                if let data = stdin.data(using: .utf8) {
                    stdinPipe.fileHandleForWriting.write(data)
                }
            }
            try? stdinPipe.fileHandleForWriting.close()

            task.waitUntilExit()

            let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
            let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()

            let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
            let stderr = String(data: stderrData, encoding: .utf8) ?? ""

            return (stdout, stderr, task.terminationStatus)
        } catch {
            return ("", "Failed to execute: \(error)", -1)
        }
    }

    /// Print unified diff of expected vs actual
    private func printDiff(expected: String, actual: String) {
        print("======================")
        print("--- expected")
        print("+++ actual")

        let expectedLines = expected.split(separator: "\n", omittingEmptySubsequences: false)
        let actualLines = actual.split(separator: "\n", omittingEmptySubsequences: false)

        for (index, (exp, act)) in zip(expectedLines, actualLines).enumerated() {
            if exp != act {
                print("@@ Line \(index + 1) @@")
                print("- \(exp)")
                print("+ \(act)")
            }
        }

        // Handle different lengths
        if expectedLines.count != actualLines.count {
            print("@@ Length mismatch @@")
            print("Expected \(expectedLines.count) lines, got \(actualLines.count) lines")
        }
    }

    /// Print summary statistics
    public func printSummary() {
        let total = passCount + failCount
        print("\n" + String(repeating: "=", count: 50))
        print("Test Summary:")
        print("  Total:  \(total)")
        print("  Passed: \(passCount)")
        print("  Failed: \(failCount)")
        if total > 0 {
            let percentage = Double(passCount) / Double(total) * 100
            print("  Success: \(String(format: "%.1f", percentage))%")
        }
        print(String(repeating: "=", count: 50))
    }

    /// Get failure count for exit code
    public var failureCount: Int { failCount }
}

// MARK: - Global Helper Functions for Tests

/// Command execution result
public struct CommandResult: Equatable {
    public let exitCode: Int32
    public let stdout: String
    public let stderr: String

    public init(exitCode: Int32, stdout: String, stderr: String) {
        self.exitCode = exitCode
        self.stdout = stdout
        self.stderr = stderr
    }
}

/// Simple command execution helper for tests
public func runCommand(_ command: String, _ args: [String]) -> CommandResult {
    let task = Process()
    let cwd = FileManager.default.currentDirectoryPath
    let swiftyboxPath = "\(cwd)/.build/debug/swiftybox"

    task.executableURL = URL(fileURLWithPath: swiftyboxPath)
    task.arguments = [command] + args

    let stdoutPipe = Pipe()
    let stderrPipe = Pipe()

    task.standardOutput = stdoutPipe
    task.standardError = stderrPipe

    do {
        try task.run()
        task.waitUntilExit()

        let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()

        let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
        let stderr = String(data: stderrData, encoding: .utf8) ?? ""

        return CommandResult(exitCode: task.terminationStatus, stdout: stdout, stderr: stderr)
    } catch {
        return CommandResult(exitCode: -1, stdout: "", stderr: "Failed to execute: \(error)")
    }
}

/// Command execution with stdin input
public func runCommandWithInput(_ command: String, _ args: [String], input: String) -> CommandResult {
    let task = Process()
    let cwd = FileManager.default.currentDirectoryPath
    let swiftyboxPath = "\(cwd)/.build/debug/swiftybox"

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

        // Write stdin
        if let data = input.data(using: .utf8) {
            stdinPipe.fileHandleForWriting.write(data)
        }
        try? stdinPipe.fileHandleForWriting.close()

        task.waitUntilExit()

        let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()

        let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
        let stderr = String(data: stderrData, encoding: .utf8) ?? ""

        return CommandResult(exitCode: task.terminationStatus, stdout: stdout, stderr: stderr)
    } catch {
        return CommandResult(exitCode: -1, stdout: "", stderr: "Failed to execute: \(error)")
    }
}
