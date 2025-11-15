import XCTest
@testable import swiftybox

final class ExprTests: XCTestCase {
    // MARK: - Basic Operations

    func testOrOperation_BothTrue() {
        XCTAssertEqual(runCommand("expr", ["1", "|", "1"]), CommandResult(exitCode: 0, stdout: "1\n", stderr: ""))
    }

    func testOrOperation_FirstTrue() {
        XCTAssertEqual(runCommand("expr", ["1", "|", "0"]), CommandResult(exitCode: 0, stdout: "1\n", stderr: ""))
    }

    func testOrOperation_SecondTrue() {
        XCTAssertEqual(runCommand("expr", ["0", "|", "1"]), CommandResult(exitCode: 0, stdout: "1\n", stderr: ""))
    }

    func testOrOperation_BothFalse() {
        XCTAssertEqual(runCommand("expr", ["0", "|", "0"]), CommandResult(exitCode: 1, stdout: "0\n", stderr: ""))
    }

    func testAndOperation_BothTrue() {
        XCTAssertEqual(runCommand("expr", ["1", "&", "1"]), CommandResult(exitCode: 0, stdout: "1\n", stderr: ""))
    }

    func testAndOperation_FirstFalse() {
        XCTAssertEqual(runCommand("expr", ["1", "&", "0"]), CommandResult(exitCode: 1, stdout: "0\n", stderr: ""))
    }

    func testAndOperation_SecondFalse() {
        XCTAssertEqual(runCommand("expr", ["0", "&", "1"]), CommandResult(exitCode: 1, stdout: "0\n", stderr: ""))
    }

    func testAndOperation_BothFalse() {
        XCTAssertEqual(runCommand("expr", ["0", "&", "0"]), CommandResult(exitCode: 1, stdout: "0\n", stderr: ""))
    }

    // MARK: - Comparison Operations

    func testLessThan_True() {
        XCTAssertEqual(runCommand("expr", ["0", "<", "1"]), CommandResult(exitCode: 0, stdout: "1\n", stderr: ""))
    }

    func testLessThan_False() {
        XCTAssertEqual(runCommand("expr", ["1", "<", "0"]), CommandResult(exitCode: 1, stdout: "0\n", stderr: ""))
    }

    func testGreaterThan_True() {
        XCTAssertEqual(runCommand("expr", ["1", ">", "0"]), CommandResult(exitCode: 0, stdout: "1\n", stderr: ""))
    }

    func testGreaterThan_False() {
        XCTAssertEqual(runCommand("expr", ["0", ">", "1"]), CommandResult(exitCode: 1, stdout: "0\n", stderr: ""))
    }

    func testLessThanOrEqual_True_Less() {
        XCTAssertEqual(runCommand("expr", ["0", "<=", "1"]), CommandResult(exitCode: 0, stdout: "1\n", stderr: ""))
    }

    func testLessThanOrEqual_True_Equal() {
        XCTAssertEqual(runCommand("expr", ["1", "<=", "1"]), CommandResult(exitCode: 0, stdout: "1\n", stderr: ""))
    }

    func testLessThanOrEqual_False() {
        XCTAssertEqual(runCommand("expr", ["1", "<=", "0"]), CommandResult(exitCode: 1, stdout: "0\n", stderr: ""))
    }

    func testGreaterThanOrEqual_True_Greater() {
        XCTAssertEqual(runCommand("expr", ["1", ">=", "0"]), CommandResult(exitCode: 0, stdout: "1\n", stderr: ""))
    }

    func testGreaterThanOrEqual_True_Equal() {
        XCTAssertEqual(runCommand("expr", ["1", ">=", "1"]), CommandResult(exitCode: 0, stdout: "1\n", stderr: ""))
    }

    func testGreaterThanOrEqual_False() {
        XCTAssertEqual(runCommand("expr", ["0", ">=", "1"]), CommandResult(exitCode: 1, stdout: "0\n", stderr: ""))
    }

    // MARK: - Arithmetic Operations

    func testAddition() {
        XCTAssertEqual(runCommand("expr", ["1", "+", "2"]), CommandResult(exitCode: 0, stdout: "3\n", stderr: ""))
    }

    func testSubtraction() {
        XCTAssertEqual(runCommand("expr", ["2", "-", "1"]), CommandResult(exitCode: 0, stdout: "1\n", stderr: ""))
    }

    func testMultiplication() {
        XCTAssertEqual(runCommand("expr", ["2", "*", "3"]), CommandResult(exitCode: 0, stdout: "6\n", stderr: ""))
    }

    func testDivision() {
        XCTAssertEqual(runCommand("expr", ["12", "/", "2"]), CommandResult(exitCode: 0, stdout: "6\n", stderr: ""))
    }

    func testModulus() {
        XCTAssertEqual(runCommand("expr", ["12", "%", "5"]), CommandResult(exitCode: 0, stdout: "2\n", stderr: ""))
    }

    // MARK: - Big Number Tests (64-bit integers)

    func testBigNumber_Overflow32Bit() {
        // 3*1000*1000*1000 overflows 32-bit signed int
        XCTAssertEqual(runCommand("expr", ["0", "<", "3000000000"]), CommandResult(exitCode: 0, stdout: "1\n", stderr: ""))
    }

    func testBigNumber_MaxInt64() {
        // 9223372036854775807 = 2^63-1 (max signed 64-bit)
        XCTAssertEqual(runCommand("expr", ["0", "<", "9223372036854775807"]), CommandResult(exitCode: 0, stdout: "1\n", stderr: ""))
    }

    func testBigNumber_NegativeComparison() {
        XCTAssertEqual(runCommand("expr", ["-9223372036854775800", "<", "9223372036854775807"]), CommandResult(exitCode: 0, stdout: "1\n", stderr: ""))
    }
}
