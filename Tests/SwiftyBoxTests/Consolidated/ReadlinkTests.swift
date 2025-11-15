// ReadlinkTests.swift
// Auto-generated from BusyBox readlink.tests
// DO NOT EDIT - regenerate with import-busybox-tests.py

import XCTest

final class ReadlinkTests: XCTestCase {
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

    func testReadlinkOnAFile_1() {
        runner.testing(
            "readlink on a file",
            command: "readlink ./$TESTFILE",
            expectedOutput: ""
        )
    }

    func testReadlinkOnALink_2() {
        runner.testing(
            "readlink on a link",
            command: "readlink ./$TESTLINK",
            expectedOutput: "./$TESTFILE\\n"
        )
    }

    func testReadlinkFOnAFile_3() {
        runner.testing(
            "readlink -f on a file",
            command: "readlink -f ./$TESTFILE",
            expectedOutput: "$pwd/$TESTFILE\\n"
        )
    }

    func testReadlinkFOnALink_4() {
        runner.testing(
            "readlink -f on a link",
            command: "readlink -f ./$TESTLINK",
            expectedOutput: "$pwd/$TESTFILE\\n"
        )
    }

    func testReadlinkFOnAnInvalidLink_5() {
        runner.testing(
            "readlink -f on an invalid link",
            command: "readlink -f ./$FAILLINK",
            expectedOutput: ""
        )
    }

    func testReadlinkFOnAWeirdDir_6() {
        runner.testing(
            "readlink -f on a weird dir",
            command: "readlink -f $TESTDIR/../$TESTFILE",
            expectedOutput: "$pwd/$TESTFILE\\n"
        )
    }

}

