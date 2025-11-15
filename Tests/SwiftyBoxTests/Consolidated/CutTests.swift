// CutTests.swift
// ============================================================================
// BusyBox Test Import Metadata
// ============================================================================
// Source Type: Individual test cases (subdirectory tests)
// Source Path: busybox/testsuite/cut/
// Import Date: 2025-11-14
// Test Count: 5
// Pass Rate: 60.0% (3/5)
// ============================================================================
// Tests for cut command functionality

import XCTest
import Foundation

final class CutTests: XCTestCase {
    var swiftyboxPath: String {
        let cwd = FileManager.default.currentDirectoryPath
        return "\(cwd)/.build/debug/swiftybox"
    }

    // MARK: - Test 1: cut cuts a character
    // Source: busybox/testsuite/cut/cut-cuts-a-character
    func testCut_cutsCharacter() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["cut", "-c", "3"]

        let inputPipe = Pipe()
        let outputPipe = Pipe()
        task.standardInput = inputPipe
        task.standardOutput = outputPipe

        try? task.run()

        inputPipe.fileHandleForWriting.write("abcd".data(using: .utf8)!)
        try? inputPipe.fileHandleForWriting.close()

        task.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "cut -c 3 should succeed")
        XCTAssertEqual(output, "c", "cut -c 3 should return 'c' from 'abcd'")
    }

    // MARK: - Test 2: cut cuts a closed range
    // Source: busybox/testsuite/cut/cut-cuts-a-closed-range
    func testCut_cutsClosedRange() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["cut", "-c", "1-2"]

        let inputPipe = Pipe()
        let outputPipe = Pipe()
        task.standardInput = inputPipe
        task.standardOutput = outputPipe

        try? task.run()

        inputPipe.fileHandleForWriting.write("abcd".data(using: .utf8)!)
        try? inputPipe.fileHandleForWriting.close()

        task.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "cut -c 1-2 should succeed")
        XCTAssertEqual(output, "ab", "cut -c 1-2 should return 'ab' from 'abcd'")
    }

    // MARK: - Test 3: cut cuts a field
    // Source: busybox/testsuite/cut/cut-cuts-a-field
    func testCut_cutsField() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["cut", "-f", "2"]

        let inputPipe = Pipe()
        let outputPipe = Pipe()
        task.standardInput = inputPipe
        task.standardOutput = outputPipe

        try? task.run()

        inputPipe.fileHandleForWriting.write("f1\tf2\tf3".data(using: .utf8)!)
        try? inputPipe.fileHandleForWriting.close()

        task.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "cut -f 2 should succeed")
        XCTAssertEqual(output, "f2", "cut -f 2 should return 'f2' from tab-separated fields")
    }

    // MARK: - Test 4: cut cuts an open range (from beginning)
    // Source: busybox/testsuite/cut/cut-cuts-an-open-range
    func testCut_cutsOpenRange() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["cut", "-c", "-3"]

        let inputPipe = Pipe()
        let outputPipe = Pipe()
        task.standardInput = inputPipe
        task.standardOutput = outputPipe

        try? task.run()

        inputPipe.fileHandleForWriting.write("abcd".data(using: .utf8)!)
        try? inputPipe.fileHandleForWriting.close()

        task.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "cut -c -3 should succeed")
        XCTAssertEqual(output, "abc", "cut -c -3 should return 'abc' from 'abcd'")
    }

    // MARK: - Test 5: cut cuts an unclosed range (to end)
    // Source: busybox/testsuite/cut/cut-cuts-an-unclosed-range
    func testCut_cutsUnclosedRange() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["cut", "-c", "3-"]

        let inputPipe = Pipe()
        let outputPipe = Pipe()
        task.standardInput = inputPipe
        task.standardOutput = outputPipe

        try? task.run()

        inputPipe.fileHandleForWriting.write("abcd".data(using: .utf8)!)
        try? inputPipe.fileHandleForWriting.close()

        task.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "cut -c 3- should succeed")
        XCTAssertEqual(output, "cd", "cut -c 3- should return 'cd' from 'abcd'")
    }
}
