// ClearTests.swift
// Comprehensive tests for the clear command

import XCTest
@testable import SwiftyBox

/// Tests for the `clear` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: ncurses clear command
/// - BusyBox: Uses ANSI escape sequences or terminfo
/// - Common usage: clear (clears terminal screen)
/// - Target scope: P0 (basic terminal clear)
///
/// Key behaviors to test:
/// - Outputs terminal clear sequence
/// - Most common: ESC[H ESC[2J or ESC[3J
/// - Exit code 0 on success
/// - No arguments
/// - When not a TTY, still outputs escape sequence
///
/// Resources:
/// - ANSI escape codes: CSI sequences for screen clearing
/// - terminfo: clear capability (typically "clear")

final class ClearTests: XCTestCase {

    // MARK: - Basic Functionality

    func testBasicClear() {
        let result = runCommand("clear", [])

        XCTAssertEqual(result.exitCode, 0, "clear should exit with 0")
        XCTAssertEqual(result.stderr, "", "clear should not output to stderr")
        XCTAssertFalse(result.stdout.isEmpty, "clear should output escape sequence")
    }

    func testOutputsEscapeSequence() {
        let result = runCommand("clear", [])

        // Common clear sequences:
        // \x1b[H\x1b[2J - move cursor home, clear screen
        // \x1b[H\x1b[J - move cursor home, clear to end
        // \x1b[2J - just clear screen
        // \x1b[3J - clear screen and scrollback

        let output = result.stdout
        XCTAssertTrue(output.contains("\u{1b}[") || output.contains("\u{001b}["),
                     "clear should output ANSI escape sequence")
    }

    func testContainsClearSequence() {
        let result = runCommand("clear", [])
        let output = result.stdout

        // Check for common clear sequences
        let hasClearSeq = output.contains("\u{1b}[2J") ||  // Clear screen
                         output.contains("\u{1b}[H") ||    // Home cursor
                         output.contains("\u{1b}[3J")      // Clear with scrollback

        XCTAssertTrue(hasClearSeq, "clear should contain screen clearing sequence")
    }

    func testNoArguments() {
        let result = runCommand("clear", [])
        XCTAssertEqual(result.exitCode, 0, "clear with no args should succeed")
    }

    // MARK: - Edge Cases

    func testIgnoresArguments() {
        // clear typically ignores arguments
        let result = runCommand("clear", ["foo"])

        // Either succeeds (ignoring args) or fails
        if result.exitCode != 0 {
            XCTAssertFalse(result.stderr.isEmpty, "If clear fails, should output error")
        }
    }

    func testNoStdinRequired() {
        let result = runCommandWithInput("clear", [], input: "should be ignored\n")

        XCTAssertEqual(result.exitCode, 0, "clear should not require stdin")
    }

    func testOutputNotEmpty() {
        let result = runCommand("clear", [])
        XCTAssertGreaterThan(result.stdout.count, 0, "clear should output something")
    }

    func testOutputShortEnough() {
        let result = runCommand("clear", [])
        // Clear sequence shouldn't be very long (typically < 50 bytes)
        XCTAssertLessThan(result.stdout.count, 100,
                         "clear sequence should be relatively short")
    }

    // MARK: - Consistency

    func testConsistentOutput() {
        let result1 = runCommand("clear", [])
        let result2 = runCommand("clear", [])

        XCTAssertEqual(result1.stdout, result2.stdout,
                      "clear should produce consistent output")
    }

    func testMultipleClearCalls() {
        // Running clear multiple times should all succeed
        for _ in 0..<3 {
            let result = runCommand("clear", [])
            XCTAssertEqual(result.exitCode, 0, "All clear calls should succeed")
            XCTAssertFalse(result.stdout.isEmpty, "All clear calls should output")
        }
    }

    // MARK: - Output Format Validation

    func testOutputBeginsWithEscape() {
        let result = runCommand("clear", [])

        // Should start with ESC character (0x1b)
        if let firstByte = result.stdout.first {
            XCTAssertTrue(firstByte == "\u{1b}" || result.stdout.starts(with: "\u{001b}"),
                         "clear output should begin with escape character")
        }
    }

    func testOutputEndsWithProperTerminator() {
        let result = runCommand("clear", [])

        // ANSI sequences end with letters (typically J, H, etc.)
        if let lastChar = result.stdout.last {
            // Should be a letter or newline
            XCTAssertTrue(lastChar.isLetter || lastChar.isWhitespace,
                         "clear sequence should end with letter or whitespace")
        }
    }
}
