// RealpathTests.swift
// Auto-generated from BusyBox realpath.tests
// DO NOT EDIT - regenerate with import-busybox-tests.py

import XCTest

final class RealpathTests: XCTestCase {
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

    func testRealpathOnNonExistentAbsolutePath1_1() {
        runner.testing(
            "realpath on non-existent absolute path 1",
            command: "realpath /not_file",
            expectedOutput: "/not_file\\n"
        )
    }

    func testRealpathOnNonExistentAbsolutePath2_2() {
        runner.testing(
            "realpath on non-existent absolute path 2",
            command: "realpath /not_file/",
            expectedOutput: "/not_file\\n"
        )
    }

    func testRealpathOnNonExistentAbsolutePath3_3() {
        runner.testing(
            "realpath on non-existent absolute path 3",
            command: "realpath //not_file",
            expectedOutput: "/not_file\\n"
        )
    }

    func testRealpathOnNonExistentAbsolutePath4_4() {
        runner.testing(
            "realpath on non-existent absolute path 4",
            command: "realpath /not_dir/not_file 2>&1",
            expectedOutput: "realpath: /not_dir/not_file: No such file or directory\\n"
        )
    }

    func testRealpathOnNonExistentLocalFile1_5() {
        runner.testing(
            "realpath on non-existent local file 1",
            command: "realpath $TESTDIR/not_file",
            expectedOutput: "$pwd/$TESTDIR/not_file\\n"
        )
    }

    func testRealpathOnNonExistentLocalFile2_6() {
        runner.testing(
            "realpath on non-existent local file 2",
            command: "realpath $TESTDIR/not_dir/not_file 2>&1",
            expectedOutput: "realpath: $TESTDIR/not_dir/not_file: No such file or directory\\n"
        )
    }

    func testRealpathOnLinkToNonExistentFile1_7() {
        runner.testing(
            "realpath on link to non-existent file 1",
            command: "realpath $TESTLINK1",
            expectedOutput: "$pwd/$TESTDIR/not_file\\n"
        )
    }

    func testRealpathOnLinkToNonExistentFile2_8() {
        runner.testing(
            "realpath on link to non-existent file 2",
            command: "realpath $TESTLINK2 2>&1",
            expectedOutput: "realpath: $TESTLINK2: No such file or directory\\n"
        )
    }

    func testRealpathOnLinkToNonExistentFile3_9() {
        runner.testing(
            "realpath on link to non-existent file 3",
            command: "realpath ./$TESTLINK1",
            expectedOutput: "$pwd/$TESTDIR/not_file\\n"
        )
    }

    func testRealpathOnLinkToNonExistentFile4_10() {
        runner.testing(
            "realpath on link to non-existent file 4",
            command: "realpath ./$TESTLINK2 2>&1",
            expectedOutput: "realpath: ./$TESTLINK2: No such file or directory\\n"
        )
    }

}

