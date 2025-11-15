// UncompressTests.swift
// Auto-generated from BusyBox uncompress.tests
// DO NOT EDIT - regenerate with import-busybox-tests.py

import XCTest

final class UncompressTests: XCTestCase {
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

    func testUncompressX1fX9dX90X01XN_2() {
        runner.testing(
            "uncompress < \\x1f\\x9d\\x90 \\x01 x N",
            command: "uncompress 2>&1 1>/dev/null; echo $?",
            expectedOutput: " uncompress: corrupted data\n1\n",
            stdin: " \\x1f\\x9d\\x90 \\01\\01\\01\\01\\01\\01\\01\\01\\01\\01\\01\\01\\01\\01\\01\\01\\01\\01\\01\\01\\01\\01\\01\\01\\01\\01\\01\\01\\01\\01\\01\\01 "
        )
    }

}

