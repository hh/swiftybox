// BasicCommandTests.swift
// Tests for basic NOFORK commands (Phase 1)

import XCTest

final class BasicCommandTests: XCTestCase {
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

    // MARK: - echo tests

    func testEcho_printsArgument() {
        runner.testing(
            "echo prints argument",
            command: "busybox echo fubar",
            expectedOutput: "fubar\n"
        )
    }

    func testEcho_printsArguments() {
        runner.testing(
            "echo prints multiple arguments",
            command: "busybox echo foo bar baz",
            expectedOutput: "foo bar baz\n"
        )
    }

    func testEcho_printsNewline() {
        runner.testing(
            "echo prints newline",
            command: "busybox echo",
            expectedOutput: "\n"
        )
    }

    func testEcho_suppressNewline() {
        runner.testing(
            "echo -n suppresses newline",
            command: "busybox echo -n foo",
            expectedOutput: "foo"
        )
    }

    func testEcho_printsDash() {
        runner.testing(
            "echo prints -",
            command: "busybox echo -",
            expectedOutput: "-\n"
        )
    }

    func testEcho_printsNonOpts() {
        runner.testing(
            "echo prints non-options after --",
            command: "busybox echo -- -n foo",
            expectedOutput: "-- -n foo\n"
        )
    }

    // MARK: - pwd tests

    func testPwd_printsWorkingDirectory() {
        let cwd = FileManager.default.currentDirectoryPath
        runner.testing(
            "pwd prints working directory",
            command: "cd '\(cwd)' && busybox pwd",
            expectedOutput: "\(cwd)\n"
        )
    }

    // MARK: - true/false tests

    func testTrue_returnsZero() {
        let result = runner.testing(
            "true returns 0",
            command: "busybox true",
            expectedOutput: ""
        )
        XCTAssertEqual(result.exitCode, 0)
    }

    func testFalse_returnsOne() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["false"]
        try? task.run()
        task.waitUntilExit()
        XCTAssertEqual(task.terminationStatus, 1, "false should return exit code 1")
    }

    // MARK: - cat tests

    func testCat_fromStdin() {
        runner.testing(
            "cat from stdin",
            command: "busybox cat",
            expectedOutput: "hello world\n",
            stdin: "hello world\n"
        )
    }

    func testCat_fromFile() {
        runner.testing(
            "cat from file",
            command: "busybox cat input",
            expectedOutput: "file contents\n",
            inputFile: "file contents\n"
        )
    }

    // MARK: - head tests

    func testHead_defaultLines() {
        let input = (1...20).map { "\($0)" }.joined(separator: "\n") + "\n"
        let expected = (1...10).map { "\($0)" }.joined(separator: "\n") + "\n"
        runner.testing(
            "head default 10 lines",
            command: "busybox head",
            expectedOutput: expected,
            stdin: input
        )
    }

    func testHead_customLines() {
        let input = "line1\nline2\nline3\nline4\n"
        runner.testing(
            "head -n 2",
            command: "busybox head -n 2",
            expectedOutput: "line1\nline2\n",
            stdin: input
        )
    }

    // MARK: - tail tests

    func testTail_defaultLines() {
        let input = (1...20).map { "\($0)" }.joined(separator: "\n") + "\n"
        let expected = (11...20).map { "\($0)" }.joined(separator: "\n") + "\n"
        runner.testing(
            "tail default 10 lines",
            command: "busybox tail",
            expectedOutput: expected,
            stdin: input
        )
    }

    func testTail_customLines() {
        let input = "line1\nline2\nline3\nline4\n"
        runner.testing(
            "tail -n 2",
            command: "busybox tail -n 2",
            expectedOutput: "line3\nline4\n",
            stdin: input
        )
    }

    // MARK: - wc tests

    func testWc_countLines() {
        runner.testing(
            "wc -l counts lines",
            command: "busybox wc -l",
            expectedOutput: "3\n",
            stdin: "line1\nline2\nline3\n"
        )
    }

    func testWc_countWords() {
        runner.testing(
            "wc -w counts words",
            command: "busybox wc -w",
            expectedOutput: "5\n",
            stdin: "one two three four five\n"
        )
    }

    func testWc_countBytes() {
        runner.testing(
            "wc -c counts bytes",
            command: "busybox wc -c",
            expectedOutput: "5\n",
            stdin: "hello"
        )
    }

    // MARK: - basename tests

    func testBasename_simple() {
        runner.testing(
            "basename simple path",
            command: "busybox basename /usr/bin/env",
            expectedOutput: "env\n"
        )
    }

    func testBasename_withSuffix() {
        runner.testing(
            "basename with suffix removal",
            command: "busybox basename /usr/bin/foo.txt .txt",
            expectedOutput: "foo\n"
        )
    }

    // MARK: - dirname tests

    func testDirname_simple() {
        runner.testing(
            "dirname simple path",
            command: "busybox dirname /usr/bin/env",
            expectedOutput: "/usr/bin\n"
        )
    }

    func testDirname_root() {
        runner.testing(
            "dirname root path",
            command: "busybox dirname /usr",
            expectedOutput: "/\n"
        )
    }

    // MARK: - uname tests

    func testUname_all() {
        // Just test that it runs and produces output
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["uname", "-a"]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        XCTAssertFalse(output.isEmpty, "uname -a should produce output")
        XCTAssertEqual(task.terminationStatus, 0)
    }

    // MARK: - seq tests

    func testSeq_simple() {
        runner.testing(
            "seq 1 to 5",
            command: "busybox seq 5",
            expectedOutput: "1\n2\n3\n4\n5\n"
        )
    }

    func testSeq_range() {
        runner.testing(
            "seq with start and end",
            command: "busybox seq 3 6",
            expectedOutput: "3\n4\n5\n6\n"
        )
    }

    func testSeq_step() {
        runner.testing(
            "seq with step",
            command: "busybox seq 0 2 10",
            expectedOutput: "0\n2\n4\n6\n8\n10\n"
        )
    }

    // MARK: - yes tests

    func testYes_default() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["yes"]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()

        // Let it run for a tiny bit
        usleep(10000) // 10ms
        task.terminate()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        XCTAssertTrue(output.contains("y\n"), "yes should output 'y\\n'")
    }
}
