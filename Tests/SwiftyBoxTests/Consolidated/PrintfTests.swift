// PrintfTests.swift
// Auto-generated from BusyBox printf.tests
// DO NOT EDIT - regenerate with import-busybox-tests.py

import XCTest

final class PrintfTests: XCTestCase {
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

}

