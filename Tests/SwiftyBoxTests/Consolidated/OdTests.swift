// OdTests.swift
// Auto-generated from BusyBox od.tests
// DO NOT EDIT - regenerate with import-busybox-tests.py

import XCTest

final class OdTests: XCTestCase {
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

    func testOdLittleEndian_2() {
        runner.testing(
            "od (little-endian)",
            command: "od",
            expectedOutput: " 0000000 001001 005003 041101 177103\n0000010\n",
            stdin: "$input"
        )
    }

    func testOdADesktop_3() {
        runner.testing(
            "od -a (!DESKTOP)",
            command: "od -a",
            expectedOutput: " 0000000 nul soh stx etx eot enq ack bel  bs  ht  lf  vt  ff  cr  so  si\n0000020 dle dc1 dc2 dc3 dc4 nak syn etb can  em sub esc  fs  gs  rs  us\n0000040   p   q   r   s   t   u   v   w   x   y   z   {   |   }   ~ del\n0000060  80  81  82  83  84  85  86  87  88  89  8a  8b  8c  8d  8e  8f\n0000100  f0  f1  f2  f3  f4  f5  f6  f7  f8  f9  fa  fb  fc  fd  fe  ff\n0000120\n",
            stdin: "\\x00\\x01\\x02\\x03\\x04\\x05\\x06\\x07\\x08\\x09\\x0a\\x0b\\x0c\\x0d\\x0e\\x0f"
        )
    }

    func testOdADesktop_4() {
        runner.testing(
            "od -a (DESKTOP)",
            command: "od -a",
            expectedOutput: " 0000000 nul soh stx etx eot enq ack bel  bs  ht  nl  vt  ff  cr  so  si\n0000020 dle dc1 dc2 dc3 dc4 nak syn etb can  em sub esc  fs  gs  rs  us\n0000040   p   q   r   s   t   u   v   w   x   y   z   {   |   }   ~ del\n0000060 nul soh stx etx eot enq ack bel  bs  ht  nl  vt  ff  cr  so  si\n0000100   p   q   r   s   t   u   v   w   x   y   z   {   |   }   ~ del\n0000120\n",
            stdin: "\\x00\\x01\\x02\\x03\\x04\\x05\\x06\\x07\\x08\\x09\\x0a\\x0b\\x0c\\x0d\\x0e\\x0f"
        )
    }

    func testOdB_5() {
        runner.testing(
            "od -B",
            command: "od -B",
            expectedOutput: " 0000000 001001 005003 041101 177103\n0000010\n",
            stdin: "$input"
        )
    }

    func testOdOLittleEndian_6() {
        runner.testing(
            "od -o (little-endian)",
            command: "od -o",
            expectedOutput: " 0000000 001001 005003 041101 177103\n0000010\n",
            stdin: "$input"
        )
    }

    func testOdB_7() {
        runner.testing(
            "od -b",
            command: "od -b",
            expectedOutput: " 0000000 001 002 003 012 101 102 103 376\n0000010\n",
            stdin: "$input"
        )
    }

    func testOdC_8() {
        runner.testing(
            "od -c",
            command: "od -c",
            expectedOutput: " 0000000 001 002 003  \\\\\\\\n   A   B   C 376\n0000010\n",
            stdin: "$input"
        )
    }

    func testOdDLittleEndian_9() {
        runner.testing(
            "od -d (little-endian)",
            command: "od -d",
            expectedOutput: " 0000000   513  2563 16961 65091\n0000010\n",
            stdin: "$input"
        )
    }

    func testOdDLittleEndian_10() {
        runner.testing(
            "od -D (little-endian)",
            command: "od -D",
            expectedOutput: " 0000000  167969281 4265820737\n0000010\n",
            stdin: "$input"
        )
    }

    func testOdEDesktopLittleEndian_11() {
        runner.testing(
            "od -e (!DESKTOP little-endian)",
            command: "od -e",
            expectedOutput: " 0000000   -1.61218556514036e+300\n0000010\n",
            stdin: "$input"
        )
    }

    func testOdFDesktopLittleEndian_12() {
        runner.testing(
            "od -F (!DESKTOP little-endian)",
            command: "od -F",
            expectedOutput: " 0000000   -1.61218556514036e+300\n0000010\n",
            stdin: "$input"
        )
    }

    func testOdFLittleEndian_13() {
        runner.testing(
            "od -f (little-endian)",
            command: "od -f",
            expectedOutput: " 0000000   6.3077975e-33  -6.4885867e+37\n0000010\n",
            stdin: "$input"
        )
    }

    func testOdHLittleEndian_14() {
        runner.testing(
            "od -H (little-endian)",
            command: "od -H",
            expectedOutput: " 0000000 0a030201 fe434241\n0000010\n",
            stdin: "$input"
        )
    }

    func testOdXLittleEndian_15() {
        runner.testing(
            "od -X (little-endian)",
            command: "od -X",
            expectedOutput: " 0000000 0a030201 fe434241\n0000010\n",
            stdin: "$input"
        )
    }

    func testOdHLittleEndian_16() {
        runner.testing(
            "od -h (little-endian)",
            command: "od -h",
            expectedOutput: " 0000000 0201 0a03 4241 fe43\n0000010\n",
            stdin: "$input"
        )
    }

    func testOdXLittleEndian_17() {
        runner.testing(
            "od -x (little-endian)",
            command: "od -x",
            expectedOutput: " 0000000 0201 0a03 4241 fe43\n0000010\n",
            stdin: "$input"
        )
    }

    func testOdILittleEndian_18() {
        runner.testing(
            "od -i (little-endian)",
            command: "od -i",
            expectedOutput: " 0000000   167969281   -29146559\n0000010\n",
            stdin: "$input"
        )
    }

    func testOdOLittleEndian_19() {
        runner.testing(
            "od -O (little-endian)",
            command: "od -O",
            expectedOutput: " 0000000 01200601001 37620641101\n0000010\n",
            stdin: "$input"
        )
    }

    func testOdILittleEndian_20() {
        runner.testing(
            "od -I (little-endian)",
            command: "od -I",
            expectedOutput: " 0000000  -125183517527965183\n0000010\n",
            stdin: "$input"
        )
    }

    func testOdLLittleEndian_21() {
        runner.testing(
            "od -L (little-endian)",
            command: "od -L",
            expectedOutput: " 0000000  -125183517527965183\n0000010\n",
            stdin: "$input"
        )
    }

    func testOdLLittleEndian_22() {
        runner.testing(
            "od -l (little-endian)",
            command: "od -l",
            expectedOutput: " 0000000  -125183517527965183\n0000010\n",
            stdin: "$input"
        )
    }

    func testOdB_23() {
        runner.testing(
            "od -b",
            command: "od -b",
            expectedOutput: " 0000000 110 105 114 114 117\n0000005\n",
            stdin: "HELLO"
        )
    }

    func testOdF_24() {
        runner.testing(
            "od -f",
            command: "od -f",
            expectedOutput: " 0000000   0.0000000e+00   0.0000000e+00\n0000010\n",
            stdin: "\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00"
        )
    }

    func testOdBTraditional_25() {
        runner.testing(
            "od -b --traditional",
            command: "od -b --traditional",
            expectedOutput: " 0000000 110 105 114 114 117\n0000005\n",
            stdin: "HELLO"
        )
    }

    func testOdBTraditionalFile_26() {
        runner.testing(
            "od -b --traditional FILE",
            command: "od -b --traditional input",
            expectedOutput: " 0000000 110 105 114 114 117\n0000005\n",
            inputFile: "HELLO"
        )
    }

}

