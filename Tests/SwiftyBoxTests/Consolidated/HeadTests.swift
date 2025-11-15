// HeadTests.swift
// Auto-generated from BusyBox head.tests
// DO NOT EDIT - regenerate with import-busybox-tests.py

import XCTest

final class HeadTests: XCTestCase {
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
            command: "command",
            expectedOutput: "expected result",
            inputFile: "file input",
            stdin: "stdin"
        )
    }

    func testHeadWithoutArgs_2() {
        runner.testing(
            "head (without args)",
            command: "head head.input",
            expectedOutput: "line 1\\nline 2\\nline 3\\nline 4\\nline 5\\nline 6\\nline 7\\nline 8\\nline 9\\nline 10\\n"
        )
    }

    func testHeadNPositiveNumber_3() {
        runner.testing(
            "head -n <positive number>",
            command: "head -n 2 head.input",
            expectedOutput: "line 1\\nline 2\\n"
        )
    }

    func testHeadNNegativeNumber_4() {
        runner.testing(
            "head -n <negative number>",
            command: "head -n -9 head.input",
            expectedOutput: "line 1\\nline 2\\nline 3\\n"
        )
    }

}

