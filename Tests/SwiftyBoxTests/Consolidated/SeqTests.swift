// SeqTests.swift
// Auto-generated from BusyBox seq.tests
// DO NOT EDIT - regenerate with import-busybox-tests.py

import XCTest

final class SeqTests: XCTestCase {
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

    func testSeqExitWithError_2() {
        runner.testing(
            "seq (exit with error)",
            command: "seq 2> /dev/null || echo yes",
            expectedOutput: "yes\\n"
        )
    }

    func testSeqOneArgument_3() {
        runner.testing(
            "seq one argument",
            command: "seq 3",
            expectedOutput: "1\\n2\\n3\\n"
        )
    }

    func testSeqTwoArguments_4() {
        runner.testing(
            "seq two arguments",
            command: "seq 5 7",
            expectedOutput: "5\\n6\\n7\\n"
        )
    }

    func testSeqTwoArgumentsReversed_5() {
        runner.testing(
            "seq two arguments reversed",
            command: "seq 7 5",
            expectedOutput: ""
        )
    }

    func testSeqTwoArgumentsEqual_6() {
        runner.testing(
            "seq two arguments equal",
            command: "seq 3 3",
            expectedOutput: "3\\n"
        )
    }

    func testSeqCountUpBy2_7() {
        runner.testing(
            "seq count up by 2",
            command: "seq 4 2 8",
            expectedOutput: "4\\n6\\n8\\n"
        )
    }

    func testSeqCountDownBy2_8() {
        runner.testing(
            "seq count down by 2",
            command: "seq 8 -2 4",
            expectedOutput: "8\\n6\\n4\\n"
        )
    }

    func testSeqCountWrongWay1_9() {
        runner.testing(
            "seq count wrong way #1",
            command: "seq 4 -2 8",
            expectedOutput: ""
        )
    }

    func testSeqCountWrongWay2_10() {
        runner.testing(
            "seq count wrong way #2",
            command: "seq 8 2 4",
            expectedOutput: ""
        )
    }

    func testSeqCountBy3_11() {
        runner.testing(
            "seq count by .3",
            command: "seq 3 .3 4",
            expectedOutput: "3.0\\n3.3\\n3.6\\n3.9\\n"
        )
    }

    func testSeqCountBy30_12() {
        runner.testing(
            "seq count by .30",
            command: "seq 3 .30 4",
            expectedOutput: "3.00\\n3.30\\n3.60\\n3.90\\n"
        )
    }

    func testSeqCountBy30To4000_13() {
        runner.testing(
            "seq count by .30 to 4.000",
            command: "seq 3 .30 4.000",
            expectedOutput: "3.00\\n3.30\\n3.60\\n3.90\\n"
        )
    }

    func testSeqCountBy9_14() {
        runner.testing(
            "seq count by -.9",
            command: "seq .7 -.9 -2.2",
            expectedOutput: "0.7\\n-0.2\\n-1.1\\n-2.0\\n"
        )
    }

    func testSeqCountByZero_15() {
        runner.testing(
            "seq count by zero",
            command: "seq 4 0 8 | head -n 10",
            expectedOutput: "4\\n4\\n4\\n4\\n4\\n4\\n4\\n4\\n4\\n4\\n"
        )
    }

    func testSeqOneArgumentWithPadding_16() {
        runner.testing(
            "seq one argument with padding",
            command: "seq -w 003",
            expectedOutput: "001\\n002\\n003\\n"
        )
    }

    func testSeqTwoArgumentsWithPadding_17() {
        runner.testing(
            "seq two arguments with padding",
            command: "seq -w 005 7",
            expectedOutput: "005\\n006\\n007\\n"
        )
    }

    func testSeqCountDownBy3WithPadding_18() {
        runner.testing(
            "seq count down by 3 with padding",
            command: "seq -w 8 -3 04",
            expectedOutput: "08\\n05\\n"
        )
    }

    func testSeqCountBy3WithPadding1_19() {
        runner.testing(
            "seq count by .3 with padding 1",
            command: "seq -w 09 .3 11",
            expectedOutput: "09.0\\n09.3\\n09.6\\n09.9\\n10.2\\n10.5\\n10.8\\n"
        )
    }

    func testSeqCountBy3WithPadding2_20() {
        runner.testing(
            "seq count by .3 with padding 2",
            command: "seq -w 03 .3 0004",
            expectedOutput: "0003.0\\n0003.3\\n0003.6\\n0003.9\\n"
        )
    }

    func testSeqFrom4CountDownBy2_21() {
        runner.testing(
            "seq from -4 count down by 2",
            command: "seq -4 -2 -8",
            expectedOutput: "-4\\n-6\\n-8\\n"
        )
    }

    func testSeqFrom0CountDownBy25_22() {
        runner.testing(
            "seq from -.0 count down by .25",
            command: "seq -.0 -.25 -.9",
            expectedOutput: "-0.00\\n-0.25\\n-0.50\\n-0.75\\n"
        )
    }

    func testSeqSWithNegativeStart_23() {
        runner.testing(
            "seq -s : with negative start",
            command: "seq -s : -1 1",
            expectedOutput: "-1:0:1\\n"
        )
    }

}

