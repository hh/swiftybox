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

}

