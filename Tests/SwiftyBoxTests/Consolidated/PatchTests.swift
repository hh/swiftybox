// PatchTests.swift
// Auto-generated from BusyBox patch.tests
// DO NOT EDIT - regenerate with import-busybox-tests.py

import XCTest

final class PatchTests: XCTestCase {
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
            command: "command(s)",
            expectedOutput: "expected result",
            inputFile: "file input",
            stdin: "stdin"
        )
    }

    func testPatchWithOldFileNewFile_2() {
        runner.testing(
            "patch with old_file == new_file",
            command: "patch 2>&1; echo $?; cat input",
            expectedOutput: " patching file input\n0\nqwe\nasd\nzxc\n",
            inputFile: " qwe\nzxc\n",
            stdin: " --- input\tJan 01 01:01:01 2000\n+++ input\tJan 01 01:01:01 2000\n@@ -1,2 +1,3 @@\n qwe\n+asd\n zxc\n"
        )
    }

    func testPatchWithNonexistentOldFile_3() {
        runner.testing(
            "patch with nonexistent old_file",
            command: "patch 2>&1; echo $?; cat input",
            expectedOutput: " patching file input\n0\nqwe\nasd\nzxc\n",
            inputFile: " qwe\nzxc\n",
            stdin: " --- input.doesnt_exist\tJan 01 01:01:01 2000\n+++ input\tJan 01 01:01:01 2000\n@@ -1,2 +1,3 @@\n qwe\n+asd\n zxc\n"
        )
    }

    func testPatchRWithNonexistentOldFile_4() {
        runner.testing(
            "patch -R with nonexistent old_file",
            command: "patch -R 2>&1; echo $?; cat input",
            expectedOutput: " patching file input\n0\nqwe\nzxc\n",
            inputFile: " qwe\nasd\nzxc\n",
            stdin: " --- input.doesnt_exist\tJan 01 01:01:01 2000\n+++ input\tJan 01 01:01:01 2000\n@@ -1,2 +1,3 @@\n qwe\n+asd\n zxc\n"
        )
    }

    func testPatchDetectsAlreadyAppliedHunk_5() {
        runner.testing(
            "patch detects already applied hunk",
            command: "patch 2>&1; echo $?; cat input",
            expectedOutput: " patching file input\nPossibly reversed hunk 1 at 4\nHunk 1 FAILED 1/1.\n abc\n+def\n 123\n1\nabc\ndef\n123\n",
            inputFile: " abc\ndef\n123\n",
            stdin: " --- input.old\tJan 01 01:01:01 2000\n+++ input\tJan 01 01:01:01 2000\n@@ -1,2 +1,3 @@\n abc\n+def\n 123\n"
        )
    }

    func testPatchDetectsAlreadyAppliedHunkAtTheEof_6() {
        runner.testing(
            "patch detects already applied hunk at the EOF",
            command: "patch 2>&1; echo $?; cat input",
            expectedOutput: " patching file input\nPossibly reversed hunk 1 at 4\nHunk 1 FAILED 1/1.\n abc\n 123\n+456\n1\nabc\n123\n456\n",
            inputFile: " abc\n123\n456\n",
            stdin: " --- input.old\tJan 01 01:01:01 2000\n+++ input\tJan 01 01:01:01 2000\n@@ -1,2 +1,3 @@\n abc\n 123\n+456\n"
        )
    }

    func testTestName_7() {
        runner.testing(
            "test name",
            command: "command(s)",
            expectedOutput: "expected result",
            inputFile: "file input",
            stdin: "stdin"
        )
    }

    func testPatchNIgnoresAlreadyAppliedHunk_8() {
        runner.testing(
            "patch -N ignores already applied hunk",
            command: "patch -N 2>&1; echo $?; cat input",
            expectedOutput: " patching file input\n0\nabc\ndef\n123\n",
            inputFile: " abc\ndef\n123\n",
            stdin: " --- input\n+++ input\n@@ -1,2 +1,3 @@\n abc\n+def\n 123\n"
        )
    }

    func testTestName_9() {
        runner.testing(
            "test name",
            command: "command(s)",
            expectedOutput: "expected result",
            inputFile: "file input",
            stdin: "stdin"
        )
    }

    func testPatchFilePatch_10() {
        runner.testing(
            "patch FILE PATCH",
            command: "cat >a.patch; patch input a.patch 2>&1; echo $?; cat input; rm a.patch",
            expectedOutput: " patching file input\n0\nabc\ndef\n123\n",
            inputFile: " abc\n123\n",
            stdin: " --- foo.old\n+++ foo\n@@ -1,2 +1,3 @@\n abc\n+def\n 123\n"
        )
    }

    func testTestName_11() {
        runner.testing(
            "test name",
            command: "command(s)",
            expectedOutput: "expected result",
            inputFile: "file input",
            stdin: "stdin"
        )
    }

    func testPatchAtTheBeginning_12() {
        runner.testing(
            "patch at the beginning",
            command: "patch 2>&1; cat input",
            expectedOutput: " patching file input\n111changed\n444\n555\n666\n777\n888\n999\n",
            inputFile: " 111\n222\n333\n444\n555\n666\n777\n888\n999\n",
            stdin: " --- input\n+++ input\n@@ -1,6 +1,4 @@\n-111\n-222\n-333\n+111changed\n 444\n 555\n 666\n"
        )
    }

    func testTestName_13() {
        runner.testing(
            "test name",
            command: "command(s)",
            expectedOutput: "expected result",
            inputFile: "file input",
            stdin: "stdin"
        )
    }

    func testPatchCreatesNewFile_14() {
        runner.testing(
            "patch creates new file",
            command: "patch 2>&1; echo $?; cat testfile; rm testfile",
            expectedOutput: " creating testfile\n0\nqwerty\n",
            stdin: " --- /dev/null\n+++ testfile\n@@ -0,0 +1 @@\n+qwerty\n"
        )
    }

    func testTestName_15() {
        runner.testing(
            "test name",
            command: "command(s)",
            expectedOutput: "expected result",
            inputFile: "file input",
            stdin: "stdin"
        )
    }

    func testPatchUnderstandsDirDir_16() {
        runner.testing(
            "patch understands ...dir///dir...",
            command: "patch -p1 2>&1; echo $?",
            expectedOutput: " patching file dir2///file\npatch: can"
        )
    }

    func testPatchInternalBufferingBug_17() {
        runner.testing(
            "patch internal buffering bug?",
            command: "patch -p1 2>&1; echo $?; cat input",
            expectedOutput: " patching file input\n0\nfoo\n\n\n\n\n\n\n1\n2\n3\n\nbar\n",
            inputFile: " foo\n\n\n\n\n\n\n\nbar\n",
            stdin: " --- a/input.orig\n+++ b/input\n@@ -5,5 +5,8 @@ foo\n \n \n \n+1\n+2\n+3\n \n bar\n-- \n2.9.2\n"
        )
    }

}

