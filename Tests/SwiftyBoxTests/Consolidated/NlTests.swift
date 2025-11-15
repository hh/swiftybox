// NlTests.swift
// Auto-generated from BusyBox nl.tests
// DO NOT EDIT - regenerate with import-busybox-tests.py

import XCTest

final class NlTests: XCTestCase {
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

    func testNlNumbersAllLines_2() {
        runner.testing(
            "nl numbers all lines",
            command: "nl -b a input",
            expectedOutput: " 1\tline 1\n     2\t\n     3\tline 3\n",
            inputFile: "line 1\\n\\nline 3\\n"
        )
    }

    func testNlNumbersNonEmptyLines_3() {
        runner.testing(
            "nl numbers non-empty lines",
            command: "nl -b t input",
            expectedOutput: " 1\tline 1\n       \n     2\tline 3\n",
            inputFile: "line 1\\n\\nline 3\\n"
        )
    }

    func testNlNumbersNoLines_4() {
        runner.testing(
            "nl numbers no lines",
            command: "nl -b n input",
            expectedOutput: " line 1\n       \n       line 3\n",
            inputFile: "line 1\\n\\nline 3\\n"
        )
    }

}

