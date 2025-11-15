// TsortTests.swift
// Auto-generated from BusyBox tsort.tests
// DO NOT EDIT - regenerate with import-busybox-tests.py

import XCTest

final class TsortTests: XCTestCase {
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

    func testTest1_1() {
        runner.testing(
            "",
            command: "tsort",
            expectedOutput: "a\\n",
            stdin: "a a\\n"
        )
    }

    func testTest2_2() {
        runner.testing(
            "",
            command: "tsort -",
            expectedOutput: "a\\n",
            stdin: "a a\\n"
        )
    }

    func testTest3_3() {
        runner.testing(
            "",
            command: "tsort input",
            expectedOutput: "a\\n",
            inputFile: "a a\\n"
        )
    }

    func testTsortInputWOEol_4() {
        runner.testing(
            "tsort input (w/o eol)",
            command: "tsort input",
            expectedOutput: "a\\n",
            inputFile: "a a"
        )
    }

    func testTest5_5() {
        runner.testing(
            "",
            command: "tsort /dev/null",
            expectedOutput: ""
        )
    }

}

