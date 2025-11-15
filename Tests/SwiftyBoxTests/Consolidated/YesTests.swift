// YesTests.swift
// Comprehensive tests for the yes command

import XCTest
@testable import swiftybox

/// Tests for the `yes` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: GNU coreutils yes
/// - BusyBox: Infinite output of "y\n" or specified string
/// - GNU: Same functionality - outputs string repeatedly until SIGPIPE/killed
/// - Common usage: yes | command (auto-confirm prompts)
/// - Target scope: P0 (basic functionality) + P1 (custom strings, binary safety)
///
/// Key behaviors to test:
/// - Default: outputs "y\n" infinitely
/// - With args: outputs args joined with spaces, infinitely
/// - Should respect SIGPIPE (stop when pipe breaks)
/// - Binary safe (can output any characters)
///
/// Resources:
/// - GNU: https://www.gnu.org/software/coreutils/manual/html_node/yes-invocation.html
/// - POSIX: Not in POSIX spec (GNU extension)

final class YesTests: XCTestCase {

    // MARK: - Basic Functionality

    func testDefaultYOutput() {
        // yes outputs "y" by default
        let task = Process()
        let cwd = FileManager.default.currentDirectoryPath
        task.executableURL = URL(fileURLWithPath: "\(cwd)/.build/debug/swiftybox")
        task.arguments = ["yes"]

        let pipe = Pipe()
        task.standardOutput = pipe

        try? task.run()

        // Read first few lines then terminate
        let fileHandle = pipe.fileHandleForReading
        var output = ""
        let deadline = Date().addingTimeInterval(0.5)

        while Date() < deadline {
            if let data = try? fileHandle.read(upToCount: 100) {
                if let str = String(data: data, encoding: .utf8) {
                    output += str
                    if output.count > 100 {
                        break
                    }
                }
            }
        }

        task.terminate()
        task.waitUntilExit()

        // Should have multiple "y\n" sequences
        XCTAssertTrue(output.contains("y\n"), "yes should output 'y\\n'")
        let lines = output.components(separatedBy: "\n").filter { !$0.isEmpty }
        XCTAssertGreaterThan(lines.count, 5, "yes should output many lines")
        XCTAssertTrue(lines.allSatisfy { $0 == "y" }, "All lines should be 'y'")
    }

    func testCustomString() {
        // yes foo outputs "foo" repeatedly
        let task = Process()
        let cwd = FileManager.default.currentDirectoryPath
        task.executableURL = URL(fileURLWithPath: "\(cwd)/.build/debug/swiftybox")
        task.arguments = ["yes", "foo"]

        let pipe = Pipe()
        task.standardOutput = pipe

        try? task.run()

        // Read first few lines then terminate
        let fileHandle = pipe.fileHandleForReading
        var output = ""
        let deadline = Date().addingTimeInterval(0.5)

        while Date() < deadline {
            if let data = try? fileHandle.read(upToCount: 100) {
                if let str = String(data: data, encoding: .utf8) {
                    output += str
                    if output.count > 100 {
                        break
                    }
                }
            }
        }

        task.terminate()
        task.waitUntilExit()

        let lines = output.components(separatedBy: "\n").filter { !$0.isEmpty }
        XCTAssertGreaterThan(lines.count, 5, "yes should output many lines")
        XCTAssertTrue(lines.allSatisfy { $0 == "foo" }, "All lines should be 'foo'")
    }

    func testMultipleArguments() {
        // yes foo bar outputs "foo bar" repeatedly
        let task = Process()
        let cwd = FileManager.default.currentDirectoryPath
        task.executableURL = URL(fileURLWithPath: "\(cwd)/.build/debug/swiftybox")
        task.arguments = ["yes", "foo", "bar", "baz"]

        let pipe = Pipe()
        task.standardOutput = pipe

        try? task.run()

        let fileHandle = pipe.fileHandleForReading
        var output = ""
        let deadline = Date().addingTimeInterval(0.5)

        while Date() < deadline {
            if let data = try? fileHandle.read(upToCount: 200) {
                if let str = String(data: data, encoding: .utf8) {
                    output += str
                    if output.count > 100 {
                        break
                    }
                }
            }
        }

        task.terminate()
        task.waitUntilExit()

        let lines = output.components(separatedBy: "\n").filter { !$0.isEmpty }
        XCTAssertGreaterThan(lines.count, 3, "yes should output many lines")
        XCTAssertTrue(lines.allSatisfy { $0 == "foo bar baz" }, "All lines should be 'foo bar baz'")
    }

    // MARK: - Edge Cases

    func testEmptyString() {
        // yes "" should output empty lines
        let task = Process()
        let cwd = FileManager.default.currentDirectoryPath
        task.executableURL = URL(fileURLWithPath: "\(cwd)/.build/debug/swiftybox")
        task.arguments = ["yes", ""]

        let pipe = Pipe()
        task.standardOutput = pipe

        try? task.run()

        let fileHandle = pipe.fileHandleForReading
        var output = ""
        let deadline = Date().addingTimeInterval(0.5)

        while Date() < deadline {
            if let data = try? fileHandle.read(upToCount: 100) {
                if let str = String(data: data, encoding: .utf8) {
                    output += str
                    if output.count > 50 {
                        break
                    }
                }
            }
        }

        task.terminate()
        task.waitUntilExit()

        // Should be all newlines
        XCTAssertTrue(output.allSatisfy { $0 == "\n" }, "yes '' should output only newlines")
    }

    func testSpecialCharacters() {
        // yes with special characters should be binary safe
        let task = Process()
        let cwd = FileManager.default.currentDirectoryPath
        task.executableURL = URL(fileURLWithPath: "\(cwd)/.build/debug/swiftybox")
        task.arguments = ["yes", "hello\tworld"]

        let pipe = Pipe()
        task.standardOutput = pipe

        try? task.run()

        let fileHandle = pipe.fileHandleForReading
        var output = ""
        let deadline = Date().addingTimeInterval(0.5)

        while Date() < deadline {
            if let data = try? fileHandle.read(upToCount: 100) {
                if let str = String(data: data, encoding: .utf8) {
                    output += str
                    if output.count > 50 {
                        break
                    }
                }
            }
        }

        task.terminate()
        task.waitUntilExit()

        let lines = output.components(separatedBy: "\n").filter { !$0.isEmpty }
        XCTAssertGreaterThan(lines.count, 2, "yes should output multiple lines")
        XCTAssertTrue(lines.allSatisfy { $0 == "hello\tworld" }, "Should preserve tab character")
    }

    func testVeryLongString() {
        // yes with a very long string
        let longString = String(repeating: "a", count: 1000)
        let task = Process()
        let cwd = FileManager.default.currentDirectoryPath
        task.executableURL = URL(fileURLWithPath: "\(cwd)/.build/debug/swiftybox")
        task.arguments = ["yes", longString]

        let pipe = Pipe()
        task.standardOutput = pipe

        try? task.run()

        let fileHandle = pipe.fileHandleForReading
        var output = ""
        let deadline = Date().addingTimeInterval(0.5)

        while Date() < deadline {
            if let data = try? fileHandle.read(upToCount: 3000) {
                if let str = String(data: data, encoding: .utf8) {
                    output += str
                    if output.count > 2000 {
                        break
                    }
                }
            }
        }

        task.terminate()
        task.waitUntilExit()

        let lines = output.components(separatedBy: "\n").filter { !$0.isEmpty }
        XCTAssertGreaterThan(lines.count, 1, "yes should output at least one line")
        if let firstLine = lines.first {
            XCTAssertEqual(firstLine.count, 1000, "Should preserve long string")
        }
    }

    func testUnicodeString() {
        // yes with unicode characters
        let task = Process()
        let cwd = FileManager.default.currentDirectoryPath
        task.executableURL = URL(fileURLWithPath: "\(cwd)/.build/debug/swiftybox")
        task.arguments = ["yes", "🚀✨"]

        let pipe = Pipe()
        task.standardOutput = pipe

        try? task.run()

        let fileHandle = pipe.fileHandleForReading
        var output = ""
        let deadline = Date().addingTimeInterval(0.5)

        while Date() < deadline {
            if let data = try? fileHandle.read(upToCount: 100) {
                if let str = String(data: data, encoding: .utf8) {
                    output += str
                    if output.count > 50 {
                        break
                    }
                }
            }
        }

        task.terminate()
        task.waitUntilExit()

        let lines = output.components(separatedBy: "\n").filter { !$0.isEmpty }
        XCTAssertGreaterThan(lines.count, 2, "yes should output multiple lines")
        XCTAssertTrue(lines.allSatisfy { $0 == "🚀✨" }, "Should preserve unicode")
    }

    // MARK: - Pipe Behavior

    func testPipedToHeadStopsCleanly() {
        // yes | head -n 5 should produce exactly 5 lines
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/sh")
        let cwd = FileManager.default.currentDirectoryPath
        let swiftybox = "\(cwd)/.build/debug/swiftybox"
        task.arguments = ["-c", "\(swiftybox) yes | head -n 5"]

        let pipe = Pipe()
        task.standardOutput = pipe

        try? task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        let lines = output.components(separatedBy: "\n").filter { !$0.isEmpty }
        XCTAssertEqual(lines.count, 5, "Piped to head should produce exactly 5 lines")
        XCTAssertTrue(lines.allSatisfy { $0 == "y" }, "All lines should be 'y'")
    }

    func testPipedWithCustomString() {
        // yes hello | head -n 3 should produce exactly 3 "hello" lines
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/sh")
        let cwd = FileManager.default.currentDirectoryPath
        let swiftybox = "\(cwd)/.build/debug/swiftybox"
        task.arguments = ["-c", "\(swiftybox) yes hello | head -n 3"]

        let pipe = Pipe()
        task.standardOutput = pipe

        try? task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        let lines = output.components(separatedBy: "\n").filter { !$0.isEmpty }
        XCTAssertEqual(lines.count, 3, "Should produce exactly 3 lines")
        XCTAssertTrue(lines.allSatisfy { $0 == "hello" }, "All lines should be 'hello'")
    }
}
