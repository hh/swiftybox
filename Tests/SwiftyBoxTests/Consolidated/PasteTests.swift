// PasteTests.swift
// ============================================================================
// BusyBox Test Import Metadata
// ============================================================================
// Source Type: Individual test cases (subdirectory tests)
// Source Path: busybox/testsuite/paste/
// Import Date: 2025-11-14
// Test Count: 5
// Pass Rate: 0% (0/5)
// ============================================================================
// Tests for paste command functionality

import XCTest
import Foundation

final class PasteTests: XCTestCase {
    var swiftyboxPath: String {
        let cwd = FileManager.default.currentDirectoryPath
        return "\(cwd)/.build/debug/swiftybox"
    }

    var testDir: String {
        return FileManager.default.temporaryDirectory.appendingPathComponent("paste-test-\(UUID().uuidString)").path
    }

    override func tearDown() {
        super.tearDown()
        let tempDir = FileManager.default.temporaryDirectory.path
        let contents = try? FileManager.default.contentsOfDirectory(atPath: tempDir)
        contents?.filter { $0.hasPrefix("paste-test-") }.forEach {
            try? FileManager.default.removeItem(atPath: tempDir + "/" + $0)
        }
    }

    // MARK: - Test 1: paste basic functionality
    // Source: busybox/testsuite/paste/paste
    func testPaste_basicFunctionality() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)

        let fooPath = testPath + "/foo"
        let barPath = testPath + "/bar"
        let bazPath = testPath + "/baz"
        let quxPath = testPath + "/qux"

        // Create test files
        try? "foo1\nfoo2\nfoo3\n".write(toFile: fooPath, atomically: true, encoding: .utf8)
        try? "bar1\nbar2\nbar3\n".write(toFile: barPath, atomically: true, encoding: .utf8)
        try? "foo1\tbar1\nfoo2\tbar2\nfoo3\tbar3\n".write(toFile: bazPath, atomically: true, encoding: .utf8)

        // Run: paste foo bar > qux
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["paste", fooPath, barPath]

        let outputPipe = Pipe()
        task.standardOutput = outputPipe

        try? task.run()
        task.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        try? data.write(to: URL(fileURLWithPath: quxPath))

        XCTAssertEqual(task.terminationStatus, 0, "paste should succeed")

        // Compare files
        let bazContent = try? String(contentsOfFile: bazPath, encoding: .utf8)
        let quxContent = try? String(contentsOfFile: quxPath, encoding: .utf8)

        XCTAssertEqual(quxContent, bazContent, "paste should merge files with tabs")

        try? FileManager.default.removeItem(atPath: testPath)
    }

    // MARK: - Test 2: paste back cut lines
    // Source: busybox/testsuite/paste/paste-back-cuted-lines
    func testPaste_backCutedLines() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)

        let fooPath = testPath + "/foo"
        let foo1Path = testPath + "/foo1"
        let foo2Path = testPath + "/foo2"
        let barPath = testPath + "/bar"

        // Create test file
        try? "this is the first line\nthis is the second line\nthis is the third line\n".write(toFile: fooPath, atomically: true, encoding: .utf8)

        // Cut into two parts
        let cut1Task = Process()
        cut1Task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        cut1Task.arguments = ["cut", "-b", "1-13", fooPath]
        let cut1Pipe = Pipe()
        cut1Task.standardOutput = cut1Pipe
        try? cut1Task.run()
        cut1Task.waitUntilExit()
        let cut1Data = cut1Pipe.fileHandleForReading.readDataToEndOfFile()
        try? cut1Data.write(to: URL(fileURLWithPath: foo1Path))

        let cut2Task = Process()
        cut2Task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        cut2Task.arguments = ["cut", "-b", "14-", fooPath]
        let cut2Pipe = Pipe()
        cut2Task.standardOutput = cut2Pipe
        try? cut2Task.run()
        cut2Task.waitUntilExit()
        let cut2Data = cut2Pipe.fileHandleForReading.readDataToEndOfFile()
        try? cut2Data.write(to: URL(fileURLWithPath: foo2Path))

        // Run: paste -d '\0' foo1 foo2 > bar
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["paste", "-d", "\0", foo1Path, foo2Path]

        let outputPipe = Pipe()
        task.standardOutput = outputPipe

        try? task.run()
        task.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        try? data.write(to: URL(fileURLWithPath: barPath))

        XCTAssertEqual(task.terminationStatus, 0, "paste -d should succeed")

        // Compare files
        let fooContent = try? String(contentsOfFile: fooPath, encoding: .utf8)
        let barContent = try? String(contentsOfFile: barPath, encoding: .utf8)

        XCTAssertEqual(barContent, fooContent, "paste -d '\\0' should rejoin cut lines")

        try? FileManager.default.removeItem(atPath: testPath)
    }

    // MARK: - Test 3: paste multi stdin
    // Source: busybox/testsuite/paste/paste-multi-stdin
    func testPaste_multiStdin() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)

        let fooPath = testPath + "/foo"
        let barPath = testPath + "/bar"
        let bazPath = testPath + "/baz"

        // Create test files
        try? "line1\nline2\nline3\nline4\nline5\nline6\n".write(toFile: fooPath, atomically: true, encoding: .utf8)
        try? "line1\tline2\tline3\nline4\tline5\tline6\n".write(toFile: barPath, atomically: true, encoding: .utf8)

        // Run: paste - - - < foo > baz
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["paste", "-", "-", "-"]

        let inputPipe = Pipe()
        let outputPipe = Pipe()
        task.standardInput = inputPipe
        task.standardOutput = outputPipe

        try? task.run()

        let inputData = try? Data(contentsOf: URL(fileURLWithPath: fooPath))
        if let inputData = inputData {
            inputPipe.fileHandleForWriting.write(inputData)
        }
        try? inputPipe.fileHandleForWriting.close()

        task.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        try? data.write(to: URL(fileURLWithPath: bazPath))

        XCTAssertEqual(task.terminationStatus, 0, "paste - - - should succeed")

        // Compare files
        let barContent = try? String(contentsOfFile: barPath, encoding: .utf8)
        let bazContent = try? String(contentsOfFile: bazPath, encoding: .utf8)

        XCTAssertEqual(bazContent, barContent, "paste - - - should group 3 lines per output line")

        try? FileManager.default.removeItem(atPath: testPath)
    }

    // MARK: - Test 4: paste pairs with serial mode
    // Source: busybox/testsuite/paste/paste-pairs
    func testPaste_pairs() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)

        let fooPath = testPath + "/foo"
        let barPath = testPath + "/bar"
        let bazPath = testPath + "/baz"

        // Create test file
        try? "foo1\nbar1\nfoo2\nbar2\nfoo3\n".write(toFile: fooPath, atomically: true, encoding: .utf8)
        try? "foo1\tbar1\nfoo2\tbar2\nfoo3\n".write(toFile: barPath, atomically: true, encoding: .utf8)

        // Run: paste -s -d "\t\n" foo > baz
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["paste", "-s", "-d", "\t\n", fooPath]

        let outputPipe = Pipe()
        task.standardOutput = outputPipe

        try? task.run()
        task.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        try? data.write(to: URL(fileURLWithPath: bazPath))

        XCTAssertEqual(task.terminationStatus, 0, "paste -s should succeed")

        // Compare files
        let barContent = try? String(contentsOfFile: barPath, encoding: .utf8)
        let bazContent = try? String(contentsOfFile: bazPath, encoding: .utf8)

        XCTAssertEqual(bazContent, barContent, "paste -s -d should pair lines alternating delimiters")

        try? FileManager.default.removeItem(atPath: testPath)
    }

    // MARK: - Test 5: paste separate (serial mode)
    // Source: busybox/testsuite/paste/paste-separate
    func testPaste_separate() {
        let testPath = testDir
        try? FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)

        let fooPath = testPath + "/foo"
        let barPath = testPath + "/bar"
        let bazPath = testPath + "/baz"
        let quxPath = testPath + "/qux"

        // Create test files
        try? "foo1\nfoo2\nfoo3\n".write(toFile: fooPath, atomically: true, encoding: .utf8)
        try? "bar1\nbar2\nbar3\n".write(toFile: barPath, atomically: true, encoding: .utf8)
        try? "foo1\tfoo2\tfoo3\nbar1\tbar2\tbar3\n".write(toFile: bazPath, atomically: true, encoding: .utf8)

        // Run: paste -s foo bar > qux
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["paste", "-s", fooPath, barPath]

        let outputPipe = Pipe()
        task.standardOutput = outputPipe

        try? task.run()
        task.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        try? data.write(to: URL(fileURLWithPath: quxPath))

        XCTAssertEqual(task.terminationStatus, 0, "paste -s should succeed")

        // Compare files
        let bazContent = try? String(contentsOfFile: bazPath, encoding: .utf8)
        let quxContent = try? String(contentsOfFile: quxPath, encoding: .utf8)

        XCTAssertEqual(quxContent, bazContent, "paste -s should serialize each file into one line")

        try? FileManager.default.removeItem(atPath: testPath)
    }
}
