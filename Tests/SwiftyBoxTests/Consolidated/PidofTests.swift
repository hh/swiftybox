// PidofTests.swift
// Auto-generated from BusyBox pidof.tests
// DO NOT EDIT - regenerate with import-busybox-tests.py

import XCTest

final class PidofTests: XCTestCase {
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

    func testPidofThis_2() {
        runner.testing(
            "pidof this",
            command: "pidof pidof.tests | grep -o -w $$",
            expectedOutput: "$$\\n"
        )
    }

    func testPidofS_3() {
        runner.testing(
            "pidof -s",
            command: "pidof -s init",
            expectedOutput: "1\\n"
        )
    }

    func testPidofOPpid_4() {
        runner.testing(
            "pidof -o %PPID",
            command: "pidof -o %PPID pidof.tests | grep -o -w $$",
            expectedOutput: ""
        )
    }

    func testPidofOPpidNop_5() {
        runner.testing(
            "pidof -o %PPID NOP",
            command: "pidof -o %PPID -s init",
            expectedOutput: "1\\n"
        )
    }

    func testPidofOInit_6() {
        runner.testing(
            "pidof -o init",
            command: "pidof -o 1 init | grep -o -w 1",
            expectedOutput: ""
        )
    }

}

