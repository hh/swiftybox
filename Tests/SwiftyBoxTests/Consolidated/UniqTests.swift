// UniqTests.swift
// Auto-generated from BusyBox uniq.tests
// DO NOT EDIT - regenerate with import-busybox-tests.py

import XCTest

final class UniqTests: XCTestCase {
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
            command: "options",
            expectedOutput: "expected result",
            inputFile: "file input",
            stdin: "stdin"
        )
    }

    func testUniqExitSuccess_2() {
        runner.testing(
            "uniq (exit success)",
            command: "uniq /dev/null && echo yes",
            expectedOutput: "yes\\n"
        )
    }

    func testUniqDefaultToStdin_3() {
        runner.testing(
            "uniq (default to stdin)",
            command: "uniq",
            expectedOutput: "one\\ntwo\\nthree\\n"
        )
    }

    func testUniqSpecifyStdin_4() {
        runner.testing(
            "uniq - (specify stdin)",
            command: "uniq -",
            expectedOutput: "one\\ntwo\\nthree\\n"
        )
    }

    func testUniqInputSpecifyFile_5() {
        runner.testing(
            "uniq input (specify file)",
            command: "uniq input",
            expectedOutput: "one\\ntwo\\nthree\\n"
        )
    }

    func testUniqDDupsOnly_6() {
        runner.testing(
            "uniq -d (dups only)",
            command: "uniq -d",
            expectedOutput: "two\\nthree\\n"
        )
    }

    func testUniqUAndDProduceNoOutput_7() {
        runner.testing(
            "uniq -u and -d produce no output",
            command: "uniq -d -u",
            expectedOutput: ""
        )
    }

}

