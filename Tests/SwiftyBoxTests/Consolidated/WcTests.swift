// WcTests.swift
// ============================================================================
// BusyBox Test Import Metadata
// ============================================================================
// Source Type: Individual test cases (subdirectory tests)
// Source Path: busybox/testsuite/wc/
// Import Date: 2025-11-14
// Test Count: 5
// Pass Rate: 40.0% (2/5)
// ============================================================================
// Tests for wc (word count) command functionality

import XCTest
import Foundation

final class WcTests: XCTestCase {
    var swiftyboxPath: String {
        let cwd = FileManager.default.currentDirectoryPath
        return "\(cwd)/.build/debug/swiftybox"
    }

    // MARK: - Test 1: wc counts all (lines, words, chars)
    // Source: busybox/testsuite/wc/wc-counts-all
    func testWc_countsAll() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["wc"]

        let inputPipe = Pipe()
        let outputPipe = Pipe()
        task.standardInput = inputPipe
        task.standardOutput = outputPipe

        try? task.run()

        // Write test data: "i'm a little teapot" (1 line, 4 words, 20 chars including newline)
        let input = "i'm a little teapot\n"
        inputPipe.fileHandleForWriting.write(input.data(using: .utf8)!)
        try? inputPipe.fileHandleForWriting.close()

        task.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "wc should succeed")

        // Output format: "  1   4  20" (may have multiple spaces)
        // Normalize spaces and trim
        let normalized = output.replacingOccurrences(of: "  ", with: " ")
                               .replacingOccurrences(of: "  ", with: " ")
                               .replacingOccurrences(of: "  ", with: " ")
                               .trimmingCharacters(in: .whitespaces)

        XCTAssertEqual(normalized, "1 4 20", "wc should count 1 line, 4 words, 20 chars")
    }

    // MARK: - Test 2: wc -c (character count)
    // Source: busybox/testsuite/wc/wc-counts-characters
    func testWc_countsCharacters() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["wc", "-c"]

        let inputPipe = Pipe()
        let outputPipe = Pipe()
        task.standardInput = inputPipe
        task.standardOutput = outputPipe

        try? task.run()

        let input = "i'm a little teapot\n"
        inputPipe.fileHandleForWriting.write(input.data(using: .utf8)!)
        try? inputPipe.fileHandleForWriting.close()

        task.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "wc -c should succeed")
        XCTAssertEqual(output, "20", "wc -c should count 20 characters")
    }

    // MARK: - Test 3: wc -l (line count)
    // Source: busybox/testsuite/wc/wc-counts-lines
    func testWc_countsLines() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["wc", "-l"]

        let inputPipe = Pipe()
        let outputPipe = Pipe()
        task.standardInput = inputPipe
        task.standardOutput = outputPipe

        try? task.run()

        let input = "i'm a little teapot\n"
        inputPipe.fileHandleForWriting.write(input.data(using: .utf8)!)
        try? inputPipe.fileHandleForWriting.close()

        task.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "wc -l should succeed")
        XCTAssertEqual(output, "1", "wc -l should count 1 line")
    }

    // MARK: - Test 4: wc -w (word count)
    // Source: busybox/testsuite/wc/wc-counts-words
    func testWc_countsWords() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["wc", "-w"]

        let inputPipe = Pipe()
        let outputPipe = Pipe()
        task.standardInput = inputPipe
        task.standardOutput = outputPipe

        try? task.run()

        let input = "i'm a little teapot\n"
        inputPipe.fileHandleForWriting.write(input.data(using: .utf8)!)
        try? inputPipe.fileHandleForWriting.close()

        task.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "wc -w should succeed")
        XCTAssertEqual(output, "4", "wc -w should count 4 words")
    }

    // MARK: - Test 5: wc -L (longest line length)
    // Source: busybox/testsuite/wc/wc-prints-longest-line-length
    func testWc_printsLongestLineLength() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["wc", "-L"]

        let inputPipe = Pipe()
        let outputPipe = Pipe()
        task.standardInput = inputPipe
        task.standardOutput = outputPipe

        try? task.run()

        // "i'm a little teapot" is 19 characters (without newline)
        let input = "i'm a little teapot\n"
        inputPipe.fileHandleForWriting.write(input.data(using: .utf8)!)
        try? inputPipe.fileHandleForWriting.close()

        task.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "wc -L should succeed")
        XCTAssertEqual(output, "19", "wc -L should show longest line is 19 chars")
    }
}
