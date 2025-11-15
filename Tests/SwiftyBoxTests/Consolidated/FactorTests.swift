// FactorTests.swift
// Auto-generated from BusyBox factor.tests
// DO NOT EDIT - regenerate with import-busybox-tests.py

import XCTest

final class FactorTests: XCTestCase {
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

    func testFactor1_2() {
        runner.testing(
            "factor +1",
            command: "factor +1",
            expectedOutput: "1:\\n"
        )
    }

    func testFactor1024_3() {
        runner.testing(
            "factor 1024",
            command: "factor 1024",
            expectedOutput: "1024: 2 2 2 2 2 2 2 2 2 2\\n"
        )
    }

    func testFactor2611_4() {
        runner.testing(
            "factor 2^61-1",
            command: "factor 2305843009213693951",
            expectedOutput: "2305843009213693951: 2305843009213693951\\n"
        )
    }

    func testFactor2621_5() {
        runner.testing(
            "factor 2^62-1",
            command: "factor 4611686018427387903",
            expectedOutput: "4611686018427387903: 3 715827883 2147483647\\n"
        )
    }

    func testFactor2641_6() {
        runner.testing(
            "factor 2^64-1",
            command: "factor 18446744073709551615",
            expectedOutput: "18446744073709551615: 3 5 17 257 641 65537 6700417\\n"
        )
    }

    func testFactor23571113171923293137414347_7() {
        runner.testing(
            "factor \\$((2*3*5*7*11*13*17*19*23*29*31*37*41*43*47))",
            command: "factor \\$((2*3*5*7*11*13*17*19*23*29*31*37*41*43*47))",
            expectedOutput: "614889782588491410: 2 3 5 7 11 13 17 19 23 29 31 37 41 43 47\\n"
        )
    }

    func testFactor230370004933037000493_8() {
        runner.testing(
            "factor 2 * 3037000493 * 3037000493",
            command: "factor 18446743988964486098",
            expectedOutput: "18446743988964486098: 2 3037000493 3037000493\\n"
        )
    }

    func testFactor324797005132479700513_9() {
        runner.testing(
            "factor 3 * 2479700513 * 2479700513",
            command: "factor 18446743902517389507",
            expectedOutput: "18446743902517389507: 3 2479700513 2479700513\\n"
        )
    }

    func testFactor337831378313783137831_10() {
        runner.testing(
            "factor 3 * 37831 * 37831 * 37831 * 37831",
            command: "factor 6144867742934288163",
            expectedOutput: "6144867742934288163: 3 37831 37831 37831 37831\\n"
        )
    }

    func testFactor31316_11() {
        runner.testing(
            "factor 3 * 13^16",
            command: "factor 1996249827549539523",
            expectedOutput: "1996249827549539523: 3 13 13 13 13 13 13 13 13 13 13 13 13 13 13 13 13\\n"
        )
    }

    func testFactor1316_12() {
        runner.testing(
            "factor 13^16",
            command: "factor 665416609183179841",
            expectedOutput: "665416609183179841: 13 13 13 13 13 13 13 13 13 13 13 13 13 13 13 13\\n"
        )
    }

}

