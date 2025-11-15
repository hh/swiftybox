// HexdumpTests.swift
// Auto-generated from BusyBox hexdump.tests
// DO NOT EDIT - regenerate with import-busybox-tests.py

import XCTest

final class HexdumpTests: XCTestCase {
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

    func testDescription_1() {
        runner.testing(
            "description",
            command: "command",
            expectedOutput: "result",
            inputFile: "infile",
            stdin: "stdin"
        )
    }

}

