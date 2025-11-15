// DiffTests.swift
// Auto-generated from BusyBox diff.tests
// DO NOT EDIT - regenerate with import-busybox-tests.py

import XCTest

final class DiffTests: XCTestCase {
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
            command: "commands",
            expectedOutput: "expected result",
            inputFile: "file input",
            stdin: "stdin"
        )
    }

    func testDiffOfStdin_2() {
        runner.testing(
            "diff of stdin",
            command: "diff -u - input | $TRIM_TAB",
            expectedOutput: " --- -\n+++ input\n@@ -1 +1,3 @@\n+qwe\n asd\n+zxc\n",
            inputFile: "qwe\\nasd\\nzxc\\n",
            stdin: "asd\\n"
        )
    }

    func testDiffOfStdinNoNewlineInTheFile_3() {
        runner.testing(
            "diff of stdin, no newline in the file",
            command: "diff -u - input | $TRIM_TAB",
            expectedOutput: " --- -\n+++ input\n@@ -1 +1,3 @@\n+qwe\n asd\n+zxc\n\\\\ No newline at end of file\n",
            inputFile: "qwe\\nasd\\nzxc",
            stdin: "asd\\n"
        )
    }

    func testDiffOfStdinTwice_4() {
        runner.testing(
            "diff of stdin, twice",
            command: "diff - -; echo $?; wc -c",
            expectedOutput: "0\\n5\\n",
            stdin: "stdin"
        )
    }

    func testDiffOfEmptyFileAgainstStdin_5() {
        runner.testing(
            "diff of empty file against stdin",
            command: "diff -u - input | $TRIM_TAB",
            expectedOutput: " --- -\n+++ input\n@@ -1 +0,0 @@\n-a\n",
            stdin: "a\\n"
        )
    }

    func testDiffOfEmptyFileAgainstNonemptyOne_6() {
        runner.testing(
            "diff of empty file against nonempty one",
            command: "diff -u - input | $TRIM_TAB",
            expectedOutput: " --- -\n+++ input\n@@ -0,0 +1 @@\n+a\n",
            inputFile: "a\\n"
        )
    }

    func testDiffBTreatsEofAsWhitespace_7() {
        runner.testing(
            "diff -b treats EOF as whitespace",
            command: "diff -ub - input; echo $?",
            expectedOutput: "0\\n",
            inputFile: "abc",
            stdin: "abc "
        )
    }

    func testDiffBTreatsAllSpacesAsEqual_8() {
        runner.testing(
            "diff -b treats all spaces as equal",
            command: "diff -ub - input; echo $?",
            expectedOutput: "0\\n",
            inputFile: "a \\t c\\n",
            stdin: "a\\t \\tc\\n"
        )
    }

    func testDiffBIgnoresChangesWhoseLinesAreAllBlank_9() {
        runner.testing(
            "diff -B ignores changes whose lines are all blank",
            command: "diff -uB - input; echo $?",
            expectedOutput: "0\\n",
            inputFile: "a\\n",
            stdin: "\\na\\n\\n"
        )
    }

    func testDiffBDoesNotIgnoreChangesWhoseLinesAreNotAllBlank_10() {
        runner.testing(
            "diff -B does not ignore changes whose lines are not all blank",
            command: "diff -uB - input | $TRIM_TAB",
            expectedOutput: " --- -\n+++ input\n@@ -1,3 +1 @@\n-\n-b\n-\n+a\n",
            inputFile: "a\\n",
            stdin: "\\nb\\n\\n"
        )
    }

    func testDiffBIgnoresBlankSingleLineChange_11() {
        runner.testing(
            "diff -B ignores blank single line change",
            command: "diff -qB - input; echo $?",
            expectedOutput: "0\\n",
            inputFile: "\\n1\\n",
            stdin: "1\\n"
        )
    }

    func testDiffBDoesNotIgnoreNonBlankSingleLineChange_12() {
        runner.testing(
            "diff -B does not ignore non-blank single line change",
            command: "diff -qB - input; echo $?",
            expectedOutput: "Files - and input differ\\n1\\n",
            inputFile: "0\\n",
            stdin: "1\\n"
        )
    }

    func testDiffAlwaysTakesContextFromOldFile_13() {
        runner.testing(
            "diff always takes context from old file",
            command: "diff -ub - input | $TRIM_TAB",
            expectedOutput: " --- -\n+++ input\n@@ -1 +1,3 @@\n+abc\n a c\n+def\n",
            inputFile: "abc\\na  c\\ndef\\n",
            stdin: "a c\\n"
        )
    }

    func testTestName_14() {
        runner.testing(
            "test name",
            command: "commands",
            expectedOutput: "expected result",
            inputFile: "file input",
            stdin: "stdin"
        )
    }

    func testDiffDiff1Diff2Subdir_15() {
        runner.testing(
            "diff diff1 diff2/subdir",
            command: "diff -ur diff1 diff2/subdir | $TRIM_TAB",
            expectedOutput: " --- diff1/-\n+++ diff2/subdir/-\n@@ -1 +1 @@\n-qwe\n+asd\n"
        )
    }

    func testDiffDirDir2File_16() {
        runner.testing(
            "diff dir dir2/file/-",
            command: "diff -ur diff1 diff2/subdir/- | $TRIM_TAB",
            expectedOutput: " --- diff1/-\n+++ diff2/subdir/-\n@@ -1 +1 @@\n-qwe\n+asd\n"
        )
    }

    func testDiffOfDirAndFifo_17() {
        runner.testing(
            "diff of dir and fifo",
            command: "diff -ur diff1 diff2/subdir | $TRIM_TAB",
            expectedOutput: " --- diff1/-\n+++ diff2/subdir/-\n@@ -1 +1 @@\n-qwe\n+asd\nOnly in diff2/subdir: test\n"
        )
    }

    func testDiffOfFileAndFifo_18() {
        runner.testing(
            "diff of file and fifo",
            command: "diff -ur diff1 diff2/subdir | $TRIM_TAB",
            expectedOutput: " --- diff1/-\n+++ diff2/subdir/-\n@@ -1 +1 @@\n-qwe\n+asd\nFile diff2/subdir/test is not a regular file or directory and was skipped\n"
        )
    }

    func testDiffRnDoesNotReadNonRegularFiles_19() {
        runner.testing(
            "diff -rN does not read non-regular files",
            command: "diff -urN diff1 diff2/subdir | $TRIM_TAB",
            expectedOutput: " --- diff1/-\n+++ diff2/subdir/-\n@@ -1 +1 @@\n-qwe\n+asd\nFile diff2/subdir/test is not a regular file or directory and was skipped\nFile diff1/test2 is not a regular file or directory and was skipped\n"
        )
    }

    func testDiffDiff1Diff2_20() {
        runner.testing(
            "diff diff1 diff2/",
            command: "diff -ur diff1 diff2/ | $TRIM_TAB; diff -ur .///diff1 diff2//// | $TRIM_TAB",
            expectedOutput: " --- diff1/-\n+++ diff2/-\n@@ -1 +1 @@\n-qwe\n+rty\n--- .///diff1/-\n+++ diff2////-\n@@ -1 +1 @@\n-qwe\n+rty\n"
        )
    }

}

