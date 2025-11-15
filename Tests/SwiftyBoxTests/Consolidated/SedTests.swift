// SedTests.swift
// Auto-generated from BusyBox sed.tests
// DO NOT EDIT - regenerate with import-busybox-tests.py

import XCTest

final class SedTests: XCTestCase {
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
            command: "commands",
            expectedOutput: "result",
            inputFile: "infile",
            stdin: "stdin"
        )
    }

    func testSedN_2() {
        runner.testing(
            "sed -n",
            command: "sed -n -e s/foo/bar/ -e s/bar/baz/",
            expectedOutput: "",
            stdin: "foo\\n"
        )
    }

    func testSedSP_3() {
        runner.testing(
            "sed s//p",
            command: "sed -e s/foo/bar/p -e s/bar/baz/p",
            expectedOutput: "bar\\nbaz\\nbaz\\n"
        )
    }

    func testSedNSP_4() {
        runner.testing(
            "sed -n s//p",
            command: "sed -ne s/abc/def/p",
            expectedOutput: "def\\n",
            stdin: "abc\\n"
        )
    }

    func testSedSChains_5() {
        runner.testing(
            "sed s chains",
            command: "sed -e s/foo/bar/ -e s/bar/baz/",
            expectedOutput: "baz\\n",
            stdin: "foo\\n"
        )
    }

    func testSedSChains2_6() {
        runner.testing(
            "sed s chains2",
            command: "sed -e s/foo/bar/ -e s/baz/nee/",
            expectedOutput: "bar\\n",
            stdin: "foo\\n"
        )
    }

    func testSedGAppendHoldSpaceToPatternSpace_7() {
        runner.testing(
            "sed G (append hold space to pattern space)",
            command: "sed G",
            expectedOutput: "a\\n\\nb\\n\\nc\\n\\n"
        )
    }

    func testSedNulInCommand_8() {
        runner.testing(
            "sed NUL in command",
            command: "sed -f sed.commands",
            expectedOutput: "woo\\nhe\\0llo\\n",
            stdin: "woo"
        )
    }

    func testDescription_9() {
        runner.testing(
            "description",
            command: "commands",
            expectedOutput: "result",
            inputFile: "infile",
            stdin: "stdin"
        )
    }

    func testDescription_10() {
        runner.testing(
            "description",
            command: "commands",
            expectedOutput: "result",
            inputFile: "infile",
            stdin: "stdin"
        )
    }

}

