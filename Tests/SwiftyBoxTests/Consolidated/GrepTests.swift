// GrepTests.swift
// Auto-generated from BusyBox grep.tests
// DO NOT EDIT - regenerate with import-busybox-tests.py

import XCTest

final class GrepTests: XCTestCase {
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

    func testGrepDefaultToStdin_2() {
        runner.testing(
            "grep (default to stdin)",
            command: "grep two",
            expectedOutput: "two\n",
            stdin: "one\ntwo\nthree\n"
        )
    }

    func testGrepSpecifyStdin_3() {
        runner.testing(
            "grep - (specify stdin)",
            command: "grep two -",
            expectedOutput: "two\n",
            stdin: "one\ntwo\nthree\n"
        )
    }

    func testGrepInputSpecifyFile_4() {
        runner.testing(
            "grep input (specify file)",
            command: "grep two input",
            expectedOutput: "two\n",
            inputFile: "one\ntwo\nthree\n"
        )
    }

    func testGrepNoNewlineAtEol_5() {
        runner.testing(
            "grep (no newline at EOL)",
            command: "grep bug input",
            expectedOutput: "bug\n",
            inputFile: "bug"
        )
    }

    func testGrepHandlesNulInFiles_6() {
        runner.testing(
            "grep handles NUL in files",
            command: "grep -a foo input",
            expectedOutput: "\0foo\n",
            inputFile: "\0foo\n\n"
        )
    }

    func testGrepHandlesNulOnStdin_7() {
        runner.testing(
            "grep handles NUL on stdin",
            command: "grep -a foo",
            expectedOutput: "\0foo\n",
            stdin: "\0foo\n\n"
        )
    }

    func testGrepESupportsExtendedRegexps_8() {
        runner.testing(
            "grep -E supports extended regexps",
            command: "grep -E fo+",
            expectedOutput: "foo\n",
            stdin: "foo\nbar\n"
        )
    }

    func testGrepIsAlsoEgrep_9() {
        runner.testing(
            "grep is also egrep",
            command: "egrep foo",
            expectedOutput: "foo\n",
            stdin: "foo\nbar\n"
        )
    }

    func testTestName_10() {
        runner.testing(
            "test name",
            command: "commands",
            expectedOutput: "expected result",
            inputFile: "file input",
            stdin: "stdin"
        )
    }

}

