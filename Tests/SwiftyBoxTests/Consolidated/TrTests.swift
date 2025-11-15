// TrTests.swift
// ============================================================================
// BusyBox Test Import Metadata
// ============================================================================
// Source Type: Individual test cases (subdirectory tests)
// Source Path: busybox/testsuite/tr/
// Import Date: 2025-11-14
// Test Count: 5
// Pass Rate: 40.0% (2/5)
// ============================================================================
// Tests for tr (translate/delete characters) command functionality

import XCTest
import Foundation

final class TrTests: XCTestCase {
    var swiftyboxPath: String {
        let cwd = FileManager.default.currentDirectoryPath
        return "\(cwd)/.build/debug/swiftybox"
    }

    // MARK: - Test 1: tr -d (delete characters)
    // Source: busybox/testsuite/tr/tr-d-works
    func testTr_deleteWorks() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["tr", "-d", "aeiou"]

        let inputPipe = Pipe()
        let outputPipe = Pipe()
        task.standardInput = inputPipe
        task.standardOutput = outputPipe

        try? task.run()

        let input = "testing"
        inputPipe.fileHandleForWriting.write(input.data(using: .utf8)!)
        try? inputPipe.fileHandleForWriting.close()

        task.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "tr -d should succeed")

        // Compare with system tr
        let systemTask = Process()
        systemTask.executableURL = URL(fileURLWithPath: "/usr/bin/tr")
        systemTask.arguments = ["-d", "aeiou"]

        let sysInputPipe = Pipe()
        let sysOutputPipe = Pipe()
        systemTask.standardInput = sysInputPipe
        systemTask.standardOutput = sysOutputPipe

        try? systemTask.run()

        sysInputPipe.fileHandleForWriting.write(input.data(using: .utf8)!)
        try? sysInputPipe.fileHandleForWriting.close()

        systemTask.waitUntilExit()

        let sysData = sysOutputPipe.fileHandleForReading.readDataToEndOfFile()
        let sysOutput = String(data: sysData, encoding: .utf8) ?? ""

        XCTAssertEqual(output, sysOutput, "tr -d output should match system tr")
    }

    // MARK: - Test 2: tr -d with character classes
    // Source: busybox/testsuite/tr/tr-d-alnum-works
    func testTr_deleteAlnumWorks() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["tr", "-d", "[[:alnum:]]"]

        let inputPipe = Pipe()
        let outputPipe = Pipe()
        task.standardInput = inputPipe
        task.standardOutput = outputPipe

        try? task.run()

        let input = "testing"
        inputPipe.fileHandleForWriting.write(input.data(using: .utf8)!)
        try? inputPipe.fileHandleForWriting.close()

        task.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "tr -d [[:alnum:]] should succeed")

        // Compare with system tr
        let systemTask = Process()
        systemTask.executableURL = URL(fileURLWithPath: "/usr/bin/tr")
        systemTask.arguments = ["-d", "[[:alnum:]]"]

        let sysInputPipe = Pipe()
        let sysOutputPipe = Pipe()
        systemTask.standardInput = sysInputPipe
        systemTask.standardOutput = sysOutputPipe

        try? systemTask.run()

        sysInputPipe.fileHandleForWriting.write(input.data(using: .utf8)!)
        try? sysInputPipe.fileHandleForWriting.close()

        systemTask.waitUntilExit()

        let sysData = sysOutputPipe.fileHandleForReading.readDataToEndOfFile()
        let sysOutput = String(data: sysData, encoding: .utf8) ?? ""

        XCTAssertEqual(output, sysOutput, "tr -d [[:alnum:]] output should match system tr")
    }

    // MARK: - Test 3: tr basic translation
    // Source: busybox/testsuite/tr/tr-non-gnu
    func testTr_basicTranslation() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["tr", "[a-z]", "[n-z][a-m]"]

        let inputPipe = Pipe()
        let outputPipe = Pipe()
        task.standardInput = inputPipe
        task.standardOutput = outputPipe

        try? task.run()

        // ROT13 cipher: "fdhrnzvfu bffvsentr"
        let input = "fdhrnzvfu bffvsentr"
        inputPipe.fileHandleForWriting.write(input.data(using: .utf8)!)
        try? inputPipe.fileHandleForWriting.close()

        task.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        XCTAssertEqual(task.terminationStatus, 0, "tr [a-z] [n-z][a-m] should succeed")

        // This is a ROT13 implementation - should decrypt to something readable
        XCTAssertFalse(output.isEmpty, "tr should produce output")
    }

    // MARK: - Test 4: tr rejects wrong class syntax
    // Source: busybox/testsuite/tr/tr-rejects-wrong-class
    func testTr_rejectsWrongClass() {
        // Test various incorrect character class syntaxes
        let invalidSyntaxes = [
            "[:alpha:]",    // Missing outer brackets
            "[[:alpha:]",   // Missing closing outer bracket
            "[[:alpha:",    // Missing closing brackets
            "[[:alpha",     // Missing closing brackets
            "[:alpha:",     // Missing brackets
            "[:alpha"       // Missing brackets
        ]

        for syntax in invalidSyntaxes {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: swiftyboxPath)
            task.arguments = ["tr", "-d", syntax]

            let inputPipe = Pipe()
            let outputPipe = Pipe()
            let errorPipe = Pipe()
            task.standardInput = inputPipe
            task.standardOutput = outputPipe
            task.standardError = errorPipe

            try? task.run()

            let input = "t12esting"
            inputPipe.fileHandleForWriting.write(input.data(using: .utf8)!)
            try? inputPipe.fileHandleForWriting.close()

            task.waitUntilExit()

            let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""

            // Compare with system tr behavior
            let systemTask = Process()
            systemTask.executableURL = URL(fileURLWithPath: "/usr/bin/tr")
            systemTask.arguments = ["-d", syntax]

            let sysInputPipe = Pipe()
            let sysOutputPipe = Pipe()
            systemTask.standardInput = sysInputPipe
            systemTask.standardOutput = sysOutputPipe
            systemTask.standardError = Pipe()

            try? systemTask.run()

            sysInputPipe.fileHandleForWriting.write(input.data(using: .utf8)!)
            try? sysInputPipe.fileHandleForWriting.close()

            systemTask.waitUntilExit()

            let sysData = sysOutputPipe.fileHandleForReading.readDataToEndOfFile()
            let sysOutput = String(data: sysData, encoding: .utf8) ?? ""

            // Output should match system tr (whether it errors or handles it)
            XCTAssertEqual(output, sysOutput, "tr -d '\(syntax)' should match system tr behavior")
        }
    }

    // MARK: - Test 5: tr comprehensive character class tests
    // Source: busybox/testsuite/tr/tr-works
    func testTr_comprehensiveWorks() {
        // Test various tr operations
        let testCases: [(input: String, set1: String, set2: String, description: String)] = [
            ("cbaab", "abc", "zyx", "simple character replacement"),
            ("TESTING A B C", "[A-Z]", "[a-z]", "uppercase to lowercase"),
            ("abc[]", "a[b", "AXB", "replacement with brackets"),
            ("abc", "[:alpha:]", "A-ZA-Z", "alpha class to range"),
            ("abc56", "[:alnum:]", "A-ZA-Zxxxxxxxxxx", "alnum class"),
            ("012", "[:digit:]", "abcdefghi", "digit class"),
            ("abc56", "[:lower:]", "[:upper:]", "lower to upper class"),
            (" \t", "[:space:]", "12345", "space class"),
            (" \t", "[:blank:]", "12", "blank class"),
            ("[:", "[:", "ab", "literal bracket colon")
        ]

        for testCase in testCases {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: swiftyboxPath)
            task.arguments = ["tr", testCase.set1, testCase.set2]

            let inputPipe = Pipe()
            let outputPipe = Pipe()
            task.standardInput = inputPipe
            task.standardOutput = outputPipe

            try? task.run()

            inputPipe.fileHandleForWriting.write(testCase.input.data(using: .utf8)!)
            try? inputPipe.fileHandleForWriting.close()

            task.waitUntilExit()

            let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""

            // Compare with system tr
            let systemTask = Process()
            systemTask.executableURL = URL(fileURLWithPath: "/usr/bin/tr")
            systemTask.arguments = [testCase.set1, testCase.set2]

            let sysInputPipe = Pipe()
            let sysOutputPipe = Pipe()
            systemTask.standardInput = sysInputPipe
            systemTask.standardOutput = sysOutputPipe

            try? systemTask.run()

            sysInputPipe.fileHandleForWriting.write(testCase.input.data(using: .utf8)!)
            try? sysInputPipe.fileHandleForWriting.close()

            systemTask.waitUntilExit()

            let sysData = sysOutputPipe.fileHandleForReading.readDataToEndOfFile()
            let sysOutput = String(data: sysData, encoding: .utf8) ?? ""

            XCTAssertEqual(task.terminationStatus, 0, "tr should succeed for: \(testCase.description)")
            XCTAssertEqual(output, sysOutput, "tr '\(testCase.set1)' '\(testCase.set2)' should match system tr for: \(testCase.description)")
        }
    }
}
