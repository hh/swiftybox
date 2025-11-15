import XCTest
@testable import swiftybox

final class NprocTests: XCTestCase {
    // MARK: - Test 1: Basic functionality - nproc with no arguments
    func testNprocBasic() {
        let result = runCommand("nproc", [])
        XCTAssertEqual(result.exitCode, 0, "nproc should succeed")
        XCTAssertFalse(result.stdout.isEmpty, "nproc should produce output")
        XCTAssertTrue(result.stderr.isEmpty, "nproc should not produce errors")
    }

    // MARK: - Test 2: Output ends with newline
    func testNprocOutputEndsWithNewline() {
        let result = runCommand("nproc", [])
        XCTAssertEqual(result.exitCode, 0, "nproc should succeed")

        // Should end with newline
        XCTAssertTrue(result.stdout.hasSuffix("\n"),
                      "nproc output should end with newline")
    }

    // MARK: - Test 3: Output is a valid positive integer
    func testNprocOutputIsPositiveInteger() {
        let result = runCommand("nproc", [])
        XCTAssertEqual(result.exitCode, 0, "nproc should succeed")

        let trimmedOutput = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)

        // Should be a valid integer
        guard let cpuCount = Int(trimmedOutput) else {
            XCTFail("nproc output should be a valid integer, got: \(trimmedOutput)")
            return
        }

        // Should be positive
        XCTAssertGreaterThan(cpuCount, 0, "nproc should return positive number")
    }

    // MARK: - Test 4: Output is in reasonable range (1-256 CPUs)
    func testNprocOutputInReasonableRange() {
        let result = runCommand("nproc", [])
        XCTAssertEqual(result.exitCode, 0, "nproc should succeed")

        let trimmedOutput = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let cpuCount = Int(trimmedOutput) else {
            XCTFail("nproc output should be a valid integer")
            return
        }

        // Reasonable range for CPU count (1 to 256)
        XCTAssertGreaterThanOrEqual(cpuCount, 1, "CPU count should be at least 1")
        XCTAssertLessThanOrEqual(cpuCount, 256, "CPU count should not exceed 256")
    }

    // MARK: - Test 5: Consistency - multiple calls return same result
    func testNprocConsistency() {
        let result1 = runCommand("nproc", [])
        let result2 = runCommand("nproc", [])
        let result3 = runCommand("nproc", [])

        XCTAssertEqual(result1.exitCode, 0, "First nproc call should succeed")
        XCTAssertEqual(result2.exitCode, 0, "Second nproc call should succeed")
        XCTAssertEqual(result3.exitCode, 0, "Third nproc call should succeed")

        let trimmed1 = result1.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmed2 = result2.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmed3 = result3.stdout.trimmingCharacters(in: .whitespacesAndNewlines)

        XCTAssertEqual(trimmed1, trimmed2, "Multiple nproc calls should return consistent results")
        XCTAssertEqual(trimmed2, trimmed3, "Multiple nproc calls should return consistent results")
    }

    // MARK: - Test 6: --all option
    func testNprocWithAllOption() {
        let result = runCommand("nproc", ["--all"])
        XCTAssertEqual(result.exitCode, 0, "nproc --all should succeed")
        XCTAssertFalse(result.stdout.isEmpty, "nproc --all should produce output")

        let trimmedOutput = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let cpuCount = Int(trimmedOutput) else {
            XCTFail("nproc --all output should be a valid integer")
            return
        }

        XCTAssertGreaterThan(cpuCount, 0, "nproc --all should return positive number")
    }

    // MARK: - Test 7: --ignore=1 option
    func testNprocIgnoreOne() {
        let basicResult = runCommand("nproc", [])
        let ignoreResult = runCommand("nproc", ["--ignore=1"])

        XCTAssertEqual(basicResult.exitCode, 0, "Basic nproc should succeed")
        XCTAssertEqual(ignoreResult.exitCode, 0, "nproc --ignore=1 should succeed")

        let basicCount = Int(basicResult.stdout.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        let ignoreCount = Int(ignoreResult.stdout.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0

        // --ignore=1 should subtract 1 from the count
        if basicCount > 1 {
            XCTAssertEqual(ignoreCount, basicCount - 1,
                          "nproc --ignore=1 should subtract 1 from CPU count")
        } else {
            // If only 1 CPU, result should be at least 1 (not negative)
            XCTAssertGreaterThanOrEqual(ignoreCount, 1,
                                       "nproc --ignore=1 should not go below 1")
        }
    }

    // MARK: - Test 8: --ignore=2 option
    func testNprocIgnoreTwo() {
        let basicResult = runCommand("nproc", [])
        let ignoreResult = runCommand("nproc", ["--ignore=2"])

        XCTAssertEqual(basicResult.exitCode, 0, "Basic nproc should succeed")
        XCTAssertEqual(ignoreResult.exitCode, 0, "nproc --ignore=2 should succeed")

        let basicCount = Int(basicResult.stdout.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        let ignoreCount = Int(ignoreResult.stdout.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0

        // --ignore=2 should subtract 2 from the count (but not go below 1)
        if basicCount > 2 {
            XCTAssertEqual(ignoreCount, basicCount - 2,
                          "nproc --ignore=2 should subtract 2 from CPU count")
        } else if basicCount > 1 {
            XCTAssertGreaterThanOrEqual(ignoreCount, 1,
                                       "nproc --ignore=2 should not go below 1")
        }
    }

    // MARK: - Test 9: Edge case - --ignore greater than CPU count
    func testNprocIgnoreGreaterThanCount() {
        let basicResult = runCommand("nproc", [])
        let cpuCount = Int(basicResult.stdout.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 1

        // Try to ignore more CPUs than available
        let largeIgnore = cpuCount + 10
        let ignoreResult = runCommand("nproc", ["--ignore=\(largeIgnore)"])

        XCTAssertEqual(ignoreResult.exitCode, 0, "nproc --ignore with large value should succeed")

        let ignoreCount = Int(ignoreResult.stdout.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0

        // Should clamp to at least 1
        XCTAssertGreaterThanOrEqual(ignoreCount, 1,
                                   "nproc should not return negative value when ignoring more than available")
    }

    // MARK: - Test 10: Invalid option handling
    func testNprocInvalidOption() {
        let result = runCommand("nproc", ["--invalid-option"])

        // Invalid option should either fail or be ignored by implementation
        // Some implementations may treat unknown options as no-op
        XCTAssertTrue(result.exitCode != 0 || !result.stdout.isEmpty,
                     "nproc should handle invalid options")
    }

    // MARK: - Test 11: --ignore with invalid number
    func testNprocIgnoreInvalidNumber() {
        let result = runCommand("nproc", ["--ignore=abc"])

        // Should fail with invalid numeric argument
        XCTAssertTrue(result.exitCode != 0 || result.stderr.contains("invalid") ||
                      result.stderr.contains("number"),
                     "nproc should reject non-numeric ignore value")
    }

    // MARK: - Test 12: Match system nproc if available
    func testNprocMatchesSystemNproc() {
        // Try to run system nproc if available
        let systemTask = Process()
        systemTask.executableURL = URL(fileURLWithPath: "/usr/bin/nproc")

        let systemPipe = Pipe()
        systemTask.standardOutput = systemPipe

        let systemAvailable = (try? systemTask.run()) != nil

        if systemAvailable {
            systemTask.waitUntilExit()
            let systemData = systemPipe.fileHandleForReading.readDataToEndOfFile()
            let systemOutput = String(data: systemData, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            if !systemOutput.isEmpty {
                let result = runCommand("nproc", [])
                let ourOutput = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)

                XCTAssertEqual(ourOutput, systemOutput,
                             "nproc output should match system nproc")
            }
        } else {
            // System nproc not available, just verify our implementation works
            let result = runCommand("nproc", [])
            XCTAssertEqual(result.exitCode, 0, "nproc should succeed")
            XCTAssertFalse(result.stdout.isEmpty, "nproc should produce output")
        }
    }
}
