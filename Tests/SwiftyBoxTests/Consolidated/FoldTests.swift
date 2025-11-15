// FoldTests.swift
// Auto-generated from BusyBox fold.tests
// DO NOT EDIT - regenerate with import-busybox-tests.py

import XCTest

final class FoldTests: XCTestCase {
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
            command: "options",
            expectedOutput: "expected result",
            inputFile: "file input",
            stdin: "stdin"
        )
    }

    func testFoldS_2() {
        runner.testing(
            "fold -s",
            command: "fold -w 7 -s",
            expectedOutput: "123456\\n\\t\\nasdf",
            stdin: "123456\\tasdf"
        )
    }

    func testFoldW1_3() {
        runner.testing(
            "fold -w1",
            command: "fold -w1",
            expectedOutput: "q\\nq\\n \\nw\\n \\ne\\ne\\ne\\n \\nr\\n \\nt\\nt\\nt\\nt\\n \\ny",
            stdin: "qq w eee r tttt y"
        )
    }

    func testFoldWithNuls_4() {
        runner.testing(
            "fold with NULs",
            command: "fold -sw22",
            expectedOutput: " The NUL is here:>\\0< \\n and another one is \\n here:>\\0< - they must \\n be preserved\n",
            stdin: "The NUL is here:>\\0< and another one is here:>\\0< - they must be preserved\n"
        )
    }

    func testFoldSw66WithUnicodeInput_5() {
        runner.testing(
            "fold -sw66 with unicode input",
            command: "fold -sw66",
            expectedOutput: " The Andromeda Galaxy (pronounced /ænˈdrɒmədə/, also known as \\n Messier 31, M31, or NGC224; often referred to as the Great \\n Andromeda Nebula in older texts) is a spiral galaxy approximately \\n 2,500,000 light-years (1.58×10^11 AU) away in the constellation \\n Andromeda. It is the nearest spiral galaxy to our own, the Milky \\n Way.\\n Галактика або Туманність Андромеди (також відома як M31 за \\n каталогом Мессьє та NGC224 за Новим загальним каталогом) — \\n спіральна галактика, що знаходиться на відстані приблизно у 2,5 \\n мільйони світлових років від нашої планети у сузір"
        )
    }

}

