// CommTests.swift
// Auto-generated from BusyBox comm.tests
// DO NOT EDIT - regenerate with import-busybox-tests.py

import XCTest

final class CommTests: XCTestCase {
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

    func testCommTest1_2() {
        runner.testing(
            "comm test 1",
            command: "comm input -",
            expectedOutput: "\\t123\\n",
            inputFile: "456\\n",
            stdin: "abc\\n"
        )
    }

    func testCommTest2_3() {
        runner.testing(
            "comm test 2",
            command: "comm - input",
            expectedOutput: "123\\n",
            inputFile: "\\t456\\n",
            stdin: "\\tabc\\n"
        )
    }

    func testCommTest3_4() {
        runner.testing(
            "comm test 3",
            command: "comm input -",
            expectedOutput: "abc\\n",
            inputFile: "\\tdef\\n",
            stdin: "xyz\\n"
        )
    }

    func testCommTest4_5() {
        runner.testing(
            "comm test 4",
            command: "comm - input",
            expectedOutput: "\\tabc\\n",
            inputFile: "def\\n",
            stdin: "\\txyz\\n"
        )
    }

    func testCommTest5_6() {
        runner.testing(
            "comm test 5",
            command: "comm input -",
            expectedOutput: "123\\n",
            inputFile: "abc\\n",
            stdin: "\\tdef\\n"
        )
    }

    func testCommTest6_7() {
        runner.testing(
            "comm test 6",
            command: "comm - input",
            expectedOutput: "\\t123\\n",
            inputFile: "\\tabc\\n",
            stdin: "def\\n"
        )
    }

    func testCommUnterminatedLine1_8() {
        runner.testing(
            "comm unterminated line 1",
            command: "comm input -",
            expectedOutput: "abc\\n",
            inputFile: "\\tdef\\n",
            stdin: "abc"
        )
    }

    func testCommUnterminatedLine2_9() {
        runner.testing(
            "comm unterminated line 2",
            command: "comm - input",
            expectedOutput: "\\tabc\\n",
            inputFile: "def\\n",
            stdin: "abc"
        )
    }

}

