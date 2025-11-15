// HeadTests.swift
// Auto-generated from BusyBox head.tests
// DO NOT EDIT - regenerate with import-busybox-tests.py

import XCTest

final class HeadTests: XCTestCase {
    var runner: TestRunner!
    var swiftyboxPath: String {
        let cwd = FileManager.default.currentDirectoryPath
        return "\(cwd)/.build/debug/swiftybox"
    }

    // The head.input content used by all tests
    let headInputContent = """
line 1
line 2
line 3
line 4
line 5
line 6
line 7
line 8
line 9
line 10
line 11
line 12

"""

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

    func testHeadWithoutArgs_2() {
        runner.testing(
            "head (without args)",
            command: "cat > head.input << 'EOF'\n\(headInputContent)EOF\nhead head.input",
            expectedOutput: """
line 1
line 2
line 3
line 4
line 5
line 6
line 7
line 8
line 9
line 10

"""
        )
    }

    func testHeadNPositiveNumber_3() {
        runner.testing(
            "head -n <positive number>",
            command: "cat > head.input << 'EOF'\n\(headInputContent)EOF\nhead -n 2 head.input",
            expectedOutput: """
line 1
line 2

"""
        )
    }

    func testHeadNNegativeNumber_4() {
        runner.testing(
            "head -n <negative number>",
            command: "cat > head.input << 'EOF'\n\(headInputContent)EOF\nhead -n -9 head.input",
            expectedOutput: """
line 1
line 2
line 3

"""
        )
    }

}

