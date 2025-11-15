// TextProcessingTests.swift
// Tests for text processing commands (Phase 7)

import XCTest

final class TextProcessingTests: XCTestCase {
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

    // MARK: - sort tests (from BusyBox sort.tests)

    func testSort_basic() {
        runner.testing(
            "sort",
            command: "busybox sort input",
            expectedOutput: "a\nb\nc\n",
            inputFile: "c\na\nb\n"
        )
    }

    func testSort_numeric() {
        runner.testing(
            "sort numeric",
            command: "busybox sort -n input",
            expectedOutput: "1\n3\n010\n",
            inputFile: "3\n1\n010\n"
        )
    }

    func testSort_reverse() {
        runner.testing(
            "sort reverse",
            command: "busybox sort -r input",
            expectedOutput: "wook\nwalrus\npoint\npabst\naargh\n",
            inputFile: "point\nwook\npabst\naargh\nwalrus\n"
        )
    }

    func testSort_stdin() {
        runner.testing(
            "sort stdin",
            command: "busybox sort",
            expectedOutput: "a\nb\nc\n",
            stdin: "b\na\nc\n"
        )
    }

    func testSort_unique() {
        runner.testing(
            "sort -u removes duplicates",
            command: "busybox sort -u",
            expectedOutput: "a\nb\nc\n",
            stdin: "b\na\nc\na\nb\n"
        )
    }

    // MARK: - uniq tests

    func testUniq_basic() {
        runner.testing(
            "uniq removes adjacent duplicates",
            command: "busybox uniq",
            expectedOutput: "a\nb\nc\n",
            stdin: "a\na\nb\nc\nc\n"
        )
    }

    func testUniq_count() {
        runner.testing(
            "uniq -c shows counts",
            command: "busybox uniq -c",
            expectedOutput: "      2 a\n      1 b\n      2 c\n",
            stdin: "a\na\nb\nc\nc\n"
        )
    }

    func testUniq_duplicatesOnly() {
        runner.testing(
            "uniq -d shows only duplicates",
            command: "busybox uniq -d",
            expectedOutput: "a\nc\n",
            stdin: "a\na\nb\nc\nc\n"
        )
    }

    func testUniq_uniqueOnly() {
        runner.testing(
            "uniq -u shows only unique lines",
            command: "busybox uniq -u",
            expectedOutput: "b\n",
            stdin: "a\na\nb\nc\nc\n"
        )
    }

    // MARK: - cut tests

    func testCut_fields() {
        runner.testing(
            "cut -f extracts fields",
            command: "busybox cut -f2",
            expectedOutput: "2\n5\n8\n",
            stdin: "1\t2\t3\n4\t5\t6\n7\t8\t9\n"
        )
    }

    func testCut_delimiter() {
        runner.testing(
            "cut -d sets delimiter",
            command: "busybox cut -d: -f1",
            expectedOutput: "user\nroot\n",
            stdin: "user:x:1000\nroot:x:0\n"
        )
    }

    func testCut_characters() {
        runner.testing(
            "cut -c extracts characters",
            command: "busybox cut -c1-3",
            expectedOutput: "hel\nwor\n",
            stdin: "hello\nworld\n"
        )
    }

    // MARK: - tr tests

    func testTr_translate() {
        runner.testing(
            "tr translates characters",
            command: "busybox tr abc ABC",
            expectedOutput: "ABCdef\n",
            stdin: "abcdef\n"
        )
    }

    func testTr_delete() {
        runner.testing(
            "tr -d deletes characters",
            command: "busybox tr -d aeiou",
            expectedOutput: "hll wrld\n",
            stdin: "hello world\n"
        )
    }

    func testTr_squeeze() {
        runner.testing(
            "tr -s squeezes repeats",
            command: "busybox tr -s ' '",
            expectedOutput: "a b c\n",
            stdin: "a  b   c\n"
        )
    }

    // MARK: - grep tests

    func testGrep_basic() {
        runner.testing(
            "grep finds pattern",
            command: "busybox grep foo",
            expectedOutput: "foo\nfoobar\n",
            stdin: "foo\nbar\nfoobar\nbaz\n"
        )
    }

    func testGrep_invertMatch() {
        runner.testing(
            "grep -v inverts match",
            command: "busybox grep -v foo",
            expectedOutput: "bar\nbaz\n",
            stdin: "foo\nbar\nfoobar\nbaz\n"
        )
    }

    func testGrep_caseInsensitive() {
        runner.testing(
            "grep -i case insensitive",
            command: "busybox grep -i FOO",
            expectedOutput: "foo\nFOO\nFoo\n",
            stdin: "foo\nbar\nFOO\nFoo\n"
        )
    }

    func testGrep_count() {
        runner.testing(
            "grep -c counts matches",
            command: "busybox grep -c foo",
            expectedOutput: "2\n",
            stdin: "foo\nbar\nfoobar\n"
        )
    }

    // MARK: - comm tests

    func testComm_basic() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-comm-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        let file1 = tempDir.appendingPathComponent("file1")
        let file2 = tempDir.appendingPathComponent("file2")
        try? "a\nb\nc\n".write(to: file1, atomically: true, encoding: .utf8)
        try? "b\nc\nd\n".write(to: file2, atomically: true, encoding: .utf8)

        runner.testing(
            "comm compares sorted files",
            command: "cd '\(tempDir.path)' && busybox comm file1 file2",
            expectedOutput: "a\n\t\tb\n\t\tc\n\t\td\n"
        )
    }

    // MARK: - fold tests

    func testFold_width() {
        runner.testing(
            "fold wraps at width",
            command: "busybox fold -w 5",
            expectedOutput: "hello\n worl\nd\n",
            stdin: "hello world\n"
        )
    }

    // MARK: - paste tests

    func testPaste_serial() {
        runner.testing(
            "paste -s merges lines",
            command: "busybox paste -s",
            expectedOutput: "a\tb\tc\n",
            stdin: "a\nb\nc\n"
        )
    }

    // MARK: - nl tests

    func testNl_basic() {
        runner.testing(
            "nl numbers lines",
            command: "busybox nl",
            expectedOutput: "     1\tline1\n     2\tline2\n     3\tline3\n",
            stdin: "line1\nline2\nline3\n"
        )
    }
}
