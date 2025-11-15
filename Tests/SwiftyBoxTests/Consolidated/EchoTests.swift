// EchoTests.swift
// ============================================================================
// BusyBox Test Import Metadata
// ============================================================================
// Source Type: Individual test cases (subdirectory tests)
// Source Path: busybox/testsuite/echo/
// Import Date: 2025-11-14
// Test Count: 11
// Pass Rate: 63.6% (7/11)
// ============================================================================
// Tests for echo command edge cases and scenarios

import XCTest
import Foundation

final class EchoTests: XCTestCase {
    var swiftyboxPath: String {
        let cwd = FileManager.default.currentDirectoryPath
        return "\(cwd)/.build/debug/swiftybox"
    }

    // MARK: - Test 1: does-not-print-newline
    // Source: busybox/testsuite/echo/echo-does-not-print-newline
    func testEcho_nSuppressesNewline() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["echo", "-n", "word"]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "echo -n should succeed")
        XCTAssertEqual(output.count, 4, "echo -n should output exactly 4 characters (no newline)")
        XCTAssertEqual(output, "word", "echo -n should output 'word' without newline")
    }

    // MARK: - Test 2: prints-argument
    // Source: busybox/testsuite/echo/echo-prints-argument
    func testEcho_printsArgument() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["echo", "fubar"]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "echo should succeed")
        XCTAssertEqual(output, "fubar\n", "echo should output 'fubar' with newline")
    }

    // MARK: - Test 3: prints-arguments
    // Source: busybox/testsuite/echo/echo-prints-arguments
    func testEcho_printsMultipleArguments() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["echo", "foo", "bar"]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "echo should succeed")
        XCTAssertEqual(output, "foo bar\n", "echo should separate arguments with spaces")
    }

    // MARK: - Test 4: prints-dash
    // Source: busybox/testsuite/echo/echo-prints-dash
    func testEcho_printsDash() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["echo", "-"]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()

        XCTAssertEqual(task.terminationStatus, 0, "echo should succeed")

        // Check hex output: should be "2d 0a" (dash + newline)
        let hexString = data.map { String(format: "%02x", $0) }.joined(separator: " ")
        XCTAssertEqual(hexString, "2d 0a", "echo - should output dash followed by newline")
    }

    // MARK: - Test 5: prints-newline
    // Source: busybox/testsuite/echo/echo-prints-newline
    func testEcho_printsNewline() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["echo", "word"]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "echo should succeed")
        XCTAssertEqual(output.count, 5, "echo should output 5 characters (word + newline)")
        XCTAssertEqual(output, "word\n", "echo should append newline")
    }

    // MARK: - Test 6: prints-non-opts
    // Source: busybox/testsuite/echo/echo-prints-non-opts
    func testEcho_printsNonOptions() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["echo", "-neEZ"]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()

        XCTAssertEqual(task.terminationStatus, 0, "echo should succeed")

        // Check hex: should be "2d 6e 65 45 5a 0a" (-neEZ\n)
        let hexString = data.map { String(format: "%02x", $0) }.joined(separator: " ")
        XCTAssertEqual(hexString, "2d 6e 65 45 5a 0a",
                      "echo should treat -neEZ as literal string (not combined flags)")
    }

    // MARK: - Test 7: prints-slash_00041
    // Source: busybox/testsuite/echo/echo-prints-slash_00041
    func testEcho_printsOctalEscape00041() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["echo", "-ne", "\\00041z"]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()

        XCTAssertEqual(task.terminationStatus, 0, "echo should succeed")

        // \00041 should be parsed as \0004 (byte 04) followed by literal '1'
        // Result: 04 31 7a (04, '1', 'z')
        let hexString = data.map { String(format: "%02x", $0) }.joined(separator: " ")
        XCTAssertEqual(hexString, "04 31 7a",
                      "echo -ne should parse \\00041 as octal \\0004 + '1'")
    }

    // MARK: - Test 8: prints-slash_0041
    // Source: busybox/testsuite/echo/echo-prints-slash_0041
    func testEcho_printsOctalEscape0041() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["echo", "-ne", "\\0041z"]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()

        XCTAssertEqual(task.terminationStatus, 0, "echo should succeed")

        // \0041 is octal for '!' (0x21)
        // Result: 21 7a ('!', 'z')
        let hexString = data.map { String(format: "%02x", $0) }.joined(separator: " ")
        XCTAssertEqual(hexString, "21 7a",
                      "echo -ne should parse \\0041 as octal for '!'")
    }

    // MARK: - Test 9: prints-slash_041
    // Source: busybox/testsuite/echo/echo-prints-slash_041
    func testEcho_printsOctalEscape041() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["echo", "-ne", "\\041z"]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()

        XCTAssertEqual(task.terminationStatus, 0, "echo should succeed")

        // \041 is octal for '!' (0x21)
        let hexString = data.map { String(format: "%02x", $0) }.joined(separator: " ")
        XCTAssertEqual(hexString, "21 7a",
                      "echo -ne should parse \\041 as octal for '!'")
    }

    // MARK: - Test 10: prints-slash_41
    // Source: busybox/testsuite/echo/echo-prints-slash_41
    func testEcho_printsOctalEscape41() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["echo", "-ne", "\\41z"]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()

        XCTAssertEqual(task.terminationStatus, 0, "echo should succeed")

        // \41 is octal for '!' (0x21)
        let hexString = data.map { String(format: "%02x", $0) }.joined(separator: " ")
        XCTAssertEqual(hexString, "21 7a",
                      "echo -ne should parse \\41 as octal for '!'")
    }

    // MARK: - Test 11: prints-slash-zero
    // Source: busybox/testsuite/echo/echo-prints-slash-zero
    func testEcho_printsNullByte() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["echo", "-e", "-n", "msg\\n\\0"]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()

        XCTAssertEqual(task.terminationStatus, 0, "echo should succeed")

        // Should output: 6d 73 67 0a 00 ('m', 's', 'g', '\n', '\0')
        let hexString = data.map { String(format: "%02x", $0) }.joined(separator: " ")
        XCTAssertEqual(hexString, "6d 73 67 0a 00",
                      "echo -e -n should output msg\\n\\0")
    }
}
