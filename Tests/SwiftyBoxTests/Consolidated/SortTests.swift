// SortTests.swift
// Auto-generated from BusyBox sort.tests
// DO NOT EDIT - regenerate with import-busybox-tests.py

import XCTest

final class SortTests: XCTestCase {
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

    func testSort_1() {
        runner.testing(
            "sort",
            command: "sort input",
            expectedOutput: "a\\nb\\nc\\n",
            inputFile: "c\\na\\nb\\n"
        )
    }

    func testSort2_2() {
        runner.testing(
            "sort #2",
            command: "sort input",
            expectedOutput: "010\\n1\\n3\\n",
            inputFile: "3\\n1\\n010\\n"
        )
    }

    func testSortStdin_3() {
        runner.testing(
            "sort stdin",
            command: "sort",
            expectedOutput: "a\\nb\\nc\\n",
            stdin: "b\\na\\nc\\n"
        )
    }

    func testSortNumeric_4() {
        runner.testing(
            "sort numeric",
            command: "sort -n input",
            expectedOutput: "1\\n3\\n010\\n",
            inputFile: "3\\n1\\n010\\n"
        )
    }

    func testSortReverse_5() {
        runner.testing(
            "sort reverse",
            command: "sort -r input",
            expectedOutput: "wook\\nwalrus\\npoint\\npabst\\naargh\\n"
        )
    }

    func testDescription_6() {
        runner.testing(
            "description",
            command: "command(s)",
            expectedOutput: "result",
            inputFile: "infile",
            stdin: "stdin"
        )
    }

    func testSortKeyRangeWithTwoKOptions_7() {
        runner.testing(
            "sort key range with two -k options",
            command: "sort -k 2,2n -k 1,1r input",
            expectedOutput: "\\\nd 2\nb 2\nc 3\n",
            inputFile: "\\\nc 3\nb 2\nd 2\n"
        )
    }

    func testSortWithNonDefaultLeadingDelim1_8() {
        runner.testing(
            "sort with non-default leading delim 1",
            command: "sort -n -k2 -t/ input",
            expectedOutput: "\\\n/a/2\n/b/1\n",
            inputFile: "\\\n/a/2\n/b/1\n"
        )
    }

    func testSortWithNonDefaultLeadingDelim2_9() {
        runner.testing(
            "sort with non-default leading delim 2",
            command: "sort -n -k3 -t/ input",
            expectedOutput: "\\\n/b/1\n/a/2\n",
            inputFile: "\\\n/b/1\n/a/2\n"
        )
    }

    func testSortWithNonDefaultLeadingDelim3_10() {
        runner.testing(
            "sort with non-default leading delim 3",
            command: "sort -n -k3 -t/ input",
            expectedOutput: "\\\n//a/2\n//b/1\n",
            inputFile: "\\\n//a/2\n//b/1\n"
        )
    }

    func testSortWithNonDefaultLeadingDelim4_11() {
        runner.testing(
            "sort with non-default leading delim 4",
            command: "sort -t: -k1,1 input",
            expectedOutput: "\\\na:b\na/a:a\n",
            inputFile: "\\\na/a:a\na:b\n"
        )
    }

    func testSortWithEndchar_12() {
        runner.testing(
            "sort with ENDCHAR",
            command: "sort -t. -k1,1.1 -k2 input",
            expectedOutput: "\\\nab.1\naa.2\n",
            inputFile: "\\\naa.2\nab.1\n"
        )
    }

    func testGlibcBuildSort_13() {
        runner.testing(
            "glibc build sort",
            command: "sort -t. -k 1,1 -k 2n,2n -k 3 input",
            expectedOutput: "\\\nGLIBC_2.1\nGLIBC_2.1.1\nGLIBC_2.2\nGLIBC_2.2.1\nGLIBC_2.10\nGLIBC_2.20\nGLIBC_2.21\n",
            inputFile: "\\\nGLIBC_2.21\nGLIBC_2.1.1\nGLIBC_2.2.1\nGLIBC_2.2\nGLIBC_2.20\nGLIBC_2.10\nGLIBC_2.1\n"
        )
    }

    func testGlibcBuildSortUnique_14() {
        runner.testing(
            "glibc build sort unique",
            command: "sort -u -t. -k 1,1 -k 2n,2n -k 3 input",
            expectedOutput: "\\\nGLIBC_2.1\nGLIBC_2.1.1\nGLIBC_2.2\nGLIBC_2.2.1\nGLIBC_2.10\nGLIBC_2.20\nGLIBC_2.21\n",
            inputFile: "\\\nGLIBC_2.10\nGLIBC_2.2.1\nGLIBC_2.1.1\nGLIBC_2.20\nGLIBC_2.2\nGLIBC_2.1\nGLIBC_2.21\n"
        )
    }

    func testSortUShouldConsiderFieldOnlyWhenDiscarding_15() {
        runner.testing(
            "sort -u should consider field only when discarding",
            command: "sort -u -k2 input",
            expectedOutput: "\\\na c\n",
            inputFile: "\\\na c\nb c\n"
        )
    }

    func testSortZOutputsNulTerminatedLines_16() {
        runner.testing(
            "sort -z outputs NUL terminated lines",
            command: "sort -z input",
            expectedOutput: "\\\none\\0three\\0two\\0\\\n",
            inputFile: "\\\none\\0two\\0three\\0\\\n"
        )
    }

    func testDescription_17() {
        runner.testing(
            "description",
            command: "command(s)",
            expectedOutput: "result",
            inputFile: "infile",
            stdin: "stdin"
        )
    }

}

