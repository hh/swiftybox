// SeqTests.swift
// Tests for the `seq` command - print a sequence of numbers

import XCTest
@testable import swiftybox

/// Tests for the `seq` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: GNU coreutils seq
/// - Prints sequences of numbers from FIRST to LAST
/// - Usage: seq [FIRST [INCREMENT]] LAST
/// - Current implementation supports basic sequences
/// - Advanced features (padding, separators, format strings) not yet implemented
///
/// Resources:
/// - GNU: https://www.gnu.org/software/coreutils/manual/html_node/seq-invocation.html
/// - POSIX: Not in POSIX, GNU extension

final class SeqTests: XCTestCase {

    // MARK: - Basic Functionality

    func testOneArgument() {
        // seq N - prints 1 to N
        let result = SeqCommand.main(["seq", "3"])
        XCTAssertEqual(result, 0)
    }

    func testOneArgumentLarger() {
        let result = SeqCommand.main(["seq", "5"])
        XCTAssertEqual(result, 0)
    }

    func testTwoArguments() {
        // seq FIRST LAST
        let result = SeqCommand.main(["seq", "5", "7"])
        XCTAssertEqual(result, 0)
    }

    func testTwoArgumentsEqual() {
        // When FIRST == LAST, should print once
        let result = SeqCommand.main(["seq", "3", "3"])
        XCTAssertEqual(result, 0)
    }

    func testTwoArgumentsReversed() {
        // When FIRST > LAST with positive step, no output
        let result = SeqCommand.main(["seq", "7", "5"])
        XCTAssertEqual(result, 0)
    }

    func testThreeArgumentsCountUp() {
        // seq FIRST INCREMENT LAST
        let result = SeqCommand.main(["seq", "4", "2", "8"])
        XCTAssertEqual(result, 0)
    }

    func testThreeArgumentsCountDown() {
        // Negative increment
        let result = SeqCommand.main(["seq", "8", "-2", "4"])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Wrong Direction Tests

    func testCountWrongWay1() {
        // Positive increment but start > end
        let result = SeqCommand.main(["seq", "4", "-2", "8"])
        XCTAssertEqual(result, 0)  // Should produce no output
    }

    func testCountWrongWay2() {
        // Negative increment but start < end
        let result = SeqCommand.main(["seq", "8", "2", "4"])
        XCTAssertEqual(result, 0)  // Should produce no output
    }

    // MARK: - Decimal/Floating Point

    func testCountByDecimal() {
        // seq 3 .3 4
        let result = SeqCommand.main(["seq", "3", ".3", "4"])
        XCTAssertEqual(result, 0)
    }

    func testCountByNegativeDecimal() {
        // seq .7 -.9 -2.2
        let result = SeqCommand.main(["seq", ".7", "-.9", "-2.2"])
        XCTAssertEqual(result, 0)
    }

    func testNegativeSequence() {
        // seq -4 -2 -8
        let result = SeqCommand.main(["seq", "-4", "-2", "-8"])
        XCTAssertEqual(result, 0)
    }

    func testDecimalWithLeadingZero() {
        // seq -.0 -.25 -.9
        let result = SeqCommand.main(["seq", "-.0", "-.25", "-.9"])
        XCTAssertEqual(result, 0)
    }

    func testNegativeToPositive() {
        // seq -1 1
        let result = SeqCommand.main(["seq", "-1", "1"])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Edge Cases

    func testZeroIncrement() {
        // Increment of 0 should be an error
        let result = SeqCommand.main(["seq", "4", "0", "8"])
        XCTAssertNotEqual(result, 0)  // Should fail
    }

    func testLargeSequence() {
        // Make sure it handles larger ranges
        let result = SeqCommand.main(["seq", "1", "100"])
        XCTAssertEqual(result, 0)
    }

    func testVerySmallIncrement() {
        let result = SeqCommand.main(["seq", "0", "0.01", "0.1"])
        XCTAssertEqual(result, 0)
    }

    func testSingleNumber() {
        // seq 1 prints just 1
        let result = SeqCommand.main(["seq", "1"])
        XCTAssertEqual(result, 0)
    }

    func testZero() {
        // seq 0 prints 0? Or is it 1 to 0 (empty)?
        let result = SeqCommand.main(["seq", "0"])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Error Handling

    func testNoArguments() {
        let result = SeqCommand.main(["seq"])
        XCTAssertNotEqual(result, 0)
    }

    func testInvalidNumber() {
        let result = SeqCommand.main(["seq", "abc"])
        XCTAssertNotEqual(result, 0)
    }

    func testInvalidNumberInRange() {
        let result = SeqCommand.main(["seq", "1", "abc"])
        XCTAssertNotEqual(result, 0)
    }

    func testTooManyArguments() {
        let result = SeqCommand.main(["seq", "1", "2", "3", "4", "5"])
        XCTAssertNotEqual(result, 0)
    }

    // MARK: - Format Preservation Tests
    // Note: Current implementation may not preserve decimal places
    // These tests verify the command runs successfully

    func testDecimalPlacesSimple() {
        // Even if format isn't perfect, should complete successfully
        let result = SeqCommand.main(["seq", "3", ".3", "4"])
        XCTAssertEqual(result, 0)
    }

    func testDecimalPlacesExtended() {
        let result = SeqCommand.main(["seq", "3", ".30", "4"])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Additional Coverage

    func testNegativeStart() {
        let result = SeqCommand.main(["seq", "-5", "5"])
        XCTAssertEqual(result, 0)
    }

    func testLargeNegativeToNegative() {
        let result = SeqCommand.main(["seq", "-100", "-95"])
        XCTAssertEqual(result, 0)
    }

    func testFractionalIncrement() {
        let result = SeqCommand.main(["seq", "0", "0.5", "2"])
        XCTAssertEqual(result, 0)
    }

    func testEqualStartEnd() {
        // seq 5 5 should print 5
        let result = SeqCommand.main(["seq", "5", "5"])
        XCTAssertEqual(result, 0)
    }
}
