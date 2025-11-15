// CalTests.swift
// Auto-generated from BusyBox cal.tests
// DO NOT EDIT - regenerate with import-busybox-tests.py

import XCTest

final class CalTests: XCTestCase {
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

    func testCal2000_2() {
        runner.testing(
            "cal 2000",
            command: "cal 1 2000",
            expectedOutput: "\\\n    January 2000\nSu Mo Tu We Th Fr Sa\n                   1\n 2  3  4  5  6  7  8\n 9 10 11 12 13 14 15\n16 17 18 19 20 21 22\n23 24 25 26 27 28 29\n30 31\n"
        )
    }

    func testUnicodeCal2000_3() {
        runner.testing(
            "unicode cal 2000",
            command: "LANG=zh_TW.utf8 cal 1 2000",
            expectedOutput: "\\\n    一月 2000\n日 一 二 三 四 五 六\n                   1\n 2  3  4  5  6  7  8\n 9 10 11 12 13 14 15\n16 17 18 19 20 21 22\n23 24 25 26 27 28 29\n30 31\n"
        )
    }

}

