// UnexpandTests.swift
// Auto-generated from BusyBox unexpand.tests
// DO NOT EDIT - regenerate with import-busybox-tests.py

import XCTest

final class UnexpandTests: XCTestCase {
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

    func testUnexpandCase1_2() {
        runner.testing(
            "unexpand case 1",
            command: "unexpand",
            expectedOutput: "\t12345678\n",
            stdin: "        12345678\n"
        )
    }

    func testUnexpandCase2_3() {
        runner.testing(
            "unexpand case 2",
            command: "unexpand",
            expectedOutput: "\t 12345678\n",
            stdin: "         12345678\n"
        )
    }

    func testUnexpandCase3_4() {
        runner.testing(
            "unexpand case 3",
            command: "unexpand",
            expectedOutput: "\t  12345678\n",
            stdin: "          12345678\n"
        )
    }

    func testUnexpandCase4_5() {
        runner.testing(
            "unexpand case 4",
            command: "unexpand",
            expectedOutput: "\t12345678\n",
            stdin: "       \t12345678\n"
        )
    }

    func testUnexpandCase5_6() {
        runner.testing(
            "unexpand case 5",
            command: "unexpand",
            expectedOutput: "\t12345678\n",
            stdin: "      \t12345678\n"
        )
    }

    func testUnexpandCase6_7() {
        runner.testing(
            "unexpand case 6",
            command: "unexpand",
            expectedOutput: "\t12345678\n",
            stdin: "     \t12345678\n"
        )
    }

    func testUnexpandCase7_8() {
        runner.testing(
            "unexpand case 7",
            command: "unexpand",
            expectedOutput: "123\t 45678\n",
            stdin: "123 \t 45678\n"
        )
    }

    func testUnexpandCase8_9() {
        runner.testing(
            "unexpand case 8",
            command: "unexpand",
            expectedOutput: "a b\n",
            stdin: "a b\n"
        )
    }

    func testUnexpandFlags_10() {
        runner.testing(
            "unexpand flags $*",
            command: "unexpand $*",
            expectedOutput: "$want",
            stdin: "        a       b    c"
        )
    }

    func testUnexpandWithUnicodeCharacher0x394_11() {
        runner.testing(
            "unexpand with unicode characher 0x394",
            command: "unexpand",
            expectedOutput: "1ΔΔΔ5\t99999\n",
            stdin: "1ΔΔΔ5   99999\n"
        )
    }

}

