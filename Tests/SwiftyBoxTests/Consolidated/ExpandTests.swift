// ExpandTests.swift
// Auto-generated from BusyBox expand.tests
// DO NOT EDIT - regenerate with import-busybox-tests.py

import XCTest

final class ExpandTests: XCTestCase {
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

    func testExpand_2() {
        runner.testing(
            "expand",
            command: "expand",
            expectedOutput: "        12345678        12345678\\n",
            stdin: "\\t12345678\\t12345678\\n"
        )
    }

    func testExpandWithUnicodeCharacher0x394_3() {
        runner.testing(
            "expand with unicode characher 0x394",
            command: "expand",
            expectedOutput: "Δ       12345ΔΔΔ        12345678\\n",
            stdin: "Δ\\t12345ΔΔΔ\\t12345678\\n"
        )
    }

}

