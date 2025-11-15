// TestTests.swift
// Auto-generated from BusyBox test.tests
// DO NOT EDIT - regenerate with import-busybox-tests.py

import XCTest

final class TestTests: XCTestCase {
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

    func testTestShouldBeFalse1_2() {
        runner.testing(
            "test: should be false (1)",
            command: "busybox test; echo \\$?",
            expectedOutput: "1\\n"
        )
    }

    func testTestShouldBeTrue0_3() {
        runner.testing(
            "test !: should be true (0)",
            command: "busybox test !; echo \\$?",
            expectedOutput: "0\\n"
        )
    }

    func testTestAShouldBeTrue0_4() {
        runner.testing(
            "test a: should be true (0)",
            command: "busybox test a; echo \\$?",
            expectedOutput: "0\\n"
        )
    }

    func testTestHelpShouldBeTrue0_5() {
        runner.testing(
            "test --help: should be true (0)",
            command: "busybox test --help; echo \\$?",
            expectedOutput: "0\\n"
        )
    }

    func testTestFShouldBeTrue0_6() {
        runner.testing(
            "test -f: should be true (0)",
            command: "busybox test -f; echo \\$?",
            expectedOutput: "0\\n"
        )
    }

    func testTestFShouldBeFalse1_7() {
        runner.testing(
            "test ! -f: should be false (1)",
            command: "busybox test ! -f; echo \\$?",
            expectedOutput: "1\\n"
        )
    }

    func testTestAAShouldBeTrue0_8() {
        runner.testing(
            "test a = a: should be true (0)",
            command: "busybox test a = a; echo \\$?",
            expectedOutput: "0\\n"
        )
    }

    func testTestLtGtShouldBeFalse1_9() {
        runner.testing(
            "test -lt = -gt: should be false (1)",
            command: "busybox test -lt = -gt; echo \\$?",
            expectedOutput: "1\\n"
        )
    }

    func testTestAAShouldBeTrue0_10() {
        runner.testing(
            "test a -a !: should be true (0)",
            command: "busybox test a -a !; echo \\$?",
            expectedOutput: "0\\n"
        )
    }

    func testTestFAOBShouldBeTrue0_11() {
        runner.testing(
            "test -f = a -o b: should be true (0)",
            command: "busybox test -f = a -o b; echo \\$?",
            expectedOutput: "0\\n"
        )
    }

    func testTestABACCShouldBeFalse1_12() {
        runner.testing(
            "test ! a = b -a ! c = c: should be false (1)",
            command: "busybox test ! a = b -a ! c = c; echo \\$?",
            expectedOutput: "1\\n"
        )
    }

    func testTestABACDShouldBeTrue0_13() {
        runner.testing(
            "test ! a = b -a ! c = d: should be true (0)",
            command: "busybox test ! a = b -a ! c = d; echo \\$?",
            expectedOutput: "0\\n"
        )
    }

}

